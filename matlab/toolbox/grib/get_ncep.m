function [values, info, lon, lat] = get_ncep(file, rec_num, ...
						   temp_file_name, rec_type)

% get_ncep returns the data from one horizontal slice of an NCEP grib file. 
% function [values, info, lon, lat] = get_ncep(file, rec_num, ...
%						   temp_file_name, rec_type)
%
%       INPUT:
%
% file: name of an NCEP grib file, e.g., '/CDROM/data/monthly/at00z/all.prs'
% rec_num: number of the record in the NCEP grib file or byte position of
%          the start of the record (see rec_type description)
% temp_file_name: the name of the temporary file used by get_ncep. If it is not
%      specified by the user or is empty then get_ncep will chose a name of its
%      own using a call to tempname. Specifying temp_file_name avoids the very
%      unlikely possibility of tempname returning a non-unique temporary file
%      name; also get_ncep may be speeded up a little. However, users should be
%      sure that they have appropriate write permissions.
% rec_type: If rec_type is missing or 0 then it is assumed that rec_num is
%           the number of the record in the NCEP grib file; this is the
%           default. If rec_type is non-zero then it is assumed that rec_num
%           is the byte position of the start of the record. 
%
%       OUTPUT:
%
% values: a matrix containing the data in a horizontal slice of the NCEP
%    grib file.  It has dimensions length(lon) X length(lat).
% info: a matlab structure containing header information from the grib file
% lon: column vector of longitudes in the horizontal slice
% lat: column vector of latitudes in the horizontal slice
%
%       NOTES:
% 1) The calculation of info, lat and lon can be time consuming - so don't
%    ask for them unless you want them.
% 2) Using the byte position (i.e., rec_type == 1) allows quicker access to
%    the record since using the record number requires access to all of the
%    earlier records in the file. This would cause rec_num fseeks instead of
%    just 1.
%
%       USAGE:
%
%    Example 1
%
% rec_num = 16;
% file = '/CDROM/data/monthly/at00z/all.prs';
% [values, info, lon, lat] = get_ncep(file, rec_num);
% info
% cs = contourf(lon, lat, values');
% clabel(cs)
% title([info.long_name ' ' info.units ' ' info.level_description])
%
%   Example 2 (to return the same data as in example 1)
%
% pos = get_pos_ncep(file);
% [values, info, lon, lat] = get_ncep(file, pos(rec_num), [], 1);


% $Id: get_ncep.m,v 1.14 2000/02/09 05:12:10 mansbrid Exp $
% Copyright J. V. Mansbridge, CSIRO, Mon Sep  1 12:30:29 EST 1997

global wgrib_dir wgrib_name
global lat_gauss_loaded

if nargin < 2
  help get_ncep
  error('Wrong number of input arguments to get_ncep.')
elseif nargin == 2
  temp_file_name = '';
  rec_type = 0;
elseif nargin == 3
  rec_type = 0;
elseif nargin > 4
  help get_ncep
  error('Wrong number of input arguments to get_ncep.')
end

if (nargout == 0) | (nargout > 4)
  help get_ncep
  error('Wrong number of output arguments to get_ncep.')
end

% Find the directory containing the executable and also the exuctable's name.

if isempty(wgrib_name)
  get_wgrib_info
end

% Create a unique temporary file if required.

if isempty(temp_file_name)
  temp_file_name = [tempname '.wgb'];
end
  
% Dump the record to a binary file, open the file, read the data into
% matlab, close the file, delete the file.

if rec_type == 0
  dump_type = ' -d ';
else
  dump_type = ' -p ';
end
if nargout == 1
  verbosity_level = '-M';
else
  verbosity_level = '-mv';
end

switch verbosity_level
  case '-M'
    [status, info_string] = unix([wgrib_name ' ' file  dump_type ...
	  num2str(rec_num) ' -nh ' verbosity_level ' -o ' ...
	  temp_file_name]);
    fid = fopen(temp_file_name, 'r');
    len_lon = fread(fid, 1, 'int');
    len_lat = fread(fid, 1, 'int');
    values = fread(fid, inf, 'float');
    fclose(fid);
    delete(temp_file_name);
  case '-mv'
    [status, info_string] = unix([wgrib_name ' ' file  dump_type ...
	  num2str(rec_num) ' -nh ' verbosity_level ' -o ' ...
	  temp_file_name]);
    fid = fopen(temp_file_name, 'r');
    values = fread(fid, inf, 'float32');
    fclose(fid);
    delete(temp_file_name);
    
    % Get information about the record.
    
    info = parse_grib_info(info_string, verbosity_level);
    len_lon = info.nx;
    len_lat = info.ny;
end

% Reshape the matrix
values = reshape(values, len_lon, len_lat);

% If required return the longitude and latitude vectors associated with the
% record.  Use the stored information to orient and check the grids.

if nargout >= 3
  switch info.gds_grid_no
    case 0                 % lon/lat grid
      del_lon = 360/len_lon;
      lon = (0:(len_lon-1))'*del_lon;
      del_lat = 180/(len_lat - 1);
      lat = (-90:del_lat:90)';
      if info.la1*lat(1) < 0
	lat = flipud(lat); % ncep starts at the north pole
      end
      
      if (abs(lon(1) - info.lo1/1000) > 1.e-6)
	error('Initial longitude wrong')
      end
      if (abs(del_lon - info.dx/1000) > 1.e-6)
	error('longitude increment wrong')
      end
      if (abs(lat(1) - info.la1/1000) > 1.e-6)
	lat(1:4)
	info.la1
	error('Initial latitude wrong')
      end
      if (abs(del_lat - info.dy_nlat/1000) > 1.e-6)
	error('latitude increment wrong')
      end
    case 4 % Gaussian grid. Note that the calculation of the latitudes on 
           % the Gaussian grid takes a long time and so I check whether it
           % has already been done and the values stored.
      del_lon = 360/len_lon;
      lon = (0:(len_lon-1))'*del_lon;
      
      if isempty(lat_gauss_loaded) | length(lat_gauss_loaded) ~= len_lat
	if len_lat == 94
      	  eval(['load ' wgrib_dir 'lat_gauss_94.mat'])
	else
	  lat = lat_legendre(len_lat, 1.e-10);
	end
	lat_gauss_loaded = lat;
      else
	lat = lat_gauss_loaded;
      end
      if info.la1*lat(1) < 0
	lat = flipud(lat); % ncep starts at the north pole
      end
      
      if (abs(lon(1) - info.lo1/1000) > 1.e-6)
	error('Initial longitude wrong')
      end
      if (abs(del_lon - info.dx/1000) > 1.e-6)
	error('longitude increment wrong')
      end
      if (abs(lat(1) - info.la1/1000) > 1.e-6)
	error('Initial latitude wrong')
      end
      if (abs(len_lat/2 - info.dy_nlat) > 1.e-6)
	error('latitude increment wrong')
      end
    otherwise
      error(['No code to calculate lons and lats for info.gds_grid_no = ' ...
	    num2str(info.gds_grid_no)])
  end
end
