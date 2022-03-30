function [locate_x, locate_y, depths, times, URLinfo, urllist, url] = pathcat(catalog_server, time, ranges)
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
% URLinfo: This is a matrix of time with the year, day and hour
% of each hit. Note that the day here is the calendar day.
%
%----------------------------------------------------------------------------

% Get beginning and ending of time interval.
start_time = max(time(1), ranges(4,1));
end_time = min(time(2), ranges(4,2));

start_year = floor(start_time);
start_day = floor(year2day(start_time, start_year)+1);

end_year = floor(end_time);
end_day = floor(year2day(end_time, end_year)+1);

start_hour = year2day(start_time,start_year)+1 - start_day;
end_hour   = year2day(end_time,end_year)+1 - end_day;
start_hour = floor(start_hour * 24);
end_hour   = ceil(end_hour * 24);

% The JPL Pathfinder dataset contains two images per day, one for the
% ascending pass and one for the descending. Thus, to query the catalog
% server we need to know the year, day and time to within 1/2 a day.

vars = [ 'ptime,file_url' ];

% Column indices of `vals' matrix
year = 1;
day  = 2;
hour = 3;
% The file url is at 4:n

% initialize returning variables
url = '';
urllist = '';
URLinfo = [];
locate_x = [];
locate_y = [];
depths = [];
times = [];

% Build constraint expression
start_time = sprintf('%04d%03d%02d', start_year, start_day, start_hour);
end_time   = sprintf('%04d%03d%02d', end_year, end_day, end_hour);
constraint = [ vars '&ptime>=' start_time '&ptime<=' end_time ];

url = [catalog_server '?' constraint];
% Clear a variable for the loaddods success test.
% *** initialize each of the variables in vars with null value
[var,ovars] = strtok(vars,',');	
while ~isempty(var)
  eval([var '= [];']);
  [var,ovars] = strtok(ovars,',');	
end  

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

% process variables
[var,vars] = strtok(vars,',');
URLinfo = [];
urllist = [];
while (~isempty(var))
  tmpvalues = URLinfo;
  if strcmp(var,'file_url')
    urllist = file_url;
%    % find the double quote characters, the url strings are
%     % between those
%     i = findstr(file_url,setstr(34));
%
%     if isempty(i)
%       return;
%     else
%     % Pull out the url's and place them in a matrix
%       file_url = strrep(file_url,' ','');
%       file_url = strrep(file_url,'"','');
%       urllist = mkstrmat(file_url);
%       
%     end
   elseif strcmp(var,'ptime')
     % ptime is returned as a single number, but we must
     % split it up into hr, day, etc.
     % Column indices of `vals' matrix
     if eval(var) ~= 0  % added for void value return  klee 07/22/99
       year = 1;
       day  = 2;
       hour = 3;
       URLinfo = zeros(size(ptime,1),3);
       % get the year
       URLinfo(:,1) = floor(ptime/1e5);
       % now subtract off the year;
       ptime = (ptime - floor(ptime/1e5)*1e5);
       % get the day
       URLinfo(:,2) = floor(ptime/1e2);
       % now subtract off the day
       ptime = ptime - floor(ptime/1e2)*1e2;
       % the hour
       URLinfo(:,3) = ptime;
     else
       URLinfo = tmpvalues;
     end
  else
     % We're ignoring other variables right now.
     dodsmsg([ 'Warning from pathcat: Ignoring variable ' var ]);
  end
  % Move onto the next variable if any
  [var, vars] = strtok(vars, ',');
end

% if we got this far there are some URLs/times:
times = day2year(URLinfo(:,day)-1 + URLinfo(:,hour)/24, URLinfo(:,year));

return;
