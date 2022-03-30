% tsloadASCII  Graphical User Interface to load ASCII data in Matlab workspace
% =========================================================================
% tsloadASCII  Version 1.0 8-Sep-1998
%
% Usage: 
%   tsloadASCII  -Called by notmat.m only NOT to be used at command line
%
% Description:
%   tsloadASCII is used to load ASCII data files into the Matlab workspace
%   and display the available variables in the tsgui salinity and temperature
%   listboxes. A window will be created which asks the user to input labels 
%   for temperature and salinity and asks which column in the file these 
%   relate to.
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

% get graphics handles for salinity labels and column boxes
salLabelHndl=findobj(gcbf,'Tag','EditTextS');
salEditHndl=findobj(gcbf,'Tag','EditTextColS');
% Assign strings for salinity labels and column #
salLabel = get(salLabelHndl,'String');
salEdit = get(salEditHndl,'String');
% get graphics handles for temperature labels and column boxes
tempLabelHndl=findobj(gcbf,'Tag','EditTextT');
tempEditHndl=findobj(gcbf,'Tag','EditTextColT');
% Assign strings for temperature labels and column #
tempLabel = get(tempLabelHndl,'String');
tempEdit = get(tempEditHndl,'String');
% close the "not .mat" window
close(gcbf);
% assign appropriate column of data file to variable name chosen
eval([salLabel,'=',fname,'(:,',salEdit,');']);
eval([tempLabel,'=',fname,'(:,',tempEdit,');']);
clear salLabelHndl
clear salEditHndl
clear salLabel
clear salEdit
clear tempLabelHndl
clear tempEditHndl
clear tempLabel
clear tempEdit
clear fname
clear ext
% varlist contains a list of variables in the Matlab workspace
varlist = who; 
% Put the varlist into UserData so that it can be accessed later
set(tsguiHndl,'UserData',varlist);
% Update the listboxes
salHndl=findobj(tsguiHndl,'Tag','ListboxSal');
tempHndl=findobj(tsguiHndl,'Tag','ListboxTemp');
set(salHndl,'String',varlist);
set(tempHndl,'String',varlist);
set(salHndl,'Value',1);
set(tempHndl,'Value',1);
clear salHndl;
clear tempHndl;
clear ans;

