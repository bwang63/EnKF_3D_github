% tsload  Graphical User Interface to load data in Matlab workspace
% =========================================================================
% tsload  Version 1.0 8-Sep-1998
%
% Usage: 
%   tsload  -Called by tsgui only NOT to be used at command line
%
% Description:
%   tsload is used to load data into the Matlab workspace and display
%   the available variables in the salinity and temperature listboxes.
%   If the file to load is a .mat file then no extra work is needed. If
%   the file does not have a .mat externsion another window will be created
%   which asks the user to input labels for temperature and salinity and
%   asks which column in the file these relate to.
%
% Input:
%   n/a
%
% Output:
%   n/a
%
% Author:
%   Blair Greenan
%   Bedford Institute of Oceanography
%   September 8, 1998
%   Matlab 5.2.1
%   greenanb@mar.dfo-mpo.gc.ca
% =========================================================================
%

% Get file and path names using standard UI window.
[filename,pathname]=uigetfile(' *. mat','Load Data File');
% Load the data into the workspace
eval(['load ', pathname,filename]);
% Use the strtok function to parse filename in the name and file extension
[fname,ext] = strtok(filename,'.');
% clear unnecessary variables
clear pathname;
clear filename;
clear varlist; 
% If this is not a .mat file open another window for input
if (~strcmp(ext,'.mat'))
   notmatHndl=notmat;
   % Make up a string which represents the first three lines of the data file
   eval(['str1=num2str(',fname,'(1,:));']);
   eval(['str2=num2str(',fname,'(2,:));']);
   eval(['str3=num2str(',fname,'(3,:));']);
   str=[str1; str2; str3]
   headerHndl = findobj(notmatHndl,'Tag','HeaderText')
   set(headerHndl,'String',str);
   clear str str1 str2 str3
   clear notmatHndl
   clear headerHndl
else
   clear fname;
   clear ext;
   % varlist contains a list of variables in the Matlab workspace
   varlist = who; 
   % Put the varlist into UserData so that it can be accessed later
   set(gcbf,'UserData',varlist);
   % Update the listboxes
   salHndl=findobj(gcbf,'Tag','ListboxSal');
   tempHndl=findobj(gcbf,'Tag','ListboxTemp');
   set(salHndl,'String',varlist);
   set(tempHndl,'String',varlist);
   set(salHndl,'Value',1);
   set(tempHndl,'Value',1);
   clear salHndl;
   clear tempHndl;
   clear ans;
end

