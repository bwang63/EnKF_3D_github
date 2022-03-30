function [locate_x, locate_y, depths, times, urlinfo, urllist, url] = ...
    ssm35cat(catalog_server, time, ranges)

%----------------------------------------------------------------------------
%
% This function generates a time and satellite type for each satellite pass
% in the specified interval.
%
% Formal parameters:
% catalog_server: URL of the catalog server.
% time: The time range of the data set.
%
% The return values are:
% times: The time in years (and fractions, see note below) for all hits.
% urlinfo: This is a matrix of time with the year and month.
%
%----------------------------------------------------------------------------

% Get beginning and ending of time interval.
start_time = max(time(1), ranges(4,1));
end_time = min(time(2), ranges(4,2));

% The JPL SSMI level 3.5 dataset contains one image per month.

% Find starting year and starting month, months numbered 1 thru 12
start_year  = floor(start_time);
start_month = start_time - start_year;
start_month = start_month * 12;
start_month = floor(start_month + 1);

% Find ending year and ending month
end_year  = floor(end_time);
end_month = end_time - end_year;
end_month = end_month * 12;
end_month = floor(end_month + 1);

vars = [ 'year,month'];
year = 1;				% Column indices of `vals' matrix
month = 2;

% Note: At some point, the url should get served by the catalog
%       server.  However that is inflexibly-coded in ssmi35url.m for now.

% initialize returning variables
url = ''; urllist = '';
urlinfo = [];
times = [];
locate_x = [];
locate_y = [];
depths = [];
% If the request spans two years we must break it up into N requests, one for
% each calendar year within the request.

% Handle single-year queries separately
values = [];
URLs = '';
cat_months = [];
cat_year = [];
if (start_year == end_year)
  cat_months = [start_month end_month];
  cat_year = [start_year];
else
  cat_months = [start_month 12]; 
  cat_year = start_year;
  for k = start_year + 1 : end_year - 1
    cat_months = [cat_months; [1 12]];
    cat_year = [cat_year; k];
  end
  cat_months = [cat_months; [1 end_month]];
  cat_year = [cat_year; end_year];
end

for k = 1:length(cat_year)
  % Build the constraint
  constraint = [ vars '&year=' int2str(cat_year(k)) ];
  vals = []; url = '';
  if (cat_months(k,1) == cat_months(k,2))
    constraint = [ constraint '&month=' int2str(cat_months(k,1)) ];
  else
    constraint = [ constraint '&month>=' int2str(cat_months(k,1)) ...
	  '&month<=' int2str(cat_months(k,2)) ];
  end
  
  % Build the url
  url = [deblank(catalog_server) '?' constraint];
  
  % Clear a variable for the loaddods success test.
  % *** initialize each of the variables in vars with null value
  [var,ovars] = strtok(vars,',');	
  while ~isempty(var)
    eval([var '= [];']);
    [var,ovars] = strtok(ovars,',');	
  end  

  % this returns all STRINGS because it is a jgofs server.  Some (but
  % not all) of the string must be reinterpreted as numbers.
  loaddods('-e', url);
  if dods_err == 1
    dods_err_msg = sprintf('%s\n%s', ...
	'           >>>>>>>> ERROR IN CATALOG ACQUISITION <<<<<<<<', ...
	dods_err_msg);
    dodsmsg(dods_err_msg)
    return
  end

  % Look for return values; if none then exit. Note that I extract the strings
  % held in `vars' (a comma separated list with no spaces) and load the return 
  % parameter `values' with those variables. Even though loaddods loads
  % directory into Matlab, it loads into the function workspace and thus, the
  % variables (whatever they are called in the dataset) will disappear when
  % this call returns. Only the values return parameter will hold the stuff
  % retrieved by loaddods.

  % if we have returned stuff, we stick it columnwise into values
  % if we have no returned stuff, values is set to null.
  % it is safe to assume that if one variable is empty the
  % others are as well and vice versa. 
  [var,vars] = strtok(vars,',');
  while (~isempty(var))
    if ~isempty(eval(var))
      if ~strcmp(eval(var),setstr(10))
	% a quick fix for null return (empty string contains newline still)     klee
	if isstr(eval(var))
	  if strcmp(deblank(var),'year') | strcmp(deblank(var),'month')
	    var = eval(var);
	    % find the newline characters
	    i = findstr(var,setstr(10));
	    i = [0 i];
	    for j = 1:length(i)-1
	      value(j) = str2num(var(i(j)+1:i(j+1)-1));
	    end
	    vals = [vals, value(:)];
	  end
	else % whatever is in var is not a string
	  vals = [vals, eval(var)];
	end
      end
    end
    [var, vars] = strtok(vars, ',');
  end    

  if k == 1
    values = vals;
    URLs = url;
  else
    values = [values; vals];
    URLs = str2mat(URLs,url);
  end
end

if isempty(values)
  return;
end

% Move the results into the return variables
yearindex = 1;
monthindex = 2;
for k = 1:size(values,1);
  urlinfo = [ urlinfo; values(k,yearindex), values(k,monthindex)];
  % year plus fraction of year given month and then add
  % to get to the middle of the month.
  pass_time = values(k,yearindex) + ((values(k,monthindex) - 1)/12) + 1/24;
  times = [times; pass_time];
end
% subselect only the valid passes
i = find(times >= start_time & times <= end_time);
times = times(i);
urlinfo = urlinfo(i,:);
return;


