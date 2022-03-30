%
%               FILE DESCRIBING THE GODDARD ISCCP C2 SURFACE REFLECTANCE

% FUNCTIONS -- REQUIRED
GetFunctionName = 'getrectg';
% FUNCTIONS -- OPTIONAL
Cat_m_File = 'ffcsquery';

% VARIABLES -- OPTIONAL
CatalogServer = 'http://daac.gsfc.nasa.gov/daac-bin/nph-ff/DODS/catalog/isccp_c2-cat.dat';

Nlon = 360;
Nlat = 180;
axes_order = [2 1 0 0];

% VARIABLES -- REQUIRED
LonRange = [-180 180];
LatRange = [90 -90];
TimeRange = [1983+6*30/365 1991+6*30/365];
DepthRange = [0 0];
Resolution = 111.0;

DataName = 'Cloud Fraction - ISCCP C2 - GSFC';
SelectableVariables = str2mat('Sky_Surface_Reflectance');
DodsName = 'srfref';

Additional_FileServer_Constraints = 'type&type="srfref"';
% note: DataNull is applied *before* scaling
DataNull = cell(size(DodsName,1)+4,1);
[DataNull(:)] = deal({nan}); 
[DataNull(5:length(DataNull))] = deal({-999.9899902343750});
DataScale = [NaN NaN; ...
             NaN NaN; ...
             NaN NaN; ...
             NaN NaN; ...
             NaN NaN];

Acknowledge = sprintf('%s\n', ...
[ ' The authors wish to thank William B. Rossow, and the Goddard Institute for ',...
 'Space Studies (GISS),New York, NY, USA, for the production of this data set, and ',...
 'the Distributed Active Archive Center (Code 902) at the Goddard Space Flight Center, ',...
 'Greenbelt, MD, 20771, for putting these data in their present format and distributing ',...
 'them. These distribution activities were sponsored by NASAs Mission to Planet Earth program.']);

% COMMENTS
Comment1 = sprintf('%s\n', ...
'     ISCCP C2 Cloud Data Product (See ISCCP D2 for a more up-to-date version of these data)', ...
' ', ...
'   A combination of satellite-measured radiances, ice/snow cover dataset and TOVS atmospheric ',...
'temperature/humidity are used by ISCCP to produce a global dataset on cloud and surface variables.',...
'Operational data collection and processing for ISCCP have been underway since July 1983. An ',...
'overview of the project and the data products is given in Rossow and Schiffer (1991); the ',...
'algorithm and its effectiveness are described by Rossow and Garder (1993a&b) while Rossow ',...
'et al. (1993) compare the resulting products to other cloud climatologies. The ISCCP C2-series ',...
'data products, briefly described here(more extensively in Rossow et al. (1996)), are gridded ',...
'data averaged over each month. These data (spanning over the period July 1983 to June 1991) ',...
'are originally produced on an equal area map grids which has a constant 2.5 degree latitude ',...
'increments and variable longitude increments ranging from 2.5 degree at the equator to 120 ',...
'degree at the pole The Goddard DAAC has regridded these dataset to 1x1 degree equal angle ',...
'grid for inclusion in the Interdisciplinary data collection.');

Comment2 = sprintf('%s\n', ...
' ',...
'                 Variables in the Data Set', ...
' ',...
'  cldfrc  -  mean cloud fraction                -   0 to 100 percent',...
'  cldprs  -  mean cloud top pressure            -  35 to 985 millibars',...
'  cldtau  -  mean cloud optical thickness       -   0.09 to 119 dimensionless',...
'  cldtmp  -  mean cloud top temperature         - -83 to 37 C (K in the original data)',...
'  srfref  -  mean clear sky surface reflectance -   0 to 1 fraction',...
'  srftmp  -  mean clear sky surface temperature - -74 to 52 C (K in the original data)',...
' ', ...
'    Because of the way these data are organized in the archive, they are ',...
'included here as separate data sets, one for each variable. They are however ',...
'all derived from the same source and can be easily combined by selecting a ',...
'a region and a time range and a data set and then requesting the data for ',...
'that data set, then requesting a second data set and requesting the corresponding ',...
'data, etc. ',...
' ', ...
'   For more information see: ', ...
'http://daac.gsfc.nasa.gov/CAMPAIGN_DOCS/FTP_SITE/INT_DIS/readmes/isccp_c2.html#200');

Comment3 = sprintf('%s\n', ...
' ',...
'                  REFERENCES',...
' ',...
'Rossow, W. B., and R. A. Schiffer, 1991. ISCCP cloud data products, ',...
'   Bull. Amer. Meteor. Soc., 72:2-20. ',...
' ',...
'Rossow, W. B., and L. C. Garder, 1993a. Cloud detection using satellite',...
'   measurements of infrared and visible radiances for ISCCP, J. Climate, ',...
'   6: 2341-2369. ',...
' ',...
'Rossow, W. B., and L. C. Garder, 1993b. Validation of ISCCP cloud detection, ',...
'   J. Climate, 6: 2370-2393. ',...
' ',...
'Rossow, W. B., A. W. Walker, and L. C. Garder, 1993. Comparison of ISCCP ',...
'   and other cloud amounts, J. Climate, 6:2394-2418.',...
' ',...
'Rossow, W. B., A. W. Walker, D. E. Beuschel, and M. D. Roiter, 1996. ',...
'   International Satellite Cloud Climatology Project (ISCCP): documentation ',...
'   of new cloud datasets, 115 pages, available on internet at: ',...
'   http://isccp.giss.nasa.gov/documents.html');

Comments = [Comment1 Comment2 Comment3];
