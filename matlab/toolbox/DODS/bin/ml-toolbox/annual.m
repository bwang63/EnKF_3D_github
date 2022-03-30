function [times, Pass_Times] = annual(TimeRange, ranges)
%
%  Annual   --- This function will generate a time (year and fraction of a year) at
%               the middle of every year in an interval. Arguments passed in are:
%
%  TimeRange  - The time range of the data set.
%  ranges     - User selected time range.
%
%  The returned arguments are:
%
%  times      - The time in years (and fractions, see note below) for all hits.
%  Pass_Times - This is the vector of time with the year, day
%               of each hit. Note that the day here is the calendar day; i.e.,
%               the value that would be obtained by taking the fraction of the
%               year, multiplying by 365 (or 366 for a leap year) AND adding 1.
%
%--------------------------------------------------------------------------------
%

% The preceding empty line is important.
% $Log: annual.m,v $
% Revision 1.1  2000/05/31 23:11:46  dbyrne
% *** empty log message ***
%
% Revision 1.1  2000/05/31 22:57:19  root
% *** empty log message ***
%
% Revision 1.1  2000/05/31 21:36:46  root
% *** empty log message ***
%
% Revision 1.3  2000/03/28 18:53:03  root
% *** empty log message ***
%
% Revision 1.3  2000/01/12 18:51:14  kwoklin
% Second checkup.  klee
%
% Revision 1.2  1999/10/28 18:50:36  dbyrne
%
%
% Fixed some minor bugs -- dbyrne 99/10/28
%
% Revision 1.2  1999/10/28 18:41:48  root
% *** empty log message ***
%
% Revision 1.1  1999/09/02 18:32:56  root
% *** empty log message ***
%
% Revision 1.1  1999/06/01 07:10:26  dbyrne
%
%
% Moved up from kleedata/
%
% Revision 1.2  1999/05/28 17:32:48  kwoklin
% Add all globec datasets. Fix depth representation for all globec datasets
% and nbneer dataset. Fix frontal display for htn and glkfront. Make use of
% getjgsta for all jgofs datasets. Point usgsmbay to new server. Point htn,
% glk, fth and prevu to new FF server.                                 klee
%

% $Id: annual.m,v 1.1 2000/05/31 23:11:46 dbyrne Exp $
% klee     05/03/99

times = []; Pass_Times = [];
StartTime = max(TimeRange(1), ranges(4,1));
LastTime = min(TimeRange(2), ranges(4,2));

LastYear = floor(LastTime);
if rem(LastYear,4) ~= 0 | LastYear == 1900
  MidYear = 182.5;
  DaysInYear = 365.0;                % This is not a leapyear.
else
  MidYear = 183;
  DaysInYear = 366.0;                % This is a leapyear.
end

More = 1;
times = [];
Pass_Times = [];

while More == 1
  StartYear = floor(StartTime);
  if rem(StartYear,4) ~= 0 | StartYear == 1900
    MidYear = 182.5; DaysInYear = 365.0;
  else
    MidYear = 183; DaysInYear = 366.0;
  end
  EndYear = floor(StartYear) + 1;

  if EndYear >= LastTime   %all in the same year
    More = 0;
  else
    StartTime = EndYear;
  end

  times = [times; StartYear+MidYear/DaysInYear];
  Pass_Times = [Pass_Times; StartYear, floor(MidYear)];
end
