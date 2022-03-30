%
%               FILE DESCRIBING THE NSCAT LEVEL 3.0 DATASET

% The preceding empty line is important.
%
% $Id: nscat30.m,v 1.3 2000/09/01 18:50:56 dbyrne Exp $

% $Log: nscat30.m,v $
% Revision 1.3  2000/09/01 18:50:56  dbyrne
%
%
% CHanges to use loaddods-3.1.6 -- dbyrne 00/09/01
%
% Revision 1.3  2000/09/01 18:31:29  root
% using new loaddods
%
% Revision 1.2  2000/06/12 17:41:43  root
% *** empty log message ***
%
% Revision 1.1  2000/05/31 22:59:20  root
% *** empty log message ***
%
% Revision 1.20  2000/04/12 01:27:33  root
% Updated to take advantage of the fact that loaddods is no longer broken,
% and that the server provides lat and lon vectors.
%
% Revision 1.19  1999/10/27 22:10:38  root
% Fixed many spelling and grammatical errors in comment fields.
%
% Revision 1.18  1999/09/02 18:27:29  root
% *** empty log message ***
%
% Revision 1.16  1999/05/13 03:09:55  dbyrne
%
%
% Added Acknowledge and Data_Use_Policy to archive.m.  Fixed getxxx functions
% to use dodsmsg instead of stdout for errors/info.  Made ChangeLog so that it's
% in Emacs format.  All changes for release 3.0.0 -- dbyrne 99/05/12
%
% Revision 1.17  1999/05/13 01:24:17  root
% Added Acknowledge and Data_Use Policy.  Fixed some bugs.  Changed any
% messages to use to use 'dodsmsg' script instead of just displaying to stdout.
%
% Revision 1.16  1999/03/04 13:13:31  root
% All changes since AGU week.
%
% Revision 1.15  1998/12/15 19:12:28  jimg
% Modified 'DataName' to include variable type information.
%
% Revision 1.14  1998/11/30 00:49:09  dbyrne
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
% Revision 1.14  1998/11/05 16:01:54  root
% Changed LonVector and LatVector to be used if no Lon returned and tried the update function.
% DataScale and DataNull should now be optional!
%
% Revision 1.13  1998/11/05 13:02:06  root
% *** empty log message ***
%
% Revision 1.12  1998/10/23 15:26:06  root
% updating NSCAT 3.0
%
% Revision 1.11  1998/10/15 14:07:29  root
% starting update.
%
% Revision 1.10  1998/09/13 19:33:25  root
% updated DataNull &c.
%
% Revision 1.9  1998/09/13 15:36:36  root
% Added new server.
%
% Revision 1.8  1998/07/13 20:29:30  jimg
% Fixes from the final test of the new build process
%
% Revision 1.8  1998/09/11 17:58:33  dbyrne
% fixed syntax error in LatRange
%
% Revision 1.7  1998/09/11 08:16:09  dbyrne
% Longitude ranges were messed up in every archive.m file except the
% two I wrote myself.  To eliminate future confusion, 'LLon' 'Llat',
% 'Rlon' and 'Ulat' etc are being eliminated in favor of two-component
% vectors LonRange LatRange TimeRange DepthRange.
%
% Revision 1.6  1998/09/09 20:12:19  dbyrne
% Changing variable names to stay within 14 characters.
%
% Revision 1.5  1998/09/09 15:04:30  dbyrne
% Eliminating all global variables.
%
% Revision 1.4  1998/09/09 07:57:38  dbyrne
% replaced Data_Scale with DataScale, Data_Null with DataNull, and Data_Range
% with DataRange for consistency with other variables in the archive.m files.
%
% Revision 1.3  1998/09/09 07:40:22  dbyrne
% Replaced getrectangular with getrectg
%
% Revision 1.2  1998/09/09 07:34:22  dbyrne
% Eliminating ReturnedVariables
%
% Revision 1.1  1998/05/17 14:18:07  dbyrne
% *** empty log message ***
%
% Revision 1.4  1998/01/12 22:27:06  jimg
% Changed from CS on dcz to the one on dods.gso.uri.edu.
%
% Revision 1.3  1997/12/11 16:56:50  jimg
% Changed email address for DODS support from customer.service@ to support@.
%
% Revision 1.2  1997/12/11 06:20:45  jimg
% Switched to full archive of data. Added catalog server.
%
% Revision 1.1.1.1  1997/09/22 14:13:55  tom
% Imported Matlab GUI sources to CVS
%

% FUNCTIONS -- REQUIRED
GetFunctionName = 'getrectf';

% FUNCTIONS -- OPTIONAL
Cat_m_File = 'gmup1c';

% VARIABLES -- OPTIONAL

% Server = 'http://dods.jpl.nasa.gov/dods-bin/nph-hdf/pub/ocean_wind/nscat/data/L30/';
CatalogServer = 'http://dods.gso.uri.edu/cgi-bin/nph-ff/catalog/nscat30fs_v1.dat';
Nlon = 720;
Nlat = 300;
IntervalTime = 24.0;
MidTime = 12.0;

% VARIABLES -- REQUIRED
LonRange = [0.0 360.0];
LatRange = [-75.0 75.0];
TimeRange = [1996+259/366 1997+126/365];
DepthRange = [0 0];
DepthUnits = '';
Resolution = 55.0;

%DataName = 'JPL Level 3 NSCAT';
                                          % PCC Changed 12/13/98 to regularize names.
