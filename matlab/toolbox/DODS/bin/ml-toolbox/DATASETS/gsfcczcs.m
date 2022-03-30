%
%  File Describing The Goddard Space Flight Center 1 degree CZCS

% FUNCTIONS -- REQUIRED
GetFunctionName = 'getrectg';
% FUNCTIONS -- OPTIONAL
Cat_m_File = 'ffcsquery';

% VARIABLES -- OPTIONAL
CatalogServer = 'http://eosdata.gsfc.nasa.gov/daac-bin/nph-ff/DODS/catalog/czcs-cat.dat';
Nlon = 360;
Nlat = 180;

% VARIABLES -- REQUIRED
LonRange = [-180.0 180.0];
LatRange = [90.0 -90.0];
TimeRange = [1979-45/360 1986+(180+15)/360];
DepthRange = [0 0];
Resolution = 111;

DataName = 'Ocean Color - CZCS - GSFC'; % Name for this dataset.
SelectableVariables = str2mat('Chlorophyll');
DodsName = 'czcs';

DataNull = cell(size(DodsName,1)+4,1);
[DataNull(:)] = deal({nan}); 
DataNull(5) = {[-999.900024414062454747350886464 -99]};
DataScale = [NaN NaN; NaN NaN; NaN NaN; NaN NaN; NaN NaN];

Data_Use_Policy = '';

Acknowledge = sprintf('%s\n%s', ...
  [ '  The production and distribution of this data set are being ',...
    'funded by NASA''s Mission To Planet Earth program. The data are ',...
    'not copyrighted; however, we request that when you publish data ',...
    'or results using these data please acknowledge as follows: '],...
  [ '  The authors wish to thank the Distributed Active Archive ',...
    'Center (Code 902.2) at the Goddard Space Flight Center, Greenbelt, ',...
    'MD, 20771, for producing the data in its present format and ',...
    'distributing them. The original data products were produced by the ',...
    'Nimbus Project Office in collaboration with the NASA Goddard Space ',...
    'Flight Center Space Data and Computing Division, the NASA GSFC ',...
    'Laboratory for Oceans, and the University of Miami Rosenstiel ',...
    'School of Marine and Atmospheric Science. Goddard''s share in these ',...
    'activities was sponsored by NASA''s Mission to Planet Earth program.']);

% COMMENTS
Comments1 = sprintf('%s\n', ...
'  This data set is a collection of monthly composites of ocean ',...
'chlorophyll concentration derived from the Coastal Zone Color ',...
'Scanner (CZCS) instrument flown aboard the Nimbus-7 satellite ',...
'from October 1978 through June 1986. This concentration provides ',...
'a direct measure of the abundance of phytoplankton and its ',...
'variability in space and time over most of the world''s oceanic ',...
'regions. The CZCS data set represents the only source of satellite- ',...
'derived, global oceanic biomass productivity, and serves as an ',...
'important precursor to the next generation of advanced ocean color ',...
'instruments. ');

Comments2 = sprintf('%s\n', ...
' ',...
'Original Archive ',...
' ',...
'  The geophysical data from which this CZCS monthly composite data set',...
'is derived were produced by the Nimbus Project Office in collaboration ',... 
'with the NASA Goddard Space Flight Center (GSFC) Space Data and Computing ',...
'Division, the NASA GSFC Laboratory for Oceans, and the University of ',...
'Miami Rosenstiel School of Marine and Atmospheric Science. This global ',...
'processing effort was initiated in 1985 and completed in early 1990. ',...
'See Feldman et al. (1989) for a complete description of the processing ',...
'system used to generate these products. The level 3 monthly composite ',...
'data product, with a spatial resolution of 20 km at the equator, was ',...
'used to generate these 1 degree x 1 degree averages. The complete suite ',...
'of CZCS-derived geophysical parameters is currently available from the ',...
'Distributed Active Archive Center (DAAC) at NASA GSFC.');

Comments3 = sprintf('%s\n', ...
'Characteristics of the Data ',...
' ',...
'  Parameters: Chlorophyll (pigment) concentration, defined as the ',...
'sum of the concentrations of chlorophyll-a and phaeophytin- a ',...
' ',...
'     Units: mg/m^3 ',...
'     Typical Range (monthly average): ',...
'          0.05 mg/m^3 (e.g., tropical non-coastal waters) to ',...
'          30 mg/m^3 (e.g., coastal waters, North Pacific, North Atlantic) ',...
' ',...
'     Temporal Coverage: November 1978 - June 1986 ',...
'     Temporal Resolution: monthly composites, monthly composites over ',...
'           temporal coverage of data set, and composites over temporal ',...
'           coverage of data set.',...
' ',...
'     Spatial Coverage: Global Ocean ',...
'     Spatial Resolution: 1 degree x 1 degree ');

Comments = [Comments1 Comments2 Comments3];

