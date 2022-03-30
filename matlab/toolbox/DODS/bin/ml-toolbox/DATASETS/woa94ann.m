%
%                            World Ocean Atlas Annual Climatology

%
% $Log: woa94ann.m,v $
% Revision 1.4  2002/08/15 02:47:12  dan
% Added axes_order to avoid axes pop-up.
%
% Revision 1.3  2002/02/08 23:37:08  dan
% Removed Nlat, Nlon and variable names. GUI will use das/dds.
% Changed time range to go to present.
%
% Revision 1.2  2001/01/18 19:35:44  dbyrne
%
%
% datarange is no longer in use.  changed datanull to cell in many cases.
% -- dbyrne 01/01/17
%
% Revision 1.1  2000/05/31 23:12:56  dbyrne
% *** empty log message ***
%
% Revision 1.1  2000/05/31 22:59:20  root
% *** empty log message ***
%
% Revision 1.6  1999/09/02 18:27:33  root
% *** empty log message ***
%
% Revision 1.7  1999/07/21 15:33:59  dbyrne
%
%
% Corrected spelling of 'Dissolved', corrected language in comments.
% -- dbyrne 99/07/21
%
% Revision 1.6  1999/07/15 20:10:20  kwoklin
% Change Oxygen to Dissolved_Oxygen.   klee
%
%
% $Id: woa94ann.m,v 1.4 2002/08/15 02:47:12 dan Exp $

% FUNCTIONS -- REQUIRED
GetFunctionName = 'getrectg';
% FUNCTIONS -- OPTIONAL

% VARIABLES -- OPTIONAL
Server = 'http://ferret.wrc.noaa.gov/cgi-bin/nph-nc/data/Ocean_atlas_annual.nc';

% VARIABLES -- REQUIRED
LonRange = [20.000 380.000];
LatRange = [-90.000 90.000];
TimeRange = [1800 str2num(datestr(date,10))];
DepthRange = [0.0 5500.0];
DepthUnits = 'Meters';
Resolution = 111.0;

% Force gridcat to ignore the axes popup window by forcing the axes order.
axes_order = [3 2 1];

DataName = 'Water Column - World Ocean Atlas 1994 Annual - PMEL';

% these names tie in to the browser as recognized common strings
% linking different datasets
SelectableVariables = str2mat('Sea_Temp', 'Salinity', ...
    'Silicate','Dissolved_Oxygen', 'Oxygen_Saturation', 'Nitrate', ...
    'Phosphate','AOU');
% there must be one DODSNAME for each selectable variable
DodsName = str2mat('TEMP','SALT','SIO3','O2','OSAT','NO3','PO4','AOU');

% note: DataNull is applied *before* scaling
DataNull = cell(size(DodsName,1)+4,1);
[DataNull(:)] = deal({nan}); 
[DataNull(5:length(DataNull))] = deal({-9999999790214767953607394487959552.0});

Data_Use_Policy = '';

Acknowledge = sprintf('%s\n%s\n%s\n%s\n%s', ...
    [ 'These data were prepared by Sydney Levitus, Timothy Boyer, ', ...
      'Russell Burgett, and Margarita Conkright of the National ', ...
      'Oceanographic Data Center (NODC). ', ...
      'and provided by the Ferret development group of ', ...
      'the Thermal Modeling and Analysis Project at NOAA''s Pacific ', ...
      'Marine Environmental Laboratory in Seattle Washington (PMEL: ', ...
      'http://www.pmel.noaa.gov  Ferret: http://ferret.pmel.noa.gov).', ...
      '  The data were accessed via the Distributed Oceanographic Data ',...
      'System (DODS: http://www.unidata.ucar.edu/packages/dods).'], ...
    [ 'Citations: ', ...
      'Conkright, M.E., S. Levitus and T.P. Boyer.  1994. World Ocean Atlas',...
      '1994 Volume 1: Nutrients.  NOAA Atlas NESDIS 1.  U.S. Department of',...
      'Commerce, Washington, D.C.  150 pp.'],...
    [ 'Levitus S. and T.P. Boyer.  1994a. World Ocean Atlas 1994 Volume 2:',...
      'Oxygen. NOAA Atlas NESDIS 2.  U.S. Department of Commerce, Washington,',...
      'D.C.  186 pp.'],...
    [ 'Levitus S., R. Burgett and T.P. Boyer.  1994b. World Ocean Atlas 1994',...
      'Volume 3: Salinity. NOAA Atlas NESDIS 3.  U.S. Department of Commerce,',...
      'Washington, D.C.  99 pp.'],...
    [ 'Levitus S. and T.P. Boyer.  1994c. World Ocean Atlas 1994 Volume 4:',...
      'Temperature.  NOAA Atlas NESDIS 4.  U.S. Department of Commerce,',...
      'Washington, D.C. 117 pp.']);

