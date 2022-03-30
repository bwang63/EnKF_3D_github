%
%   DOE precipitation and air temp anomalies, monthly

% The preceding empty line is important.
%

% FUNCTIONS -- REQUIRED
GetFunctionName = 'getrectg';
% FUNCTIONS -- OPTIONAL

% VARIABLES -- OPTIONAL
Server = str2mat('http://www.cdc.noaa.gov/cgi-bin/nph-nc/Datasets/doe/precip.ann.nc', ...
  'http://www.cdc.noaa.gov/cgi-bin/nph-nc/Datasets/doe/air.ann.nc');

% VARIABLES -- REQUIRED
LonRange = [0.0 360.0];
LatRange = [90.0 -90.0];
TimeRange = [1851 1990.9];
DepthRange = [0.0 0.0];
Resolution = 555.0;

% Force gridcat to ignore the axes popup window by forcing the axes order
axes_order = [3 2 0 1];

DataName = 'Surface - DoE Compiled Annual Dataset - NOAA/CDC';

SelectableVariables = str2mat('Precip_anom', 'Air_Temp_anom');
DodsName = str2mat('precip','air');

% note: DataNull is applied *before* scaling
DataNull = cell(size(DodsName,1)+4,1);
DataNull(:) = deal({-9969209968386869046778552952102584320});

Acknowledge = sprintf('%s\n', ...
'DOE data provided by the NOAA-CIRES Climate Diagnostics Center,', ...
'Boulder, Colorado, from their Web site at http://www.cdc.noaa.gov/');

% COMMENTS
Comments1 = sprintf('%s\n', ...
'DOE Gridded Surface Precipitation and Temperature Anomalies', ...
' ',...
'This global precipitation and temperature anomaly data set for the',...
'period 1851 through 1990 has been assembled under funding by the',...
'U.S. Department of Energy.',...
' ',...
'Temperature data is given in deg C.',...
'Precipitation data is given in mm.',...
' ',...
'Precision: ',...
' ',...
'     Grid point anomalies have been calculated to an accuracy',...
'     of .01 deg C for temperature data. This does not necessarily reflect',...
'     the accuracy of the original data, however. Individual monthly grid',...
'     point anomalies are probably accurate to .2 deg C. Precipitation data',...
'     includes a precision of .01 mm for monthly data and .001 for seasonal',...
'     data. The individual monthly grid point anomalies are probably',...
'     accurate to 10 mm.');

Comments2 = sprintf('%s\n', ...
'Spatial coverage: ', ...
' ', ...
'     90N-90S (by 5.0), 0-355E (by 5.0) ', ...
' ', ...
'Temporal coverage:  ', ...
' ', ...
'     1851 through 1990', ...
'     monthly, seasonal, annual mean anomalies ',...
' ', ...
'Levels: ', ...
' ', ...
'     Surface data. ', ...
' ', ...
'Missing data: ', ...
' ', ...
'     Grid cells for which insufficent data were available are flagged ', ...
'     as missing in the data set.', ...
' ', ...
'Dataset format and size: ', ...
' ', ...
'     netCDF ', ...
'     Two monthly files, 20 Mbytes each (precip.mon.nc, air.mon.nc)', ...
'     Two seasonal files, 6 Mbytes each (precip.seas.nc, air.seas.nc)', ...
'     Two annual files, 2 Mbytes each (precip.ann.nc, air.ann.nc)', ...
' ', ...
'References:',...
' ', ...
'     P.D. Jones, S.C.B. Raper, B. Santer, B.S.G. Cherry, C. Goodess, ',...
'     P.M. Kelly, T.M.L. Wigley, R.S. Bradley, and H.F. Diaz (Eds.), 1985:',...
'     A Grid Point Surface Air Temperature Data Set for the ',...
'     Northern Hemisphere. U.S. Dept. of Energy, Washington, DC, 251 pp.',...
' ', ...
'     J.K. Eischeid, H.F. Diaz, R.S. Bradley, and P.D. Jones (Eds.), 1991:',...
'     A Comprehensive Precipitation Data Set for Global Land Areas. ',...
'     U.S. Dept. of Energy, Washington, DC, 82 pp.',...
' ', ...
'Original Source: ',...
'     Prepared under contract funded by the U.S. Dept. of Energy.');

Comments3 = sprintf('%s\n', ...
' ', ...
'Archive location(s): ',...
'     Climate Diagnostics Center, ',...
'     U.S. Dept. of Commerce ',...
'     NOAA, Code R/E/CD, ',...
'     325 Broadway,',...
'     Boulder, CO 80303',...
' ', ...
'Contact person(s):',...
' ', ...
'     Henry F. Diaz, Climate Diagnostics Center, NOAA/ERL R/E/CD, ',...
'     325 Broadway, Boulder, CO 80303; (303) 497-6649',...
'     hfd@cdc.noaa.gov',...
' ', ...
'     Jon Eischeid, Climate Diagnostics Center, NOAA/ERL R/E/CD, ',...
'     325 Broadway, Boulder, CO 80303; (303) 497-5970',...
'     jon@cdc.noaa.gov');


Comments = [Comments1 Comments2 Comments3];


% $Id: doeann.m,v 1.6 2002/08/15 03:57:46 dan Exp $

% $Log: doeann.m,v $
% Revision 1.6  2002/08/15 03:57:46  dan
% Added axes_order to avoid pop-up window.
%
% Revision 1.5  2002/02/09 21:43:14  dan
% Changed the resolution. It was set at 219km but should be 555km
%
% Revision 1.4  2002/02/08 23:33:05  dan
% Removed Nlat, Nlon and variable names. GUI will use das/dds.
%
% Revision 1.3  2001/06/26 10:56:30  dbyrne
%
%
% Fixed specification of datanull.  --dbyrne 01/06/26
%
% Revision 1.2  2001/01/18 19:35:44  dbyrne
%
%
% datarange is no longer in use.  changed datanull to cell in many cases.
% -- dbyrne 01/01/17
%
% Revision 1.1  2000/05/31 23:12:55  dbyrne
% *** empty log message ***
%
% Revision 1.1  2000/05/31 22:59:19  root
% *** empty log message ***
%
% Revision 1.1  2000/05/26 21:35:33  root
% *** empty log message ***
%
% Revision 1.1  1999/09/02 18:32:58  root
% *** empty log message ***
%
% Revision 1.3  1999/06/01 07:16:28  dbyrne
%
%
% Fixed datanull values and dataname and depthunits. -- dbyrne 99/06/01
%
% Revision 1.2  1999/06/01 06:48:41  dbyrne
%
%
% updating things ...
%
% Revision 1.1  1999/05/27 18:25:23  tom
% added to the GUI
%
