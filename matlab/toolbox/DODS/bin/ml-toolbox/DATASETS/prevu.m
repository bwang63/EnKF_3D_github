%
%               FILE DESCRIBING THE URI PREVU SST DATA SET
%

% FUNCTIONS -- REQUIRED
GetFunctionName = 'getrectg';
% FUNCTIONS -- OPTIONAL
Cat_m_File = 'ffcsquery';

% VARIABLES -- OPTIONAL
CatalogServer = 'http://dods.gso.uri.edu/cgi-bin/nph-dods/catalog/avhrr.dat';

% VARIABLES -- REQUIRED
LonRange = [-96.2220 -33.7780];
LatRange = [60.5750 9.4250];
tempvar = datestr(now);
yrbase = str2num(tempvar(8:11));
nowyrfrac = yrbase + (datenum(now) - datenum(yrbase,1,1)) / 365;
% TimeRange = [1979.3 nowyrfrac];    
TimeRange = [1979.3 str2num(datestr(date,10))+2];
DepthRange = [0 0];
Resolution = 5.5446;

% Force gridcat to ignore the axes popup window by forcing the axes order
axes_order = [2 1 0 0];

DataName = 'SST - 5.5km Browse AVHRR - URI';

SelectableVariables = str2mat('Sea_Temp');
DodsName = 'dsp_band_1';

% note: DataNull is applied *before* scaling
DataNull = [NaN NaN NaN NaN 0];
DataScale = [NaN NaN; NaN NaN; NaN NaN; NaN NaN;  0.0  0.125];
DataRange = [NaN NaN; NaN NaN; NaN NaN; NaN NaN;  0.625 31.875];

Acknowledge = sprintf('%s\n%s', ...
    [ 'The authors of this dataset are R. Evans and  P. Cornillon.  ', ...
      'The data were provided by the Graduate School of Oceanography at ',...
      'University of Rhode Island ', ...
      '(http://rs.gso.uri.edu/avhrr-archive/archive.html) and accessed via ', ...
      'the Distributed Oceanographic Data System (DODS: ', ...
      'http://www.unidata.ucar.edu/packages/dods).'], ...
    [ 'Citation:  P. Cornillon, C. Gilman, L. Stramma, O. Brown, R. Evans and',...
      'J. Brown (1987). Processing and analysis of large volumes of ',...
      'satellite-derived thermal infrared data. J. Geophys. Res., 92,',...
      '12993-13002. ']);

% COMMENTS
Comments1 = sprintf('%s\n', ...
'                           URI 5.5km Browse AVHRR SST', ...
'     ', ...
'    This is the University of Rhode Island, Graduate School of Oceanographys ', ...
'    archive of sea surface temperature satellite images. These images are ', ...
'    processed Advanced Very High Resolution Radiometer (AVHRR) data from NOAA ', ...
'    satellites. ', ...
'    ', ...
'    The archive contains in excess of 25,000 images from April 1979 to the ', ...
'    present.  New images are added to the archive every day at 10:30 GMT. During ', ...
'    the  first two years of the archive holdings, coverage is quite spotty, but ', ...
'    subsequent years generally have several images for each day.  Each of the ', ...
'    1024 by 1024 pixel images in the archive covers the area from latitude 60.575N ', ...
'    longitude 96.222W to latitude 9.399N longitude 33.768W using a cylindrical ', ...
'    equirectangular map projection with a resolution of approximately 5km/pixel.',...
'    The SST values in this dataset were determined using the operational MCSST ',...
'    algorithm.  Temperature data values are stored as 8 bit unsigned integer values',...
'    (digital counts 0 - 255). The data are stored in a 1024x1024 grid with a grid ',...
'    lat/lon resolution of 5.5x5.5 km at the image center. The grid origin, ',...
'    (indices (1,1)) corresponds to lat/lon of (60.575,-96.222). The temperature (T)',...
'    in degrees centigrade for a digital count of D is given by the  equation: ',...
'     ', ...
'                                        T = 0.125 * D ',...
'   ', ... 
'    Digital count values 0-3 are reserved for graphics.  A digital count of 4 ', ...
'    represents clouds.  Valid temperature values are in the range 0.625-31.875 deg. C', ...
'    with 0.5 corresponding to clouds.',...
'    Scaling can be turned off by setting all values of DataScale to NaN.',...
'   ', ... 
'    References: ', ...
'   ', ... 
'    Multi-channel improvements to satellite-derived global sea surface ', ...
'        temperatures.  E.P. McClain, W.G. Pichel, C.C. Walton, Z. Ahmad and J. ', ...
'        Sutton.  Advances in Space Research, vol. 2,  no. 6, pp43-47, 1983.', ...
'   ', ...
'    NOAA/NESDIS, 1982: Coefficients presented at the 32nd SST Research Panel ', ...
'        Meeting, Suitland, Maryland.', ...
'   ', ...
'    NOAA/NESDIS, 1985: Coefficients presented at the 48th SST Research Panel ', ...
'        Meeting, Suitland, Maryland.');

