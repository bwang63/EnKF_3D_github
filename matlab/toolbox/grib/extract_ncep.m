function [status, info_string] = extract_ncep(file_input, rec_no_list, file_output)
% EXTRACT_NCEP: Appends some grib 'slices' to a grib file.
%
% function [status, info_string] = extract_ncep(file_input, rec_no_list, ...
%                                               file_output)
% FILE_INPUT is the name of a grib file. REC_NO_LIST is a vector which lists
% the record numbers to be appended to the grib file FILE_OUTPUT. If
% FILE_OUTPUT does not exist it will be created. STATUS is a list of status
% values returned as each slice is appended; a value is non-zero if an error
% occurred. INFO_STRING is either a string of the 'matlab friendly'
% information strings returned when the slices are written or error
% messages.
%
%   Example usage: This grabs the 12 monthly means of 1000 mb relative
%                  humidity slices.
%
% file_input = '/misc/cd/data/monthly/prs/all.prs';
% rec_no_list = 117 + (0:11)*195;
% file_output = 'test.1000mb';
% [status, info_string] = extract_ncep(file_input, rec_no_list, file_output);


% $Id: extract_ncep.m,v 1.1 2000/04/07 00:49:56 mansbrid Exp $
% Copyright J. V. Mansbridge, CSIRO, Friday April  7 10:30:34 EST 2000

global wgrib_dir wgrib_name

if nargin ~= 3
  help extract_ncep
  error('there must be 3 input names')
end

% Find the directory containing the executable and also the executable's name.

if isempty(wgrib_name)
  get_wgrib_info
end

stat_list = [];
info_str_list = [];
for ii = rec_no_list
  [stat, info_str] = unix([wgrib_name ' ' file_input ' -grib -append' ...
		    ' -d ' num2str(ii) ' -mv -o ' file_output]);
  if stat ~= 0
    error(info_str)
  end
  stat_list = [stat_list stat];
  info_str_list = [info_str_list info_str];
end

if nargout == 1
  status = stat_list;
elseif nargout == 2
  status = stat_list;
  info_string = info_str_list;  
end