DataName = 'Wind - Level 3 NSCAT - JPL';
LongitudeName = 'column';
LatitudeName = 'row';

% N.B.: the server actually provides latitude and longitude now, and
% the bug that required two server names has been fixed.
% -- dbyrne 00/03/29
TimeName = '';
DepthName = '';
SelectableVariables = str2mat('U_Wind','V_Wind');
DodsName = str2mat('NSCAT%20Rev%2030.Avg_Wind_Vel_U','NSCAT%20Rev%2030.Avg_Wind_Vel_V');
% note: DataNull is applied *before* scaling
DataNull = [nan nan nan nan nan nan];
DataScale = [NaN NaN; NaN NaN; NaN NaN; NaN NaN; 0.0  0.01;  0.0  0.01];
DataRange = [NaN NaN; NaN NaN; NaN NaN; NaN NaN; -50.0 50.0; -50.0 50.0];

Acknowledge = sprintf('%s\n\n%s\n%s\n%s', ...
    [ ' These data are provided on-line by NASA''s Physical ',...
      'Oceanography Data Active Archive Center (PODAAC: ',...
      'http://podaac.jpl.nasa.gov) and were accessed via ',...
      'the Distributed Oceanographic Data System (DODS: ',...
      'http://www.unidata.ucar.edu/packages/dods).'], ...
    [ 'Citations:']);
% COMMENTS
Comments1 = sprintf('%s\n', ...
'                         NASA/JPL Level 3 NSCAT', ...
' ', ...
'   NSCAT, the NASA Scatterometer, is a specialized microwave radar that measures ', ... 
'   the speed and direction of winds over the global ocean surface. The primary ', ...
'   mission of NSCAT is to acquire all-weather, high-resolution measurements of ', ...
'   near surface winds over the global oceans. The coverage is global once every 2 ', ...
'   days with each sample an average wind vector over a 50 km ''wind vector ', ...
'   cell''. The NSCAT Science Product (NSP) consists of three distinct data sets: ', ...
'   Level 1.7, Level 2.0 and Level 3.0 which provide collocated ocean sigma-0 ', ...
'   data, vector wind data, and averaged global ocean wind maps, respectively. ', ...
'   ', ...
'   The Level 3 NSCAT data are produced from the Level 2 wind vector product ', ...
'   and are a set of global ocean averaged maps of wind vector solutions, along ', ...
'   with various secondary variables and statistical descriptors. The averaging ', ...
'   interval is one day, spanning complete revs beginning and ending nearest to ', ...
'   0h UTC and 24h UTC, respectively. The map projection used is a simple linear ', ...
'   latitude/longitude projection. The map grid is in half degree resolution ', ...
'   (nominal 55.5kmx55.5km) defined within latitude limits of 75S to 75N and ', ...
'   longitude limits of 0 to 360.', ...
'    ', ...
'   The global wind vector Level 3 data is stored as map grids of Average U Wind ', ...
'   Component and Average V Wind Component.  The U Wind is the average east-west ', ...
'   component of the wind velocity vector, positive eastward.  The V Wind is the ', ...
'   average north-south component of the wind velocity vector, positive northward.  ', ...
'   The data are delivered from the archive in meters per second times 100. If ',...
'   scaling is turned on these numbers are multiplied by 0.01 in the interface. ',...
'   To turn off scaling prefix the lines: Avg_Wind_Vel_U_Scale = [0.0 0.01];',...
'                                    and: Avg_Wind_Vel_V_Scale = [0.0 0.01];',...
'   with a percent sign (%) in the nscat30.m file in the DATASETS subdirectory.',...   
'   The range of scaled wind speeds is:  -50 to +50 m/s.', ...
'    ', ...
'   References:', ...
'    ', ...
'   NSCAT Scatterometer Science Product, Levels 1.7, 2, 3 (JPL), Available at:', ...
'        http://podaac-www.jpl.nasa.gov:2031/dataset_docs/nscat_nsp.html');
Comments2 = sprintf('%s\n', ...
'    ', ...
'    Units:  (on server) cm/s ==> (once converted) m/s ', ...
'    Time_Period_of_Content = ', ...
'         Beginning_Date:1997/02/06 ', ...
'         Ending_Date:1997/03/18 ', ...
'    Spatial_Domain = ', ...
'         Bounding Coordinates: ', ...
'              West Bounding Coordinate:0.0 ', ...
'              East Bounding Coordinate:360.0 ', ...
'              South Bounding Coordinate:-75 .0 ', ...
'              North Bounding Coordinate:+75.0 ', ...
'    Point_of_Contact (Science) = ', ...
'         Address: ', ...
'               R. Scott Dunbar ', ...
'               Jet Propulsion Laboratory', ...
'               4800 Oak Grove Drive', ...
'               Pasadena, California 91109', ...
'               USA ', ...
'         Telephone: (818) 354-8329', ...
'         Electronic Mail Address:INTERNET > rsd@zephyr.jpl.nasa.gov', ...
'    ', ...
'    Point_of_Contact (Data Provision) = ', ...
'         Address: ', ...
'               Johan Berlin', ...
'               JPL PO.DAAC', ...
'               M/S 300-320', ...
'               Jet Propulsion Laboratory', ...
'               4800 Oak Grove Drive', ...
'               Pasadena, California 91109', ...
'               USA ', ...
'               Telephone: (818) 354-8032', ...
'         Electronic Mail Address:INTERNET > johan@podaac.jpl.nasa.gov');



Comments = [Comments1 Comments2];
