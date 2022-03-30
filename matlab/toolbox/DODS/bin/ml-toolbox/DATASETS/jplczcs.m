%
%                       JPL CZCS Temporary dataset

% The preceding empty line is important.

% FUNCTIONS -- REQUIRED
GetFunctionName = 'getrectg';
% FUNCTIONS -- OPTIONAL
Cat_m_File = 'jplczcat';
URL_m_File = 'jplczurl';

% VARIABLES -- OPTIONAL
Server = 'http://dods.jpl.nasa.gov/dods-bin/nph-hdf/czcs/pigment';
CatalogServer = 'http://dods.jpl.nasa.gov/dods-bin/nph-jg/czcs';
Nlon = 2048;
Nlat = 1024;

% VARIABLES -- REQUIRED
LonRange = [0 360.0];
LatRange = [90.0 -90.0];
% January 81 through June 1986
TimeRange = [1981.0 1986.5];
DepthRange = [0.0 0.0];
DepthUnits = '';
Resolution = 18.0;

%DataName = 'JPL CZCS Temporary Dataset';
                                          % PCC Changed 12/13/98 to regularize names.
DataName = 'Color - CZCS Pigment Concentration (Temporary) - JPL';
TimeName = '';
LongitudeName = '';
LatitudeName = '';
DepthName = '';
SelectableVariables = str2mat('Pigment_Concentration');
DodsName = str2mat('Raster%20Image%20%230');

% note: DataNull is applied *before* scaling
DataNull = [NaN; NaN; NaN; NaN; NaN];
DataScale = [NaN NaN; NaN NaN; NaN NaN; NaN NaN; NaN NaN];
DataRange = [NaN NaN; NaN NaN; NaN NaN; NaN NaN; NaN NaN];

% COMMENTS
Comments1 = sprintf('%s\n', ...
'         This is temporary dataset for demo purposes only.', ...
'    ', ...
'    It is derived from Product #15 at the JPL PO.DAAC.', ...
'    ');

Comments = [Comments1];