% COMMENTS
Comments1 = sprintf('%s\n', ...
    '                       World Ocean Atlas (1994)', ...
    '                              Annual fields', ...
    '    ', ...
    '    The WOA94 climatology is constructed using high-quality research data from', ...
    '    NODC archives that was collected using XBTs, CTDs, and hydrographic bottles',...
    '    between 1900 and the first quarter of 1993 (Levitus and Boyer 1994).  Most ',...
    '    observations, however, were collected after 1950.  Observations were binned ',...
    '    in a one-degree grid over the entire globe and compared with a "first-guess"',...
    '    estimate based on one-degree zonal averages for the ocean basin in question.',...
    '    A correction factor based on the difference between the "first-guess" and ',...
    '    the one-degree square mean was applied to the "first-guess" parameter, and ',...
    '    the results were median filtered to yield annual (also, monthly and seasonal, qv)',...
    '    climatologies resolved at one degree in latitude and longitude. The WOA94 ',...
    '    procedures were developed and applied to not only create surface climatologies ',...
    '    but those at standard depth levels as well. ', ...
    '     ', ...
    '    The dataset consists of temperature, salinity, oxygen and nutrient levels ', ...
    '    (silicate, nitrate, phosphate, oxygen and apparent oxygen utilization) in the ',...
    '    world ocean. It was prepared by Sydney Levitus, Timothy Boyer, Russell Burgett,', ...
    '    and Margarita Conkright of the National Oceanographic Data Center (NODC). The ', ...
    '    atlas continues and extends the 1982 Climatological Atlas by Levitus.');

Comments2 = sprintf('%s\n', ...
    '    ', ...
    '    Table 1.  Precision and number of profiles for each parameter.', ...
    '    ----------------------------------------------------------------',...
    '                                                      Maximum',...
    '                                                        stored          # of',...
    '    Parameter            Unit               precision        Profiles',...
    '    ----------------------------------------------------------------',...
    '    Temperature         degrees C             xx.xxx      4,553,426',...
    '    Salinity                     p.s.u.                xx.xxx      1,254,771',...
    '    Oxygen                      ml/l                   xx.xx        367,635',...
    '    Phosphate            micromolar             xx.xx        184,153',...
    '    Silicate                  micromolar             xxx.x        110,413',...
    '    Nitrate                   micromolar              xx.x         75,403',...
    '    ----------------------------------------------------------------',...
    '    (from the Lamont Ocean Climate Library,', ...
    '    http://ingrid.ldeo.columbia.edu/SOURCES/.LEVITUS94/.dataset_documentation.html)',...
    '    ',...
    '    The standard depths at which these observations have been ',...
    '    gridded are (in meters): 0, 10, 20, 30, 50, 75, 100, 125, ',...
    '    150, 200, 250, 300, 400, 500, 600, 700, 800, 900, 1000, 1100, ',...
    '    1200, 1300, 1400 1500, 1750, 2000, 2500, 3000, 3500, 4000, 4500, ',...
    '    5000, and 5500.');
    
    
