%
%               FILE DESCRIBING THE NSCAT LEVEL 3.0 DATASET

% The preceeding blank line is important for cvs.
% FUNCTIONS -- REQUIRED
GetFunctionName = 'getrectg';

% FUNCTIONS -- OPTIONAL
Cat_m_File = 'ffcsquery';

% VARIABLES -- OPTIONAL
CatalogServer = ...
    'http://dods.gso.uri.edu/cgi-bin/nph-dods/catalog/fsu_nscat2fs.dat';

% VARIABLES -- REQUIRED
LonRange = [0.0 360.0];
LatRange = [-90.0 90.0];
TimeRange = [1996+259/366 1997+180/365];
DepthRange = [0 0];
Resolution = 111.0;

% Force gridcat to ignore the axes popup window by forcing the axes order
axes_order = [2 1 0 0];

DataName = 'Wind - Level 3 NSCAT 1-Deg. Averaged - COAPS(FSU)';

SelectableVariables = str2mat('Wind_U','Wind_V');
DodsName = str2mat('u','v');
% note: DataNull is applied *before* scaling
DataNull = cell(size(DodsName,1)+4,1);
[DataNull(:)] = deal({nan}); 
[DataNull(5:length(DataNull))] = deal({32767});
DataScale = [0.0 1.0; 0.0 1.0; NaN NaN; NaN NaN; 0.0  0.01;  0.0  0.01];

% COMMENTS
Comments1 = sprintf('%s\n', ...
'                         COAPS  NSCAT Gridded Daily Winds', ...
' ', ...
' Daily wind fields are produced using a heavily weighted temporal average.', ...
' These products are on a one degree grid, for each day scatterometer', ...
' observations were available over part of the globe. The scatterometer', ...
' winds, and these gridded winds, are calibrated to a height of 10 m.', ...
' This approach bins the satellite swath observations (in 1 degree bins)', ...
' without any additional smoothing in space. The data set should be', ...
' considered research quality. ', ...
' ', ...
' The effective sampling time is non-homogeneous in space and time, but', ...
' is typically between one and three days, with a peak at two days. A', ...
' characteristic averaging time can be estimated by applying the averaging', ...
' technique to the absolute value of the difference in time between each', ...
' observation and 12Z on the day to which the wind field applies. This', ...
' characteristic time is roughly half the effective sampling period. The', ...
' probability distribution of this characteristic time (for the region', ...
' around the Gulf of Mexico and the Caribbean Sea) shows the effectiveness', ...
' of this averaging technique. Data sets with homogeneous sampling', ...
' characteristics require much larger spatial and temporal bins for', ...
' averaging. This technique captures relatively rapid and small scale', ...
' changes that might otherwise be missed. ' , ...
' ', ... 
' This gridding technique and a similar data set are described in', ...
' Bourassa, M. A., L. Zamudio, and J. J. O''Brien, 1998:', ...
' Non-inertial flow in NSCAT observations of Tehuantepec winds.', ...
'  J. Geophys. Res., in press.');

Comments2 = sprintf('%s\n', ...
'    ', ...
'    Units:  (on server) cm/s ==> (once converted) m/s ', ...
'    Time_Period_of_Content = ', ...
'         Beginning_Date:1996/259 ', ...
'         Ending_Date:1997/180 ', ...
'    Spatial_Domain = ', ...
'         Bounding Coordinates: ', ...
'              West Bounding Coordinate:0 ', ...
'              East Bounding Coordinate:360 ', ...
'              South Bounding Coordinate:-90 ', ...
'              North Bounding Coordinate:+90 ', ...
'    Point_of_Contact (Science) = ', ...
'            contact-name: Dr. Mark A. Bourassa', ...
'            contact-address1: Center for Ocean-Atmospheric Prediction Studies', ...
'            contact-address2: Florida State University', ...
'               contact-address3: Tallahassee, FL 32306-2840', ...
'               contact-country: USA', ...
'        contact-Telephone: (850) 644-6923', ...
'       contact-Electronic Mail Address:INTERNET > bourassa@coaps.fsu.edu', ...
'       contact-http: http://www.coaps.fsu.edu/~bourassa/', ...
'    ', ...
'    Point_of_Contact (Data Provision) = ', ...
'               name: Center for Ocean-Atmospheric Prediction Studies', ...
'               address1: Florida State University', ...
'               address2: Tallahassee, FL 32306-2840', ...
'               country: USA', ...
'               Telephone: (850) 644-6923', ...
'         Electronic Mail Address:INTERNET > bourassa@coaps.fsu.edu');

Comments = [Comments1 Comments2];

Acknowledge = sprintf('%s\n\n%s\n\n%s\n\n%s', ...
         ['The author of this dataset is M. A. Bourassa, bourassa@coaps.fsu.edu.'], ...
         ['The data are provided by the Center for Ocean-Atmospheric Prediction ', ...
          'Studies (COAPS), Florida State University, Tallahassee, ', ...
          'FL 32306-2840, bourassa@coaps.fsu.edu,'], ...
         ['and accessed via the Distributed Oceanographic Data ', ...
          'System (DODS: http://www.unidata.ucar.edu/packages/dods).'], ...
          ['Citation: ', ...
' This gridding technique and a similar data set are described in', ...
' Bourassa, M. A., L. Zamudio, and J. J. O''Brien, 1998:', ...
' Non-inertial flow in NSCAT observations of Tehuantepec winds.', ...
'  J. Geophys. Res., in press.']   ) ;

Data_Use_Policy='';

% $Id: fsun2.m,v 1.6 2002/08/15 03:57:46 dan Exp $
%

% $Log: fsun2.m,v $
% Revision 1.6  2002/08/15 03:57:46  dan
% Added axes_order to avoid pop-up window.
%
% Revision 1.5  2002/02/09 00:03:58  dan
% Removed Nlat, Nlon and variable names. GUI will use das/dds.
% Removed IntervalTime and MidTime
% Changed names for winds.
%
% Revision 1.4  2002/01/22 21:51:48  dan
% Modified CatalogServer entry for current usage.
%
% Revision 1.3  2001/01/18 19:35:44  dbyrne
%
%
% datarange is no longer in use.  changed datanull to cell in many cases.
% -- dbyrne 01/01/17
%
% Revision 1.2  2000/06/16 02:51:53  dbyrne
%
%
% Upgrades for standardization/toolbox. -- dbyrne 00/06/15
%
% Revision 1.2  2000/06/12 17:41:44  root
% *** empty log message ***
%
% Revision 1.1  2000/05/31 22:59:19  root
% *** empty log message ***
%
% Revision 1.3  2000/04/12 01:18:19  root
% All fsun datasets now use getrectf, and only 2 cat_m_files in use.
%
% Revision 1.5  2000/03/17 16:57:30  dbyrne
%
%
% Changed datanames so all indicate NSCAT origin of data.
%
% -- dbyrne 00/03/17
%
% Revision 1.4  1999/09/21 13:50:53  paul
% changing catalog server to maewest...pdh
%
% Revision 1.3  1999/06/01 06:48:41  dbyrne
%
%
% updating things ...
%
% Revision 1.2  1999/05/21 17:46:22  paul
%  add DepthUnits = '';  .....  phemenway
%
% Revision 1.1  1999/05/21 16:55:50  paul
% Initial version....phemenway
%
