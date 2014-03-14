#-------------------------------------------------------------------------------
#
# Project: ngEO Browse Server <http://ngeo.eox.at>
# Authors: Fabian Schindler <fabian.schindler@eox.at>
#          Daniel Santillan <daniel.santillan@eox.at>
#
#-------------------------------------------------------------------------------
# Copyright (C) 2013 EOX IT Services GmbH
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell 
# copies of the Software, and to permit persons to whom the Software is 
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies of this Software or works derived from this Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
#-------------------------------------------------------------------------------



from django.contrib.gis.geos import (
    GEOSGeometry, MultiPolygon, Polygon, LinearRing, 
)
from eoxserver.contrib import gdal
from eoxserver.processing.preprocessing import (
    WMSPreProcessor, PreProcessResult
)
from eoxserver.processing.preprocessing.optimization import *
from eoxserver.processing.preprocessing.util import create_mem_copy

from ngeo_browse_server.control.ingest.preprocessing.merge import (
    GDALDatasetMerger, GDALGeometryMaskMergeSource
)

from os.path import splitext
import shutil
from django.contrib.gis.geos import MultiPolygon, Polygon, LineString

from eoxserver.resources.coverages.crss import crs_tolerance

from PIL import Image
import numpy as np


class NGEOPreProcessor(WMSPreProcessor):

    def process(self, input_filename, output_filename, 
                geo_reference=None, generate_metadata=True, 
                merge_with=None, original_footprint=None):
        
        # open the dataset and create an In-Memory Dataset as copy
        # to perform optimizations
        ds = create_mem_copy(gdal.Open(input_filename))
        
        gt = ds.GetGeoTransform()
        footprint_wkt = None
        
        if not geo_reference:
            if gt == (0.0, 1.0, 0.0, 0.0, 0.0, 1.0): # TODO: maybe use a better check
                raise ValueError("No geospatial reference for unreferenced "
                                 "dataset given.")
        else:
            logger.debug("Applying geo reference '%s'."
                         % type(geo_reference).__name__)
            ds, footprint_wkt = geo_reference.apply(ds)
        
        # apply optimizations
        for optimization in self.get_optimizations(ds):
            logger.debug("Applying optimization '%s'."
                         % type(optimization).__name__)
            new_ds = optimization(ds)
            ds = None
            ds = new_ds
            
        # generate the footprint from the dataset
        if not footprint_wkt:
            logger.debug("Generating footprint.")
            footprint_wkt = self._generate_footprint_wkt(ds)
        
        
        if self.footprint_alpha:
            logger.debug("Applying optimization 'AlphaBandOptimization'.")
            opt = AlphaBandOptimization()
            opt(ds, footprint_wkt)

        output_filename = self.generate_filename(output_filename)
        
        if merge_with is not None:
            if original_footprint is None:
                raise ValueError(
                    "Original footprint with to be merged image required."
                )

            original_ds = gdal.Open(merge_with)
            merger = GDALDatasetMerger([
                GDALGeometryMaskMergeSource(original_ds, original_footprint),
                GDALGeometryMaskMergeSource(ds, footprint_wkt)
            ])

            ds = merger.merge(
                output_filename, self.format_selection.driver_name,
                self.format_selection.creation_options
            )
            # cleanup previous file
            driver = original_ds.GetDriver()
            original_ds = None
            driver.Delete(merge_with) 

        else:
            logger.debug("Writing file to disc using options: %s."
                         % ", ".join(self.format_selection.creation_options))
            
            logger.debug("Metadata tags to be written: %s"
                         % ", ".join(ds.GetMetadata_List("") or []))
            
            # save the file to the disc
            driver = gdal.GetDriverByName(self.format_selection.driver_name)
            ds = driver.CreateCopy(output_filename, ds,
                                   options=self.format_selection.creation_options)
        
        for optimization in self.get_post_optimizations(ds):
            logger.debug("Applying post-optimization '%s'."
                         % type(optimization).__name__)
            optimization(ds)
        
        # generate metadata if requested
        footprint = None
        if generate_metadata:
            normalized_space = Polygon.from_bbox((-180, -90, 180, 90))
            non_normalized_space = Polygon.from_bbox((180, -90, 360, 90))
            
            footprint = GEOSGeometry(footprint_wkt)
            #.intersection(normalized_space)
            outer = non_normalized_space.intersection(footprint)
            
            if len(outer):
                footprint = MultiPolygon(
                    *map(lambda p: 
                        Polygon(*map(lambda ls:
                            LinearRing(*map(lambda point: 
                                (point[0] - 360, point[1]), ls.coords
                            )), tuple(p)
                        )), (outer,)
                    )
                ).union(normalized_space.intersection(footprint))
            else:
                if isinstance(footprint, Polygon):
                    footprint = MultiPolygon(footprint)
                
            
            
            logger.info("Calculated Footprint: '%s'" % footprint.wkt)
            
            
            
            # use the provided footprint
            #geom = OGRGeometry(footprint_wkt)
            #exterior = []
            #for x, y in geom.exterior_ring.tuple:
            #    exterior.append(y); exterior.append(x)
            
            #polygon = [exterior]
        
        num_bands = ds.RasterCount
        
        # close the dataset and write it to the disc
        ds = None
        
        return PreProcessResult(output_filename, footprint, num_bands)


class VerticalCurtainGeoReference(object):
    def __init__(self, gcps, srid):
        self._gcps = gcps
        self._srid = srid

    @property
    def line(self):
        geom = LineString([(x, y) for x, y, _, _ in self.gcps])
        geom.srid = self._srid
        if self._srid != 4326:
            geom.transform(4326)
        return geom

    @property
    def polygon(self):
        return self.line.buffer(crs_tolerance(self._srid))

    @property
    def gcps(self):
        return self._gcps


class VerticalCurtainPreprocessor(object):
    def __init__(self, radiometric_interval_min=None, 
                 radiometric_interval_max=None):
        self.radiometric_interval_min = radiometric_interval_min
        self.radiometric_interval_max = radiometric_interval_max

    def generate_filename(self, output_filename):
        # TODO: use correct filename extension
        return splitext(output_filename)[0] + ".png"

    def process(self, input_filename, output_filename, geo_reference,
                generate_metadata=False, merge_with=None, original_footprint=None):

        textureImage = Image.open(input_filename)

        i = np.array(list(textureImage.getdata())).reshape(textureImage.size[::-1])
        g = np.divide(np.subtract(i, self.radiometric_interval_min), (self.radiometric_interval_max - self.radiometric_interval_min) / 255.0)
        g[g < 0] = 0
        textureImage = Image.fromarray(g.astype(np.uint8), 'L')

        textureImage.save(output_filename)
        return VerticalCurtainPreProcessResult(1, geo_reference)


class VerticalCurtainPreProcessResult(object):
    def __init__(self, num_bands, geo_reference):
        self.num_bands = num_bands
        self.geo_reference = geo_reference

    @property
    def footprint_geom(self):
        return MultiPolygon(self.geo_reference.polygon)

    @property
    def ground_path(self):
        return self.geo_reference.line