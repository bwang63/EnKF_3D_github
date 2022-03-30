%               REYNOLDS SST WEEKLY MEANS

% The preceding empty line is important.
%
% Reynolds data at NOAA in Boulder.
% Note that the weekly data in Boulder are spread between two files:
% sst.wkmean.1981-1989.nc and sst.wkmean.1990-1996.nc. Also note that users
% will need DODS-2.15 or greater on the client side to read the data.

% FUNCTIONS -- REQUIRED
GetFunctionName = 'getrectg'; 
% FUNCTIONS -- OPTIONAL

% VARIABLES -- OPTIONAL
Server = 'http://www.cdc.noaa.gov/cgi-bin/nph-nc/Datasets/reynolds_sst/sst.wkmean.1990-present.nc';

% VARIABLES -- REQUIRED
LonRange = [0.0 360.0];
LatRange = [90.0 -90.0];
TimeRange = [1990 str2num(datestr(date,10))+2];
DepthRange = [0 0];
DepthUnits = '';
Resolution = 111.0;

% Force gridcat to ignore the axes popup window by forcing the axes order
axes_order = [3 2 0 1];

DataName = 'Reynolds Weekly Mean 1990-present - NCEP';   

Acknowledge = sprintf('%s\n%s', ...
    [ 'The authors of this dataset are R.W. Reynolds and T. M. Smith.  ', ...
      'The data were provided by the NOAA-CIRES Climate Diagnostics Center ', ...
      '(http://www.cdc.noaa.gov) and accessed via ', ...
      'the Distributed Oceanographic Data System (DODS: ', ...
      'http://www.unidata.ucar.edu/packages/dods).'], ...
    [ 'Citation: Reynolds, R. W. and T. M. Smith (1995).  A ', ...
      'high-resolution global sea surface temperature climatology.  ', ...
      'Journal of Climate 8, 1571--1583. ']);

SelectableVariables = str2mat('Sea_Temp');
DodsName = 'sst';

% note: DataNull is applied *before* scaling
DataScale = [0 1; NaN NaN; NaN NaN; NaN NaN; 0.0 0.01];

Data_Use_Policy = sprintf('%s%s%s', ...
    'Availability and usage restrictions: ', ...
    'Anonymous ftp at ftp.cdc.noaa.gov ', ...
    '~ftp/Datasets/reynolds_sst');

%Acknowledge = sprintf('%s\n\n%s', ...
%    [ 'These data were produced by the Coupled Model Project W/NMCx3', ...
%      'National Meteorological Center, World Weather Building, Room 807', ...
%      '5200 Auth Road, Camp Springs, MD 20746 USA.  ', ...
%      'The data were provided by the Graduate School of Oceanography at ',...
%      'University of Rhode Island ', ...
%      '(http://rs.gso.uri.edu/avhrr-archive/archive.html) and accessed via ', ...
%      'the Distributed Oceanographic Data System (DODS: ', ...
%      'http://www.unidata.ucar.edu/packages/dods).'], ...
%    [ 'Citation: Reynolds, R. and D. C. Marsico (1993), An ',...
%      'improved real-time global ', ...
%      'sea surface temperature analysis.  Journal of Climate 6, 114-119. ', ...
%      ]);

% COMMENTS
Comments1 = sprintf('%s\n', ...
'                               Reynolds Weekly Mean SST', ...
'   ', ...
'    This dataset is an optimally-interpolated SST analysis (Reynolds and ', ...
'    Smith 1995).  The optimum interpolation (OI) sea surface temperature', ...
'    (SST) analysis is produced weekly on a one-degree grid.  The analysis', ...
'    uses in situ and satellite SSTs plus SSTs simulated by sea-ice', ...
'    cover.  Before the analysis is computed, the satellite data is adjusted', ...
'    for biases using the method of Reynolds (1988) and Reynolds and ', ...
'    Marsico (1993).  A description of the OI analysis can be found in ', ...
'    Reynolds and Smith (1994)', ...
'    ', ....
'    The bias correction improves the large scale accuracy of the OI.', ...
'    Examples of the effect of recent corrections is given by Reynolds (1993)', ...
'    The bias correction does add a small amount of noise in time.  Most', ...
'    of the noise can be eliminated by using a 1/4 - 1/2 - 1/4 binomial', ...
'    filter in time.  The dataset author STRONGLY recommends that this', ...
'    filter be applied to the data fields before they are used.  An improved', ...
'    method of correcting the biasses is being developed', ...
'    ', ...
'    For a complete description of the data as given by the providers ', ...
'    and references for the papers cited in the description please see ', ...
'    their information file.  The dates used in the DODS file are the', ...
'    beginning of the average period. ', ...
'    ', ...
'    For more information see the Reynolds SST information web site:', ...
'    http://www.cdc.noaa.gov/cdc/reynolds_sst.info.html ', ...
'   ');

