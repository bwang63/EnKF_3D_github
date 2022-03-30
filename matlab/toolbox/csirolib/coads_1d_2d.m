function [field_2d, lon, lat] = coads_1d_2d(field_1d, ...
    ind_lon_min, ind_lon_max, ind_lat_min, ind_lat_max)
% coads_1d_2d converts a 1-d COADS field to a 2-d one.
% The data stored on the COADS cd rom has only one dimension for the
% horizontal.  (This is a space saving device since land points are not
% recorded.)  Usually we want the data on a lon/lat grid and this
% function does the conversion.  While the 1-d field (vector) has 42164
% points the 2-d field is a 360*180 matrix.  The row elements are
% longitude (0.5:359.5) and the column elements are latitude (-89.5:89.5).
% All missing values have been converted to NaNs.
%
% There must be either 1 or 5 input fields.  The 4 final input variables are
% the integers specifying the minimumn and maximum indices of the longitude
% and latitude vectors.  Hence they partially correspond to hyperslab access
% which would have been available if there had been separate longitudinal
% and latitudinal directions in the netCDF files.  When only 1 input
% argument is given then the full, 180*360 matrix will be returned.
%    INPUT:
% field_1d: a 1-d COADS field as would be returned by a call to getnc.
% ind_lon_min: The minimum index in the longitudinal direction.
% ind_lon_max: The maximum index in the longitudinal direction.
% ind_lat_min: The minimum index in the latitudinal direction.
% ind_lat_max: The maximum index in the latitudinal direction.
%
%    OUTPUT:
% field_2d: The same data as in the 1d field but as a matrix where the
%           rows vary with longitude and the columns with latitude.
%           Note that this is corresponds to the order that the values are
%           stored in the original 1-d form and gives the quickest
%           retrieval.
% lon: A vector giving the longitudes corresponding to different rows
% lat: A vector giving the latitudes corresponding to different columns
%
%    EXAMPLE USAGE:
%
% file = '/CDROM/data/anomaly/netheat'; % cd-rom 2
% k = 10; % month 10
% netheat_init = getnc(file, 'clm', [k -1], [k -1]);  % get a vector
% [netheat, lon, lat] = coads_1d_2d(netheat_init);    % get the 2-d netheat
% [netheat_sub, lon_sub, lat_sub] = coads_1d_2d(netheat_init, 100, 180, 40, 80);

% $Id: coads_1d_2d.m,v 1.2 1997/08/27 04:02:04 mansbrid Exp $
% Copyright J. V. Mansbridge, CSIRO, Wed Aug 27 11:27:12 EST 1997

global coads_index_1d

if length(field_1d) ~= 42164
  error([ 'The input field has length ' num2str(length(field_1d)) ...
	' and so cannot be mapped to a 2-d grid'])
end

% Load coads_grid.mat if required

if isempty(coads_index_1d)
  temp = which('coads_grid.mat');
  eval(['load ' temp])
end

% Get the array.  Behave differently according to the number of input
% arguments.

if nargin == 1
  field_2d = NaN*zeros(360, 180);
  field_2d(coads_index_1d) = field_1d;
  lon = 0.5:359.5;
  lat = -89.5:89.5;
elseif nargin == 5
  field_tmp = NaN*zeros(360, 180);
  field_tmp(coads_index_1d) = field_1d;
  field_2d = field_tmp(ind_lon_min:ind_lon_max, ...
      ind_lat_min:ind_lat_max);
  lon = (ind_lon_min:ind_lon_max) - 0.5;
  lat = (ind_lat_min:ind_lat_max) - 90.5;
else  
  error([ 'There must be either 1 or 5 input arguments but ' ...
	'there are ' num2str(nargin) ])
end
