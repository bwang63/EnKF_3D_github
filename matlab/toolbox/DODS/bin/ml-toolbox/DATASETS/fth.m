%
%               FILE DESCRIBING THE URI HIGH RESOLUTION SST DATA SET
%                              Florida to Cape Hatteras
%

% FUNCTIONS -- REQUIRED
GetFunctionName = 'getrectg';
% FUNCTIONS -- OPTIONAL
Cat_m_File = 'ffcsquery';

% VARIABLES -- OPTIONAL
CatalogServer = 'http://dods.gso.uri.edu/cgi-bin/nph-dods/catalog/fth.dat';

% VARIABLES -- REQUIRED
LonRange = [-82.962 -68.497];
LatRange = [35.356 24.308];
TimeRange = [1985.337 1995.3233];
DepthRange = [0 0];

Resolution = 1.236;                  % avg res.

% Force gridcat to ignore the axes popup window by forcing the axes order
axes_order = [2 1 0 0];

DataName = 'SST - Florida to Hatteras AVHRR - URI'; % Name for this dataset.

SelectableVariables = str2mat('Sea_Temp');
DodsName = 'dsp_band_1';

% note: DataNull is applied *before* scaling
DataNull = cell(size(DodsName,1)+4,1);
[DataNull(:)] = deal({nan}); 
DataNull(5) = {0};
DataScale = [NaN NaN; NaN NaN; NaN NaN; NaN NaN; 2.0  0.125];

Acknowledge = sprintf('%s\n\n%s', ...
    [ 'The authors of this dataset are R. Evans and P. Cornillon.  ', ...
      'The data were provided by the Graduate School of Oceanography at ',...
      'University of Rhode Island ', ...
      '(http://rs.gso.uri.edu/avhrr-archive/archive.html) and accessed via ', ...
      'the Distributed Oceanographic Data System (DODS: ', ...
      'http://www.unidata.ucar.edu/packages/dods).'], ...
    [ 'Citation:  P. Cornillon, C. Gilman, L. Stramma, O. Brown, R. Evans and',...
      ' J. Brown (1987). Processing and analysis of large volumes of ',...
      'satellite-derived thermal infrared data. J. Geophys. Res., 92,',...
      ' 12993-13002.']);

% COMMENTS
Comments1 = sprintf('%s\n', ...
'                  URI 1.1km Florida to Hatteras SST fields', ...
'     ', ...
'    This is a subset of the University of Rhode Island, Graduate School of ', ...
'    Oceanography''s archive of sea surface temperature satellite images. These', ...
'    images are processed Advanced Very High Resolution Radiometer (AVHRR)', ...
'    data from NOAA satellites. ', ...
'    ', ...
'    The archive contains up to 5 images per day. We are reprocessing all', ...
'    of the data in our archive which covers the period from April 1979 to', ...
'    the present.  We began the reprocessing effort with data in the late', ...
'    1980''s and are processing forward and backward in time. The NASA/NOAA', ...
'    Pathfinder SST algorithm is being used for the reprocessing. Each of the ', ...
'    1024 by 1024 pixel images in the archive covers the area from latitude 24.30N', ...
'    longitude 82.96W to latitude 35.36N longitude 68.50W using a cylindrical ', ...
'    equirectangular map projection with a resolution of approximately 1.1 km/pixel.',...
'    Temperature data values are stored as 8 bit unsigned integer values (digital', ...
'    counts 0 - 255). The temperature (T) in degrees centigrade for a digital', ...
'    count of D is given by the equation: ',...
'     ', ...
'                                        T = 0.125 * D + 2',...
'   ', ... 
'    Digital count values 0-3 are reserved for graphics.  A digital count of 4 ', ...
'    represents clouds.  Valid temperature values are in the range 2.625-33.875 C', ...
'    with 2.0-2.375 not used and 2.5 corresponding to clouds.', ...
'    Scaling can be turned off by setting all values of DataScale to NaN.');

Comments2 = sprintf('%s\n', ...
'   ', ...
'    Time_Period_of_Content = ', ...
'         Beginning_Date: 1985 ', ...
'         Ending_Date: 1990 ', ...
'    Spatial_Domain = ', ...
'         Bounding Coordinates: ', ...
'              West Bounding Coordinate: 82.962 W ', ...
'              East Bounding Coordinate: 68.497 W ', ...
'              South Bounding Coordinate: 24.308 N ', ...
'              North Bounding Coordinate: 35.356 N ', ...
'    Units:  Once converted from digital counts ==> Degrees Centigrade ', ...
'    Resolution: .125 deg. C ', ...
'   ', ...
'    Point_of_Contact = ', ...
'         Address: ', ...
'               Peter Cornillon ', ...
'               Graduate School of Oceanography ', ...
'               University of Rhode Island ', ...
'               South Ferry Road ', ...
'               Narragansett, Rhode Island  02882 ', ...
'               USA ', ...
'         Electronic Mail Address:INTERNET > support@unidata.ucar.edu ');

Comments = [Comments1 Comments2];

%
% $Log: fth.m,v $
% Revision 1.9  2002/08/15 03:57:46  dan
% Added axes_order to avoid pop-up window.
%
% Revision 1.8  2002/04/08 21:33:19  dan
% Fixed time range.
%
% Revision 1.7  2002/02/08 23:11:22  dan
% Removed Nlat, Nlon and variable names. GUI will use das/dds.
%
% Revision 1.6  2002/01/22 21:21:59  dan
% Modified CatalogServer entry for current usage.
%
% Revision 1.5  2001/01/18 19:35:44  dbyrne
%
%
% datarange is no longer in use.  changed datanull to cell in many cases.
% -- dbyrne 01/01/17
%
% Revision 1.4  2000/06/16 02:51:53  dbyrne
%
%
% Upgrades for standardization/toolbox. -- dbyrne 00/06/15
%
% Revision 1.2  2000/06/15 22:46:42  root
% *** empty log message ***
%
% Revision 1.1  2000/05/31 22:59:20  root
% *** empty log message ***
%
% Revision 1.17  2000/05/24 23:40:04  root
% Removed unused 'Server' line. -- dbyrne 00/05/25
%
% Revision 1.16  2000/04/12 01:20:39  root
% *** empty log message ***
%
% Revision 1.12  2000/03/09 17:36:48  kwoklin
% Share one cat_m_file dycat.m.   klee
%
% Revision 1.11  1999/10/27 22:18:22  dbyrne
% *** empty log message ***
%
% Revision 1.15  1999/10/27 22:10:40  root
% Fixed many spelling and grammatical errors in comment fields.
%
% Revision 1.14  1999/09/02 18:27:24  root
% *** empty log message ***
%
% Revision 1.10  1999/06/01 00:53:51  dbyrne
%
%
% Many fixes in prep for AGU.  fth, htn, glk and prevu changed to use
% fileservers. -- dbyrne 99/05/31
%
% Revision 1.2  1999/05/28 17:32:48  kwoklin
% Add all globec datasets. Fix depth representation for all globec datasets
% and nbneer dataset. Fix frontal display for htn and glkfront. Make use of
% getjgsta for all jgofs datasets. Point usgsmbay to new server. Point htn,
% glk, fth and prevu to new FF server.                                 klee
%

% $Id: fth.m,v 1.9 2002/08/15 03:57:46 dan Exp $
% make use of new FF file server            klee 05/17/99 
