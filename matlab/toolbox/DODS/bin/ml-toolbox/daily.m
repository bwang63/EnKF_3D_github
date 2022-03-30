function [times, Pass_Times] = daily(Time, InTime, ranges)

%
%  Assume the existence of a series of events, starting at some 
%  time, and recurring at some regular interval. This function 
%  returns the times of those events of the series that occur 
%  between two input boundaries. Of course, since the events we 
%  are talking about are data events in some dataset, the input
%  boundaries are further constrained by the dataset bounds 
%  themselves.
%
%  The returned times are provided in two different formats, for 
%  convenience only.
%
%  The input times are passed as elements of a single array, to 
%  accommodate future extensions.
%
%  Time -      A vector containing two values, the start time and 
%              stop time of the desired interval, expressed in 
%              decimal years.
%
%  InTime(1) - IntervalTime. This is the interval at which the 
%              times repeat, in decimal hours.
%
%  InTime(2) - MidTime. Is the first midpoint in time of an 
%              interval in the current year; i.e., relative to 1
%              January. For example, suppose IntervalTime is 120 hours
%              (5 days) and MidTime is 48 hours.  The midpoint of the
%              first interval in the year would correspond to midnight
%              of the second day or 0 hours of the third day. For
%              these values of IntervalTime and MidTime, suppose that
%              ranges(4,1) = 1997.0415 (non-leap year) ==> 3.45 hours
%              on 16 January 1997. This would be yearday 16.1475, but
%              if the fraction of ranges(4,1) were converted to days
%              it would be 15.1475 days since 0 hours of 1 January
%              correspondes to 0.0 fractions of a day in the
%              year. Then the first point in the time series larger
%              than ranges(4,1) is year=1997.0468 or yearday = 18.
%              This inventory counter is reset at the beginning of
%              each year. If MidTime is null (NaN), RefTime is used 
%              instead.
%
%  InTime(3) - RefTime. If MidTime is null (NaN), the series is assumed 
%              to have begun at RefTime, specified in decimal years. If 
%              both MidTime and RefTime are specified, MidTime is used, 
%              and RefTime is ignored.
%
%
%  The function return values are: 
%
%  times     - A vector containing the times in decimal years of each 
%              event occurring between the input bounds (constrained by 
%              the dataset bounds).
%
%  Pass_Times -This is a 2-d array containing the year, day, hour and 
%              minute of each hit. Note that the day here is the calendar 
%              day; i.e. the value that would be obtained by taking the 
%              fraction of the year, multiplying by 365 (or 366 for a leap 
%              year) AND adding 1.
%
% Note Jan 1, year day 001 is decimal day 0. 
% January 1 starts at midnight on the 365/366th day of the previous year.
% Yearday 0 starts at midnight on the 365/366th day of the previous year.
% Need two times, the one that Deirdre uses in the interface, argout1, 
% (year here) and the one that is used to specify the JPL day, argout2
% (yearday here).
%

% The preceding empty line is important.
%
% $Id: daily.m,v 1.1 2000/05/31 23:11:47 dbyrne Exp $

% $Log: daily.m,v $
% Revision 1.1  2000/05/31 23:11:47  dbyrne
% *** empty log message ***
%
% Revision 1.1  2000/05/31 22:57:19  root
% *** empty log message ***
%
% Revision 1.1  2000/05/31 21:40:37  root
% *** empty log message ***
%
% Revision 1.6  1999/09/02 18:27:23  root
% *** empty log message ***
%
% Revision 1.12  1999/05/13 03:09:54  dbyrne
%
%
% Added Acknowledge and Data_Use_Policy to archive.m.  Fixed getxxx functions
% to use dodsmsg instead of stdout for errors/info.  Made ChangeLog so that it's
% in Emacs format.  All changes for release 3.0.0 -- dbyrne 99/05/12
%
% Revision 1.5  1999/03/04 13:13:26  root
% All changes since AGU week.
%
% Revision 1.10  1998/11/18 19:57:01  dbyrne
%
%
% Second try.  Bug fixes to jpl pathfinder data, changed names of
% Reynolds datasets to clarify that one is a climatology and one is not.
%
% Revision 1.4  1998/11/18 14:05:41  root
% *** empty log message ***
%
% Revision 1.3  1998/11/05 16:01:51  root
% Changed LonVector and LatVector to be used if no Lon returned and tried the update function.
% DataScale and DataNull should now be optional!
%
% Revision 1.7  1998/09/13 21:31:08  dbyrne
% Updated to elminate global variables and add multivariables.
%
% Revision 1.2  1998/09/09 15:04:27  dbyrne
% Eliminating all global variables.
%
% Revision 1.1  1998/05/17 14:18:03  dbyrne
% *** empty log message ***
%
% Revision 1.4  1997/10/09 22:05:57  jimg
% Merged changes from 2.14c
%
% Revision 1.3  1997/10/04 00:33:31  jimg
% Release 2.14c fixes
%
% Revision 1.2  1997/10/01 23:02:30  tom
% added documentation
%
% Revision 1.1.1.1  1997/09/22 14:13:54  tom
% Imported Matlab GUI sources to CVS
%

