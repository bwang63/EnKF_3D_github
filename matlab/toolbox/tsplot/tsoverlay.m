% tsoverlay  Overlay T-S data on the current T-S diagram
% =========================================================================
% tsoverlay  Version 1.0 8-Sep-1998
%
% Usage: 
%   tsoverlay  -Called by tsgui only NOT to be used at command line
%
% Description:
%   Overlay T-S data on the current T-S diagram. User selects variables
%   to plot from tsgui listboxes and chooses marker style and color then
%   clicks "Overlay" button to execute.
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

% find the figure to plot data on
figure(figHndl);
hold on;
% determine which variables the user has chosen to plot
% from the two listboxes.
salHndl = findobj(gcbf,'Tag','ListboxSal');
v1=get(salHndl,'Value');
tempHndl = findobj(gcbf,'Tag','ListboxTemp');
v2=get(tempHndl,'Value');
clear salHndl;
clear tempHndl;
% Determine which marker to use for the data
markerHndl = findobj(gcbf,'Tag','PopupMenuMarker');
markerVal=get(markerHndl,'Value');
switch markerVal,
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
switch colorVal,
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
eval(['plot('varlist{v1},',',varlist{v2},',''',[marker,color],''')']);
clear markerHndl;
clear colorHndl;
clear markerVal;
clear colorVal;
clear marker;
clear color;
clear v1;
clear v2;
