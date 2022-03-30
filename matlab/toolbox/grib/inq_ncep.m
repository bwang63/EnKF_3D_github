function info = inq_ncep(file, print_info)

% inq_ncep returns information about an NCEP grib file
%
%       INPUT:
%
% file: name of an NCEP grib file, e.g., '/CDROM/data/monthly/at00z/all.prs'
% print_info: if print_info is non-zero or no argument is passed then a
%             table of information about the file is written to the screen.
%             Thus the only way to avoid this print-out is to pass 0.
%
%       OUTPUT:
%
% info: a matlab structure containing header information from the grib
%       file.  If there is more than one record in the file then the
%       structure is indexed by record number, i.e., info(4).units will
%       contain the units for the data in record 4 of the file.

% $Id: inq_ncep.m,v 1.7 2000/02/09 05:12:10 mansbrid Exp $
% Copyright J. V. Mansbridge, CSIRO, Mon Sep  1 12:00:21 EST 1997

global wgrib_dir wgrib_name

if nargin == 1
  print_info = 1;
elseif  nargin ~= 2
  help inq_ncep
  error('Wrong number of input arguments to inq_ncep.')
end

if nargout > 1
  help inq_ncep
  error('Wrong number of output arguments to inq_ncep.')
end

% Find the directory containing the executable and also the exuctable's name.

if isempty(wgrib_name)
  get_wgrib_info
end

% Get a string of the info.

verbosity_level = '-mv';
[status, info_string] = unix([wgrib_name ' ' file ' ' verbosity_level]);
if (status ~= 0)
  error(['status = ' num2str(status)])
end

info = parse_grib_info(info_string, verbosity_level);

% If required print out information about the file.

if print_info ~= 0
  len_info = length(info);
  disp(['There are ' num2str(len_info) ' records'])
  disp(['rec_num       long_name                level     ' ...
	'production hr day mth yr'])
  disp(' ')
  for ii = 1:len_info
    fprintf(1, '%3d %33s %8s %12s %2d:%2d:%2d:%4d\n', ...
	  ii, info(ii).long_name, info(ii).level_description, ...
	  info(ii).production_info, info(ii).hour, info(ii).day, ...
	  info(ii).month, info(ii).year);
  end
end
