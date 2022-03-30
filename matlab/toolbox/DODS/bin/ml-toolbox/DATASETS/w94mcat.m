function [locate_x, locate_y, depths, times, urlinfolist, urllist, ...
      url] = w94mcat(CatalogServer, Time, ranges)
%
%  Time       - The time range of the data set.
%
%  The returned arguments are:
%
%  times      - The time in years (and fractions, see note below) for all hits.
%--------------------------------------------------------------------------------
%

% The preceding empty line is important.

% predefined Levitus depths for Ferret.
% Faking this because it seems very silly to issue an http
% request for information that does not actually change.  However,
% we do provide the actual URL for sticklers.
depths = [0, 10, 20, 30, 50, 75, 100, 125, 150, 200, 250, 300, ...
      400, 500, 600, 700, 800, 900, 1000];
times  = [];
locate_x = [];
locate_y = [];
urlinfolist = [];
urllist = '';
url = [CatalogServer '?ZAXLEVIT19'];
% if we really wanted to make the request ... :
% depths = loaddods(url);

StartTime = max(Time(1), ranges(4,1));
EndTime = min(Time(2), ranges(4,2));
YEAR = floor(StartTime);
if ~isleap(YEAR)
  decday = 1.0/365.0;                % This is not a leapyear.
  MidMonth = [ 15 46 74 105 135 166 196 227 258 288 319 349 400];
  % gm code
  MonthLastDay = [31 59 90 120 151 181 212 243 273 304 334 400];
  % end gm code
else
  decday = 1.0/366.0;                % This is a leapyear.
  MidMonth = [ 15 46 75 106 136 167 197 228 259 289 320 350 400];
  % gm code
  MonthLastDay = [31 60 91 121 152 182 213 244 274 305 335 400];
  % end gm code
end

MidMonth = MidMonth - 1;
StartDay = (StartTime - YEAR) / decday;

iMonth = 1;

while StartDay > MonthLastDay(iMonth)
  % end gm code
  iMonth = iMonth + 1;
end
if iMonth > length(MidMonth)
  iMonth = 1;
  YEAR = YEAR + 1;
end

tmptime = [];
urlinfolist = [];
tmptime(1) = (YEAR + MidMonth(iMonth) * decday);
month_no = iMonth-1;
day_cnt = 1;
timecheck = tmptime(1);
while timecheck < EndTime
  if day_cnt > 1
    tmptime(day_cnt) = timecheck;
    month_no(day_cnt) = iMonth-1;
  end
  day_cnt = day_cnt + 1;
  iMonth = iMonth + 1;
  if iMonth > length(MidMonth)
    iMonth = 1;
    YEAR = YEAR + 1;
  end
  timecheck = YEAR + MidMonth(iMonth) * decday;
end
i = find(tmptime >= StartTime & tmptime <= EndTime);
tmptime = tmptime(i);
month_no = month_no(i);
d = find(depths >= ranges(3,1) & depths <= ranges(3,2))-1;
n = length(d);
k = 1;
for j = 1:length(month_no)
  for i = 1:n
    urlinfolist(k,:) = [month_no(j) d(i) d(i) depths(d(i)+1)];
    times(k) = tmptime(j);
    k = k+1;
  end
end
depths = depths(d+1);
return
