function [day] = year2day(dyear, dref)
%
%  Converts a decimal year into the number of days since dref,
%  also expressed as a decimal year. Note that if you want to see
%  the days since 1/1/1, then dref should be 1.
%

% The preceding empty line is important.
%
% $Id: year2day.m,v 1.1 2000/05/31 23:11:48 dbyrne Exp $

% $Log: year2day.m,v $
% Revision 1.1  2000/05/31 23:11:48  dbyrne
% *** empty log message ***
%
% Revision 1.1  2000/05/31 22:57:20  root
% *** empty log message ***
%
% Revision 1.2  1999/09/02 18:12:26  root
% *** empty log message ***
%
% Revision 1.6  1999/05/13 03:09:54  dbyrne
%
%
% Added Acknowledge and Data_Use_Policy to archive.m.  Fixed getxxx functions
% to use dodsmsg instead of stdout for errors/info.  Made ChangeLog so that it's
% in Emacs format.  All changes for release 3.0.0 -- dbyrne 99/05/12
%
% Revision 1.1  1998/05/17 14:10:56  dbyrne
% *** empty log message ***
%
% Revision 1.1.1.1  1997/09/22 14:13:55  tom
% Imported Matlab GUI sources to CVS
%

notleap = [100 200 300 500 600 700 900 1000 1100 1300 1400 1500 ...
           1700 1800 1900 2100 2200 2300];

intyear = floor(dyear);

% Check if our target year is a leap year.

if isleap(intyear)
   Ndaysinyear = 366.0;
else
   Ndaysinyear = 365.0;
end

% Calculate the number of days that have elapsed since 1/1/1

day = (intyear - 1.0) * 365.0;
day = day + (dyear - intyear) * Ndaysinyear;

Nleap = floor(dyear / 4.0);  % leap years per Julius Caesar
i = 1;
while notleap(i) <= dyear % corrected per Pope Gregory
   Nleap = Nleap - 1;
   i = i + 1;
end

if isleap(dyear)
   Nleap = Nleap - 1;
end

day = day + Nleap;

%
% Repeat earlier operations for dref to create refday.

intrefyear = floor(dref);
Ndaysinrefyear = 365.0;

if intrefyear == intyear
   Ndaysinrefyear = Ndaysinyear;
else
   if isleap(intrefyear)
      Ndaysinrefyear = 366.0;
   end
end

refday = (intrefyear - 1.0) * 365.0;
refday = refday + (dref - intrefyear) * Ndaysinrefyear;

Nleap = floor(dref / 4.0);  % leap years per Julius Caesar
i = 1;
while notleap(i) <= dref % corrected per Pope Gregory
   Nleap = Nleap - 1;
   i = i + 1;
end

if isleap(dref)
   Nleap = Nleap - 1;
end

refday = refday + Nleap;

day = day - refday;

return