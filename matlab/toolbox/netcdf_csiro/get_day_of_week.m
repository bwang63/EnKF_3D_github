function [day_num, day_name] = get_day_of_week(jd)
% GET_DAY_OF_WEEK  Gets the day of the week given the Julian day number.
%
%     Usage: [day_num, day_name] = get_day_of_week(jd)
%
%        jd... input decimal Julian day number
%
%        day_num... 0 => Sunday, 1 => Monday, 2 => Tuesday, etc
%        day_name... 'Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri' or 'Sat'
%
%             NOTES
%    1) Formally, Julian days start and end at noon. In this convention,
% Julian day 2440000 begins at 1200 hours, May 23, 1968.
%    2) jd may be a row or column vector of julian days. day_num will be the
% same type of vector. day_name will be an NX3 matrix.
%    3) The algorithm is taken from Astronomical Algorithms by Jean Meeus and
% gives the correct dates on the Gregorian and Julian calenders. Thus it is
% accurate back to the beginning of the year -4712.
%    4) Because the Christian calendar does not have a year zero then what
% historians call 10 BC is actually the year -9.
%    5) The standard matlab functions datenum, datevec and datestr assume
% that we are using a Gregorian calendar and so cannot be used before 15
% October 1582. The same restriction applies to the locally written matlab
% routines julian and gregorian.

% $Id: get_day_of_week.m,v 1.1 2000/07/03 04:13:46 mansbrid Exp $
% Copyright J. V. Mansbridge, CSIRO, Monday June 26 16:02:11 EST 2000

day_num = rem(round(jd + 1), 7);
if nargout > 1
  list_day_names = ['Sun'; 'Mon'; 'Tue'; 'Wed'; 'Thu'; 'Fri'; 'Sat'];
  day_name = list_day_names(day_num+1, :);
end



