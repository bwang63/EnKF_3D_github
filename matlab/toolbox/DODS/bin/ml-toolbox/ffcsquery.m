function [locate_x, locate_y, depths, tmp_times, URLinfo, urllist, ...
      url] = ffcsquery(get_archive, CatalogServer, Time, ranges, URLinfo)

%----------------------------------------------------------------------------
%
% Consult a DODS Freeform catalog server for a multifile dataset in which
% the only difference between the datasets in different files is the time.
%
% Formal parameters:
% catalog_server: URL of the catalog server.
% time: The time range of the data set.
% ranges: the user selection ranges (LON, LAT, DEPTH, TIME) 
%
% The return values are:
% times: The time in years (and fractions, see note below) for all hits.
% URLinfo: This is a matrix of time with the year and day
% url: Constrained catalog server URL.
% URLlist: list of valid URLs returned in response to catalog query.
%
%
%   Original coded by pdh, 2 May 1999
%----------------------------------------------------------------------------

% The preceeding blank line is important for cvs.
% Initialize variables.

locate_x = [];
locate_y = [];
depths = [];
tmp_times = [];
URLinfo.axnames = [];
URLinfo.axes = [];
URLinfo.axindex = [];
URLinfo.stride = [];
URLinfo.geopos = zeros(1,4);
URLinfo.info = [];
urllist = '';
url = '';
DODS_URL = '';
DODS_Decimal_Year = '';

% Now source the archive.m file to see if there are any additional
% constraints on the file server.

if exist(get_archive) ~= 2
  dodsmsg(['Problem reading dataset metadata ' get_archive '.m'])
  return
else
  eval(get_archive)
end

% Get beginning and ending of time interval.

StartTime = max(Time(1), ranges(4,1));
LastTime = min(Time(2), ranges(4,2));

clear eps % use built-in matlab function eps
% make sure our request to the server has the same precision
prec = ceil(abs(log10(eps)))+1;

[DAS] = loaddods('-A -e', CatalogServer);
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

if exist('Additional_FileServer_Constraints')  
  Constraint = [ 'DODS_URL,DODS_Decimal_Year(' csfield '),',...
                Additional_FileServer_Constraints, '&date("' ...
      num2str(StartTime,prec) '","' num2str(LastTime,prec) '")' ];
else
  Constraint = [ 'DODS_URL,DODS_Decimal_Year(' csfield ')&date("' ...
      num2str(StartTime,prec) '","' num2str(LastTime,prec) '")' ];
end

url=[CatalogServer '?' Constraint];
loaddods('-e', url)
if dods_err == 1
  dods_err_msg = sprintf('%s\n%s', ...
      '           >>>>>>>> ERROR IN DODS CATALOG ACQUISITION <<<<<<<<', ...
      dods_err_msg);
  dodsmsg(dods_err_msg)
  return
end

% changes to use new loaddods (3.1.6)
% TEMP HACK until James fixes loaddods 00/12/11 -- dbyrne
urllist = derefurl(DODS_URL);
DODS_Decimal_Year = derefurl(DODS_Decimal_Year);
% END TEMP HACK
if ~isempty(DODS_Decimal_Year)
  tmp_times = str2num(DODS_Decimal_Year);
  % for some reason server returns more than valid times.
  % Subset them:
  i = find(tmp_times >= StartTime & tmp_times <= LastTime);
  tmp_times = tmp_times(i);
  urllist = urllist(i,:);
end
URLinfo.info = tmp_times;
return
