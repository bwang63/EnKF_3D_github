function pos = get_pos_ncep(file)

% GET_POS_NCEP: returns the byte position of the headers in an NCEP grib file.
% The byte position can then be used in an appropriate call to GET_NCEP so
% that the data is found directly without having to read every recoed in the
% file sequentially.
%
%       INPUT:
%
% file: name of an NCEP grib file, e.g., '/CDROM/data/monthly/at00z/all.prs'
%       OUTPUT:
%
% pos: The byte position of the start of every header in the ncep file
%
%       EXAMPLE USAGE
% 
% pos = get_pos_ncep(file);
% [values, info, lon, lat] = get_ncep(file, pos(rec_num), [], 1);
%
% This will return the same values as:
%
% [values, info, lon, lat] = get_ncep(file, rec_num);

% $Id: get_pos_ncep.m,v 1.3 2000/02/09 05:12:10 mansbrid Exp $
% Copyright J. V. Mansbridge, CSIRO, Mon Sep  1 12:00:21 EST 1997

global wgrib_dir wgrib_name

if nargin ~= 1
  help get_pos_ncep
  error('Wrong number of input arguments to get_pos_ncep.')
end

if nargout > 1
  help get_pos_ncep
  error('Wrong number of output arguments to get_pos_ncep.')
end

% Find the directory containing the executable and also the exuctable's name.

if isempty(wgrib_name)
  get_wgrib_info
end

% Get a string of the info.

verbosity_level = '-ppos';
[status, w] = unix([wgrib_name ' ' file ' ' verbosity_level]);
if (status ~= 0)
  error(['status = ' num2str(status)])
end
w = ['[' w ']']; % To fit the old definition of str2num
pos = str2num(w);
