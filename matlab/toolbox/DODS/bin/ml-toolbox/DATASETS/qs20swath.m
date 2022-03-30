%               FILE DESCRIBING THE QuikSCAT LEVEL 2.0 DATASET 

% $Id: qs20swath.m,v 1.9 2002/08/17 02:16:15 dan Exp $

% $Log: qs20swath.m,v $
% Revision 1.9  2002/08/17 02:16:15  dan
% Extended ending date to 2004.
%
% Revision 1.8  2002/07/18 17:55:41  dan
% Fixed the end date for the GUI - again.
%
% Revision 1.6  2002/04/15 19:56:51  dan
% Changed names of generated variables.
%
% Revision 1.5  2002/04/11 15:43:37  dan
% Changed time range to correspond to range in fileserver.
%
% Revision 1.4  2001/01/18 19:35:44  dbyrne
%
%
% datarange is no longer in use.  changed datanull to cell in many cases.
% -- dbyrne 01/01/17
%
% Revision 1.3  2000/12/08 15:50:04  paul
% Added Acknowledge and Data_Use_Policy
%
% Revision 1.2  2000/12/07 22:24:24  paul
% put in test for no orbits found, in the "catalog" section of getswath
%
% Revision 1.1  2000/09/21 16:35:14  paul
% Add QuikSCAT files and swath getfunction files.
% : Added Files:
% : 	qs20swath.m qs20CO.m getswath.m windswathcat.m eqxrange.m
% : 	typeorb.m
%
% Revision 1.2  2000/09/19 18:48:22  paul
% removing my local startup.m
%
% Revision 1.1  2000/07/20 14:57:41  paul
%       Initial swath directory with functions and quikscat dataset.
%
% Revision 1.1  2000/04/07 21:10:58  paul
%           initializing QuikSCAT level 2B dataset
%           The first cut is with a sample dataset at URI.
%

% FUNCTIONS -- REQUIRED
GetFunctionName = 'getswath';

Cat_m_File = 'windswathcat';

% CANONICAL ORBIT FILE -- REQUIRED
CanOrbFile = 'qs20CO';


% Server:
% This server doesn't go to the bottom of the tree.  Caveat Emptor.
% This new CatalogServer installed at jpl on 26 July 2000.
Server = 'http://dods.jpl.nasa.gov/cgi-bin/nph-hdf/pub/ocean_wind/quikscat/L2B/data/';
CatalogServer = 'http://dods.jpl.nasa.gov/cgi-bin/nph-ff/catalogs/quikscat/L2B/jplqsfs.dat';

% compute the end of the time range as today.  Provisional.
%qsk=strtok(datestr(now));
%lqsk=length(qsk);
%qsendyear=str2num(qsk(lqsk-3:lqsk));
%qsdaysinyear=floor(datenum(now)-1)-datenum(qsendyear,1,1);
%qsendtime=qsendyear + qsdaysinyear/(365 + isleap(qsendyear));
%Time = [1999+200/365 qsendtime];
Time = [1999+200/365 2008+1/366];

% VARIABLES -- REQUIRED
LonRange = [0.0 360.0];
LatRange =  [-90.0 90.0];
%TimeRange = [1999+200/365 qsendtime];
%TimeRange = [1999+200/365  str2num(datestr(date,10))+2];
TimeRange = [1999+200/365  2004];
DepthRange = [0 0];
DepthUnits = '';
% This is for 25km data.
  Resolution = 25.0; 
