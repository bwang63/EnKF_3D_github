function fig = tsgui()
% tsgui  Generate graphical user interface for T-S plots
% =========================================================================
% tsgui  Version 1.0 8-Sep-1998
%
% Usage: 
%   tsgui  -Called by tsplot but can also be issued at command line
%
% Description:
%   tsgui generates a graphical user interface for T-S plots. Various
%   user interface controls enable the user to select pressure,
%   density contours, axis limits, and marker color and style.
%
% Input:
%   n/a
%
% Output:
%   fig = handle to window containing this graphical user interface
%
% Author:
%   Blair Greenan
%   Bedford Institute of Oceanography
%   September 8, 1998
%   Matlab 5.2.1
%   greenanb@mar.dfo-mpo.gc.ca
% =========================================================================
%

load tsgui

% designed for 1024x768, so scale it if rootscreensize is different
set(0,'units','pixels');
rootscreensize = get(0,'screensize');
pixfactor = rootscreensize(3)/1024;

h0 = figure('Color',[0.250980392156863 0.501960784313725 0.501960784313725], ...
	'Colormap',mat0, ...
	'MenuBar','none', ...
	'Name','Matlab T-S Plot', ...
	'NumberTitle','off', ...
	'PaperPosition',[18 180 576.0000000000001 432.0000000000002], ...
	'PaperUnits','points', ...
	'PointerShapeCData',mat1, ...
	'Position',pixfactor*[14 67 222 621], ...
	'Tag','Fig1');
h1 = uimenu('Parent',h0, ...
	'Label','File', ...
	'Tag','FileUImenu');
h2 = uimenu('Parent',h1, ...
	'Callback','close gcf', ...
	'Label','Close', ...
	'Tag','FileUImenuClose');
h1 = uimenu('Parent',h0, ...
	'Label','Help', ...
	'Tag','HelpUImenu');
h2 = uimenu('Parent',h1, ...
	'Callback','tshelp', ...
	'Label','T-S Plot', ...
	'Tag','HelpuimenuTS');
h1 = uicontrol('Parent',h0, ...
	'BackgroundColor',[0.752941176470588 0.752941176470588 0.752941176470588], ...
	'ListboxTop',0, ...
	'Position',pixfactor*[35 222 153 70], ...
	'Style','frame', ...
	'Tag','StaticText2');
h1 = uicontrol('Parent',h0, ...
	'BackgroundColor',[1 1 1], ...
	'ListboxTop',0, ...
	'Position',pixfactor*[54 235 114 27], ...
	'Style','edit', ...
	'Tag','EditTextAxis', ...
	'Visible','off');
h1 = uicontrol('Parent',h0, ...
	'BackgroundColor',[0.752941176470588 0.752941176470588 0.752941176470588], ...
	'Callback','tsguifun axis', ...
	'ListboxTop',0, ...
   'FontSize',ceil(pixfactor*8), ...
	'Position',pixfactor*[44 262 134 27], ...
   'String','Axis Limits', ...
	'Style','checkbox', ...
	'Tag','CheckboxAxis');
h1 = uicontrol('Parent',h0, ...
	'BackgroundColor',[0.752941176470588 0.752941176470588 0.752941176470588], ...
	'ListboxTop',0, ...
	'Position',pixfactor*[35 302 153 70], ...
	'Style','frame', ...
	'Tag','StaticText2');
h1 = uicontrol('Parent',h0, ...
	'BackgroundColor',[0.752941176470588 0.752941176470588 0.752941176470588], ...
	'ListboxTop',0, ...
	'Position',pixfactor*[36 381 151 38], ...
	'Style','frame', ...
	'Tag','StaticText2');
h1 = uicontrol('Parent',h0, ...
	'BackgroundColor',[1 1 1], ...
   'FontSize',ceil(pixfactor*8), ...
	'Position',pixfactor*[36 430 150 64], ...
	'String',mat2, ...
	'Style','listbox', ...
	'Tag','ListboxTemp', ...
	'Value',1);
h1 = uicontrol('Parent',h0, ...
	'BackgroundColor',[1 1 1], ...
   'FontSize',ceil(pixfactor*8), ...
	'Position',pixfactor*[37 518 149 65], ...
	'String',mat3, ...
	'Style','listbox', ...
	'Tag','ListboxSal', ...
	'Value',1);
h1 = uicontrol('Parent',h0, ...
	'BackgroundColor',[0.250980392156863 0.501960784313725 0.501960784313725], ...
	'ListboxTop',0, ...
   'FontSize',ceil(pixfactor*8), ...
	'Position',pixfactor*[81 586 61 19], ...
	'String','Salinity', ...
	'Style','text', ...
	'Tag','StaticText2');
