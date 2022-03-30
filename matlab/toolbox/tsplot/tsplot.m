% tsplot  Graphical User Interface to produce TS plots
% =========================================================================
% tsplot  Version 1.1 21-Dec-1998
%
% Usage: 
%   tsplot
%
% Description:
%   This Matlab script calls the tsgui function which generates a window
%   and initializes this window. tsgui enables the user to easily
%   produce T-S diagrams.
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

%
% Modifications:
%   Version 1.1 - set the USERDATA property of the tsgui figure window
%                 to a cell array containing a list of variables in the
%                 workspace. This caused a problem in version 1.0 which
%                 forced the user to use the "load" button even if the
%                 data already existed in the Matlab workspace.

% Call the tsgui function
tsguiHndl=tsgui;
% varlist holds a listing of variables in the Matlab workspace. Clear it
% if it existed before.
clear varlist;
varlist = who;
% Put the varlist into UserData so that it can be accessed later
set(gcf,'UserData',varlist);
% Find the salinity and temperature listboxes in the tsgui window
% and fill them with the list of variables in the workspace.
salHndl=findobj(gcf,'Tag','ListboxSal');
tempHndl=findobj(gcf,'Tag','ListboxTemp');
set(salHndl,'String',varlist);
set(tempHndl,'String',varlist);
set(salHndl,'Value',1);
set(tempHndl,'Value',1);
% clear unnecessary variables
clear salHndl
clear tempHndl
clear ans
clear varlist
% Find the popup menu for marker styles and fill it with the
% options
markerHndl=findobj(gcf,'Tag','PopupMenuMarker');
marker{1}='.';
marker{2}='+';
marker{3}='o';
marker{4}='*';
marker{5}='x';
set(markerHndl,'String',marker);
set(markerHndl,'Value',1);
clear markerHndl
clear marker
% find the popup menu for the color options and fill it.
colorHndl=findobj(gcf,'Tag','PopupMenuColor');
color{1}='red';
color{2}='green';
color{3}='blue';
color{4}='cyan';
color{5}='magenta';
color{6}='yellow';
color{7}='white';
color{8}='black';
set(colorHndl,'String',color);
set(colorHndl,'Value',1);
clear colorHndl
clear color
