function [gregorian_time, serial_time, gregorian_base, serial_base, sizem] = ...
 timenc(file, time_var, corner, end_point);
% TIMENC   Returns time information for a file that meets COARDS standards
%
% [gregorian_time, serial_time, gregorian_base, serial_base, sizem] = ...
% timenc(file, time_var);
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
% Note that timenc uses the matlab5 functions datenum and datevec.
% Hence serial time refers to the values returned by those functions.
% timenc is based on get_time.m which used julian.m and gregorian.m.
% They use julian days, as defined by astronomers, to specify linear
% time. All returned times are in UT.
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
%    'time' variable in the netCDF file. (Serial times are used by datestr,
%    datevec, etc. Thus gregorian_time = datevec(serial_time).  Note that
%    the 'time' variable actually contains the serial time relative to a
%    base time; thus the values actually stored in the netCDF file will be
%    serial_time - serial_base.
% gregorian_base: a 6-vector giving the year, month, day, hour, minute,
%    second of the base time as specified in the 'units' attribute of
%    the 'time' variable. This is in UT.
% serial_base: the serial time of the base time, in UT, (as determined by
%    matlab's datenum function, see serial_time above).
% sizem: the size of the 'time' variable in the netCDF file.
%
%     Copyright J. V. Mansbridge, CSIRO, Tue May  9 11:36:06 EST 1995
%     (with the ability to handle a multi-dimensional time variable
%     added by Rose O'Connor).

%$Id: timenc.m,v 1.6 1998/04/22 00:41:43 mansbrid Exp $

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
% path can be found by a call to pos_data_cdf.m.  If a compressed form
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
    path_name = pos_data_cdf;
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

  %[serial_rel, rcode] = ncmex('ncvarget', cdfid, varid, 0, sizem);
  [serial_rel, rcode] = ncmex('ncvarget', cdfid, varid, st, sizem);
  if rcode == -1
    error(['** ERROR ** ncvarget: rcode = ' num2str(rcode)])
  end
else
  [serial_rel, rcode] = ncmex('ncvarget', cdfid, varid, ...
      corner-1, end_point-corner+1);
  if rcode == -1
    error(['** ERROR ** ncvarget: rcode = ' num2str(rcode)])
  end
  if nargout >= 5
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

%Parse the string containing the base date to get its constituents and
%then find its serial and gregorian dates.

%Note 1) I had trouble using strtok with ':' and '-' and so I converted
%        the first 2 instances of each of them to spaces.  This leaves
%        the correction to Universal time (if there is one) untouched.

fm = find(base_str == '-');
fc = find(base_str == ':');
str = base_str;

if length(fm) >= 2
  str(fm(1:2)) = ' '*ones(size(fm(1:2)));
else
  error('The year-month-day string is wrongly specified in the base date')
end

if length(fc) == 1
  str(fc(1)) = ' ';
elseif length(fc) >= 2
  str(fc(1:2)) = ' '*ones(size(fc(1:2)));
end
str = setstr(str);

%Convert the time vector to serial days since the base time.

[str, remainder] = strtok(str);
if ( strcmp('week', str) | strcmp('weeks', str) | ...
      strcmp('Week', str) | strcmp('week', str) )
  serial_rel = serial_rel*7;
elseif ( strcmp('day', str) | strcmp('days', str) | ...
      strcmp('Day', str) | strcmp('day', str) )
elseif ( strcmp('hour', str) | strcmp('hours', str) | ...
      strcmp('Hour', str) | strcmp('Hours', str) )
  serial_rel = serial_rel/24;
elseif ( strcmp('minute', str) | strcmp('minutes', str) | ...
      strcmp('Minute', str) | strcmp('Minutes', str) )
  serial_rel = serial_rel/(24*60);
elseif ( strcmp('second', str) | strcmp('seconds', str) | ...
      strcmp('Second', str) | strcmp('Seconds', str) )
  serial_rel = serial_rel/(24*60*60);
else
  error(['bad time baseline string = ' base_str ])
end

%Find the serial base time (initially without paying attention to any
%reference to Universal time).

[str, remainder] = strtok(remainder);
[str, remainder] = strtok(remainder);
if isempty(str)
  error('The base time has no string for the year')
end
year_base = str2num(str);
[str, remainder] = strtok(remainder);
if isempty(str)
  error('The base time has no string for the month')
end
month_base = str2num(str);
[str, remainder] = strtok(remainder);
if isempty(str)
  error('The base time has no string for the day')
end
day_base = str2num(str);
[str, remainder] = strtok(remainder);
if isempty(str)
  disp('The base time has no string for the hour, assume hour = min = sec = 0')
  hour_base = 0;
  minute_base = 0;
  second_base = 0;
else
  hour_base = str2num(str);
  [str, remainder] = strtok(remainder);
  if isempty(str)
    disp('The base time has no string for the minute, assume min = sec = 0')
    minute_base = 0;
    second_base = 0;
  else
    minute_base = str2num(str);
    [str, remainder] = strtok(remainder);
    if isempty(str)
      disp('The base time has no string for the second, assume sec = 0')
      second_base = 0;
    else
      second_base = str2num(str);
    end
  end
end
gregorian_base = [year_base month_base day_base hour_base ...
        minute_base second_base];
% serial_base = serial(gregorian_base);
serial_base = datenum(year_base, month_base, day_base, hour_base, ...
    minute_base, second_base);

% Strip off the string 'UTC' or 'UT' and any trailing blanks from
% remainder.

xx = findstr(remainder, 'UTC');
if ~isempty(xx)
  remainder = remainder(1:(xx-1));
end
xx = findstr(remainder, 'UT');
if ~isempty(xx)
  remainder = remainder(1:(xx-1));
end
remainder = deblank(remainder);

% If the remainder of the string is not empty (or filled with blanks)
% then we assume that there is information about the conversion to
% Universal time.  This is parsed and serial_base and gregorian_base are
% then modified appropriately.

if ~isempty(remainder)

  % Find the number of hours and minutes that the time is offset from
  % Coordinated Universal Time.
  
  fc = find(remainder == ':');
  if length(fc) == 0
    intxx = str2num(remainder);
    if ( (-99 < intxx) & ( intxx < 99) )
      hour_extra = intxx;
      min_extra = 0;
    elseif ( (-9999 < intxx) & ( intxx < 9999) )
      hour_extra = fix(0.01*intxx);
      min_extra = intxx - 100*hour_extra;
    else
      error(['1:Universal time offset is faulty in ' base_str])
    end
  elseif length(fc) == 1
    [str, remainder] = strtok(remainder, ':');
    hour_extra = str2num(str);
    [str, remainder] = strtok(remainder, ':');
    min_extra = sign(hour_extra)*str2num(str);
  else
    error(['2:Universal time offset is faulty in ' base_str])
  end
 
  % Error checks
  
  if ((hour_extra < -12) | (hour_extra > 12))
    error(['3:Universal time offset is faulty in ' base_str])
  end
  if ((min_extra < -59) | (min_extra > 59))
    error(['4:Universal time offset is faulty in ' base_str])
  end

  % Covert the Universal time correction to days.
  
  time_extra = (hour_extra + min_extra/60)/24;

  % Correct serial_base from the local time, as specified in the early
  % part of the string, to Universal time.  Thus in the example
  % 'seconds since 1992-10-8 15:15:42.5 -6:00' we will have
  % time_extra = -6/24 days and this value must be subtracted from
  % serial_base.

  serial_base = serial_base - time_extra;
  % gregorian_base = gregorian(serial_base);
  gregorian_base = datevec(serial_base);

end

%Find the absolute serial date and resultant gregorian date of the time
%vector.

serial_time = serial_rel + serial_base;

% gregorian_time = gregorian(serial_time);
gregorian_time = datevec(serial_time);