Comments2 = sprintf('%s\n', ...
'    For these data (1990 - present), the in situ data were ', ...
'    obtained from radio messages carried on the Global Telecommunications ', ...
'    System.  The satellite observations were obtained from operational ', ...
'    data produced by the National Environmental Satellite, Data and ', ...
'    Information Service (NESDIS).  For this period the weeks were defined ', ...
'    to be centered on Wednesday.  This was done to agree with the ', ...
'    definition used for ocean modeling.  ', ...
'    ', ...
'    The times are in elapsed days from 1/1/1 0:00:00. Note that January 1, 1981', ...
'    is day 723182.  Day2year(time,1) will return the time in (more intelligible) ',...
'    decimal years.', ...
'    Longitude runs from 0.5 to 359.5 (pixel grid centers)', ...
'    Latitude runs from 89.5N to 89.5S (pixel grid centers)', ...
'    Temperature data (D) are given in integer units of 0.01 degrees C. ', ...
'    ', ...
'                                  T = 0.01*D  ', ...
'    ', ...
'    SST at (110.5W,10.5S) from the beginning of 1992 should be as follows:', ...
'            91/12/29 - 92/01/04 = 24.88 ', ...
'            92/01/05 - 92/01/11 = 25.48 ', ...
'            92/01/12 - 92/01/18 = 25.40 ', ...
'            92/01/19 - 92/01/25 = 25.58 ', ...
'            92/01/26 - 92/02/01 = 25.76 ', ...
'    ', ...
'    References: ', ...
'    ', ...
'    Reynolds, R. W. (1988), A real-time global sea surface temperature ', ...
'       analysis.  J. Climate, 1, 75-86. ', ...
'   ', ...
'    Reynolds, R. W. (1993), Impact of Mount Pinatubo aerosols on ', ...
'       satellite-derived sea surface temperatures.  J. Climate 6, ', ...
'       768-774 ', ...
'   ', ...
'    Reynolds, R. and D. C. Marsico (1993), An improved real-time global ', ...
'       sea surface temperature analysis.  Journal of Climate 6, 114-119 ', ...
'   ', ...
'    Reynolds, R. and T. Smith (1994). Improved global sea surface temperature ', ...
'       analyses using optimum interpolation.  Journal of Climate 7, 929--948. ', ...
'    ', ...
'    Reynolds, R. W. and T. M. Smith (1995). A high-resolution global sea surface ',...
'       temperature climatology.  Journal of Climate 8, 1571--1583. ');

Comments3 = sprintf('%s\n', ...
'    ', ...
'    Units:  0.01 Degrees Centigrade ', ...
'    Resolution: .15 deg. C ', ...
'    Accuracy: ', ...
'    Time_Period_of_Content = ', ...
'         Beginning_Date:1990 ', ...
'         Ending_Date: present', ...
'    Spatial_Domain = ', ...
'         Bounding Coordinates: ', ...
'              West Bounding Coordinate:0.0 ', ...
'              East Bounding Coordinate:360.0 ', ...
'              South Bounding Coordinate:-90.0 ', ...
'              North Bounding Coordinate:+90.0 ', ...
'    ', ...
'    Point_of_Contact (Science) = ', ...
'         Address: ', ...
'               Richard W. Reynolds ', ...
'               Climate Modelling Branch W/NP24', ...
'               NCEP/NWS/NOAA ', ...
'               5200 Auth Road, Room 807', ...
'               Camp Springs, Maryland 20746 ', ...
'               USA ', ...
'               Telephone: (301) 763-8000 ext 7580', ...
'         Electronic Mail Address:INTERNET > rreynolds@sun1.wwb.noaa.gov', ...
'    Point_of_Contact (Data Provision) = ', ...
'         Address: ', ...
'              CDC Data Management', ...
'              Climate Diagnostics Center', ...
'              NOAA/ERL R/E/CD', ...
'              325 Broadway', ...
'              Boulder, CO  80303', ...
'         Electronic Mail Address:INTERNET > support@unidata.ucar.edu ');

Comments = [Comments1 Comments2 Comments3]; 
