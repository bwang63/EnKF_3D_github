%
%  Digital Bathymetric Data Base -  5 minute Resolution (DBDB5) for the Southwest Pacific

% Added by PCC 1/22/02

GetFunctionName = 'getrectg';
% the effect of the following 2 specs is to allow a constraint to be
% set up without actually querying this or any server (or the dataset,
% which has no grid maps).
Cat_m_File = 'dummy';
CatalogServer = 'http://pdas.navo.navy.mil/cgi-bin/nph-nc/data/DBDBV/DBDBV_sw_pacific.nc';
  
LonRange = [99.9581  180.0419];
LatRange =  [-72.0419    0.0419];
TimeRange = [1800.0 str2num(datestr(date,10))];
DepthRange = [0.0 0.0];
Resolution = 9.2;

% Force gridcat to ignore the axes popup window by forcing the axes order
axes_order = [1 2 0 0];

DataName = 'Bathymetry - DBDB5 Southwest Pacific - NAVOCEANO';

SelectableVariables = str2mat('Bathymetry');
DodsName = str2mat('Depth');

DataNull = [NaN NaN NaN NaN 1.0000000272564224e+16];
DataScale = [NaN NaN; NaN NaN; NaN NaN; NaN NaN; 0 -1.0];

Acknowledge = sprintf('%s\n', ...
    [ ]);
Data_Use_Policy = [];

Comments1 = sprintf('%s\n', ...
'                                  Naval Oceanographic Office', ...
'                      Digital Bathymetric Data Base - Variable Resolution', ...
' ',...
'                                              DBDB-V', ...
' ',...
'     The DBDB-V Database, is a digital bathymetric database which provides ocean', ...
'     floor depths at various gridded resolutions (i.e. 5, 2, 1, and 0.5 minute).', ...
'     The DBDB-V database was developed by NAVOCEANO to support the generation', ...
'     of bathymetric chart products and to provide ocean floor depth data to be', ...
'     integrated with other geophysical and environmental parameters for ocean modeling.', ... 
' ');

Comments2 = sprintf('%s\n', ...
'      Southwest Pacific Coverage of the Digital Bathymetry Data Base 5 Min Resolution',...
'     ',...
'     This subset of the DBDB-V database provides ocean depths at every oceanic geographic',...
'     position evenly divisible by 5 minutes of latitude and longitude. ',...
'     ',...
'     A more complete description is avialable from the Global Change Master',...
'     Directory at:',...
'     ',...
'     http://gcmd2.gsfc.nasa.gov/servlets/md/getdif.py?xsl=brief_display.xsl&',...
'        entry_id=DBDB5&interface=FROMDODS');

Comments = [Comments1 Comments2];
