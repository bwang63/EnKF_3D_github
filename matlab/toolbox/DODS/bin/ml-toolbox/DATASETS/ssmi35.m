%
%                       JPL SSM/I Level 3.5 MONTHLY DATASETS

% The preceding empty line is important.

% FUNCTIONS -- REQUIRED
GetFunctionName = 'getrectg';
% FUNCTIONS -- OPTIONAL
Cat_m_File = 'ssm35cat';
URL_m_File = 'ssm35url';

% VARIABLES -- OPTIONAL
Server = 'http://dods.jpl.nasa.gov/dods-bin/nph-hdf/pub/ocean_wind/ssmi/atlas_ssmi/hdf/data/level3.5/';
CatalogServer = 'http://dods.jpl.nasa.gov/dods-bin/nph-jg/ssmi35';
Nlon = 144;
Nlat = 91;

% VARIABLES -- REQUIRED
LonRange = [-180 180];
LatRange = [-90.0 90.0];
% August 87 thru december 96
TimeRange = [1987.583 1997.0];
DepthRange = [0.0 0.0];
DepthUnits = '';
% Warning, pixels are not actually square !!!
% The gui must be extended to allow different aspect ratios.
% This assumption of squareness must be fixed somehow. R.Morris 11/16/98.
% SSMI Level 3.5 is actually 2 degrees by 2.5 degrees (256 km x 202.549 km).
Resolution = 202.55;

DataName = 'Wind - SSM/I 3.5 - JPL';
TimeName = 'time';
LongitudeName = 'longitude';
LatitudeName = 'latitude';
DepthName = '';
SelectableVariables = str2mat('U_Wind', 'V_Wind');
DodsName = str2mat('u10m', 'v10m');
u10m.size = [1 91 144];
u10m.maps{1} = {TimeName};
u10m.maps{2} = {LatitudeName};
u10m.maps{3} = {LongitudeName};

% note: DataNull is applied *before* scaling
DataNull = [NaN; NaN; NaN; NaN; 32767; 32767];
DataScale = [NaN NaN; NaN NaN; NaN NaN; NaN NaN;0 0.00122074; ...
  0 0.00122074];
DataRange = [NaN NaN; NaN NaN; NaN NaN; NaN NaN; NaN NaN; ...
 NaN NaN];

Data_Use_Policy = '';

Acknowledge = sprintf('%s\n\n%s\n%s\n%s', ...
    [ ' These data are provided on-line by NASA''s Physical ',...
      'Oceanography Data Active Archive Center (PODAAC: ',...
      'http://podaac.jpl.nasa.gov) and were accessed via ',...
      'the Distributed Oceanographic Data System (DODS: ',...
      'http://www.unidata.ucar.edu/packages/dods).'], ...
    [ 'Citations: ']);
% COMMENTS
Comments1 = sprintf('%s\n', ...
'         SSM/I derived global ocean surface-wind components (87 - 96)', ...
'    ', ...
'    This data consists of global surface winds over the ocean. It is the latest of', ...
'    several products containing SSM/I derived winds over the oceans produced by Robert', ...
'    Atlas and Joseph Ardizzone (NASA Goddard Space Flight Center) in collaboration with', ...
'    Ross N. Hoffman (Atmospheric and Environmental research - AER) . A 2D variational', ...
'    analysis method (VAM) was used to combine information from  ECMWF 10m surface wind', ...
'    analyses, SSM/I wind speeds (from Frank Wentz, Remote Sensing Systems), and ship and', ...
'    buoy winds to produce new surface wind analyses between -78 and 78 degrees latitude.', ...
'    ');

Comments2 = sprintf('%s\n', ...
'    For further information see the description of the level 3.5 product at:', ...
'    http://podaac.jpl.nasa.gov/order/order_ocnwind.html#Product079', ...
'    ');

% Comments = [Comments1 Comments2 Comments3 Comments4];
Comments = [Comments1 Comments2];


