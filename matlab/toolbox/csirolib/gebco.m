function handle = gebco(symbol,linewidth);

% GEBCO      Draws coastlines in lat/lon coordinates.
%
%	GEBCO plots coastlines in the longitude range -180 to 540 using
%       the GEBCO coastlines data.  Default is to draw over entire
%       latitude/longitude region.  Use AXIS to limit region.
%
%       GEBCO('SYMBOL') uses linetype 'SYMBOL'.  Any linetype supported 
%       by PLOT is allowed.  The default is 'm-' (i.e., magenta). 
%
%       GEBCO(LINEWIDTH) or GEBCO('SYMBOL',LINEWIDTH) specifies thickness 
%       of lines.  Default is 1.
%
%       Optional output returns row vector of handle of coastline
%       segments.  This can be used to reset line properties such as
%       thickness or colour using the handle graphics command SET.
%       Note that there will be one handle for each gebco sheet.
% 
%	Examples:  >> contour(lon,lat,z,v); h=gebco('r-');
%       Plots coastlines over a contour plot created with contour and
%       returns the handle of the plotted coastline.
%                  >> set(h,'LineWidth',2)
%       This resets the thickness of all portions of coastline.
%                  >> set(h,'Color','c')
%       This changes the coastline colour to cyan. A vector RGB triple
%       may be used to specify the colour.
%                  >> set(h) 
%       shows properties that can be reset.

%     Copyright J. V. Mansbridge, CSIRO, Tue Dec 13 14:32:01 EST 1994
%       $Id: gebco.m,v 1.6 1997/08/15 06:09:48 mansbrid Exp $
%       Based on coast.m which was developed as below:
%	John Wilkin 3 February 93
%       Peter McIntosh 26/5/94 - faster algorithm using new data set
%       John Wilkin 27 April 94 - changed input handling and help.
%       Jim Mansbridge 3/8/95 - modified to use gebco data
%       Jim Mansbridge 3/8/95 - doesn't use unnecessary gebco sheets
%       Jim Mansbridge 10/4/96 - doesn't need the $TOOLBOX environment
%                                variable.
%       John Wilkin - some matlab5 syntax and the default action is always
%       to add to the current axes (not replace)

if nargin < 1,
  symbol = 'm-';
  linewidth = 1;
end

if nargin == 1,
  if isstr(symbol)
    linewidth = 1;
  else
    linewidth = symbol;
    symbol = 'm-';
  end
end

% Find the directory which contains gebco_limits.mat
% For matlab version 4 or less it is assumed the gebco data are in the same
% directory and for version 5 or higher gebco_limits.mat is located
% directly.

vers = version;
vers = str2num(vers(1));

if vers <= 4
  temp = which('gebco');
  dir = temp(1:((length(temp) - 7)));
else
  temp = which('gebco_limits.mat');
  dir = temp(1:((length(temp)-16)));
end

nextpl_gcf = get(gcf, 'NextPlot');
ax = gca;
nextpl_gca = get(ax, 'NextPlot');
xlim = get(gca, 'XLim');
ylim = get(gca, 'YLim');
han = [];

% Get the matrix detailing the lon and lat limits of the gebco sheets.
load([dir 'gebco_limits']);

% Work through each sheet and only plot those which will appear in the
% region defined by the current axis.

set(gcf,'nextplot','add');
set(ax,'nextplot','add');

for i = 501:531
  ii = i - 500;
  if    (gebco_limits(ii, 3) < xlim(2)) & ...
	(gebco_limits(ii, 4) > xlim(1)) & ...
	(gebco_limits(ii, 1) < ylim(2)) & ...
	(gebco_limits(ii, 2) > ylim(1))
    name = ['gebco' num2str(i)];
    load([dir name])
    eval(['matrix = ' name ';']);
    h = plot(matrix(:, 2), matrix(:, 1), symbol);
    set(h,'LineWidth',linewidth);
    han = [han h];
    eval(['clear ' name ]);
  end
end

set(gca, 'XLim', xlim);
set(gca, 'YLim', ylim);
set(gcf, 'NextPlot', nextpl_gcf);
set(ax, 'NextPlot', nextpl_gca);

if nargout>0,handle=han;end
