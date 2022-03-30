function [jd] = get_julian_day(y, m, d, h)
% GET_JULIAN_DAY   Converts calendar dates to corresponding Julian day numbers.
%
%     Usage: [jd] = get_julian_day(y, m, d, h)
%        or
%            [jd] = get_julian_day([y m d hour min sec])
%     ************************************************************
%
%        jd... decimal Julian day number
%        d.... day (1-31) component of Gregorian date
%        m.... month (1-12) component
%        y.... year (e.g., 1979) component
%        h.... decimal hours (can be a fraction, assumed 0 if absent)
%
%     ************************************************************
%
%    NOTES
%    1) Formally, Julian days start and end at noon. In this convention,
% Julian day 2440000 begins at 1200 hours, May 23, 1968.
%    2) gtime may be a matrix containing columns of years, months,
% etc. Alternatively, y, m, d, h may be vectors and must all be of the same
% type, i.e. a row or column vector. In any case jd will be a column vector
% of julian days.
%    3) The algorithm is taken from Astronomical Algorithms by Jean Meeus and
% gives the correct dates on the Gregorian and Julian calenders. Thus it is
% accurate back to the beginning of the year -4712.
%    4) Because the Christian calendar does not have a year zero then what
% historians call 10 BC is actually the year -9.
%    5) The standard matlab functions datenum, datevec and datestr assume
% that we are using a Gregorian calendar and so cannot be used before 15
% October 1582. The same restriction applies to the locally written matlab
% routines julian and gregorian.

% $Id: get_julian_day.m,v 1.2 2000/07/03 04:54:08 mansbrid Exp $
% Copyright J. V. Mansbridge, CSIRO, Tuesday June 27 15:15:51 EST 2000

if nargin == 3,
  h=0.;
elseif nargin == 1,
  h = y(:,4) + (y(:,5) + y(:,6)/60)/60; % hour,min,sec as fraction of hour
  d=y(:, 3);
  m=y(:, 2);
  y=y(:, 1);
elseif nargin == 4
  
else
  error('get_julian_day must have either 1, 3 or 4 input arguments')
end

d = d + h/24; % Make d non-integer as used by Meeus

greg_lim = 15 + 31*(10 + 12*1582);
ff = find(m <= 2);
if ~isempty(ff)
  m(ff) = m(ff) + 12;
  y(ff) = y(ff) - 1;
end

ff_greg = find((d + 31*(m + 12*y)) >= greg_lim);
b = zeros(size(y));
if ~isempty(ff_greg)
  a = floor(y(ff_greg)/100);
  b(ff_greg) = 2 - a + floor(a/4);
end
jd = floor(365.25*(y + 4716)) + floor(30.6001*(m + 1)) + d + b - 1524.5;
jd = jd(:);
