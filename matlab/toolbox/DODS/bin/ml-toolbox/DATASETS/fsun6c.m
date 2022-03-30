function [locate_x, locate_y, depths, times, URLinfo, urllist, ...
      url] = fsun6c(CatalogServer, Time, ranges)

%----------------------------------------------------------------------------
%
% Consult the nscat30 catalog server to find images that fall within the time
% range given by the user.
%
% Formal parameters:
% catalog_server: URL of the catalog server.
% time: The time range of the data set.
%
% The return values are:
% times: The time in years (and fractions, see note below) for all hits.
% URLinfo: This is a matrix of time with the year and day
% url: dummy return value to satisfy cat function type signature.
%
%
%   17 April 1999, pdh
%----------------------------------------------------------------------------

% The preceeding blank line is important for cvs.
% $Id: fsun6c.m,v 1.2 2000/06/13 19:11:08 dbyrne Exp $
%

% $Log: fsun6c.m,v $
% Revision 1.2  2000/06/13 19:11:08  dbyrne
%
%
% fixed bug in ending time ... -- dbyrne 00/06/13
%
% Revision 1.2  2000/06/12 17:41:44  root
% *** empty log message ***
%
% Revision 1.1  2000/05/31 22:59:20  root
% *** empty log message ***
%
% Revision 1.3  2000/04/12 01:18:20  root
% All fsun datasets now use getrectf, and only 2 cat_m_files in use.
%
% Revision 1.2  1999/11/05 22:05:57  root
% Fixed bad return from CS -- was returning zeroes in day,hour,year when
% no data were actually available. -- dbyrne 99/11/05
%
% Revision 1.1  1999/09/02 18:33:01  root
% *** empty log message ***
%
% Revision 1.3  1999/06/29 16:51:49  kwoklin
% Quick fixes on some cat files.           klee
%
% Revision 1.2  1999/05/27 13:37:36  paul
% initialize urlmat dodsdates (global variables)
%
% Revision 1.1  1999/05/21 16:55:50  paul
% Initial version....phemenway
%


% Initialize variables.

locate_x = [];
locate_y = [];
depths = [];
times = [];
URLinfo = [];
urllist = ''; url = '';
DODS_URL = '';
DODS_Date = '';

% Get Starting and ending of time interval.
StartTime = max(Time(1), ranges(4,1));
LastTime = min(Time(2), ranges(4,2));

Constraint = [ 'DODS_URL,DODS_Decimal_Year(time)&date("' ...
      num2str(StartTime,9), '","', num2str(LastTime,9), '")' ];

url = [CatalogServer '?' Constraint];
loaddods('-e', url)
if dods_err == 1
  dods_err_msg = sprintf('%s\n%s', ...
      '           >>>>>>>> ERROR IN DODS CATALOG ACQUISITION <<<<<<<<', ...
      dods_err_msg);
  dodsmsg(dods_err_msg)
  return
end

urllist = mkstrmat(DODS_URL);
%deref string vector DODS_Decimal_Year
times = derefdat(DODS_Decimal_Year);
i = find(times > ranges(4,1) & times < ranges(4,2));
urllist = urllist(i,:);
times = times(i);
URLinfo = times;

return
