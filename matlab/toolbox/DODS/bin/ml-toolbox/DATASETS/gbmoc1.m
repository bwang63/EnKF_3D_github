%
%  GLOBEC MOCNESS 1 m^2 CTD Data

% The preceding empty line is important
% $Log: gbmoc1.m,v $
% Revision 1.1  2000/09/19 20:50:41  kwoklin
% First toolbox internal release.   klee
%
%

% $Id: gbmoc1.m,v 1.1 2000/09/19 20:50:41 kwoklin Exp $
% klee 08/2000
% klee 04/1999

GetFunctionName = 'getjgsta';
Server = 'http://dods.gso.uri.edu/cgi-bin/nph-jg/mocctd?&datatype=MOCNESS_1';
Cat_m_File = 'gbcat';
URL_m_File = 'gburl';

LonRange = [-70 -65]; 
LatRange = [40 44];   
TimeRange = [1995.11232877 2000];
DepthRange = [0 600];  
Resolution = nan;

DodsName = str2mat('temp','theta','sal','sigma','fluor');
DataName = 'Water Column - CTD collected from MOCNESS_1 hauls - URI/GLOBEC ';    
%%LongitudeName = 'lon';
%%LatitudeName = 'lat';
%%TimeName = str2mat('year_local','','','yrday_local','','','','','','');         
DepthName = str2mat('press','','','','');
DepthUnits = 'Meters';
SelectableVariables = str2mat('Sea_Temp','Pot_Temp','Salinity', ...
                              'Pot_Density','Fluorescence');
OptionalVariables = str2mat('station','station_std','tow','angle','flow',...
                            'hzvel','vtvel','vol');
SelectableOptional = str2mat('Station','Station_Std','Tow','Angle','Flow',...
                             'Hzvel','Vtvel','Vol');

% in order of time/xdim/ydim/zdim/variables
DataNull = [nan -999.0 -999.0 nan nan nan nan nan nan nan nan nan nan nan nan nan nan nan]; 

Acknowledge = [];
Data_Use_Policy = sprintf('%s' ,...
      'Any person making substantial use of a data set must communicate with the investigators who acquired the data prior to publication and anticipate that the data collectors will be co-authors of published results. This extends to model results and to data organized for retrospective studies. (Please refer to U.S. GLOBEC''s data policy Report #10 (http://cbl.umces.edu/fogarty/usglobec/reports/datapol/ datapol.contents.html).) The data available here are intended for scholarly use by the academic and scientific community, with the express understanding that any such use will properly acknowledge the originating investigator. Use or reproduction of any material herein for any commercial purpose is prohibited without prior written permission from the U.S. GLOBEC Georges Bank Data Management Office. (http://globec.whoi.edu/globec-dir/contact_dmo.html)');

%COMMENTS
Comments1 = sprintf('%s\n', ...
'                                    MOCNESS 1 m^2 CTD Data      ',...
'   ',...
'                   Parameter         Description                     Units',...
'                 ----------------------------------------------------------',...
'   ',...
'                   yrday_local       local day and decimal time, as 326.5 for the 326th day of 1995,',...
'                                     or November 22, 1995 at 1200 hours ',...
'                   press             depth                           meter',...
'                   netnum            sequential MOCNESS net number (same as "net")',...
'                   echo',...
'                   temp              temperature                     degrees C',...
'                   theta             potential temperature',...
'                   sal               salinity                        ppt',...
'                   sigma             potential density',...
'                   fluor             fluorescence (0-5 volts)        volts',...
'                   angle             angle of net frame relative to vertical (0-89 dgrees)',...
'                   flow              consecutive flow counts',...
'                   hzvel             horizontal net velocity         m/min',...
'                   vtvel             vertical net velocity           m/min',...
'                   vol               volume filtered                 m^3',...
'                   ptran             trasmissometry or light         volts',...
'                                     transmission (0-5 volts)',...
'                   oxycurrent        oxygen sensor current (0-5 volts)',...
'                   oxytemp           oxygen sensor internal temperature (0-5 volts)',...
'                   oxygen            dissolved oxygen                ml/liter',...
'                   lite              downwelling light               volts',...
'                   tempco            light sensor thermistor         voltage',...
'                   tvel              unused channel, reserved for future use',...
'                   net               sequential MOCNESS net number (same as "netnum")',...
'                   lat               latitude',...
'                   lon               longitude',...
'  ',...
' These data are the unprocessed CTD measurements taken by the CTD instrument attached to the',...
' MOCNESS frame. For additional information, contact the chief scientist for the cruise or one of the',...
' following people: ',...
'  ',...
' MOCNESS 1/4 meter^2      Greg Lough',...
' MOCNESS 1 meter^2        Ted Durbin, Erich Horgan, and Greg Lough',...
' MOCNESS 10 meter^2       Erich Horgan',...
'  ',...
' References',...
'  ',...
' Fofonoff and Millard, 1983, UNESCO technical papers in Marine Sciences, #44 ');

Comments4 = sprintf('%s\n', ...
'   ', ...
'    Time_Period_of_Content = ', ...
'         Beginning_Date: Feb. 11, 1995 (1995.11273326) ', ...
'         Ending_Date:    Oct. 25, 1999 (1999.81792849)', ...
'    Spatial_Domain = ', ...
'         Bounding Coordinates: ', ...
'              West Bounding Coordinate: 69.8241 W ', ...
'              East Bounding Coordinate: 65.0833 W ', ...
'              South Bounding Coordinate: 40.0000 N ', ...
'              North Bounding Coordinate: 43.8391 N ', ...
'   ', ...
'    Point_of_Contact = ', ...
'         Address - si: ', ...
'               Ted Durbin',...
'               Graduate School of Oceanography',...
'               University of Rhode Island',...
'               Narragansett, RI 02882',...
'               Electronic Mail Address:INTERNET > edurbin@gsosun1.gso.uri.edu',...
'               Fax: 401-874-6853',...
'               ------------------------------',...
'               Erich Horgan',...
'               WHOI ',...
'               Redfield 230 MS #33',...
'               Woods Hole, MA 02543-1049',...
'               Electronic Mail Address:INTERNET > ehorgan@whoi.edu',...
'               FAX: 508-457-2169',...
'               -------------------------------',...
'               Greg Lough', ...
'               NMFS',...
'               Woods Hole, MA 02543',...
'               USA ', ...
'               Electronic Mail Address:INTERNET > Gregory.Lough@noaa.gov',...
'               FAX: 508-495-2258',...
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
