#-------------------------------------------------------------------------------
#
# Project: ngEO Browse Server <http://ngeo.eox.at>
# Authors: Fabian Schindler <fabian.schindler@eox.at>
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


import shutil
from django.contrib.gis.geos import MultiPolygon, Polygon, LineString

from eoxserver.resources.coverages.crss import crs_tolerance


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
    def __init__(self):
        pass

    def generate_filename(self, output_filename):
        # TODO: use correct filename extension
        return output_filename

    def process(self, input_filename, output_filename, geo_reference,
                generate_metadata=False):
        shutil.copyfile(input_filename, output_filename)
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
