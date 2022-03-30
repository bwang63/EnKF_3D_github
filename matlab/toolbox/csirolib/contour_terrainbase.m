function [c, h, cont_h] = contour_terrainbase(cont);

% CONTOUR_TERRAINBASE -- Plot isopleths based on the terrainbase height field.
% function [c, h, cont_h] = contour_terrainbase(cont);
%
%     INPUT:
%   cont: a vector of bathymetric levels, i.e., -ve is underwater
%
%     OUTPUT
%   c: contour matrix C as described in CONTOURC
%   h: a column vector H of handles to LINE or PATCH objects, one handle per
%      line. 
%   cont_h: the contour level for each of the handles, i.e., cont_h(ii) will
%           be the contour level for the handle h(ii).
%
% Both C and H can be used as input to CLABEL.
%
%   WARNING - this can be quite slow and terrainbase is often inaccurate
%
%   Example usages:
% 1) to label and change the properties of all of the contour lines
%
% axis([142 150 -45 -37])
% cont = [0 -100 -200];
% [c, h, cont_h] = contour_terrainbase(cont);
% set(h, 'LineWidth', 2)
% set(h, 'LineStyle', '--')
% clabel(c)
%
% 2) to label and change the properties of all of the 100 metre contour
%    lines. Note that you can change the colours of the contours by using
%    the 'EdgeColor' property.
%
% axis([142 150 -45 -37])
% cont = [0 -100 -200];
% [c, h, cont_h] = contour_terrainbase(cont);
% ff = find(cont_h == -100);
% set(h(ff), 'LineWidth', 2)
% set(h(ff), 'LineStyle', ':')
% set(h(ff), 'EdgeColor', 'b')
% clabel(c, h)

% $Id: contour_terrainbase.m,v 1.1 1998/03/23 02:13:35 mansbrid Exp $
% Copyright J. V. Mansbridge, CSIRO, Mon Sep 29 18:37:02 EST 1997

if nargin ~= 1
  help contour_terrainbase
  error('must be exactly one input argument')
end

% Find 'NextPlot' values so that they can be reset later.

nextpl_gcf = get(gcf, 'NextPlot');
ax = gca;
nextpl_gca = get(ax, 'NextPlot');
xlim = get(gca, 'XLim');
ylim = get(gca, 'YLim');
set(gcf,'nextplot','add');
set(ax,'nextplot','add');

bath_name = 'terrainbase';

lon_bath_index_min = floor(xlim(1)*12 + 1);
lon_bath_index_max = floor(xlim(2)*12 + 1);
lat_bath_index_min = floor(ylim(1)*12 + 1081);
lat_bath_index_max = floor(ylim(2)*12 + 1081);

lon_bath = getnc(bath_name, 'lon', lon_bath_index_min, ...
    lon_bath_index_max);
lat_bath = getnc(bath_name, 'lat', lat_bath_index_min, ...
    lat_bath_index_max);
height_bath = getnc(bath_name, 'height', ...
    [lat_bath_index_min lon_bath_index_min], ...
    [lat_bath_index_max lon_bath_index_max]);

if length(cont) > 1
  [cs_t, h_t] = contour(lon_bath, lat_bath, height_bath, cont);
elseif length(cont) == 1
  [cs_t, h_t] = contour(lon_bath, lat_bath, height_bath, [cont cont]);
else
  error('cont has zero length')
end

% Find the contour levels for each handle. Note that the UserData
% property of each handle is a cell that contains the height value for each
% contour. 

cont_h_t = zeros(size(h_t));
xx = get(h_t, 'UserData');
for ii = 1:length(h_t)
  cont_h_t(ii) = xx{ii}(1);  
end

set(gca, 'XLim', xlim);
set(gca, 'YLim', ylim);
set(gcf, 'NextPlot', nextpl_gcf);
set(ax, 'NextPlot', nextpl_gca);

if nargout == 1
  c = cs_t;
elseif nargout == 2
  c = cs_t;
  h = h_t;
elseif nargout == 3
  c = cs_t;
  h = h_t;
  cont_h = cont_h_t;
end
