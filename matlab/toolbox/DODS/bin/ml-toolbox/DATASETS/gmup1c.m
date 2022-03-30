function [locate_x, locate_y, depths, times, URLinfo, urllist, ...
      url] = gmup1c(CatalogServer, Time, ranges)

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
%   2 May 1999, pdh
%----------------------------------------------------------------------------

% The preceeding blank line is important for cvs.
% $Id: gmup1c.m,v 1.3 2000/09/01 18:50:56 dbyrne Exp $
%

% $Log: gmup1c.m,v $
% Revision 1.3  2000/09/01 18:50:56  dbyrne
%
%
% CHanges to use loaddods-3.1.6 -- dbyrne 00/09/01
%
% Revision 1.3  2000/09/01 18:31:28  root
% using new loaddods
%
% Revision 1.2  2000/06/02 20:22:36  root
% *** empty log message ***
%
% Revision 1.1  2000/05/31 22:59:20  root
% *** empty log message ***
%
% Revision 1.1  1999/09/02 18:33:38  root
% *** empty log message ***
%
% Revision 1.2  1999/05/27 13:37:36  paul
% initialize urlmat dodsdates (global variables)
%
% Revision 1.1  1999/05/21 16:54:40  paul
% Initial version...phemenway
%

% Initialize variables.

locate_x = [];
locate_y = [];
depths = [];
times = [];
URLinfo = [];
urllist = '';
url = '';
DODS_URL = '';
DODS_Decimal_Year = '';

% Get beginning and ending of time interval.

StartTime = max(Time(1), ranges(4,1));
LastTime = min(Time(2), ranges(4,2));

Constraint = [ 'DODS_URL,DODS_Decimal_Year(time)&date("' ...
      num2str(StartTime,9) '","' num2str(LastTime,9) '")' ];

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
urllist=mkstrmat(DODS_URL);
times = str2num(DODS_Decimal_Year);
% for some reason server returns more than valid times.
% Subset:
i = find(times >= StartTime & times <= LastTime);
times = times(i);
urllist = urllist(i,:);
URLinfo = times;
return