DataName = 'JPL Level 2 QuikSCAT (25km) - JPL';
LongitudeName = 'wvc_lon';
LatitudeName = 'wvc_lat';
TimeName = ''; % Null tells getswath to use pass time
DepthName = '';
numxtrackpts = 76;

      % (NB: SelectableVariables contains both compute_variables and
      %      the "human-friendly" names of the dataset variables.
      %    The names of the dataset variables IN THE DATASET ITSELF
      %     are given in DodsName.  Note that for consistent processing,
      %     the compute_variables names have been *prepended* to both
      %     the SelectableVariables and the DodsName arrays.

compute_variables = ['Wind_U'; 'Wind_V'];
% COMPUTE_VARIABLES and DEPENDENCIES MUST BE SUBSETS OF SelectableVariables
% compute_variable dependencies:
% note that the compute dependencies are given in terms of DodsName variables.
%  i.e. the variable names from the dataset.
%  The use of the DodsName variable names in the ComputeFunctions is
%  critical and required.


cvdependencies=str2mat( ...
           'wind_speed_selection,wind_dir_selection', ...
           'wind_speed_selection,wind_dir_selection');

% cvdependencies are "strings of strings", where the first row of strings
% gives the dependencies for the first compute_variable, the second
% row of strings gives the dependencies fo the second compute_variable,
% and so on.


ComputeFunctions=str2mat( ...
 'Wind_U = wind_speed_selection .* sin(wind_dir_selection * pi / 18000.0);', ...
 'Wind_V = wind_speed_selection .* cos(wind_dir_selection * pi / 18000.0);');

 
% variables contained in the Catalog Server which are returned
% and used in the subsequent processing

CatServerVariables=str2mat('wvc_rows','rev_num','longitude');

 SelectableVariables = str2mat('Wind_U','Wind_V','Wind_Speed',...
     'Wind_Dir','Ambiguity_Selection');
 DodsName = str2mat('Wind_U','Wind_V', ...
    'wind_speed_selection', 'wind_dir_selection','wvc_selection');

% for dirth files:
%   'wind_speed_selection', 'wind_dir_selection');


% note: DataNull is applied *before* scaling
DataNull = [nan; 0; 0; nan; 0; 0; 0; 0; 0];
DataScale = [nan nan; 0.0 0.01; 0.0 0.01; nan nan;  ...
             0.0 0.01; 0.0 0.01; 0.0 0.01; 0.0 0.01; 0 1]; 

Acknowledge='These Data are provided through the PO-DAAC at JPL' ;

Data_Use_Policy = [];


% COMMENTS

%
% Paul Hemenway @ uri, 04/07/00 .

Comments1 = sprintf('%s\n', ...
'            NASA/JPL Level 2B QuikSCAT (Ocean Winds)', ...
' ', ...
 'QuikSCAT L2B data are described in    ', ...
 '            The QuikSCAT Science Data Product    ', ...
 '            User''s Manual, Document D-18053 , Ed: Glenn Shirtliffe    ', ...
 '   from the Jet Propulsion Laboratory, California Institute of Technology    ', ...
 '    ', ...
' The winds are derived from the NASA Quick Scatterometer.  ', ...
' The winds are determined at 76 cross track "footprints" of 25km ', ...
' resolution, starting on day 204 of 1999, and continuing through the ', ...
' present.', ...
' ',...
'');

Comments2 = sprintf('%s\n', ...
' Units:  Meters/Second (m/s)',...
' Scale Factor: 0.01',...
' Resolution: 50 km (spatial)',...
'              seconds (temporal)',...
' Accuracy:',...
'         Speed:     2 m/s (winds < 20 m/s)',...
'                    10%   (winds > 20 m/s)',...
'         Direction: 20 degrees',...
' Range:',...
'         Speed:     0 - 50 m/s',...
'         Direction: 0 - 359.99 degrees',...
' Time_Period_of_Content',...
'      Beginning_Date:1999/204 (sample data)',...
'      Ending_Date:~2000/150',...
' Spatial_Domain',...
'      Bounding Coordinates',...
'           West Bounding Coordinate:0.0',...
'           East Bounding Coordinate:360.0',...
'           South Bounding Coordinate:-85 .0',...
'           North Bounding Coordinate:+85.0',...
' Point_of_Contact',...
'      Contact Person:Paul Hemenway (DODS development)',...
'      Contact Position:Marine Research Specialist',...
'      Address            Graduate School of Oceanography',...
'            University of Rhode Island',...
'            Watkins Laboratory', ...
'            215 South Ferry Road',...
'            Narragansett, RI 02882',...
'      Telephone:(401) 874-6677',...
'      Electronic Mail Address:INTERNET > phemenway@gso.uri.edu',...
'      Contact Person:Paul Hemenway',...
'      Contact Position:Marine Research Specialist',...
'      Address',...
'            Graduate School of Oceanography',...
'            University of Rhode Island',...
'            South Ferry Road',...
'            Narragansett, Rhode Island  02882',...
'            USA',...
'      Electronic Mail Address:INTERNET > support@unidata.ucar.edu');

Comments = [Comments1 Comments2];