Comments3 = sprintf('%s\n', ...
    '       ',...
    '                         References',...
    '       ',...
    '    Conkright, M.E., S. Levitus and T.P. Boyer.  1994. World Ocean Atlas',...
    '     1994 Volume 1: Nutrients.  NOAA Atlas NESDIS 1.  U.S. Department of',...
    '     Commerce, Washington, D.C.  150 pp.',...
    '    ',...
    '     Levitus S. and T.P. Boyer.  1994a. World Ocean Atlas 1994 Volume 2:',...
    '     Oxygen. NOAA Atlas NESDIS 2.  U.S. Department of Commerce, Washington,',...
    '     D.C.  186 pp.',...
    '    ',...
    '     Levitus S., R. Burgett and T.P. Boyer.  1994b. World Ocean Atlas 1994',...
    '     Volume 3: Salinity. NOAA Atlas NESDIS 3.  U.S. Department of Commerce,',...
    '     Washington, D.C.  99 pp.',...
    '     ',...
    '     Levitus S. and T.P. Boyer.  1994c. World Ocean Atlas 1994 Volume 4:',...
    '     Temperature.  NOAA Atlas NESDIS 4.  U.S. Department of Commerce,',...
    '     Washington, D.C. 117 pp.',...
    '    ',...
    '     Levitus, S., R. Gelfeld, T. Boyer and D. Johnson.  1994e.  Results of the',...
    '     NODC and IOC Oceanographic Data Archaeology and Rescue Projects.  Key',...
    '     to Oceanographic Records Documentation No. 19, NODC, Washington, D.C.',...
    '     ',...
    '     Levitus, S. and R. Gelfeld.  1992.  NODC Inventory of Physical',...
    '     Oceanographic Profiles.  Key to Oceanographic Records Documentation No. 18,',...
    '     NODC, Washington, D.C.',...
    '    ',...
    '     Boyer, T.P. and S. Levitus.  1994.  Quality control and processing of',...
    '     historical temperature, salinity and oxygen data.  NOAA',...
    '     Technical Report NESDIS 81.  U.S. Department of Commerce. Washington,',...
    '     D.C.  65 pp.',...
    '     ',...
    '     Conkright, M.E., T.P. Boyer and S. Levitus.  1994.  Quality control',...
    '     and processing of historical nutrient data.  NOAA Technical Report',...
    '     NESDIS 79.  U.S. Departement of Commerce, Washington, D.C. 75 pp.');

Comments4 = sprintf('%s\n', ...
'    Time_Period_of_Content = ', ...
'         Beginning_Date:1935 ', ...
'         Ending_Date:1990 ', ...
'    Spatial_Domain = ', ...
'         Bounding Coordinates: ', ...
'              West Bounding Coordinate:0.0 ', ...
'              East Bounding Coordinate:360.0 ', ...
'              South Bounding Coordinate:-90.00 ', ...
'              North Bounding Coordinate:+90.00 ', ...
'   ', ...
'    Point_of_Contact (Science) = Sydney Levitus', ...
'         Address: E/OC5', ...
'                  National Oceanographic Data Center', ...
'                  RM 4363 Bldg SSMC3', ...
'                  1315 East-West Highway',...
'                  Silver Spring, MD 20910-3282',...
'                  USA',...
'               Telephone: (202) 626-4411', ...
'               Telephone: (202) 673-5411', ...
'         Electronic Mail Address:INTERNET > Sydney.Levitus@noaa.gov', ...
'     ',...
'    Point_of_Contact (Data Provision) = ', ...
'         Address: ', ...
'               Kevin O''Brien ', ...
'               NOAA/PMEL', ...
'               7600 Sand Point Way NE', ...
'               Seattle, Washington 98115-0070', ...
'               USA ', ...
'               Telephone: (206) 526-6751', ...
'         Electronic Mail Address:INTERNET > ferret@pmel.noaa.gov');

Comments = [Comments1 Comments2 Comments3 Comments4];

