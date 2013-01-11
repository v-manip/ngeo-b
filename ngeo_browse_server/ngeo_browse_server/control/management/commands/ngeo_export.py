#-------------------------------------------------------------------------------
#
# Project: ngEO Browse Server <http://ngeo.eox.at>
# Authors: Fabian Schindler <fabian.schindler@eox.at>
#          Marko Locher <marko.locher@eox.at>
#          Stephan Meissl <stephan.meissl@eox.at>
#
#-------------------------------------------------------------------------------
# Copyright (C) 2012 EOX IT Services GmbH
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

from os.path import basename
import logging
from cStringIO import StringIO
from optparse import make_option

from django.core.management.base import BaseCommand, CommandError
from eoxserver.resources.coverages.management.commands import CommandOutputMixIn
from eoxserver.core.system import System
from eoxserver.core.util.timetools import getDateTime

from ngeo_browse_server.control.management.commands import LogToConsoleMixIn

from ngeo_browse_server.config.models import ( 
    BrowseReport, BrowseLayer, RectifiedBrowse, FootprintBrowse, 
    RegularGridBrowse, ModelInGeotiffBrowse, Browse
)
from ngeo_browse_server.control.browsereport import data
from ngeo_browse_server.control.migration import package
from ngeo_browse_server.control.browsereport.serialization import serialize_browse_report
from ngeo_browse_server.control.browselayer.serialization import serialize_browse_layers
from ngeo_browse_server.mapcache import tileset
from ngeo_browse_server.mapcache.config import get_tileset_path
from ngeo_browse_server.mapcache.tileset import URN_TO_GRID
from django.db.models.aggregates import Count


logger = logging.getLogger(__name__)


class Command(LogToConsoleMixIn, CommandOutputMixIn, BaseCommand):
    
    option_list = BaseCommand.option_list + (
        make_option('--layer', '--browse-layer',
            dest='browse_layer_id',
            help=("The browse layer to be exported.")
        ),
        make_option('--browse-type',
            dest='browse_type',
            help=("The browse type to be exported.")
        ),
        make_option('--start',
            dest='start',
            help=("The start date and time in ISO 8601 format.")
        ),
        make_option('--end',
            dest='end',
            help=("The end date and time in ISO 8601 format.")
        ),
        make_option('--compression',
            dest='compression', default="gzip",
            choices=["none", "gzip", "gz", "bzip2", "bz2"],
            help=("Declare the compression algorithm for the output package. "
                  "Default is 'gzip'.")
        ),
        make_option('--export-cache', action="store_true",
            dest='export_cache', default=False,
            help=("If this option is set, the tile cache will be exported "
                  "aswell.")
        ),
        make_option('--output', '--output-path',
            dest='output_path',
            help=("The path for the result package. Per default, a suitable "
                  "filename will be generated and the file will be stored in "
                  "the current working directory.")
        )
    )
    
    # TODO
    args = ("--layer=<layer-id> | --browse-type=<browse-type> "
            "[--start=<start-date-time>] [--end=<end-date-time>] "
            "[--compression=none|gzip|bz2] [--export-cache] "
            "[--output=<output-path>]")
    help = ("Exports the given browse layer specified by either the layer ID "
            "or its browse type. The output is a package, a tar archive, "
            "containing metadata of the browse layer, and all browse reports "
            "and browses that are associated. The processed browse images are "
            "inserted as well. The export can be refined by stating a time "
            "window.")

    def handle(self, *args, **kwargs):
        System.init()
        
        # parse command arguments
        self.verbosity = int(kwargs.get("verbosity", 1))
        traceback = kwargs.get("traceback", False)
        self.set_up_logging(["ngeo_browse_server"], self.verbosity, traceback)
        
        browse_layer_id = kwargs.get("browse_layer_id")
        browse_type = kwargs.get("browse_type")
        if not browse_layer_id and not browse_type:
            raise CommandError("No browse layer or browse type was specified.")
        elif browse_layer_id and browse_type:
            raise CommandError("Both browse layer and browse type were specified.")
        
        start = kwargs.get("start")
        end = kwargs.get("end")
        compression = kwargs.get("compression")
        export_cache = kwargs["export_cache"]
        output_path = kwargs.get("output_path")
        
        # parse start/end if given
        if start: 
            start = getDateTime(start)
        if end:
            end = getDateTime(end)
        
        if not output_path:
            output_path = package.generate_filename(compression)
        
        
        with package.create(output_path, compression) as p:
            # query the browse layer
            if browse_layer_id:
                try:
                    browse_layer = BrowseLayer.objects.get(id=browse_layer_id)
                except BrowseLayer.DoesNotExist:
                    raise CommandError("Browse layer '%s' does not exist" 
                                       % browse_layer_id)
            else:
                try:
                    browse_layer = BrowseLayer.objects.get(browse_type=browse_type)
                except BrowseLayer.DoesNotExist:
                    raise CommandError("Browse layer with browse type'%s' does "
                                       "not exist" % browse_type)
            
            stream = StringIO()
            serialize_browse_layers((browse_layer,), stream, pretty_print=True)
            p.set_browse_layer(stream)
            
            # query browse reports; optionally filter for start/end time
            browse_reports_qs = BrowseReport.objects.all()
            
            if start:
                browse_reports_qs = browse_reports_qs.filter(browses__start_time__gte=start)
            if end:
                browse_reports_qs = browse_reports_qs.filter(browses__end_time__lte=end)
                
            browse_reports_qs = browse_reports_qs.annotate(
                browse_count=Count('browses')
            ).filter(browse_layer=browse_layer, browse_count__gt=0)
            
            print len(browse_reports_qs)
        
            # iterate over all browse reports
            # TODO: only include browse reports that fall into 
            for browse_report_model in browse_reports_qs:
                browses_qs = Browse.objects.filter(
                    browse_report=browse_report_model
                )
                if start:
                    browses_qs = browses_qs.filter(start_time__gte=start)
                if end:
                    browses_qs = browses_qs.filter(end_time__lte=end)
                
                browse_report = data.BrowseReport.from_model(
                    browse_report_model, browses_qs
                )
                
                # save browse report xml and add it to the package
                p.add_browse_report(
                    serialize_browse_report(browse_report, pretty_print=True),
                    name="%s_%s_%s.xml" % (
                        browse_report.browse_type,
                        browse_report.responsible_org_name,
                        browse_report.date_time.strftime("%Y%m%d%H%M%S%f")
                    )
                )
                
                # iterate over all browses in the query
                for browse_model in browses_qs:
                    coverage_wrapper = System.getRegistry().getFromFactory(
                        "resources.coverages.wrappers.EOCoverageFactory",
                        {"obj_id": browse_model.coverage_id}
                    )
                    
                    # add browse to
                    data_package = coverage_wrapper.getData()
                    data_package.prepareAccess()
                    browse_file_path = data_package.getGDALDatasetIdentifier()
                    with open(browse_file_path) as f:
                        p.add_browse(f, basename(browse_file_path))
                    
                    if export_cache:
                        # get "dim" parameter
                        dim = (browse_model.start_time.isoformat("T") + "/" +
                               browse_model.end_time.isoformat("T"))
                        
                        # get path to sqlite tileset and open it
                        ts = tileset.open(
                            get_tileset_path(browse_layer.browse_type)
                        )
                        
                        for tile_desc in ts.get_tiles(
                            browse_layer.browse_type, 
                            URN_TO_GRID[browse_layer.grid], dim=dim,
                            minzoom=browse_layer.highest_map_level,
                            maxzoom=browse_layer.lowest_map_level
                        ):
                            p.add_cache(*tile_desc)
