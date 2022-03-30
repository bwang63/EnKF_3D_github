function jdate = f_julian(x,zone,daylight)
% - convert date vector to Julian date
%
% USAGE: jdate = f_julian(x,zone,daylight)
%
% x        = input matrix specifying dates     [yy mm dd h m s]
% zone     = time zone                         (default = 0)
% daylight = correct for Daylight Savings Time (default = 0)
% jdate    = Julian date
%
% See also: f_gregorian, f_isDST, f_leapYear

% -----Notes:-----
% This program can span multiple years, with dates after
% the first year > 365 (or 366).
%
% The time zone for US East Coast = -5.
%
% This program calls f_isDST to correct for Daylight Savings Time,
% which currently only supports the US definition.

% ----- Author(s): -----
% by Dave Jones,<djones@rsmas.miami.edu> Dec-2002
% http://www.rsmas.miami.edu/personal/djones/
% ----------------- DISCLAIMER: -------------------
% This code is provided as is, with no guarantees
% and is only intended for non-commercial use.
% --------------------------------------------------

% -----Check input and set defaults:-----
if (nargin < 2), zone     = 0; end; % default no correction for time zone
if (nargin < 3), daylight = 0; end; % default no correction for DST

% pad input with 0's if < 6 columns:
[nr,nc] = size(x);
if (nc < 6)
	x(nr,6) = 0;
end
% ---------------------------------------

% convert to serial date (days since 01-Jan-0000):
serialDate = datenum([x(:,1),x(:,2),x(:,3),x(:,4),x(:,5),x(:,6)]);

% apply time zone correction:
if (zone ~= 0)
	serialDate = serialDate + (zone*(1/24));
end

% add 1 hr to dates during Daylight Savings:
if (daylight>0)
	[y,m,d,h] = datevec(serialDate);
	dst       = f_isDST([y m d h]);
	serialDate(find(dst==1)) = serialDate(find(dst==1)) + (1/24);
end

% get starting date (31-Dec of previous year):
startDay = datenum([min(x(:,1))-1,12,31,0,0,0]);

% rescale (days since 31-Dec of prevous year):
jdate = (serialDate - startDay);

