%
% FSU Pacific Climatological Monthly Pseudostress Averages 1966-1985

GetFunctionName = 'getrectg';
Server='http://www.coaps.fsu.edu/cgi-bin/nph-nc/WOCE/SAC/fsuwinds/pacftp/pac_pstress.clim.66-85.nc';

LonRange = [123 291];
LatRange = [-30 30];
TimeRange = [1800 str2num(datestr(date,10))];
DepthRange = [0.0 0.0];
Resolution = 222;

% Force gridcat to ignore the axes popup window by forcing the axes order
axes_order = [3 2 0 1];

DataName = 'Wind - Pacific Monthly Climatology Pseudostress (1966-1985) - FSU';
SelectableVariables = str2mat('Wind_Pseudostress_U', 'Wind_Pseudostress_V');
DodsName = str2mat('Wu', 'Wv');

DataNull = cell(size(DodsName,1)+4,1);
[DataNull(:)] = deal({nan}); 
[DataNull(5:length(DataNull))] = deal({9990});
DataScale = [NaN NaN; NaN NaN; NaN NaN; NaN NaN; 0 0.1; 0 0.1];

Acknowledge = [];
Data_Use_Policy = [];

Comments1 = sprintf('%s\n', ...
'              FSU Pacific Climatological Monthly Pseudostress Averages 1966-1985', ...
'     ', ...
'    These data are monthly averaged observations based on data available during the ',...
'    time period 1966-1985 for that month binned on a global 2x2 degree grid (i.e., the ',...
'    dataset contains 12 grids, one for each month of the year).',...
'    ', ...
'    The data set has been created by screening, binning and subjectively analysing ',...
'    individual observations on 2-deg latitude, 10-deg longitude grid, and is digitized ',...
'    onto 2x2-deg grid. The analysis for the years 1961-1965 are based on the Wyrtki-Meyers ',...
'    data set, while the analysis for the years 1966-1980 is based on the COADS data set.',...
'    ', ...
'    References',...
'    ', ...
'    Legler, D.M., and J.J. O''Brien, 1988: Tropical Pacific wind stress analysis for TOGA, ',...
'    IOC Time series of ocean measurements, IOC Technical Series 33, Volume 4, UNESCO. ',...
'    ',...
'    Stricherz, Jame N., J. J. O''Brien, and D. M. Legler, 1992: Atlas of Florida State ',...
'    University Tropical Pacific Winds for TOGA 1966-1985, Florida State University, ',...
'    Tallahassee, FL, 250 pp. ',...
'    ',...
'    Stricherz, James N., David M. Legler, and James J. O''Brien, 1997: TOGA Pseudo-stress Atlas',...
'    1985-1994, Volume II: Pacific Ocean, Florida State University, Tallahassee, FL, 155 pp. ',...
'    ', ...
'    Wyrtki, K. and G. Meyers, 1975: The trade wind field over the Pacific Ocean. Part I. The ',...
'    mean field and mean annual variation. Hawaii Inst. Geophys., University of Hawaii. HIG-',...
'    75-1, 26 pp. ',...
'    ',...
'    Slutz, R. J., S. J. Lubker, J. D. Hiscox, S. D. Woodruff, R. L. Jenne, D. H. Joseph, P. M.',...
'    Seurer and J. D. Elms, COADS-Comprehenisve Ocean-Atmosphere Data Set, CIRES/ERL/NCAR/NCDC, ',...
'    Boulder, CO, 1985. .');

Comments2 = sprintf('%s\n', ...
'   ', ...
'    Time_Period_of_Content = ', ...
'         Beginning_Date: Jan. 1, 1966 ', ...
'         Ending_Date: Dec. 31, 1985 ', ...
'    Spatial_Domain = ', ...
'         Bounding Coordinates: ', ...
'              West Bounding Coordinate:   70 W ', ...
'              East Bounding Coordinate:  124 E ', ...
'              South Bounding Coordinate:  29 S ', ...
'              North Bounding Coordinate:  29 N ', ...
'    Units:  m2/s2 ', ...
'    Spatial Resolution: 220 km', ...
'   ', ...
'    Point_of_Contact = ', ...
'         Address - dods: ', ...
'         Electronic Mail Address: INTERNET >  support@unidata.ucar.edu');

Comments = [Comments1 Comments2];
