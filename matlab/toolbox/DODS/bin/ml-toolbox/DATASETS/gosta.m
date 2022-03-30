%
%               FILE DESCRIBING THE GOSTA SST CLIMATOLOGY

% The preceding empty line is important.
% Fixed to use dds and das 1/28/02 pcc

% FUNCTIONS -- REQUIRED
GetFunctionName = 'getrectg';
% FUNCTIONS -- OPTIONAL
Cat_m_File = 'climcat';

% VARIABLES -- OPTIONAL
CatalogServer = 'http://dods.gso.uri.edu/cgi-bin/nph-dods/catalog/gosta.dat';
% Nlon = 72;
% Nlat = 36;

% VARIABLES -- REQUIRED
LonRange = [-180.0 180.0];
LatRange = [90.0 -90.0];
DepthRange = [0.0 0.0];
DepthUnits = '';
TimeRange = [1800 str2num(datestr(date,10))];
Resolution = 540.0;

% Force gridcat to ignore the axes popup window by forcing the axes order
axes_order = [2 1 0 0];

DataName = 'SST - GOSTA Global Atlas - URI';
%LongitudeName = 'lon';
%LatitudeName = 'lat';
%TimeName = '';
%DepthName = '';
SelectableVariables = str2mat('Sea_Temp');
DodsName = str2mat('dsp_band_1');

% note: DataNull is applied *before* scaling
DataNull = cell(size(DodsName,1)+4,1);
[DataNull(:)] = deal({nan}); 
DataNull(5) = {0};
DataScale = [NaN NaN; NaN NaN; NaN NaN; NaN NaN; -3.0 0.15];

Acknowledge = sprintf('%s\n\n%s\n%s\n%s\n%s\n%s', ...
    [ 'The authors of this dataset are M. Bottomley, C. Folland, ',...
      'J. Hsiung, R. Newell, and D. Parker.  ', ...
      'The data were provided by the Graduate School of Oceanography ', ...
      'at University of Rhode Island. (http://www.gso.uri.edu), ',...
      'and accessed via ', ...
      'the Distributed Oceanographic Data System (DODS: ', ...
      'http://www.unidata.ucar.edu/packages/dods). ',...
      'A more recent version of this dataset, GOSTAplus, is',...
      'provided by British Atmospheric Data Center and MIT. ',...
      '(http://www.badc.rl.ac.uk/data/gosta).'], ...
    [ 'Citation:  Bottomley, M., C. Folland, J. Hsiung, R. Newell, and D. Parker ',...
      '(1990). Global ocean surface temperature atlas (GOSTA). Technical ',...
      'report, Joint Meteorological Office/Massachusetts Institute of ',...
      'Technology Project, HMSO London. '],...
    [ 'Folland, C., T. Karl, and K. Vinnikov (1990). Observed climate ',...
      'variations and change. In J. Houghton, G. Jenkins, and J. Ephraums ',...
      '(Eds.), Climate Change, The IPCC Scientific Assessment Chapter 7, ',...
      'pp. 195--238. Cambridge University Press.'], ...
    [ 'Folland, C., T. Karl, N. Nicholls, B. Nyenzi, D. Parker, and K. ', ...
      'Vinnikov(1992). Observed climate variability and change.  In Climate ', ...
      'Change 1992:  The Supplementary Report to the IPCC Scientific ',...
      'Assessment, pp.135--170. Cambridge University Press.'], ...
    [ 'Jones, P., T. Wigley, and G. Farmer (1991). Marine and land temperature ',...
      'data sets: A comparison and a look at recent trends.  In M. Schlesinger ',...
      '(Ed.), Greenhouse-Gas-Induced Climatic Change: A Critical Appraisal of ', ...
      'Simulations and Observations, Chapter 3, pp. 153--172. Elsevier.'], ...
    [ 'Parker, D., P. Jones, C. Folland, and A. Bevan (1994). Interdecadal ',...
      'changes of surface temperature since the late nineteenth century.  ',...
      'J. of Geophys. Res. (99)(D7), 14373--14399.']);



