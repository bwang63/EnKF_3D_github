function f_vecPlot(jdate,u,v,scale,units,jRange);
% - plot time series of velocity vectors
%
% USAGE: f_vecPlot(jdate,u,v,scale,units,jRange)
%
% jdate  = column vector of Julian dates
% u,v    = corresponding vector components
% scale  = scale factor                       (default = 1)
% units  = Y-axis label; e.g., units = 'm/s') (default = none)
% jRange = limits of dates to plot            (default = auto)
%          (e.g., jRange = [min max])
%
% See also: f_julian, f_vecUV, f_shadeBox

% ----- Notes: -----
% This function is used to plot time series of wind or 
% current meter velocity vectors using Matlab's QUIVER
% function. This function is necessary in order to obtain
% vectors that have the proper length and angle of rotation.
% An optional scaling factor can be applied allowing the
% user control over the amount of overlap among vectors
% and/or the scaling of vectors relative to the overall
% time series. The X-axis is scaled accordingly. The Y-axis
% allows easy, visual interpretation of vector length.
%
% U,V components of velocity vectors can be extracted from
% data specifying only Speed and Direction using f_vecUV.

% ----- Author(s): -----
% by Dave Jones,<djones@rsmas.miami.edu> Dec-2002
% http://www.rsmas.miami.edu/personal/djones/
% ----------------- DISCLAIMER: -------------------
% This code is provided as is, with no guarantees
% and is only intended for non-commercial use.
% --------------------------------------------------

% 10-Dec-2002: scaling now operates on the X- vs. Y-axis;
%              Y-axis limits can now be specified

% ----- Check input & set defaults: -----
if (nargin < 4), scale   = 1;  end; % no scaling by default
if (nargin < 5), units   = []; end; % no units by default
if (nargin < 6), jRange  = []; end; % no range specified

if (scale==0)
	error('You cannot scale vectors by 0');
end

if (size(u,1) ~= size(v,1)) | (size(u,1) ~= size(jdate,1))
	error('U,V, and JDATE must be same size!')
end
% ---------------------------------------

nr = size(jdate,1); % # rows

figure;
hold on;

% plot vectors:
h = quiver(jdate/scale,zeros(nr,1),u,v,0,'.b-');

% plot base line:
plot([min(jdate/scale) max(jdate/scale)]',[0 0]','k-');

% adjust aspect ratio for correct angles and lengths:
daspect([1 1 1]);

% adjust X-axis limits & labels:
if (scale ~= 1)
	
	if (jRange ~= [])
		xlim([jRange(1)/scale jRange(2)/scale]);
	end
	
	xLabels = get(gca,'xticklabel');  % get tick labels
	xLabels = str2num(xLabels);       % convert to numbers
	xLabels = num2str(xLabels*scale); % recale values
	set(gca,'xticklabel',xLabels);    % replace labels
end

% adjust plot appearance:
set(gcf,'color','w');
set(gca,'TickDir','out');
xlabel('Julian Day');
ylabel(units);
box off;

hold off;

