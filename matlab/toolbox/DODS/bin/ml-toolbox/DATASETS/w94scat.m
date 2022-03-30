function [locate_x, locate_y, depths, times, URLinfo, urllist, ...
      url] = w94scat(CatalogServer, Time, ranges)
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
depths = [0, 10, 20, 30, 50, 75, 100, 125, 150, 200, 250, 300, 400, ...
      500, 600, 700, 800, 900, 1000, 1100, 1200, 1300, 1400 1500, ...
      1750, 2000, 2500, 3000, 3500, 4000, 4500, 5000, 5500];
times  = [];
locate_x = [];
locate_y = [];
URLinfo = [];
urllist = '';
url = [CatalogServer '?ZAXLEVITUS'];
% if we really wanted to make the request ... :
% depths = loaddods(url);

StartTime = max(Time(1), ranges(4,1));
EndTime = min(Time(2), ranges(4,2));
YEAR = floor(StartTime);
if ~isleap(YEAR)
  decday = 1.0/365.0;                % This is not a leapyear.
  midseason = [46 135 227 319];
  seasonlastday =  [90 181 273 400];
else
  decday = 1.0/366.0;                % This is a leapyear.
  midseason = [46 136 228 320];
  seasonlastday =  [90 182 274 400];
end

midseason = midseason - 1;
StartDay = (StartTime - YEAR) / decday;

iseason = 1;

while StartDay > seasonlastday(iseason)
  iseason = iseason + 1;
end
if iseason > length(midseason)
  iseason = 1;
  YEAR = YEAR + 1;
end

tmptime = [];
URLinfo = [];
tmptime(1) = (YEAR + midseason(iseason) * decday);
season_no = iseason-1;
day_cnt = 1;
timecheck = tmptime(1);
while timecheck < EndTime
  if day_cnt > 1
    tmptime(day_cnt) = timecheck;
    season_no(day_cnt) = iseason-1;
  end
  day_cnt = day_cnt + 1;
  iseason = iseason + 1;
  if iseason > length(midseason)
    iseason = 1;
    YEAR = YEAR + 1;
  end
  timecheck = YEAR + midseason(iseason) * decday;
end
i = find(tmptime >= StartTime & tmptime <= EndTime);
tmptime = tmptime(i);
season_no = season_no(i);
d = find(depths >= ranges(3,1) & depths <= ranges(3,2))-1;
n = length(d);
k = 1;
for j = 1:length(season_no)
  for i = 1:n
    URLinfo(k,:) = [season_no(j) d(i) d(i) depths(d(i)+1)];
    times(k) = tmptime(j);
    k = k+1;
  end
end
depths = depths(d+1);
return
