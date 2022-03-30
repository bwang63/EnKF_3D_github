% tsgraph - Checks user choices and calls tsdiagram to plot TS data
% =========================================================================
% tsgraph  Version 1.0 8-Sep-1998
%
% Usage: 
%   tsgraph (Note: called by the tsgui function ONLY)
%
% Description:
%   This script check the settings of the various uicontrols in the tsgui
%   window and makes the appropriate call to the tsdiagram function based
%   on these settings.
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

% get the list of variables in the workspace
varlist=get(gcbf,'UserData');
% generate a new figure window and assign it a handle
figHndl=figure;
% determine which variables the user has chosen to plot
% from the two listboxes.
salHndl = findobj(gcbf,'Tag','ListboxSal');
v1=get(salHndl,'Value');
tempHndl = findobj(gcbf,'Tag','ListboxTemp');
v2=get(tempHndl,'Value');
% Check to see whether the user wants to assign a pressure
press1Hndl = findobj(gcbf,'Tag','CheckboxPress');
press2Hndl = findobj(gcbf,'Tag','EditTextPress');
if (get(press1Hndl,'Value')),
   % convert string from text box to number and assign it to press
   press = str2num(get(press2Hndl,'String'));
else
   % default to pressure = 0
   press = 0;
end
clear press1Hndl
clear press2Hndl
% Check to see whether the user wants to assign isopycnals
dens1Hndl = findobj(gcbf,'Tag','CheckboxDens');
dens2Hndl = findobj(gcbf,'Tag','EditTextDens');
if (get(dens1Hndl,'Value'))
   % convert string from text box to number and assign it to dens
   dens = str2num(get(dens2Hndl,'String'));
else
   % default to -1 means no isopycnals will be drawn
   dens = -1;
end
clear dens1Hndl
clear dens2Hndl
% Check to see whether the user wants to assign axis limits
axis1Hndl = findobj(gcbf,'Tag','CheckboxAxis');
axis2Hndl = findobj(gcbf,'Tag','EditTextAxis');
if (get(axis1Hndl,'Value'))
   % convert string from text box to number and assign it to axs
   axs = str2num(get(axis2Hndl,'String'));
else
   % default to null
   axs = [];
end
% Determine which marker to use for the data
markerHndl = findobj(gcbf,'Tag','PopupMenuMarker');
markerVal=get(markerHndl,'Value');
switch markerVal
case 1
   marker = '.';
case 2
   marker = '+';
case 3
   marker = 'o';
case 4
   marker = '*';
case 5
   marker = 'x';
end
% determine which color to use for the data
colorHndl = findobj(gcbf,'Tag','PopupMenuColor');
colorVal=get(colorHndl,'Value');
switch colorVal
case 1
   color = 'r';
case 2
   color = 'g';
case 3
   color = 'b';
case 4
   color = 'c';
case 5
   color = 'm';
case 6
   color = 'y';
case 7
   color = 'w';
case 8
   color = 'k';
end
% plot the data using the specified marker and color
if  (get(axis1Hndl,'Value'))
   eval(['tsdiagram(' varlist{v1} ',' varlist{v2} ', press , dens ,''',[marker,color],''', axs)']);
else
   eval(['tsdiagram(' varlist{v1} ',' varlist{v2} ', press , dens,''',[marker,color],''')']);
end
% clear unncessary variables
clear axis1Hndl
clear axis2Hndl
clear axs
clear salHndl;
clear tempHndl;
clear overlay;
clear press;
clear dens;
clear markerHndl;
clear colorHndl;
clear markerVal;
clear colorVal;
clear marker;
clear color;
clear v1;
clear v2;
