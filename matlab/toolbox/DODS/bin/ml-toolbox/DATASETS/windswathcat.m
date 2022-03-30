function [locate_x, locate_y, depths, pass_times,csvvalues,URLinfo, urllist, ...
      url] = windswathcat(get_archive, CatalogServer, Time, ranges, CatServerVariables)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  Get the URLs in the specified time range, from the Catalog Server.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Initialize variables.  ***** WHY HAVEN'T ALL THE CS VARIABLES
% BEEN INITIALIZED HERE??? *****
%Creating string vector `DODS_URL' with 4722 elements.
%Creating vector `wvc_rows' with 4722 elements.
%Creating vector `rev_num' with 4722 elements.
%Creating vector `longitude' with 4722 elements.
%Creating vector `m_seconds' with 4722 elements.
%Creating vector `seconds' with 4722 elements.
%Creating vector `minutes' with 4722 elements.
%Creating vector `hours' with 4722 elements.
%Creating vector `day' with 4722 elements.
%Creating vector `year' with 4722 elements.
% *****
%
wvc_rows=[];
rev_num=[];
longitude=[];
m_seconds=[];
seconds=[];
minutes=[];
hours=[];
day=[];
year=[];
locate_x = [];
locate_y = [];
depths = [];
pass_times = [];
URLinfo = [];
url = '';
urllist = '';
DODS_URL = '';
DODS_Date = '';


% Initialize CatServerVariables and values:

for i=1:size(CatServerVariables,1)
eval([deblank(CatServerVariables(i,:)) '= [];'])
end
csvvalues=[];


% Get beginning and ending of time interval.

StartTime = max(Time(1), ranges(4,1));
LastTime = min(Time(2), ranges(4,2));

Constraint = [ '&date("' ...
               num2str(StartTime,9) '","' num2str(LastTime,9) '")' ];

url = [CatalogServer '?' Constraint];
loaddods('-e', url)
if dods_err == 1
  dods_err_msg = sprintf('%s\n%s', ...
      '           >>>>>>>> ERROR IN DODS CATALOG ACQUISITION <<<<<<<<', ...
      dods_err_msg);
  dodsmsg(dods_err_msg)
  return
end

urllist = derefurl(DODS_URL);
if ~isempty(urllist)
  info = [year day+(hours/24)];
  pass_times = cald2yr(info(:,2),info(:,1));
  i = find(pass_times > ranges(4,1) & pass_times < ranges(4,2));
  urllist = urllist(i,:);
  pass_times = pass_times(i);
  URLinfo.info = info(i,:);
  % pack up the CatServerVariable values for variables j.
  % pack only the values for the pass_times i within the time range.
  for j=1:size(CatServerVariables,1)
    eval(sprintf( ...
      'csvvalues=[csvvalues; %s(i)];', ...
                  deblank(CatServerVariables(j,:)) ));
  end
end