h1 = uicontrol('Parent',h0, ...
	'BackgroundColor',[0.250980392156863 0.501960784313725 0.501960784313725], ...
	'ListboxTop',0, ...
   'FontSize',ceil(pixfactor*8), ...
	'Position',pixfactor*[65 494 92 20], ...
	'String','Temperature', ...
	'Style','text', ...
	'Tag','StaticText2');
h1 = uicontrol('Parent',h0, ...
	'BackgroundColor',[0.752941176470588 0.752941176470588 0.752941176470588], ...
	'Callback','tsguifun pressure', ...
	'ListboxTop',0, ...
   'FontSize',ceil(pixfactor*8), ...
	'Position',pixfactor*[44 385 90 31], ...
	'String','Pressure', ...
	'Style','checkbox', ...
	'Tag','CheckboxPress');
h1 = uicontrol('Parent',h0, ...
	'BackgroundColor',[1 1 1], ...
	'ListboxTop',0, ...
   'FontSize',ceil(pixfactor*8), ...
	'Position',pixfactor*[133 388 34 24], ...
	'String','0', ...
	'Style','edit', ...
	'Tag','EditTextPress', ...
	'Visible','off');
h1 = uicontrol('Parent',h0, ...
	'BackgroundColor',[0.752941176470588 0.752941176470588 0.752941176470588], ...
	'Callback','tsguifun density', ...
	'ListboxTop',0, ...
   'FontSize',ceil(pixfactor*8), ...
	'Position',pixfactor*[44 343 134 27], ...
	'String','Density Contours', ...
	'Style','checkbox', ...
	'Tag','CheckboxDens');
h1 = uicontrol('Parent',h0, ...
	'Callback','tsgraph', ...
	'ListboxTop',0, ...
   'FontSize',ceil(pixfactor*8), ...
	'Position',pixfactor*[43.99999999999999 61.50000000000001 59.99999999999999 20], ...
	'String','Plot', ...
	'Tag','PushbuttonPlot');
h1 = uicontrol('Parent',h0, ...
	'BackgroundColor',[1 1 1], ...
	'ListboxTop',0, ...
   'FontSize',ceil(pixfactor*8), ...
	'Position',pixfactor*[54 315 114 28], ...
	'String','5', ...
	'Style','edit', ...
	'Tag','EditTextDens', ...
	'Visible','off');
h1 = uicontrol('Parent',h0, ...
	'Callback','tsload', ...
	'ListboxTop',0, ...
   'FontSize',ceil(pixfactor*8), ...
	'Position',pixfactor*[43.99999999999999 98.99999999999999 59.99999999999999 21], ...
	'String','Load', ...
	'Tag','PushbuttonLoad');
h1 = uicontrol('Parent',h0, ...
	'Callback','tsoverlay', ...
	'ListboxTop',0, ...
   'FontSize',ceil(pixfactor*8), ...
	'Position',pixfactor*[123 61.50000000000001 59.99999999999999 20], ...
	'String','Overlay', ...
	'Tag','PushbuttonOverlay');
h1 = uicontrol('Parent',h0, ...
	'Callback','tsrefresh', ...
	'ListboxTop',0, ...
   'FontSize',ceil(pixfactor*8), ...
	'Position',pixfactor*[125 99 60 21], ...
	'String','Refresh', ...
	'Tag','PushbuttonRefresh');
h1 = uicontrol('Parent',h0, ...
	'Units','points', ...
	'ListboxTop',0, ...
   'FontSize',ceil(pixfactor*8), ...
	'Position',pixfactor*mat4, ...
	'String',mat5, ...
	'Style','popupmenu', ...
	'Tag','PopupMenuMarker', ...
	'Value',1);
h1 = uicontrol('Parent',h0, ...
	'Units','points', ...
	'BackgroundColor',[0.250980392156863 0.501960784313725 0.501960784313725], ...
	'ListboxTop',0, ...
   'FontSize',ceil(pixfactor*8), ...
	'Position',pixfactor*[25.44827586206897 112.3448275862069 37.24137931034483 12.41379310344828], ...
	'String','Marker', ...
	'Style','text', ...
	'Tag','StaticText1');
h1 = uicontrol('Parent',h0, ...
	'Units','points', ...
	'ListboxTop',0, ...
   'FontSize',ceil(pixfactor*8), ...
	'Position',pixfactor*[75.10344827586209 90.62068965517243 37.24137931034483 12.41379310344828], ...
	'String',mat6, ...
	'Style','popupmenu', ...
	'Tag','PopupMenuColor', ...
	'Value',1);
h1 = uicontrol('Parent',h0, ...
	'Units','points', ...
	'BackgroundColor',[0.250980392156863 0.501960784313725 0.501960784313725], ...
	'ListboxTop',0, ...
   'FontSize',ceil(pixfactor*8), ...
	'Position',pixfactor*[27.93103448275863 88.75862068965519 37.24137931034483 12.41379310344828], ...
	'String','Color', ...
	'Style','text', ...
	'Tag','StaticText1');
if nargout > 0, fig = h0; end