Comments2 = sprintf('%s\n', ...
'   ', ...
'    Time_Period_of_Content = ', ...
'         Beginning_Date: 1979 ', ...
'         Ending_Date: Present ', ...
'    Spatial_Domain = ', ...
'         Bounding Coordinates: ', ...
'              West Bounding Coordinate:-96.222 ', ...
'              East Bounding Coordinate:-33.768 ', ...
'              South Bounding Coordinate: 9.425 ', ...
'              North Bounding Coordinate: 60.575 ', ...
'    Units:  Once converted from digital counts ==> Degrees Centigrade ', ...
'    Resolution: .15 deg. C ', ...
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

% The preceding empty line is important.
%
% $Id: prevu.m,v 1.10 2002/08/15 14:38:06 dan Exp $

% $Log: prevu.m,v $
% Revision 1.10  2002/08/15 14:38:06  dan
% Added axes_order to avoid axes pop-up.
%
% Revision 1.9  2002/08/15 03:57:46  dan
% Added axes_order to avoid pop-up window.
%
% Revision 1.8  2002/07/18 17:05:42  dan
% Changed ending time to end of 2003 since this data set is continually updated.
%
% Revision 1.7  2002/02/09 15:21:00  dan
% Changed the end date on the time axis to TODAY
%
% Revision 1.6  2002/02/08 23:26:44  dan
% Removed Nlat, Nlon and variable names. GUI will use das/dds.
%
% Revision 1.5  2002/01/22 21:23:09  dan
% Modified CatalogServer entry for current usage.
%
% Revision 1.4  2001/01/18 19:35:44  dbyrne
%
%
% datarange is no longer in use.  changed datanull to cell in many cases.
% -- dbyrne 01/01/17
%
% Revision 1.3  2000/06/16 02:51:53  dbyrne
%
%
% Upgrades for standardization/toolbox. -- dbyrne 00/06/15
%
% Revision 1.2  2000/06/02 20:04:09  kwoklin
% Move cat server to version 1. klee
%
% Revision 1.1  2000/05/31 23:12:56  dbyrne
% *** empty log message ***
%
% Revision 1.1  2000/05/31 22:59:20  root
% *** empty log message ***
%
% Revision 1.16  2000/03/28 20:23:48  root
% Updates from release gui-3-2-0
%
% Revision 1.16  2000/03/09 17:36:48  kwoklin
% Share one cat_m_file dycat.m.   klee
%
% Revision 1.15  1999/10/27 22:18:22  dbyrne
% *** empty log message ***
%
% Revision 1.15  1999/10/27 22:10:41  root
% Fixed many spelling and grammatical errors in comment fields.
%
% Revision 1.14  1999/09/02 18:27:30  root
% *** empty log message ***
%
% Revision 1.14  1999/07/21 19:19:32  kwoklin
% Move archive server back to dods.gso.uri.edu.  klee
%
% Revision 1.13  1999/07/02 16:25:54  kwoklin
% Move server to 'maewest'.    klee
%
% Revision 1.12  1999/06/01 00:53:52  dbyrne
%
%
% Many fixes in prep for AGU.  fth, htn, glk and prevu changed to use
% fileservers. -- dbyrne 99/05/31
%
% Revision 1.2  1999/05/28 17:32:51  kwoklin
% Add all globec datasets. Fix depth representation for all globec datasets
% and nbneer dataset. Fix frontal display for htn and glkfront. Make use of
% getjgsta for all jgofs datasets. Point usgsmbay to new server. Point htn,
% glk, fth and prevu to new FF server.                                 klee
%
% Revision 1.11  1999/05/13 03:09:55  dbyrne
%
%
% Added Acknowledge and Data_Use_Policy to archive.m.  Fixed getxxx functions
% to use dodsmsg instead of stdout for errors/info.  Made ChangeLog so that it's
% in Emacs format.  All changes for release 3.0.0 -- dbyrne 99/05/12
%
% Revision 1.13  1999/05/13 01:24:18  root
% Added Acknowledge and Data_Use Policy.  Fixed some bugs.  Changed any
% messages to use to use 'dodsmsg' script instead of just displaying to stdout.
%
% Revision 1.12  1999/03/04 13:13:32  root
% All changes since AGU week.
%
% Revision 1.10  1998/12/15 19:11:13  jimg
% Modified 'DataName' to include variable type information.
%
% Revision 1.8  1998/11/18 19:57:02  dbyrne
%
%
% Second try.  Bug fixes to jpl pathfinder data, changed names of
% Reynolds datasets to clarify that one is a climatology and one is not.
%
% Revision 1.11  1998/11/05 16:01:55  root
% Changed LonVector and LatVector to be used if no Lon returned and tried the update function.
% DataScale and DataNull should now be optional!
%
% Revision 1.5  1998/09/14 01:32:57  dbyrne
% Elminated an inconsistency whereby the depth variable was not scaled
% and had no DataNull etc.  Added check for empty variables to plotscript.m
%
% Revision 1.10  1998/09/13 19:33:25  root
% updated DataNull &c.
%
% Revision 1.9  1998/09/13 19:21:25  root
% Eliminated an inconsistency in DataScale, DataRange, and DataNull, that
% Depth was not included!
%
% Revision 1.8  1998/09/11 18:01:55  dbyrne
% undid latitude range swap!
%
% Revision 1.7  1998/09/11 08:16:10  dbyrne
% Longitude ranges were messed up in every archive.m file except the
% two I wrote myself.  To eliminate future confusion, 'LLon' 'Llat',
% 'Rlon' and 'Ulat' etc are being eliminated in favor of two-component
% vectors LonRange LatRange TimeRange DepthRange.
%
% Revision 1.6  1998/09/09 20:12:18  dbyrne
% Changing variable names to stay within 14 characters.
%
% Revision 1.5  1998/09/09 16:10:28  dbyrne
% Fixed numerous small bugs.
%
% Revision 1.4  1998/09/09 07:57:39  dbyrne
% replaced Data_Scale with DataScale, Data_Null with DataNull, and Data_Range
% with DataRange for consistency with other variables in the archive.m files.
%
% Revision 1.3  1998/09/09 07:40:23  dbyrne
% Replaced getrectangular with getrectg
%
% Revision 1.2  1998/09/09 07:34:23  dbyrne
% Eliminating ReturnedVariables
%
% Revision 1.1  1998/05/17 14:18:11  dbyrne
% *** empty log message ***
%
% Revision 1.1.1.1  1997/09/22 14:13:55  tom
% Imported Matlab GUI sources to CVS
%

% make use of new FF file server            klee 05/17/99 
