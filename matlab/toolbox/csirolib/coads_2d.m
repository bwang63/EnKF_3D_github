function [field_2d, lon, lat] = coads_2d(field_1d, ...
    coads_index_1d, ind_lon_min, ind_lon_max, ind_lat_min, ind_lat_max)
% coads_2d converts a 1-d COADS field to a 2-d one.
% The data stored on the COADS cd rom has only one dimension for the
% horizontal.  (This is a space saving device since land points are not
% recorded.)  Usually we want the data on a lat/lon grid and this
% function does the conversion.  While the 1-d field (vector) has 42164
% points the 2-d field is a 360*180 matrix.  The row elements are
% latitude (-89.5:89.5) and the column elements are longitude
% (0.5:359.5).  Information describing the mapping from 1-d to 2-d is in
% the file coads_grid.mat that was created by grid_mat.m.  All missing
% values have been converted to NaNs.
%
% There must be either 1,2 or 6 input fields.  If coads_index_1d, the
% second input variable, is not passed then it will be loaded from
% coads_grid.mat.  Typically this takes about half the time of the whole
% coads_2d call.  Thus if coads_2d.m is called in a loop it is much more
% efficient to load coads_grid.mat once outside the loop and then pass
% it.  If coads_index_1d is not of the expected length then it will be
% loaded separately.  Thus a loading can be forced by passing a simple
% scalar.  The 4 final input variables are the integers specifying the
% minimum and maximum indicies of the longitude and latitude vectors.
% Hence they partially correspond to hyperslab access which would have
% been available if there had been separate longitudinal and latitudinal
% directions in the netCDF files.  When only 1 or 2 input argument are
% given then the full, 180*360 matrix will be returned.
%
%    input fields:
% field_1d: a 1-d COADS field as would be returned by a call to getcdf.
% coads_index_1d: The indices of all of the ocean points in the matrix
%                 field_2d.
% ind_lon_min: The minimum index in the longitudinal direction.
% ind_lon_max: The maximum index in the longitudinal direction.
% ind_lat_min: The minimum index in the latitudinal direction.
% ind_lat_max: The maximum index in the latitudinal direction.
%
%    output fields:
% field_2d: The same data as in the 1d field but as a matrix where the
%           rows vary with latitude and the columns with longitude.
%           Note that this is the usual order of storing geographical
%           fields and requires the taking of a transpose.
% lon: A vector giving the longitudes corresponding to different columns
% lat: A vector giving the latitudes corresponding to different rows
%
% $Id: coads_2d.m,v 1.5 1998/05/12 01:24:16 mansbrid Exp $
% Copyright J. V. Mansbridge, CSIRO, Wed Sep 11 09:44:11 EST 1996

if length(field_1d) ~= 42164
  error([ 'The input field has length ' num2str(length(field_1d)) ...
	' and so cannot be mapped to a 2-d grid'])
end


if nargin == 1
  load coads_grid
  field_2d = NaN*zeros(360, 180);
  field_2d(coads_index_1d) = field_1d;
  field_2d = field_2d';
elseif nargin == 2
  field_2d = NaN*zeros(360, 180);
  field_2d(coads_index_1d) = field_1d;
  field_2d = field_2d';
  lon = 0.5:359.5;
  lat = -89.5:89.5;
elseif nargin == 6
  if length(coads_index_1d) ~= 42164
    load coads_grid
    lon = lon(ind_lon_min:ind_lon_max);
    lat = lat(ind_lat_min:ind_lat_max);    
  else
    lon = (ind_lon_min:ind_lon_max) - 0.5;
    lat = (ind_lat_min:ind_lat_max) - 90.5;
  end
  field_tmp = NaN*zeros(360, 180);
  field_tmp(coads_index_1d) = field_1d;
  field_2d = field_tmp(ind_lon_min:ind_lon_max, ...
      ind_lat_min:ind_lat_max)';
else  
  error([ 'There must be either 1, 2 or 6 input arguments but ' ...
	'there are ' num2str(nargin) ])
end
