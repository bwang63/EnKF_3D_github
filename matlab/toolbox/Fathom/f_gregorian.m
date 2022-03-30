function [gdate,vdate] = f_gregorian(jdate,yr);
% - convert Julian date to Gregorian
%
% USAGE [gdate,vdate] = f_gregorian(jdate,yr);
%
% jdate = Julian date
% yr    = 4-digit year
%
% gdate = 'dd-mmm-yyyy'      (date string)
% vdate = [yyyy mm dd h m s] (date vector)
%
% See also: f_julian, f_isDST, f_leapYear

% ----- Notes: -----
% This function returns the Gregorian date as a string
% and a date vector, given a Julian date and the Year.
%
% Use this program to easily create a matrix of dates
% for axis ticks, etc. (be careful with leap years):
% [gdate,vdate] = f_gregorian(1:365,2002);

% ----- Author(s): -----
% by Dave Jones,<djones@rsmas.miami.edu> Dec-2002
% http://www.rsmas.miami.edu/personal/djones/
% ----------------- DISCLAIMER: -------------------
% This code is provided as is, with no guarantees
% and is only intended for non-commercial use.
% --------------------------------------------------

% get starting date (31-Dec of previous year):
startDay = datenum([yr-1,12,31,0,0,0]);

% convert to serial date
serialDate = (startDay + jdate);

% convert to Gregorian date string:
gdate = datestr(serialDate,1);

% convert to Gregorian date vector:
vdate = datevec(serialDate);

