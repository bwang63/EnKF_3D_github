function [gregorian_time, serial_time, gregorian_base, serial_base, ...
	  sizem, serial_time_jd, serial_base_jd] = ...
    timenc(file, time_var, corner, end_point);
% TIMENC   Returns time information for a file that meets COARDS standards.
%
% function [gregorian_time, serial_time, gregorian_base, serial_base, ...
% 	  sizem, serial_time_jd, serial_base_jd] = ...
%         timenc(file, time_var, corner, end_point);
%
% DESCRIPTION:
%
% timenc finds the time vector and the corresponding base date for a
% file that meets COARDS standards.  This means that the units attribute
% of the time-like variable should contain a string like:
%      'seconds since 1992-10-8 15:15:42.5 -6:00'
% This indicates seconds since October 8th, 1992 at 3 hours, 15
% minutes and 42.5 seconds in the afternoon in the time zone
% which is six hours to the west of Coordinated Universal Time
% (i.e. Mountain Daylight Time). The time zone specification can
% also be written without a colon using one or two-digits
% (indicating hours) or three or four digits (indicating hours
% and minutes).  Instead of 'seconds' the string may contain 'minutes',
% 'hours', 'days' and 'weeks' and all of these may be singular or plural
% and have capital first letters.  I also allow the letters 'UTC' or
% 'UT' at the end of the string, but these are ignored.
%
% All calculations are done using the functions get_calendar_date and
% get_julian_day which know about both the Julian and Gregorian calendars and
% so work back to julian day 0 in the year -4712. Previous versions of timenc
% used the matlab functions datestr, datevec & datenum and so were faulty if
% applied to any date before the adoption of the Gregorian calendar in
% October 15 1582. Wrong answers were given even if only the base date was
% before this time. All returned times are in UT. 
%
% INPUT:
% file: the name of a netCDF file with or without the .cdf or .nc extent.
% time_var: the name of the 'time' variable in the netCDF file.  If this
%    argument is missing then it is assumed that variable name is 'time'.
%    If time_var is multi-dimensional then it will be handled as if it
%    had been reshaped as one 'giant' vector. 
% corner: a vector of length n specifying the hyperslab corner
%    with the lowest index values (the bottom left-hand corner in a
%    2-space).  The corners refer to the dimensions in the same
%    order that these dimensions are listed in the relevant questions
%    in getnc.m and in the inqnc.m description of the variable.  A
%    negative element means that all values in that direction will be
%    returned.  If this argument is missing or a negative scalar is used
%    this means that all of the elements in the array will be returned.
%  end_point is a vector of length n specifying the hyperslab corner
%    with the highest index values (the top right-hand corner in a
%    2-space).  The corners refer to the dimensions in the same order
%    that these dimensions are listed in the relevant questions in
%    getnc.m and in the inqnc.m description of the variable.  An
%    element in the end_point vector will be ignored if the corresponding
%    element in the corner vector is negative.
%
% OUTPUT:
% gregorian_time: an Mx6 matrix where the rows refer to the M times
%    specified in the 'time' variable in the netCDF file.  The columns
%    are the year, month, day, hour, minute, second in that order, UT.
% serial_time: an M vector giving the serial times (in UT) specified in the
%    'time' variable in the netCDF file. Serial times are used by datestr,
%    datevec & datenum. Thus gregorian_time = datevec(serial_time). Note that
%    the 'time' variable actually contains the serial time relative to a
%    base time.
% gregorian_base: a 6-vector giving the year, month, day, hour, minute,
%    second of the base time as specified in the 'units' attribute of
%    the 'time' variable. This is in UT.
% serial_base: the serial time of the base time, in UT, as determined by
%    matlab's datenum function. Thus gregorian_base = datevec(serial_base).
%    serial_base will be a NaN for times before October 15 1582, when the
%    Gregorian calendar was adopted, since datenum is not meaningful in this
%    case.
% sizem: the size of the 'time' variable in the netCDF file.
% serial_time_jd: an M vector giving the julian day number (in UT) specified
%    in the 'time' variable in the netCDF file. (julian day numbers are used
%    by get_julian_day and get_calendar_date. Thus gregorian_time =
%    get_calendar_date(serial_time_jd).
% serial_base_jd: the Julian day number of the base time, in UT, as
%    determined by get_julian_day. Thus gregorian_base =
%    get_calendar_date(serial_base_jd).
%
%     Copyright J. V. Mansbridge, CSIRO, Tue May  9 11:36:06 EST 1995
%     (with the ability to handle a multi-dimensional time variable
%     added by Rose O'Connor).

%$Id: timenc.m,v 1.11 2000/07/04 02:31:37 mansbrid Exp $

% Process the input arguments

if nargin == 1
  time_var = 'time';
  get_all = 1;
elseif nargin == 2
  get_all = 1;
elseif nargin == 4
  if (corner > 0) & (end_point >= corner)
    get_all = 0;
  else
    get_all = 1;
  end
else
  disp('timenc takes either 1, 2 or 4 input arguments')
  help timenc
  return
end

% Check that the file is accessible.  If it is then its full name will
% be stored in the variable cdf.  The file may have the extent .cdf or
% .nc and be in the current directory or the common data set (whose
% path can be found by a call to pos_cds.m.  If a compressed form
% of the file is in the current directory then the procedure gives an
% error message and exits.  If the netcdf file is not accessible then
% the m file is exited with an error message.

cdf_list = { '.nc' '.cdf' ''};
ilim = length(cdf_list);
for i = 1:ilim 
  cdf = [ file cdf_list{i} ];
  err = check_nc(cdf);

  if err == 0
    break;
  elseif err == 1
    if i == ilim
      error([ file ' could not be found' ]);
    end
  elseif err == 2
    path_name = pos_cds;
    cdf = [ path_name cdf ];
    break;
  elseif err == 3
    error([ 'exiting because ' cdf ' is in compressed form' ]);
  end
end

%Open the netcdf file.

[cdfid, rcode] = ncmex('OPEN', cdf, 'NC_NOWRITE');
if rcode == -1
  error(['** ERROR ** ncopen: rcode = ' num2str(rcode)])
end

%Suppress all error messages from netCDF 

[rcode] = ncmex('setopts', 0);

%Get the id number of the variable 'time' and find out the info. about
%the variable 'time'.

[varid, rcode] = ncmex('varid', cdfid, time_var);
if rcode == -1
  error(['** ERROR ** ncvarid: time variable = ''' time_var ''' not found'])
end

if get_all == 1
  [varnam, vartypv, nvdims, vdims, nvatts, rcode] = ...
      ncmex('ncvarinq', cdfid, varid);
  if rcode == -1
    error(['** ERROR ** ncvarinq: rcode = ' num2str(rcode) ...
	  ', time variable = ''' time_var ''''])
  end
  
  %Find out the size of the dimension 'time' which is the same as the
  %variable 'time'.

  %[name, sizem, rcode] = ncmex('ncdiminq', cdfid, vdims(1));
  %ROC
  sizem = zeros(1,nvdims);
  st    = zeros(1,nvdims);
  for i = 1:nvdims
    [name, sizem(i), rcode] = ncmex('ncdiminq', cdfid, vdims(i));
    if rcode == -1
      error(['** ERROR ** ncdiminq: rcode = ' num2str(rcode)])
    end
  end
  
  %Retrieve the elements of the variable 'time'.  These are the serial day
  %relative to the base date.

  if any(sizem == 0)
    serial_rel = []; % Presumably time is an unlimited dimension of length 0.
    disp(['Warning: There are apparently no ''time'' records'])
  else
    %[serial_rel, rcode] = ncmex('ncvarget', cdfid, varid, 0, sizem);
    [serial_rel, rcode] = ncmex('ncvarget', cdfid, varid, st, sizem);
    if rcode == -1
      error(['** ERROR ** ncvarget: rcode = ' num2str(rcode)])
    end
  end
else
  [varnam, vartypv, nvdims, vdims, nvatts, rcode] = ...
      ncmex('ncvarinq', cdfid, varid);
  if rcode == -1
    error(['** ERROR ** ncvarinq: rcode = ' num2str(rcode) ...
	   ', time variable = ''' time_var ''''])
  end
  
  sizem = zeros(1,nvdims);
  for i = 1:nvdims
    [name, sizem(i), rcode] = ncmex('ncdiminq', cdfid, vdims(i));
    if rcode == -1
      error(['** ERROR ** ncdiminq: rcode = ' num2str(rcode)])
    end
  end
  
  if any(sizem == 0)
    serial_rel = []; % Presumably time is an unlimited dimension of length 0.
    disp(['Warning: There are apparently no ''time'' records'])
  elseif any(corner) < 1
    error('corner values are too small')
  elseif any(end_point > sizem)
    error('end_point values are too large')
  else
    [serial_rel, rcode] = ncmex('ncvarget', cdfid, varid, ...
				corner-1, end_point-corner+1);
    if rcode == -1
      error(['** ERROR ** ncvarget: rcode = ' num2str(rcode)])
    end
  end
end

%Get the string describing the base date.

[base_str, rcode] = ncmex('attget', cdfid, varid, 'units');
if rcode == -1
  error(['** ERROR ** ncattget: rcode = ' num2str(rcode)])
end

%Close the netcdf file.

[rcode] = ncmex('ncclose', cdfid);
if rcode == -1
  error(['** ERROR ** ncclose: rcode = ' num2str(rcode)])
end

% Parse the string containing the base date to get its constituents and
% then find its serial and gregorian dates. Also rescale the relative serial
% time vector to turn it into days since the base time.

[gregorian_base, rescale_serial_rel, serial_base_jd, serial_base] = ...
    parsetnc(base_str);
if rescale_serial_rel ~= 1
  serial_rel = rescale_serial_rel*serial_rel;
end

%Find the absolute serial date and resultant gregorian date of the time
%vector.

serial_time_jd = serial_rel + serial_base_jd;

if isempty(serial_time_jd)
  gregorian_time = [];
else
  gregorian_time = get_calendar_date(serial_time_jd);
  serial_time = datenum(gregorian_time(:, 1), gregorian_time(:, 2), ...
			gregorian_time(:, 3), gregorian_time(:, 4), ...
			gregorian_time(:, 5), gregorian_time(:, 6));
end