StartTime = max(Time(1), ranges(4,1));
EndTime = min(Time(2), ranges(4,2));
IntervalTime = InTime(1);
MidTime = InTime(2);
RefTime = InTime(3);

StartTimeYear = floor(StartTime);
if isleap(StartTime)
   decday = 1.0 / 366.0;
else
   decday = 1.0 / 365.0;
end

% Convert IntervalTime and MidTime from hours to days.
   IntervalDays = IntervalTime / 24.0;
   MTDays = MidTime / 24.0;


if isnan(MidTime)
%
%  If the series references a specific time, instead of the beginning
%  of the current year, then calculate the first event after StartTime,
%  counting from RefTime
%
   if StartTimeYear > RefTime
      noffset = year2day( StartTime, RefTime );
      RefDay = ceil( noffset / IntervalDays ) * IntervalDays;
      yearday = RefDay - noffset;
      year = StartTime + yearday * decday;
   else
      noffset = year2day( StartTime, RefTime );
      yearday = ceil( noffset / IntervalDays ) * IntervalDays;
      year = RefTime + yearday * decday;
   end
else
%
%  Referring to the StartTimeYear, calculate the number of intervals 
%  between MidTime and the first event after the StartTime.
%
   noffset = (StartTime - StartTimeYear) / decday; 
   noffset = (noffset - MTDays); 
   noffset = ceil(noffset / IntervalDays);

   yearday = noffset * IntervalDays + MTDays + 1;
   year = StartTimeYear + (yearday - 1.0) * decday;
end

%  
%  Now generate the series, up to EndTime. If we go over
%  a year boundary, increment the year counter.
%  

day_cnt = 0;
times = [];
Pass_Times = [];
while year < EndTime

   day_cnt = day_cnt + 1;
   times(day_cnt) = year;

%  Calculate the yearday, hour and minutes

   YearInt = floor(year);
   calday = (year - YearInt) / decday;
   YearDayInt = floor(calday);
   hour = (calday - YearDayInt) * 24.0;
   HourInt = floor(hour);
   minute = (hour - HourInt) * 60.0;
   MinuteInt = round(minute);
   if MinuteInt >= 60
      HourInt = HourInt + 1;
      MinuteInt = MinuteInt - 60;
   end
   if HourInt >= 24
      YearDayInt = YearDayInt + 1;
      HourInt = HourInt - 24;
   end
  
   Pass_Times = [ Pass_Times; YearInt, (YearDayInt+1), HourInt, MinuteInt ]; 

   if floor(year) < floor( year + IntervalDays * decday )

   % Incrementing the 'year' variable with 'IntervalDays * decday'
   % will work fine unless we are switching between a leap year 
   % and a non-leap year (or vice-versa).

      if isleap(year) 
         frac = ceil(year) - year;
         IntervalFrac = IntervalDays - frac / decday;
         decday = 1.0 / 365.0;
         year = ceil(year) + IntervalFrac * decday;
      elseif isleap(year + 1)
         frac = ceil(year) - year;
         IntervalFrac = IntervalDays - frac / decday;
         decday = 1.0 / 366.0;
         year = ceil(year) + IntervalFrac * decday;
      else
         year = year + IntervalDays * decday;
      end
   else
      year = year + IntervalDays * decday;
   end
end
i = find(times >= StartTime & times <= EndTime);
times = times(i);
times = times(:);
Pass_Times = Pass_Times(i,:);
return

