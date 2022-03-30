function [dyear] = d2years(day, dref)
%
%  A customized version of day2year. This version was simplified 
%  to speed up the calculation of dyear(s) when day is a very large array
%  and dref is fixed
%
%  Converts a number of days since dref into a decimal year
%  value. dref is the base year.
%

% The preceding empty line is important.
% $Log: d2years.m,v $
% Revision 1.1  2000/05/31 23:12:55  dbyrne
% *** empty log message ***
%
% Revision 1.1  2000/05/31 22:59:19  root
% *** empty log message ***
%
% Revision 1.1  1999/09/02 18:32:57  root
% *** empty log message ***
%
% Revision 1.1  1999/07/22 19:28:06  kwoklin
% Add R. Platner's local data files in.   klee
%

% $Id: d2years.m,v 1.1 2000/05/31 23:12:55 dbyrne Exp $
% Ruth Platner     07/12/99

%
%
%  The following lines were commented out because this condition
%  will not exist in these sequential dates (gsodock.m)
%
%if any(floor(day) == 1)
%  % catch the first of the year and *force* it to be an integer
%  % this catches a bug present on PC ix86 chips that I found for
%  % converstion of Jan 1,1997.
%  i = find(floor(day) == 1);
%  dyear = nan*day;
%  dyear(i) = dref(i)+(day(i)-floor(day(i)))/(365+isleap(dref));
%end
%k = find(floor(day) ~= 1);
%dref = dref(k);
%day = day(k);
%
%preallocate memory for dyear to save time
%
dyear = zeros(1,length(day));
ndays = [0   36524   73048  109572  146097  182621 ...
      219145  255669  292194  328718  365242  401766 ...
      438291  474815  511339  547863  584388  620912 ...
      657436  693960  730485];
offset = year2day(dref, 1);
for j = 1:length(day)
  day(j) = day(j) + offset;
  i = find(ndays < day(j));
  i = max(i);
  diff = day(j) - ndays(i);
  nleaps = floor(diff/1461);
  mleaps = floor((diff+1)/1461);
  oleaps = mleaps - nleaps;
  diff = diff-nleaps;
% if this is the last day of a leap year, oleaps = 1
% without oleaps, dyear = next year, the wrong year
  dyear(j) = floor((diff-oleaps)/365);
  diff = diff - (dyear(j)*365);
  dyear(j) = dyear(j) + 1 + (100*(i-1));
  dyear(j) = dyear(j) + diff/(365.0+isleap(dyear(j)));
end
return
