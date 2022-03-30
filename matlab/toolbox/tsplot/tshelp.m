% tshelp -generates string for the Matlab Help Window to provide help for tsgui
% ============================================================================
% tshelp  Version 1.0 8-Sep-1998
%
% Usage: 
%   tshelp
%
% Description:
%   Generates the string which appears in the Matlab Help Window when
%   the user if tsgui clicks Help->TSPlot.
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

helpstr={'tsplot.m';
   ' ';
   'tsplot is a Matlab 5.2 function which provides the user with a';
   'Graphical User Interface (GUI) to ease the procedure of making';
   'T-S plots. The GUI controls provided in the T-S Plot window include:';
   ' ';
   'Salinity listbox: This provide the user with a list of variables in';
   'the current Matlab workspace. The user can then pick the variable';
   'representing salinity';
   ' ';
   'Temperature listbox: This provide the user with a list of variables in';
   'the current Matlab workspace. The user can then pick the variable';
   'representing temperature';
   ' ';
   'Pressure Checkbox: This control toggles on/off. In the "off" mode the';
   'default value of P=0 is assigned. In the "on" mode a edit box appears';
   'in which the user can specify a pressure';
   ' ';
   'Density Checkbox: This control toggles on/off. In the "off" mode the';
   'default value of dens=-1 is assigned which means that no isopycnals';
   'will be plotted. In the "on" mode a edit box appears in which the user';
   'can specify either the number of isopycnals to be drawn (enter a scalar)';
   'or the exact isopycnals (enter a vector)';
   ' ';
   'Axis Checkbox: This control toggles on/off. In the "off" mode the';
   'default value of NULL is assigned which means that the axis limits';
   'will be determined by the min and max values of Temperature and Salinity.';
   'In the "on" mode a edit box appears in which the user can specify the';
   'axes limits by entering a vector such as [32 34 5 20]';
   ' ';
   'Marker: provides a popup menu allowing the user to specify the data marker';
   ' ';
   'Color: provides a popup menu allowing the user to specify the data color';
   ' ';
   'Load Button: loads data into the Matlab workspace and updates the';
   'Temperature and Salinity listboxes';
   ' ';
   'Refresh Button: checks variables in Matlab workspace and updates the';
   'Temperature and Salinity listboxes';
   ' ';
   'Plot Button: Produces a plot in another figure window using the';
   'selections chosen in the variuos controls listed above';
   ' ';
   'Overlay Button: Overlays chosen T-S data in figure window produced';
   'by the Plot button. There is no limit on the number of overlays';
   ' ';
   'Blair Greenan';
   'Bedford Institute of Oceanography';
   'September, 1998';
   'Matlab 5.2.1';
   'email: greenanb@mar.dfo-mpo.gc.ca';
};
helpwin(helpstr,'T-S Plot');
