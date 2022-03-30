function [locate_x, locate_y, depths, times, URLinfo, urllist, url] = dycat(CS, time, ranges)
%----------------------------------------------------------------------------
%
% This function generates a time and file name for URI AVHRR images
%
% Formal parameters:
% catalog_server: URL of the catalog server.
% time: The time range of the data set.
%
% The return values are:
% times: The time in decimal years (years and fractions) for all hits.
% URLinfo: This is a matrix of time with the year, day and hour
% of each hit. Note that the day here is the calendar day.
%
%----------------------------------------------------------------------------

%
% $Log: dycat.m,v $
% Revision 1.2  2000/06/02 20:04:09  kwoklin
% Move cat server to version 1. klee
%
% Revision 1.1  2000/05/31 23:12:55  dbyrne
% *** empty log message ***
%
% Revision 1.1  2000/05/31 22:59:19  root
% *** empty log message ***
%
% Revision 1.1  2000/03/28 18:44:46  root
% New dataset files.
%
% Revision 1.1  2000/03/09 17:36:48  kwoklin
% Share one cat_m_file dycat.m.   klee
%

% $Id: dycat.m,v 1.2 2000/06/02 20:04:09 kwoklin Exp $
% Replacing URI Avhrr catalog files.   klee 03/01/2000 

URLinfo = []; 
locate_x = [];
locate_y = [];
depths = [];
times = []; 
prefix = '';
url=''; 
urllist = ''; 
DODS_URL = '';
DODS_Decimal_Year = '';

%if findstr(CS, 'htn.dat'), prefix = 'HTN_Avhrr';
%elseif findstr(CS, 'glk.dat'), prefix = 'GLK_Avhrr';
%elseif findstr(CS, 'fth.dat'), prefix = 'FTH_Avhrr';
%elseif findstr(CS, 'avhrr.dat'), prefix = 'URI_Avhrr';
%end

% Get beginning and ending of time interval.
StartTime = max(time(1), ranges(4,1));
LastTime = min(time(2), ranges(4,2));

Constraint = [ 'DODS_URL,DODS_Decimal_Year(time)&date("',...
               num2str(StartTime,9), '","',num2str(LastTime,9),'")'];
URL = [CS,'?',Constraint];
url = URL;
loaddods('-e', url);
if dods_err == 1
  dods_err_msg = sprintf('%s\n%s', ...
      '           >>>>>>>> ERROR IN CATALOG ACQUISITION <<<<<<<<', ...
      dods_err_msg);
  dodsmsg(dods_err_msg)
  return
end

%deref string vector DODS_URL
urllist = mkstrmat(DODS_URL);

%deref string vector DODS_Decimal_Year
times = derefdat(DODS_Decimal_Year);
% for some reason server returns more than valid times.
% Subset:
i = find(times >= StartTime & times <= LastTime);
times = times(i);
urllist = urllist(i,:);
URLinfo = times;
return;
