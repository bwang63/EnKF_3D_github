function [locate_x, locate_y, depths, times, URLinfo, urllist, ...
      url] = climcat(CS, TimeRange, get_ranges)

times = [];  
locate_x = [];
locate_y = [];
depths = [];
URLinfo = []; 
url = ''; 
urllist = '';
date = [];
DODS_URL = '';
DODS_Decimal_Year = '';

% find valid time range for request
timelimit(1) = max(TimeRange(1), get_ranges(4,1));
timelimit(2) = min(TimeRange(2), get_ranges(4,2));

% find the number of years we must span
year(1) = floor(timelimit(1));
year(2) = floor(timelimit(2));

cat_times = [];
cat_years = [];
if (year(1) == year(2))
  cat_times = [timelimit - year(1)];
  cat_years = year(1);
else
  clear eps % use built-in matlab function eps
  cat_times = [timelimit(1)-year(1) 1-eps]; 
  cat_years = year(1);
  for k = year(1)+1:year(2)-1
    cat_times = [cat_times; 0 1-eps];
    cat_years = [cat_years; k];
  end
  cat_times = [cat_times; [0 timelimit(2)-year(2)]];
  cat_years = [cat_years; year(2)];
end
% note: climatologies all have the year set to "1", not "0"
cat_times = cat_times + 1;

for k = 1:size(cat_times,1)
  cs_url = [CS '?' 'DODS_Decimal_Year(climatology),DODS_URL&', ...
	'date("' num2str(cat_times(k,1),9) '",', ...
	'"', num2str(cat_times(k,2),9) '")'];
  loaddods('-e',cs_url)
  if dods_err == 1
    dods_err_msg = sprintf('%s\n%s', ...
	'           >>>>>>>> ERROR IN CATALOG ACQUISITION <<<<<<<<', ...
	dods_err_msg);
    dodsmsg(dods_err_msg)
    return
  end
  if k == 1
    url = cs_url;
    urllist = mkstrmat(DODS_URL);
    % convert times from year 1 to year of user request
    times = str2num(DODS_Decimal_Year)-1+cat_years(k);
  else
    url = sprintf('%s\n%s', url, cs_url);
    tmpstr = mkstrmat(DODS_URL);
    if ~isempty(tmpstr)
      urllist = str2mat(urllist,tmpstr);
    end
    % convert times from year 1 to year of user request
    times = [times; str2num(DODS_Decimal_Year)-1+cat_years(k)];
  end
end
if any(size(url) == 0)
  url = '';
end
if any(size(urllist) == 0)
  urllist = '';
  times = [];
end
URLinfo = dy2dat(times);
return