% COMMENTS
Comments1 = sprintf('%s\n', ...
'                   Global Ocean Surface Temperature Atlas', ...
' ', ...
'    The GOSTA climatology was created from volunteer observing ship data found in ', ...
'    version 4 of the Meteorological Office Historical Sea Surface Temperature data ', ...
'    bank (Bottomley et al. 1990). This monthly climatology is resolved to five ', ...
'    degrees in latitude and longitude, and is referenced to a 1951-1980 base ', ...
'    period. It has been used in numerous studies of SST warming (Folland et al. ', ...
'    1990; Jones et al. 1991; Folland et al. 1992; Parker et al. 1994) either ', ...
'    directly or as the basis of an improved analysis.', ... 
'     ', ...
'    The URI version of this dataset has been interpolated from the original ', ...
'    temperature values and stored as 8 bit unsigned integer value (digital counts ', ...
'    0 - 255). The data are stored in a 36x72 grid with a grid lat/lon resolution ', ...
'    of 5x5 degrees. The grid origin (indices (1,1)) corresponds to a lat/lon of ', ...
'    (87.5,-177.5). The temperature (T) in degrees centigrade for given digital ', ...
'    count (D) is given by the equation: ', ...
'    ', ...
'                                  T = -3.0 + 0.15D ', ...
'    ', ...
'    Digital count values of 0 represent land, digital count values of 1 represent ', ...
'    ice and counts 2-7 are reserved. Valid temperature values are in the range ', ... 
'    -1.8 - 35.25 deg. C', ...
'    ', ...
'    References: ', ...
'     ', ...
'    Bottomley, M., C. Folland, J. Hsiung, R. Newell, and D. Parker (1990).  ', ...
'        Global ocean surface temperature atlas (GOSTA). Technical report, Joint ', ...
'        Meteorological Office/Massachusetts Institute of Technology Project, HMSO ', ...
'        London.', ...
'     ', ...
'    Folland, C., T. Karl, and K. Vinnikov (1990). Observed climate variations and ', ...
'        change. In J. Houghton, G. Jenkins, and J. Ephraums (Eds.), Climate ', ...
'        Change, The IPCC Scientific Assessment, Chapter~7, pp. 195--238. Cambridge ', ...
'        University Press.', ...
'     ', ...
'    Folland, C., T. Karl, N. Nicholls, B. Nyenzi, D. Parker, and K. ', ...
'        Vinnikov(1992). Observed climate variability and change.  In Climate ', ...
'        Change 1992:  The Supplementary Report to the IPCC Scientific Assessment, ', ...
'        pp.135--170. Cambridge University Press.', ...
'     ', ...
'    Jones, P., T. Wigley, and G. Farmer (1991). Marine and land temperature data ', ...
'        sets: A comparison and a look at recent trends.  In M. Schlesinger (Ed.), ', ...
'        Greenhouse-Gas-Induced Climatic Change: A Critical Appraisal of ', ...
'        Simulations and Observations, Chapter 3, pp. 153--172. Elsevier.', ...
'     ', ...
'    Parker, D., P. Jones, C. Folland, and A. Bevan (1994). Interdecadal changes ', ...
'        of surface temperature since the late nineteenth century.  Journal of ', ...
'        Geophysical Research (99)(D7), 14373--14399. ');
Comments2 = sprintf('%s\n', ...
'     ', ...
'Units:  Degrees Centigrade ', ...
'Resolution: .15 deg. C ', ...
'Accuracy: ', ...
'    Time_Period_of_Content = ', ...
'         Beginning_Date:1951 ', ...
'         Ending_Date:1980 ', ...
'    Spatial_Domain = ', ...
'         Bounding Coordinates: ', ...
'              West Bounding Coordinate:-180.0 ', ...
'              East Bounding Coordinate:180.0 ', ...
'              South Bounding Coordinate:-90.0 ', ...
'              North Bounding Coordinate:+90.0 ', ...
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
% $Id: gosta.m,v 1.6 2002/08/16 22:42:55 dan Exp $

% $Log: gosta.m,v $
% Revision 1.6  2002/08/16 22:42:55  dan
% Added axes_order to avoid axes order pop-up.
%
% Revision 1.5  2002/02/09 15:19:54  dan
% Changed the end date on the time axis to this year.
%
% Revision 1.4  2002/02/08 22:46:18  dan
% Removed Nlat, Nlon and variable names. GUI will use das/dds.
%
% Revision 1.3  2002/01/22 21:24:20  dan
% Modified CatalogServer entry for current usage.
%
% Revision 1.2  2001/01/18 19:35:44  dbyrne
%
%
% datarange is no longer in use.  changed datanull to cell in many cases.
% -- dbyrne 01/01/17
%
% Revision 1.1  2000/05/31 23:12:55  dbyrne
% *** empty log message ***
%
% Revision 1.1  2000/05/31 22:59:20  root
% *** empty log message ***
%
% Revision 1.17  1999/10/27 22:10:40  root
% Fixed many spelling and grammatical errors in comment fields.
%
% Revision 1.16  1999/09/02 18:27:26  root
% *** empty log message ***
%
% Revision 1.11  1999/07/02 16:25:54  kwoklin
% Move server to 'maewest'.    klee
%
% Revision 1.10  1999/05/13 03:09:55  dbyrne
%
%
% Added Acknowledge and Data_Use_Policy to archive.m.  Fixed getxxx functions
% to use dodsmsg instead of stdout for errors/info.  Made ChangeLog so that it's
% in Emacs format.  All changes for release 3.0.0 -- dbyrne 99/05/12
%
% Revision 1.15  1999/05/13 01:24:16  root
% Added Acknowledge and Data_Use Policy.  Fixed some bugs.  Changed any
% messages to use to use 'dodsmsg' script instead of just displaying to stdout.
%
% Revision 1.14  1999/03/04 13:13:28  root
% All changes since AGU week.
%
% Revision 1.9  1998/12/15 19:14:35  jimg
% Modified 'DataName' to include variable type information.
%
% Revision 1.8  1998/11/18 19:57:01  dbyrne
%
%
% Second try.  Bug fixes to jpl pathfinder data, changed names of
% Reynolds datasets to clarify that one is a climatology and one is not.
%
% Revision 1.13  1998/11/05 16:01:53  root
% Changed LonVector and LatVector to be used if no Lon returned and tried the update function.
% DataScale and DataNull should now be optional!
%
% Revision 1.5  1998/09/14 01:32:55  dbyrne
% Elminated an inconsistency whereby the depth variable was not scaled
% and had no DataNull etc.  Added check for empty variables to plotscript.m
%
% Revision 1.12  1998/09/13 19:33:23  root
% updated DataNull &c.
%
% Revision 1.11  1998/09/13 19:21:23  root
% Eliminated an inconsistency in DataScale, DataRange, and DataNull, that
% Depth was not included!
%
% Revision 1.10  1998/09/12 15:27:47  root
% Fixed some small bugs.
%
% Revision 1.9  1998/09/11 17:52:19  dbyrne
% undid latitude range swap!
%
% Revision 1.8  1998/09/11 08:16:08  dbyrne
% Longitude ranges were messed up in every archive.m file except the
% two I wrote myself.  To eliminate future confusion, 'LLon' 'Llat',
% 'Rlon' and 'Ulat' etc are being eliminated in favor of two-component
% vectors LonRange LatRange TimeRange DepthRange.
%
% Revision 1.7  1998/09/09 20:12:16  dbyrne
% Changing variable names to stay within 14 characters.
%
% Revision 1.6  1998/09/09 15:04:28  dbyrne
% Eliminating all global variables.
%
% Revision 1.5  1998/09/09 09:23:13  dbyrne
% Changes to make creation of a 'time' variable more sensible.
%
% Revision 1.4  1998/09/09 07:57:37  dbyrne
% replaced Data_Scale with DataScale, Data_Null with DataNull, and Data_Range
% with DataRange for consistency with other variables in the archive.m files.
%
% Revision 1.3  1998/09/09 07:40:21  dbyrne
% Replaced getrectangular with getrectg
%
% Revision 1.2  1998/09/09 07:34:21  dbyrne
% Eliminating ReturnedVariables
%
% Revision 1.1  1998/05/17 14:18:05  dbyrne
% *** empty log message ***
%
% Revision 1.1.1.1  1997/09/22 14:13:54  tom
% Imported Matlab GUI sources to CVS
%
