%
%                            GSFC TRMM Precip

% FUNCTIONS -- REQUIRED
GetFunctionName = 'getrectg';
% FUNCTIONS -- OPTIONAL
Cat_m_File = 'ffcsquery';

% VARIABLES -- OPTIONAL
CatalogServer = 'http://daac.gsfc.nasa.gov/daac-bin/nph-ff/DODS/catalog/trmm_3B42-cat.dat';

Nlon = 360;
Nlat = 80;
axes_order = [1 2 0 0];
Constraint_Prefix = '[0:1:0]';

% VARIABLES -- REQUIRED
LonRange = [0 360];
LatRange = [-40 40];
TimeRange = [1998 2002+59/365];
DepthRange = [0 0];
DepthUnits = 'meters';
Resolution = 111.0;

DataName = 'GSFC TRMM Precipitation';

SelectableVariables = str2mat('Precipitation');
DodsName = str2mat( 'percipitate');

% note: DataNull is applied *before* scaling
DataNull = cell(size(DodsName,1)+4,1);
[DataNull(:)] = deal({nan}); 
[DataNull(5:length(DataNull))] = deal({-9.999900390625000e+03});
DataScale = [NaN NaN; ...
             NaN NaN; ...
             NaN NaN; ...
             NaN NaN; ...
		 NaN NaN];

Acknowledge = ' ';

% COMMENTS
Comments = sprintf('%s\n', ...
'                 TRMM Precipitation', ...
' ', ...
'   Daily surface rainfall and error estimates, derived from a combination of',... 
'the rainfall measurements from instruments aboard TRMM and geostationary ',...
'satellites (e.g., GOES), mapped to 1 degree grid between 40 degrees north ',...
		   'and 40 degrees south. Geographic projection in HDF format.', ...
' ', ...
'   For more information see: ', ...
'http://daac.gsfc.nasa.gov/CAMPAIGN_DOCS/hydrology/readme_html/interim_readme.html');




