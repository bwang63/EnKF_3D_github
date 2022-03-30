function [locate_x, locate_y, depths, tmp_times, URLinfo, urllist, ...
      url] = climcat(get_archive, CS, TimeRange, get_ranges, URLinfo)

tmp_times = [];  
locate_x = [];
locate_y = [];
depths = [];
url = ''; 
urllist = '';
date = [];
DODS_URL = '';
DODS_Decimal_Year = '';
URLinfo.axnames = [];
URLinfo.axes = [];
URLinfo.axindex = [];
URLinfo.stride = [];
URLinfo.geopos = zeros(1,4);
URLinfo.info = [];

% find valid time range for request
timelimit(1) = max(TimeRange(1), get_ranges(4,1));
timelimit(2) = min(TimeRange(2), get_ranges(4,2));

% find the number of years we must span
year(1) = floor(timelimit(1));
year(2) = floor(timelimit(2));

cat_times = [];
cat_years = [];
clear eps % use built-in matlab function eps
% make sure our request to the server has enough precision
% to keep it from Barfing!
fuzz = eps;
precision = ceil(abs(log10(fuzz)))+1;

if (year(1) == year(2))
  cat_times = [timelimit - year(1)];
  cat_years = year(1);
else
  
  % first year
  cat_times = [timelimit(1)-year(1) 1-fuzz]; 
  cat_years = year(1);
  
  % middle years
  for k = year(1)+1:year(2)-1
    cat_times = [cat_times; 0+fuzz 1-fuzz];
    cat_years = [cat_years; k];
  end
  
  % last year
  cat_times = [cat_times; [0+fuzz timelimit(2)-year(2)]];
  cat_years = [cat_years; year(2)];
end
% note: climatologies all have the year set to "1", not "0"
cat_times = cat_times + 1;

[DAS] = loaddods('-A -e', CS);
if dods_err == 1
  dods_err_msg = sprintf('%s\n%s', ...
      '           >>>>>>>> ERROR IN DODS CATALOG DDS ACQUISITION <<<<<<<<', ...
      dods_err_msg);
  dodsmsg(dods_err_msg)
  return
end

fields = fieldnames(DAS);
sequence = find(~strcmp('global',fields));
csfield = fields{sequence};

for k = 1:size(cat_times,1)
  cs_url = [CS '?' 'DODS_Decimal_Year(' csfield '),DODS_URL&', ...
	'date("' num2str(cat_times(k,1), precision) '",', ...
	'"', num2str(cat_times(k,2), precision) '")'];
  loaddods('-e',cs_url)
  if dods_err == 1
    dods_err_msg = sprintf('%s\n%s', ...
	'           >>>>>>>> ERROR IN CATALOG ACQUISITION <<<<<<<<', ...
	dods_err_msg);
    dodsmsg(dods_err_msg)
    return
  end
  DODS_Decimal_Year = derefurl(DODS_Decimal_Year);
  if ~isempty(DODS_Decimal_Year)
    tmpstr = derefurl(DODS_URL);
    if ~isempty(tmpstr)
      urllist = strvcat(urllist,tmpstr);
    end
    tmp_times = [tmp_times; str2num(DODS_Decimal_Year)-1+cat_years(k)];
    url = sprintf('%s ', url, cs_url);
  end
end
if isempty(tmp_times)
  url = '';
  urllist = '';
else
  % strip off leading blank
  url = url(2:length(url));
end
URLinfo.info = dy2dat(tmp_times);
return

