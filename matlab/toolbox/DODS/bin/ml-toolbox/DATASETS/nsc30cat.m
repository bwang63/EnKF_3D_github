function [locate_x, locate_y, depths, times, URLinfo, urllist, url] ...
    = nsc30cat(CatalogServer, time, ranges)

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
% $Id: nsc30cat.m,v 1.1 2000/05/31 23:12:55 dbyrne Exp $
%
%----------------------------------------------------------------------------

% $Log: nsc30cat.m,v $
% Revision 1.1  2000/05/31 23:12:55  dbyrne
% *** empty log message ***
%
% Revision 1.1  2000/05/31 22:59:20  root
% *** empty log message ***
%
% Revision 1.3  2000/05/24 20:41:37  root
% New version incorporates both Paul's and my changes. -- dbyrne 00/05/24
%
% Revision 1.5  2000/05/04 20:37:41  paul
%      Changed:  in-dataset names to reflect true names in the dataset (DodsName)
%      Changed:  timing function in the cat.m file to cross 1996-1997 correctly.
%
% Revision 1.4  2000/04/14 21:11:32  paul
%      Change to a Catalog Server on maewest
%      Change to use getrectf
%      Change to not use a separate pass-times catalog file.
%
% Revision 1.3  2000/04/12 18:27:24  paul
%      Test commit
%
% Revision 1.2  2000/04/11 15:07:23  paul
% Initialize loadnscat30passtimes.m
% Change the URLinfo_cat load from a .mat file to a .m ascii file.
%
% Revision 1.1  1999/05/13 02:55:20  dbyrne
%
%
% New palettes, dataset files with shortened names, and a few new scripts for
% release 3.0.0. -- dbyrne 99/05/12
%
% Revision 1.1  1999/05/13 01:22:22  root
% These are all files that had names shortened from something longer.
%
% Revision 1.7  1999/03/04 13:13:31  root
% All changes since AGU week.
%
% Revision 1.10  1998/11/30 00:49:09  dbyrne
%
%
% Fixed bug in unpack that deleted all returning names for datasets with
% no empty strings in the required fields.  Fixed vectorization of day2year
% and add workaround for a FLOP bug I found on ix86 machines.  Fixed calendar
% day to yearday conversion error in nscat30cat.m.  Added workaround for writeval
% bug in nscat30.m (2 server lines force 2 loaddods calls).  Fixed a bunch
% of bugs in new SSM/I code submitted by Rob Morris, JPL.  Added SSM/I, CZCS,
% Levitus (1982), World Ocean Atlas monthly, seasonal, and annual datasets and
% Mauna Loa CO2 record.  Fixed a logic error in urieccat.m. -- dbyrne, 98/11/29
%
% Revision 1.5  1998/10/23 15:26:07  root
% updating NSCAT 3.0
%
% Revision 1.4  1998/10/22 18:30:29  root
% updating.
%
% Revision 1.3  1998/09/13 15:41:00  root
% meshed James' changes.
%
% Revision 1.5  1998/09/13 02:29:01  dbyrne
% Modified so it loads nscat30_cat.mat, not nscat30_cat3.mat
%
% Revision 1.4  1998/07/13 20:29:30  jimg
% Fixes from the final test of the new build process
%
% Revision 1.3  1998/05/14 21:59:35  dbyrne
% Many small fixes.  DAB 98/05/14
% $Log: nsc30cat.m,v $
% Revision 1.1  2000/05/31 23:12:55  dbyrne
% *** empty log message ***
%
% Revision 1.1  2000/05/31 22:59:20  root
% *** empty log message ***
%
% Revision 1.3  2000/05/24 20:41:37  root
% New version incorporates both Paul's and my changes. -- dbyrne 00/05/24
%
% Revision 1.5  2000/05/04 20:37:41  paul
%      Changed:  in-dataset names to reflect true names in the dataset (DodsName)
%      Changed:  timing function in the cat.m file to cross 1996-1997 correctly.
%
% Revision 1.4  2000/04/14 21:11:32  paul
%      Change to a Catalog Server on maewest
%      Change to use getrectf
%      Change to not use a separate pass-times catalog file.
%
% Revision 1.3  2000/04/12 18:27:24  paul
%      Test commit
%
% Revision 1.2  2000/04/11 15:07:23  paul
% Initialize loadnscat30passtimes.m
% Change the URLinfo_cat load from a .mat file to a .m ascii file.
%
% Revision 1.1  1999/05/13 02:55:20  dbyrne
%
%
% New palettes, dataset files with shortened names, and a few new scripts for
% release 3.0.0. -- dbyrne 99/05/12
%
% Revision 1.1  1999/05/13 01:22:22  root
% These are all files that had names shortened from something longer.
%
% Revision 1.7  1999/03/04 13:13:31  root
% All changes since AGU week.
%
% Revision 1.10  1998/11/30 00:49:09  dbyrne
%
%
% Fixed bug in unpack that deleted all returning names for datasets with
% no empty strings in the required fields.  Fixed vectorization of day2year
% and add workaround for a FLOP bug I found on ix86 machines.  Fixed calendar
% day to yearday conversion error in nscat30cat.m.  Added workaround for writeval
% bug in nscat30.m (2 server lines force 2 loaddods calls).  Fixed a bunch
% of bugs in new SSM/I code submitted by Rob Morris, JPL.  Added SSM/I, CZCS,
% Levitus (1982), World Ocean Atlas monthly, seasonal, and annual datasets and
% Mauna Loa CO2 record.  Fixed a logic error in urieccat.m. -- dbyrne, 98/11/29
%
% Revision 1.5  1998/10/23 15:26:07  root
% updating NSCAT 3.0
%
% Revision 1.4  1998/10/22 18:30:29  root
% updating.
%
% Revision 1.3  1998/09/13 15:41:00  root
% meshed James' changes.
%
% Revision 1.2  1998/09/09 15:04:30  dbyrne
% Eliminating all global variables.
%
% Revision 1.1  1998/05/17 14:18:08  dbyrne
% *** empty log message ***
%
% Revision 1.1  1997/12/11 06:20:45  jimg
% Switched to full archive of data. Added catalog server.
%

