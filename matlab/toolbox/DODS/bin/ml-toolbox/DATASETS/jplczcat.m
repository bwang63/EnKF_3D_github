function [locate_x, locate_y, depths, times, urlinfo, urllist, url] = ...
    jplczcat(catalog_server, time, ranges)

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

% The JPL temporary czcs dataset contains one image per month

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
%       server.  However that is inflexibly-coded in jplczurl.m for now.

% initialize returning variables
urllist = '';
url = '';
urlinfo = [];
times = [];
locate_x = [];
locate_y = [];
depths = [];

% If the request spans two years we must break it up into N requests, one for
% each calendar year within the request.

% Handle single-year queries separately
if (start_year == end_year)
  [vals, url] = qjplczct(catalog_server, vars, start_year, start_month, ...
      end_month);
else
  % Query the CS about the first year.
  [vals, url] = qjplczct(catalog_server, vars, start_year, start_month, 12);
  % Query about the middle years.
  for k = start_year + 1 : end_year - 1
    vals = [vals; qjplczct(catalog_server, vars, k, 1, 12)];
  end
  % Query about the last year.
  vals = [vals; qjplczct(catalog_server, vars, end_year, 1, end_month)];
end

if isempty(vals)
  return;
end

% Move the results into the return variables
for k = 1:size(vals,1);
  urlinfo = [ urlinfo; vals(k,year), vals(k,month)];
  % year plus fraction of year given month and then add
  % to get to the middle of the month.
  pass_time = vals(k,year) + ((vals(k,month) - 1)/12) + 1/24;
  times = [times pass_time];
end
% subselect only the valid passes
i = find(times >= start_time & times <= end_time);
times = times(i);
urlinfo = urlinfo(i,:);

return;

function [values, url] = qjplczct(server, vars, yr, s_month, e_month)
%
% Query the czcs catalog server. This function is designed to be
% called from a loop so that multi-year queries can be broken up into
% multiple calls.
%
% Parameters:
% server: URL of the catalog server.
% vars: String containing names of variables to retrieve. Used verbatim in
% the projection part of the constraint expression. This should be a comma
% separated list of variable names, with no spaces. If there is only one
% variable, then the comma should be omitted.
% yr: Year for the constraint.
% s_day, e_day: Start and end day of the query.
%

% Build the constraint
constraint = [ vars '&year=' int2str(yr) ];
values = []; url = [];
if (s_month == e_month)
    constraint = [ constraint '&month=' int2str(s_month) ];
else
    constraint = [ constraint '&month>=' int2str(s_month) '&month<=' ...
	      int2str(e_month) ];
end

% Build the url
url = [server '?' constraint];

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
values = [];
while (~isempty(var))
  if ~isempty(eval(var))
  if ~strcmp(eval(var), setstr(10))
    if isstr(eval(var))
      if strcmp(deblank(var),'year') | strcmp(deblank(var),'month')
	var = eval(var);
	% find the newline characters
	i = findstr(var,setstr(10));
	i = [0 i];
	for j = 1:length(i)-1
	  value(j) = str2num(var(i(j)+1:i(j+1)-1));
	end
	values = [values, value(:)];
      end
    else % whatever is in var is not a string
      values = [values, eval(var)];
    end
  end
  end
  [var, vars] = strtok(vars, ',');
end    
return;



