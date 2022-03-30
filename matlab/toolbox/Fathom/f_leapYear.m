function leap = f_leapYear(year);
% - determine if a year is a leap year
%
% USAGE: leap = f_leapYear(year);
%
% year = 4 digit year between 1901 - 2999
% leap = boolean value indicating true/false
%
% See also f_isDST, f_julian, f_gregorian

% -----Author(s):-----
% by Dave Jones<djones@rsmas.miami.edu>, Dec-2002
% http://www.rsmas.miami.edu/personal/djones/
% ----------------- DISCLAIMER: -------------------
% This code is provided as is, with no guarantees
% and is only intended for non-commercial use.
% --------------------------------------------------

if (year < 1901) | (year > 2999)
	error('Error: year not b/n 1901-2999');
end

% force input as integers:
year = fix(year);

% preallocate:
[nr,nc] = size(year);
leap    = zeros(nr,nc); 

% check for leap year:
leap(find(year/4 - fix(year/4) == 0)) = 1;

