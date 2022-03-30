function [times, Pass_Times] = monthly(Time, ranges)
%
%  MONTHLY --- This function will generate a time (year and fraction of a year) at
%              the middle of every month in an interval. Arguments passed in are:
%
%  Time       - The time range of the data set.
%
%  The returned arguments are:
%
%  times      - The time in years (and fractions, see note below) for all hits.
%  Pass_Times - This is the vector of time with the year, day, hour and minute
%               of each hit. Note that the day here is the calendar day; i.e.,
%               the value that would be obtained by taking the fraction of the
%               year, multiplying by 365 (or 366 for a leap year) AND adding 1.
%
% Note Jan 1, year day 001 is decimal day 0, so we need to be careful.
% January 1 starts at midnight on the 365/366th day of the previous year.
% Yearday 0 starts at midnight on the 365/366th day of the previous year.
% Need two times, the one that Deirdre uses in the interface, argout1, 
% (year here) and the one that is used to specify the JPL day, argout2
% (yearday here).
%
%--------------------------------------------------------------------------------
%

% The preceding empty line is important.
%
% $Id: monthly.m,v 1.1 2000/05/31 23:11:48 dbyrne Exp $

% $Log: monthly.m,v $
% Revision 1.1  2000/05/31 23:11:48  dbyrne
% *** empty log message ***
%
% Revision 1.1  2000/05/31 22:57:20  root
% *** empty log message ***
%
% Revision 1.1  2000/05/31 21:36:46  root
% *** empty log message ***
%
% Revision 1.6  1999/09/02 18:27:28  root
% *** empty log message ***
%
% Revision 1.9  1999/05/13 03:09:55  dbyrne
%
%
% Added Acknowledge and Data_Use_Policy to archive.m.  Fixed getxxx functions
% to use dodsmsg instead of stdout for errors/info.  Made ChangeLog so that it's
% in Emacs format.  All changes for release 3.0.0 -- dbyrne 99/05/12
%
% Revision 1.5  1999/03/04 13:13:30  root
% All changes since AGU week.
%
% Revision 1.7  1998/11/18 19:57:01  dbyrne
%
%
% Second try.  Bug fixes to jpl pathfinder data, changed names of
% Reynolds datasets to clarify that one is a climatology and one is not.
%
% Revision 1.4  1998/11/16 11:33:04  root
% Fixed spelling of my name.
%
% Revision 1.3  1998/11/05 16:01:53  root
% Changed LonVector and LatVector to be used if no Lon returned and tried the update function.
% DataScale and DataNull should now be optional!
%
% Revision 1.4  1998/09/13 21:31:12  dbyrne
% Updated to elminate global variables and add multivariables.
%
% Revision 1.2  1998/09/09 15:04:29  dbyrne
% Eliminating all global variables.
%
% Revision 1.1  1998/05/17 14:18:06  dbyrne
% *** empty log message ***
%
% Revision 1.1.1.1  1997/09/22 14:13:54  tom
% Imported Matlab GUI sources to CVS
%

StartTime = max(Time(1), ranges(4,1));
EndTime = min(Time(2), ranges(4,2));

YEAR = floor(StartTime);

if isleap(YEAR)
  decday = 1.0/366.0;
  MidMonth = [ 15 46 75 106 136 167 197 228 259 289 320 350 400];
  MonthLastDay = [31 60 91 121 152 182 213 244 274 305 335 400];
else
  decday = 1.0/365.0;
  MidMonth = [ 15 46 74 105 135 166 196 227 258 288 319 349 400];
  MonthLastDay = [31 59 90 120 151 181 212 243 273 304 334 400];
end

MidMonth = MidMonth - 1;

StartDay = (StartTime - YEAR) / decday;

iMonth = 1;

%while MidMonth(iMonth) > StartDay
% gm code
while StartDay > MonthLastDay(iMonth)
  % end gm code
  iMonth = iMonth + 1;
end
if iMonth >= 13
  iMonth = 1;
  YEAR = YEAR + 1;
end
times = [];
Pass_Times = [];

times(1) = YEAR + MidMonth(iMonth) * decday;
yearday = (times(1) - floor(times(1))) / decday + 1; 
hour = (yearday - floor(yearday)) * 24.0;
minute = (hour - floor(hour)) * 60.0;
Pass_Times = [ floor(times(1)), floor(yearday), floor(hour), minute]; 
day_cnt = 1;
timecheck = times(1);
while timecheck < EndTime
  if day_cnt > 1
    times(day_cnt) = timecheck;
    yearday = (times(day_cnt) - floor(times(day_cnt))) / decday + 1; 
    hour = (yearday - floor(yearday)) * 24.0;
    minute = (hour - floor(hour)) * 60.0;
    Pass_Times = [ Pass_Times; floor(times(day_cnt)), floor(yearday), ...
	  floor(hour), minute]; 
  end
  day_cnt = day_cnt + 1;
  iMonth = iMonth + 1;
  if iMonth > 12
    iMonth = 1;
    YEAR = YEAR + 1;
  end
  timecheck = YEAR + MidMonth(iMonth) * decday;
end
i = find(times >= StartTime & times <= EndTime);
times = times(i);
Pass_Times = Pass_Times(i,:);
return
