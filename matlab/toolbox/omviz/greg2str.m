function [str]=greg2str(gtime)
% GREG2STR Converts Gregorian time array to String
%  Usage:
%    [str]=greg2str(gtime)
% convert gregorian time to string for display (don't include seconds)

% Rich Signell (rsignell@usgs.gov)
str=sprintf('%4.4d/%2.2d/%2.2d %2.2d:%2.2d',gtime(1:5));