% N.B. ranges are space and time constraint info.
% load nscat30_cat.mat

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  pdh 11 April 2000
% convert to an ascii file pass_time load:
%loadnscat30passtimes

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% pdh 12 April 2000
% converted to a catalog server and getrectf.
% removed the need to load pass times.

% must substract 1 from day to go from CALENDAR DAY (where Jan 1 is
% Day 1) to DECIMAL DAY (where Jan 1 is day 0.)  We want middle of the
% day, to we add 0.5 day back in.  Result: subtract 0.5 from the day.
%times_cat = day2year(URLinfo_cat(:,2)-0.5,URLinfo_cat(:,1));

locate_x = [];
locate_y = [];
depths = [];
URLinfo = [];
times = [];
% dummy initialization to match other Cat_m_Files
url = '';
urllist = '';

% Get beginning and ending of time interval.
start_time = max(time(1), ranges(4,1));
end_time = min(time(2), ranges(4,2));

start_year = floor(start_time);
start_day = round(year2day(start_time, start_year)+1);
if isleap(start_year) & start_day==367
   start_day=1; start_year=start_year + 1;
elseif ~isleap(start_year) & start_day==366
   start_day=1; start_year=start_year + 1;
end

end_year = floor(end_time);
end_day = round(year2day(end_time, end_year));

byst=sprintf('%03d',start_year);
bdst=sprintf('%03d',start_day);
lyst=sprintf('%03d',end_year);
ldst=sprintf('%03d',end_day);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  construct the catalog server constraint

Constraint= [ 'year,day,subdir,DODS_URL,DODS_Date(NSCAT30)&date("' ...
      byst '/' bdst '","' lyst '/' ldst '")' ];

% INITIALIZE ALL VARIABLES
day = [];
year = [];
DODS_URL = '';

% construct and dereference the URL
cs=[CatalogServer '?' Constraint];
loaddods('-e', cs)
%pass out the C-S url no matter what!
url=cs;
if dods_err == 1
  dods_err_msg = sprintf('%s\n%s', ...
      '           >>>>>>>> ERROR IN CATALOG ACQUISITION <<<<<<<<', ...
      dods_err_msg);
  dodsmsg(dods_err_msg)
  return
end

% only construct URLlist if no error occurred.
urllist=mkstrmat(DODS_URL);

if all(day==0) & all(year==0)
   URLinfo=[];
   times = [];
else
   URLinfo = [year day];
   times = cald2yr(URLinfo(:,2)+.5,URLinfo(:,1));
end

return;

