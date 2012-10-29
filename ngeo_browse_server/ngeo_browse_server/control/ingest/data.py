"""\ 
This module contains intermediary (runtime) data for ingestion or the like.
The classes in this module are explicitly not tied to database models, but
provide means for easy data exchange.
"""

class Browse(object):
    """ Abstract base class for browse records. """

    def __init__(self, browse_identifier, file_name, image_type,
                 reference_system_identifier, start_time, end_time):
        self._browse_identifier = browse_identifier
        self._file_name = file_name
        self._image_type = image_type
        self._reference_system_identifier = reference_system_identifier
        self._start_time = start_time
        self._end_time = end_time


    browse_identifier = property(lambda self: self._browse_identifier)
    file_name = property(lambda self: self._file_name)
    image_type = property(lambda self: self._image_type)
    reference_system_identifier = property(lambda self: self._reference_system_identifier)
    start_time = property(lambda self: self._start_time)
    end_time = property(lambda self: self._end_time)


    def get_kwargs(self):
        return {
            "file_name": self.file_name,
            "image_type": self.image_type,
            "reference_system_identifier": self.reference_system_identifier,
            "start_time": self.start_time,
            "end_time": self.end_time
        }

    
class RectifiedBrowse(Browse):
    
    def __init__(self, minx, miny, maxx, maxy, *args, **kwargs):
        super(RectifiedBrowse, self).__init__(*args, **kwargs)
        self._extent = minx, miny, maxx, maxy
    
    minx = property(lambda self: self._extent[0])
    miny = property(lambda self: self._extent[1])
    maxx = property(lambda self: self._extent[2])
    maxy = property(lambda self: self._extent[3])


    def get_kwargs(self):
        kwargs = super(RectifiedBrowse, self).get_kwargs()
        kwargs.update({
            "minx": self.minx,
            "miny": self.miny,
            "maxx": self.maxx,
            "maxy": self.maxy
        })
        return kwargs

class FootprintBrowse(Browse):
    
    def __init__(self, node_number, col_row_list, coord_list, *args, **kwargs):
        super(FootprintBrowse, self).__init__(*args, **kwargs)
        self._node_number = node_number
        self._col_row_list = col_row_list
        self._coord_list = coord_list


    node_number = property(lambda self: self._node_number)
    col_row_list = property(lambda self: self._col_row_list)
    coord_list = property(lambda self: self._coord_list)
    
    
    def get_kwargs(self):
        kwargs = super(FootprintBrowse, self).get_kwargs()
        kwargs.update({
            "node_number": self._node_number,
            "col_row_list": self._col_row_list,
            "coord_list": self._coord_list
        })
        return kwargs


class RegularGridBrowse(Browse):
    
    def __init__(self, col_node_number, row_node_number, col_step, row_step, 
                 coord_lists, *args, **kwargs):
        
        super(RegularGridBrowse, self).__init__(*args, **kwargs)
        
        self._col_node_number = col_node_number
        self._row_node_number = row_node_number
        self._col_step = col_step
        self._row_step = row_step
        self._coord_lists = coord_lists

    col_node_number = property(lambda self: self._col_node_number)
    row_node_number = property(lambda self: self._row_node_number)
    col_step = property(lambda self: self._col_step)
    row_step = property(lambda self: self._row_step)
    coord_lists = property(lambda self: self._coord_lists)
    
    def get_kwargs(self):
        kwargs = super(RegularGridBrowse, self).get_kwargs()
        kwargs.update({
            "col_node_number": self._col_node_number,
            "row_node_number": self._row_node_number,
            "col_step": self._col_step,
            "row_step": self._row_step
        })
        return kwargs

    
class VerticalCurtainBrowse(Browse):
    pass


class ModelInGeotiffBrowse(Browse):
    pass


class BrowseReport(object):
    """ Browse report data model. """
    
    def __init__(self, browse_type, date_time, responsible_org_name, browses):
        self._browse_type = browse_type
        self._date_time = date_time
        self._responsible_org_name = responsible_org_name
        self._browses = list(browses)
    
    
    def __iter__(self):
        return iter(self._browses)
    
    
    def append(self, browse):
        self._browses.append(browse)
    
    
    browse_type = property(lambda self: self._browse_type)
    date_time = property(lambda self: self._date_time)
    responsible_org_name = property(lambda self: self._responsible_org_name)
    
    def get_kwargs(self):
        return {
            "date_time": self._date_time,
            "responsible_org_name": self._responsible_org_name
        }