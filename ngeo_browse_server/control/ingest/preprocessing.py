
import shutil
from django.contrib.gis.geos import MultiPolygon, Polygon

class VerticalCurtainPreprocessor(object):
    def __init__(self):
        pass

    def generate_filename(self, output_filename):
        # TODO: use correct filename extension
        return output_filename

    def process(self, input_filename, output_filename, geo_reference=None,
                generate_metadata=False):
        shutil.copyfile(input_filename, output_filename)
        return VerticalCurtainPreProcessResult(
            3, MultiPolygon(Polygon.from_bbox((0, 0, 1, 1)))
        )


class VerticalCurtainPreProcessResult(object):
    def __init__(self, num_bands, footprint_geom):
        self.num_bands = num_bands
        self.footprint_geom = footprint_geom
