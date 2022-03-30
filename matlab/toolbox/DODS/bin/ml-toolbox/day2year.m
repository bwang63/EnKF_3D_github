function [dyear] = day2year(day, dref)
%
%  Converts a number of days since dref into a decimal year
%  value. dref is the base year. THIS FUNCTION ASSUMES JANUARY 1
%  OF EACH YEAR IS DAY "1" (not day 0) OR THAT "DAY 1" is
%  simultaneous with DREF (not one day later).
%

dyear = zeros(1,length(day));
if all(size(dref) == 1)
  dref = ones(size(day))*dref;
end

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

ndays = [0   36524   73048  109572  146097  182621 ...
      219145  255669  292194  328718  365242  401766 ...
      438291  474815  511339  547863  584388  620912 ...
      657436  693960  730485];
%for j = 1:length(k)
for j = 1:length(day)
  if dref(j) ~= 1
    offset = year2day(dref(j), 1);
    day(j) = day(j) + offset;
  end
  i = find(ndays < day(j));
  if ~isempty(i)
    i = max(i);
  else
    i = length(ndays);
  end
  diff = day(j) - ndays(i) - 1; % added 2000/12/20 dbyrne
%  diff = day(j) - ndays(i);
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

%  Originally written by Tom Sgouros.
%
% $Id: day2year.m,v 1.2 2000/12/20 22:29:19 dbyrne Exp $


% The preceding empty line is important.

% $Log: day2year.m,v $
% Revision 1.2  2000/12/20 22:29:19  dbyrne
%
%
% Merged with d2years.m -- dbyrne 00/12/20
%
% Revision 1.1  2000/05/31 23:11:47  dbyrne
% *** empty log message ***
%
% Revision 1.1  2000/05/31 22:57:19  root
% *** empty log message ***
%
% Revision 1.2  1999/09/02 18:12:20  root
% *** empty log message ***
%
% Revision 1.8  1999/05/03 17:40:59  tom
% fixed spelling of my name.
%
% Revision 1.7  1998/11/30 00:49:09  dbyrne
%
%
% Fixed bug in unpack that deleted all returning names for datasets with
% no empty strings in the required fields.  Fixed vectorization of day2year
% and add workaround for a FLOP bug I found on ix86 machines.  Fixed calendar
% day to yearday conversion error in nscat30cat.m.  Added workaround for writeval
% bug in nscat30.m (2 server lines force 2 loaddods calls).  Fixed a bunch
% of bugs in new SSM/I code submitted by Rob Morris, JPL.  Added SSM/I, CZCS,
% Levitus (1982), World Ocean Atlas monthly, seasonal, and annual datasets and
% Mauna Loa CO2 record.  Fixed a logic error in urieccat.m. -- dbyrne, 98/11/29
%
% Revision 1.1  1998/05/17 14:10:44  dbyrne
% *** empty log message ***
%
% Revision 1.2  1997/11/26 19:01:49  jimg
% Changed comment about dref.
%
% Revision 1.1  1997/11/26 18:51:27  jimg
% Added.
%
