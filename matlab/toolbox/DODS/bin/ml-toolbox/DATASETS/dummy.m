function [locate_x, locate_y, depths, times, URLinfo, urllist, url] = ...
    dummy(get_archive, CatalogServer, TimeRange, get_ranges, URLinfo)

% This catalog file is a placeholder for use in getrectg.m.  It can
% be used with single-file, 2-D datasets that have no map vectors,
% if the two dimensions of the dataset are [Latitude, Longitude] (in
% that order.

locate_x = [];
locate_y = [];
depths = [];
times = [];
URLinfo = [];
urllist = CatalogServer;
url = CatalogServer;
