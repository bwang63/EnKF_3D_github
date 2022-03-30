function [date_string] = jd2str ( jd )
% ECOMTIME2STR:  Converts julian time into string representation.
%
% USAGE:  date_string = jd2str ( julian_date );
% Paramters:
%   julian_date:  day number in Julian time.


greg_date = gregorian ( jd );
serial_date = datenum(greg_date(1), ...
					  greg_date(2), ...
					  greg_date(3), ...
					  greg_date(4), ...
					  greg_date(5), ...
					  greg_date(6) );

date_string = datestr ( serial_date, 0 );

