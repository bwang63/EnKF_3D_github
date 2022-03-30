function [locate_x, locate_y, depths, times, urlinfolist, urllist, ...
      url] = w94acat(CatalogServer, Time, ranges)

%
%  Time       - The time range of the data set.
%
%  The returned arguments are:
%
%  times      - The time in years (and fractions, see note below) for all hits.
%--------------------------------------------------------------------------------
%

% The preceding empty line is important.

% predefined Levitus depths for Ferret.  Note that original
% Levitus dataset has 33 levels! dbyrne, 98/11/16.  I am
% faking this because it seems very silly to issue an http
% request for information that does not actually change.  However,
% we do provide the actual URL for sticklers.
depths = [0, 10, 20, 30, 50, 75, 100, 125, 150, 200, 250, 300, 400, ...
      500, 600, 700, 800, 900, 1000, 1100, 1200, 1300, 1400 1500, ...
      1750, 2000, 2500, 3000, 3500, 4000, 4500, 5000, 5500];
times  = [];
locate_x = [];
locate_y = [];
urlinfolist = [];
urllist = '';
url = [CatalogServer '?ZAXLEVITUS'];
% if we really wanted to make the request ... :
% depths = loaddods(url);

StartTime = max(Time(1), ranges(4,1));
EndTime = min(Time(2), ranges(4,2));
YEAR = floor(StartTime);
i = 1;
tmptime = floor(StartTime)+0.5;
while YEAR < EndTime
  i = i+1;
  YEAR = YEAR+1;
  tmptime(i) = YEAR+0.5;
end
i = find(tmptime >= StartTime & tmptime <= EndTime);
tmptime = tmptime(i);
d = find(depths >= ranges(3,1) & depths <= ranges(3,2))-1;
n = length(d);
k = 1;
for j = 1:length(tmptime)
  for i = 1:n
    % nan spacer makes columns match the monthly catalogue output!
    urlinfolist(k,:) = [nan d(i) d(i) depths(d(i)+1)];
    times(k) = tmptime(j);
    k = k+1;
  end
end
times = times(:);
depths = depths(d+1);
return
