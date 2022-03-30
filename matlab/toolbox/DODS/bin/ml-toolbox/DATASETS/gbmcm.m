%
%  BIO/Globec Moored Current Meter Data

%
% $Log: gbmcm.m,v $
% Revision 1.1  2000/09/19 20:50:41  kwoklin
% First toolbox internal release.   klee
%

% $Id: gbmcm.m,v 1.1 2000/09/19 20:50:41 kwoklin Exp $
% klee 08/2000
% klee 03/1999

GetFunctionName = 'getjgsta';
CatalogServer = 'http://dods.gso.uri.edu/cgi-bin/nph-ff/catalog/gbmcm.dat'; 
Cat_m_File = 'gbcat';
URL_m_File = 'gburl';

LonRange = [-66.70 -65.40];
LatRange = [41.00 43.06];
TimeRange = [1993.7 1999.8];
DepthRange = [10 196];
Resolution = nan;

DodsName = str2mat('temp','sal','curr_dir_abs','curr_speed_abs');
DataName = 'Water Column - Moored Current Meter Data: Eastern Gulf of Maine/Scotian Shelf - BIO/GLOBEC';
%%LongitudeName = 'lon';
%%LatitudeName = 'lat';
%%TimeName = str2mat('','','','yrday_utc','','','','','','');         
DepthName = str2mat('depth','','','','');
DepthUnits = 'Meters';
SelectableVariables = str2mat('Sea_Temp','Salinity','Current_Dir','Current_Speed');
OptionalVariables = str2mat('sounding');
SelectableOptional = str2mat('Sounding');

Acknowledge = [];
Data_Use_Policy = sprintf('%s' ,...
      'Any person making substantial use of a data set must communicate with the investigators who acquired the data prior to publication and anticipate that the data collectors will be co-authors of published results. This extends to model results and to data organized for retrospective studies. (Please refer to U.S. GLOBEC''s data policy Report #10 (http://cbl.umces.edu/fogarty/usglobec/reports/datapol/ datapol.contents.html).) The data available here are intended for scholarly use by the academic and scientific community, with the express understanding that any such use will properly acknowledge the originating investigator. Use or reproduction of any material herein for any commercial purpose is prohibited without prior written permission from the U.S. GLOBEC Georges Bank Data Management Office. (http://globec.whoi.edu/globec-dir/contact_dmo.html)');

%COMMENTS
Comments1 = sprintf('%s\n', ...
'                    Moored Current Meter Data from Eastern Gulf of Maine/Scotian Shelf           ',...
'   ',...
'                   Parameter         Description                    Units',...
'                 ----------------------------------------------------------',...
'                   day               Julian Day                     fractional day',...
'                   temp              Temperature                    degrees C',...
'                   sal               Salinity                       nd',...
'                   curr_dir_abs      Direction                      degrees True',...
'                   curr_speed_abs    Speed                          cm/s',...
'   ',...
' INSTRUMENT_HEADER,',...
'     MODEL = RCM-8 ',...
'   ',...
' ');

Comments4 = sprintf('%s\n', ...
'   ', ...
'    Time_Period_of_Content = ', ...
'         Beginning_Date: Oct. 12, 1993 (1993.7831055)', ...
'         Ending_Date:    Nov. 28, 1996 (1996.7476027)', ...
'    Spatial_Domain = ', ...
'         Bounding Coordinates: ', ...
'              West Bounding Coordinate: 66.5383 W ', ...
'              East Bounding Coordinate: 65.7793 W ', ...
'              South Bounding Coordinate: 41.7335 N ', ...
'              North Bounding Coordinate: 43.0455 N ', ...
'   ', ...
'    Point_of_Contact = ', ...
'         Address - si: ', ...
'               Peter C. Smith', ...
'               Coastal Ocean Science, OSD',...
'               Bedford Institute of Oceanography',...
'               P.O. Box 1006', ...
'               Dartmouth, N.S. B2Y 4A2',...
'               CANADA',...
'               Electronic Mail Address:INTERNET > smithpc@mar.dfo-mpo.gc.ca',...
'               FAX: 902-426-7827 ',...
'         Address - globec: ',...
'               Robert Groman',...
'               Swift House MS# 38',...
'               Woods Hole, MA 02543-1127',...
'               USA ',...
'               Electronic Mail Address:INTERNET > rgroman@whoi.edu',...
'               FAX: (508) 457-2169',...
'         Address - dods: ',...
'               Electronic Mail Address:INTERNET > support@unidata.ucar.edu ');

Comments = [Comments1 Comments4];
