function [gtime] = get_calendar_date(jd)
% GET_CALENDAR_DATE Converts Julian day numbers to calendar dates.
%
%     Usage: [gtime] = get_calendar_date(jd) 
%
%        jd... input decimal Julian day number
%
%        gtime is a six component Gregorian time vector
%          i.e.   gtime=[yyyy mo da hr mi sec]
%                 gtime=[1989 12  6  7 23 23.356]
% 
%        yr........ year (e.g., 1979)
%        mo........ month (1-12)
%        d........ corresponding Gregorian day (1-31)
%        h........ decimal hours
%
%             NOTES
%    1) Formally, Julian days start and end at noon. In this convention,
% Julian day 2440000 begins at 1200 hours, May 23, 1968.
%    2) jd may be a row or column vector of julian days. In either case gtime
% will be a matrix containing columns of years, months, etc.
%    3) The algorithm is taken from Astronomical Algorithms by Jean Meeus and
% gives the correct dates on the Gregorian and Julian calenders. Thus it is
% accurate back to the beginning of the year -4712.
%    4) Because the Christian calendar does not have a year zero then what
% historians call 10 BC is actually the year -9.
%    5) The standard matlab functions datenum, datevec and datestr assume
% that we are using a Gregorian calendar and so cannot be used before 15
% October 1582. The same restriction applies to the locally written matlab
% routines julian and gregorian.

% $Id: get_calendar_date.m,v 1.1 2000/07/03 04:13:46 mansbrid Exp $
% Copyright J. V. Mansbridge, CSIRO, Monday June 26 16:02:11 EST 2000

if (nargin ~= 1) | (nargout ~= 1)
  error('Wrong number of arguments in call to get_calendar_date')
end

% Add half a day to julian plus a little bit to prevent a roundoff error on
% seconds.
 
delta = 5.e-9;
jd = jd(:) + 0.5 + delta;
z = floor(jd);
f = rem(jd, 1);
greg_lim = 2299161;
a = zeros(size(jd));
ff_old = find(jd < greg_lim);
if ~isempty(ff_old)
  a(ff_old) = z(ff_old);
end
ff_new = find(jd >= greg_lim);
if ~isempty(ff_new)
  alpha = floor((z(ff_new) - 1867216.25)/36524.25);
  a(ff_new) = z(ff_new) + 1 + alpha - floor(alpha/4);
end
b = a + 1524;
c = floor((b - 122.1)/365.25);
d = floor(365.25*c);
e = floor((b - d)/30.6001);
day = b - d - floor(30.6001*e);
month = e - 1;
ff = find(month > 12);
if ~isempty(ff)
  month(ff) = month(ff) - 12;
end
year = c - 4715;
ff = find(month > 2);
if ~isempty(ff)
  year(ff) = year(ff) - 1;
end
hour = floor(24*f);
remainder = f - hour/24;
minute = floor(24*60*remainder);
remainder = remainder - minute/(24*60);

% Find the number of seconds and correct for the previous fiddle that
% prevented a rounding error.

second = 24*3600*(remainder - delta);
ff = find(second < 0);
if ~isempty(ff)
  second(ff) = zeros(size(ff));
end

gtime = [year month day hour minute second];
