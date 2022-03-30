%
%            FILE DESCRIBING FSU Monthly Averaged Wind Stresses DATASET

% The preceeding blank line is important for cvs.
% FUNCTIONS -- REQUIRED
GetFunctionName = 'getrectg';

% FUNCTIONS -- OPTIONAL
Cat_m_File = 'ffcsquery';

% VARIABLES -- OPTIONAL
CatalogServer = ...
    'http://dods.gso.uri.edu/cgi-bin/nph-dods/catalog/fsu_nscat6fs.dat';

% VARIABLES -- REQUIRED
LonRange = [0.0 360.0];
LatRange = [-90.0 90.0];
TimeRange = [1996+283.5/366 1997+167/365];
DepthRange = [0 0];
Resolution = 111.0;

% Force gridcat to ignore the axes popup window by forcing the axes order
axes_order = [2 1 0 0];

DataName = 'Wind - Gridded NSCAT Monthly Wind Stress - COAPS(FSU)';

SelectableVariables = str2mat('Wind_Stress_U','Wind_Stress_V');
DodsName = str2mat('tx','ty');
% note: DataNull is applied *before* scaling
DataNull = cell(size(DodsName,1)+4,1);
[DataNull(:)] = deal({nan}); 
[DataNull(5:length(DataNull))] = deal({32767});
DataScale = [0.0 1.0; 0.0 1.0; NaN NaN; NaN NaN; ...
               0.0  9.9999997e-5;  0.0  9.9999997e-5];

%COMMENTS
Comments1 = sprintf('%s\n', ...
'                  COAPS NSCAT Gridded Monthly Surface Wind Stresses', ...
' ', ...
' Global grids of half degree resolution, monthly averaged, surface wind', ...
' stress over water are available. The stresses are determined from NSCAT', ...
' observations through the use of David Weissman''s stress model function.', ...
' Two data sets are available: smoothed and unsmoothed.  These are the', ...
'  unsmoothed data.');

Comments2 = sprintf('%s\n', ...
'    ', ...
'    Units:   (N/m^2s) ', ...
'    Time_Period_of_Content = ', ...
'         Beginning_Month:1996/10 ', ...
'         Ending_Month:1997/6 ', ...
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
' Verschell, M. A., M. A. Bourassa, D. E. Weissman, and J. J. O''Brien,', ...
' 1998: Model Validation of the NASA Scatterometer Winds.', ...
' J. Geophys. Res., in press.']    );



Data_Use_Policy='';

% $Id: fsun6.m,v 1.6 2002/08/15 03:57:46 dan Exp $
%

% $Log: fsun6.m,v $
% Revision 1.6  2002/08/15 03:57:46  dan
% Added axes_order to avoid pop-up window.
%
% Revision 1.5  2002/02/09 00:05:03  dan
% Removed Nlat, Nlon and variable names. GUI will use das/dds.
% Changed names for winds.
%
% Revision 1.4  2002/01/22 21:52:03  dan
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
% Revision 1.1  2000/05/31 22:59:20  root
% *** empty log message ***
%
% Revision 1.4  2000/04/12 01:18:20  root
% All fsun datasets now use getrectf, and only 2 cat_m_files in use.
%
% Revision 1.7  2000/03/17 16:57:30  dbyrne
%
%
% Changed datanames so all indicate NSCAT origin of data.
%
% -- dbyrne 00/03/17
%
% Revision 1.6  1999/10/27 22:18:21  dbyrne
% *** empty log message ***
%
% Revision 1.3  1999/10/27 22:10:38  root
% Fixed many spelling and grammatical errors in comment fields.
%
% Revision 1.2  1999/10/27 21:09:31  root
% *** empty log message ***
%
% Revision 1.5  1999/09/21 13:50:53  paul
% changing catalog server to maewest...pdh
%
% Revision 1.4  1999/06/01 06:48:41  dbyrne
%
%
% updating things ...
%
% Revision 1.3  1999/05/21 18:17:25  paul
%  add getfunction name .....  phemenway
%
% Revision 1.2  1999/05/21 17:46:23  paul
%  add DepthUnits = '';  .....  phemenway
%
% Revision 1.1  1999/05/21 16:55:50  paul
% Initial version....phemenway
%
