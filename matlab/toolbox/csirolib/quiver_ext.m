function hh = quiver_ext(rescale, length_legend, tail_point, axis_val, ...
      x, y, u, v, varargin)
% QUIVER_EXT: like QUIVER but with extra features.
%   QUIVER_EXT rescales vectors, has a legend and maintains the magnitude and
%   direction of the original vectors. Additionally, any cases where the
%   magnitude of the vector is zero or a NaN will not be printed - this
%   avoids the printing of a dot on the paper.
%
% hh = quiver_ext(rescale, length_legend, tail_point, axis_val, ...
%            x, y, u, v, varargin)
%
%  INPUT ARGUMENTS.
%
% The first 4 arguments are unique to QUIVER_EXT and are described below. The
% arguments after that are the same as in a call to QUIVER.
% RESCALE: A vector (RESCALE, 0) in (u, v) space will be plotted as length 1
%          in the x direction. If AXIS_VAL (see below) is also passed
%          scaling will be carried out so that all vectors of the same
%          magnitude in (u, v) space will have the same length on the screen
%          or paper. Note that (x, y) space is not the same as space on the
%          paper and if AXIS_VAL is empty then all vectors of the same
%          magnitude in (u, v) space will have the same length in (x, y)
%          space - which is not what you usually want. If RESCALE is empty
%          then the QUIVER autoscale is used unless a value of autoscale is
%          passed separately in the varargin part of the call - see QUIVER
%          documentation.
% LENGTH_LEGEND: length in (u, v) space for the arrow in the legend. If
%                length_legend is empty then the legend will not be drawn; if
%                it is <= 0 then the length will be taken as the maximum
%                length of the input vector, i.e., sqrt(max(u(:).^2 + v(:).^2)).
% TAIL_POINT: point in (x, y) space for the tail of the arrow in the
%             legend. If TAIL_POINT is empty or any element of tail_point
%             is a NaN then the user is prompted to use the mouse to mark
%             the tail of the arrow.
% AXIS_VAL: [xmin xmax ymin ymax] as passed to the axis command to specify
%           the figure axis. Passing this vector also causes the vector
%           lengths to be scaled so that vectors of the same magnitude in
%           (u, v) space will have the same length on the screen or paper.
%           If AXIS_VAL is empty then all vectors of the same
%           magnitude in (u, v) space will have the same length in (x, y)
%           space - which is not what you usually want.
%
%       Notes on the magnitude and direction of the vectors:
%
% Consider a common problem - plotting a series of wind vectors on a lat/lon
% grid. Assume that the wind at point A is a south-westerly. Furthermore,
% consider a point B which is 10 degrees north and 10 degrees east of A. Using
% QUIVER, the standard matlab routine for plotting vectors, the wind vector
% with its tail at A will point directly at B. This will happen even if the
% plot is stretched in one direction, i.e., delta(lon) ~= delta(lat) and does
% not allow for the non-linear mapping between lon/lat space and physical space
% (we are missing a cos(lat)). Accordingly, the vector need not be at 45
% degrees to the paper or screen. Furthermore, winds of the same magnitude but
% different direction will appear on the plot with different magnitudes (and
% the wrong directions) due to differential stretching in the lon and lat
% direction. By using the AXIS_VAL argument QUIVER_EXT can show a plot in which
% the magnitudes and angles of each vector are "correct" (relative to the
% paper). Of course, this means that the south-westerly vector described above
% will not point from A to B. Although this is usually what is required it
% can be misleading when plotting something like pressure contours with
% geostrophic winds overlaid. In this case it is best to just avoid the
% problem by fiddling things so that the delta(lon) == delta(lat). The
% easiest way to do this is by using 'axis equal'. Alternatively you can
% choose various settings to get the same effect. Suppose:
% >> axis_val = axis;
% >> Position = get(gca, 'Position');
% >> PaperPosition = get(gcf, 'PaperPosition');
% >> new_scale = (axis_val(4) - axis_val(3))/(axis_val(2) - axis_val(1))* ...
%     Position(3)*PaperPosition(3)/(Position(4)*PaperPosition(4));
% new_scale is the value used in QUIVER_EXT for the rescaling of the vector
% components and so the aim is to choose the settings so that new_scale == 1.
% The default settings have:
% >> Position(3)*PaperPosition(3)/(Position(4)*PaperPosition(4)) = 1.2679
% and so 'axis equal' simply sets 
% (axis_val(4) - axis_val(3))/(axis_val(2) - axis_val(1)) == 1/1.2679

% $Id: quiver_ext.m,v 1.5 1998/09/25 02:29:42 mansbrid Exp $
% Copyright J. V. Mansbridge, CSIRO, Mon Mar  9 18:24:39 EST 1998

if nargin < 8
  error('quiver_ext needs at least 8 arguments')
end

% Set defaults

if isempty(rescale)
  rescale = 1;
  autoscale = 1;
else
  autoscale = 0;
end
if isempty(tail_point)
  tail_point = NaN;
end
if isempty(axis_val)
  scale_y = 0;
else
  scale_y = 1;
end

ax_lims = axis;
nextpl_gcf = get(gcf, 'NextPlot');
ax = gca;
nextpl_gca = get(ax, 'NextPlot');
% xlim = get(gca, 'XLim');
% ylim = get(gca, 'YLim');
han = [];

if scale_y == 1
  Position = get(gca, 'Position');
  PaperPosition = get(gcf, 'PaperPosition');
  new_scale = (axis_val(4) - axis_val(3))/(axis_val(2) - axis_val(1))* ...
      Position(3)*PaperPosition(3)/(Position(4)*PaperPosition(4));
  v = v*new_scale;
else
  Position = get(gca, 'Position');
  PaperPosition = get(gcf, 'PaperPosition');
  new_scale = (ax_lims(4) - ax_lims(3))/(ax_lims(2) - ax_lims(1))* ...
      Position(3)*PaperPosition(3)/(Position(4)*PaperPosition(4));
end

% Parse the variable input arguments and pass on to quiver_old those that are
% strings. The autoscaling option is only reset if rescale has not
% been passed. The color of the legend is also determined.

len_v = length(varargin);
ind = [];
number_str = 0;
ls = '-';
ms = '';
col = '';
for ii = 1:len_v
  vv = varargin{ii};
  if isnumeric(vv)
    if length(vv) ~= 1
      if isempty(rescale)
	autoscale = vv;
      end
    else
      error('passed an array in the wrong place')
    end
  elseif ischar(vv)
    number_str = number_str + 1;
    ind(number_str) = ii;
    if ~strcmp(lower(vv(1)),'f')
      [l,c,m,msg] = colstyle(vv);
      if ~isempty(msg), 
	error(sprintf('Unknown option "%s".',vv));
      end
      if ~isempty(l), ls = l; end
      if ~isempty(c), col = c; end
      if ~isempty(m), ms = m; plotarrows = 0; end
      if isequal(m,'.'), ms = ''; end % Don't plot '.'
    end
  end
end
len_str = length(ind);
if len_str == 0
  [han, autoscale_return]  = quiver_old(x, y, u/rescale, v/rescale, autoscale);
elseif len_str == 1
  [han, autoscale_return] = quiver_old(x, y, u/rescale, v/rescale, ...
      autoscale, varargin{ind(1)});
elseif len_str == 2
  [han, autoscale_return] = quiver_old(x, y, u/rescale, v/rescale, ...
      autoscale, varargin{ind(1)}, varargin{ind(2)});
else
  error('too many strings passed')
end

if ~isempty(length_legend)
  if length_legend <= 0
    length_legend = sqrt(max(u(:).^2 + v(:).^2));
  end
  hold on
  len_arrow = length_legend/rescale;
  if autoscale_return ~= 0
    len_arrow = autoscale_return*len_arrow;
  end
  alpha = 0.33; % Size of arrow head relative to the length of the vector
  beta = 0.33;  % Width of the base of the arrow head relative to the length
  delta = 0.2*len_arrow;

  % Draw the legend-type box with the vector in it.

  if any(isnan(tail_point))
    disp('click mouse at desired tail point of the arrow in the legend'); 
    tail_point = ginput(1);
  end

  plot(tail_point(1)+[0 len_arrow], tail_point(2)+[0 0], [col ls])
  plot(tail_point(1)+len_arrow*[1 1-alpha], ...
      tail_point(2)+len_arrow*[0 -alpha*beta], [col ls])
  h_plot_samp = plot(tail_point(1)+len_arrow*[1 1-alpha], ...
      tail_point(2)+len_arrow*[0 alpha*beta], [col ls]);
  
  h_text = text((tail_point(1) + len_arrow/2), ...
      (tail_point(2) + len_arrow*alpha*beta*1.1), ...
      num2str(length_legend, 4));
  set(h_text, 'HorizontalAlignment', 'center');
  set(h_text, 'VerticalAlignment', 'bottom');
  if isempty(col)
    set(h_text, 'Color', get(h_plot_samp, 'Color'));
  else
    set(h_text, 'Color', col);
  end

  extent = get(h_text, 'Extent');
  x_lower = min([tail_point(1) extent(1)]) - delta;
  x_upper = max([(tail_point(1) + len_arrow) (extent(1) + extent(3))]) + delta;
  y_lower = tail_point(2) - len_arrow*alpha*beta - delta*new_scale;
  y_upper = extent(2) + extent(4) + delta*new_scale;
  plot([x_lower x_upper x_upper x_lower x_lower], ...
      [y_lower y_lower y_upper y_upper y_lower], [col ls])
  hold off
end

if scale_y == 1
  axis(axis_val)
end
% set(gca, 'XLim', xlim);
% set(gca, 'YLim', ylim);
set(gcf, 'NextPlot', nextpl_gcf);
set(ax, 'NextPlot', nextpl_gca);

if nargout > 0
  hh=han;
end

% The following is a copy of the matlab routine quiver except:
% 1) I have added code to avoid the printing of any vector whose magnitude is
%    zero or a NaN.
% 2) quiver_old can return the autoscale value that it uses so that this can
%    be used to rescale the legend vector.

function [hh, autoscale_return] = quiver_old(varargin)
%QUIVER Quiver plot.
%   QUIVER(X,Y,U,V) plots velocity vectors as arrows with components (u,v)
%   at the points (x,y).  The matrices X,Y,U,V must all be the same size
%   and contain corresponding position and vecocity components (X and Y
%   can also be vectors to specify a uniform grid).  QUIVER automatically
%   scales the arrows to fit within the grid.
%
%   QUIVER(U,V) plots velocity vectors at equally spaced points in
%   the x-y plane.
%
%   QUIVER(U,V,S) or QUIVER(X,Y,U,V,S) automatically scales the 
%   arrows to fit within the grid and then stretches them by S.  Use
%   S=0 to plot the arrows without the automatic scaling.
%
%   QUIVER(...,LINESPEC) uses the plot linestyle specified for
%   the velocity vectors.  Any marker in LINESPEC is drawn at the base
%   instead of an arrow on the tip.  Use a marker of '.' to specify
%   no marker at all.  See PLOT for other possibilities.
%
%   QUIVER(...,'filled') fills any markers specified.
%
%   H = QUIVER(...) returns a vector of line handles.
%
%   Example:
%      [x,y] = meshgrid(-2:.2:2,-1:.15:1);
%      z = x .* exp(-x.^2 - y.^2); [px,py] = gradient(z,.2,.15);
%      contour(x,y,z), hold on
%      quiver(x,y,px,py), hold off, axis image
%
%   See also FEATHER, QUIVER3, PLOT.

%   Clay M. Thompson 3-3-94
%   Copyright (c) 1984-97 by The MathWorks, Inc.
%   $Revision: 1.5 $  $Date: 1998/09/25 02:29:42 $

% Arrow head parameters
alpha = 0.33; % Size of arrow head relative to the length of the vector
beta = 0.33;  % Width of the base of the arrow head relative to the length
autoscale = 1; % Autoscale if ~= 0 then scale by this.
plotarrows = 1; % Plot arrows
sym = '';

filled = 0;
ls = '-';
ms = '';
col = '';

nin = nargin;
% Parse the string inputs
while isstr(varargin{nin}),
  vv = varargin{nin};
  if ~isempty(vv) & strcmp(lower(vv(1)),'f')
    filled = 1;
    nin = nin-1;
  else
    [l,c,m,msg] = colstyle(vv);
    if ~isempty(msg), 
      error(sprintf('Unknown option "%s".',vv));
    end
    if ~isempty(l), ls = l; end
    if ~isempty(c), col = c; end
    if ~isempty(m), ms = m; plotarrows = 0; end
    if isequal(m,'.'), ms = ''; end % Don't plot '.'
    nin = nin-1;
  end
end

error(nargchk(2,5,nin));

% Check numeric input arguments
if nin<4, % quiver(u,v) or quiver(u,v,s)
  [msg,x,y,u,v] = xyzchk(varargin{1:2});
else
  [msg,x,y,u,v] = xyzchk(varargin{1:4});
end
if ~isempty(msg), error(msg); end

if nin==3 | nin==5, % quiver(u,v,s) or quiver(x,y,u,v,s)
  autoscale = varargin{nin};
end

% Scalar expand u,v
if prod(size(u))==1, u = u(ones(size(x))); end
if prod(size(v))==1, v = v(ones(size(u))); end

if autoscale,
  % Base autoscale value on average spacing in the x and y
  % directions.  Estimate number of points in each direction as
  % either the size of the input arrays or the effective square
  % spacing if x and y are vectors.
  if min(size(x))==1, n=sqrt(prod(size(x))); m=n; else [m,n]=size(x); end
  delx = diff([min(x(:)) max(x(:))])/n;
  dely = diff([min(y(:)) max(y(:))])/m;
  len = sqrt((u.^2 + v.^2)/(delx.^2 + dely.^2));
  autoscale = autoscale*0.9 / max(len(:));
  u = u*autoscale; v = v*autoscale;
end

ax = newplot;
next = lower(get(ax,'NextPlot'));
hold_state = ishold;

% Make velocity vectors
x = x(:).'; y = y(:).';
u = u(:).'; v = v(:).';

% Extra code to eliminate those vectors whose magnitude is zero or a NaN.

mag = u.*u + v.*v;
ff = find(~isnan(mag) & mag > 0);
if length(ff) > 0
  x = x(ff);
  y = y(ff);
  u = u(ff);
  v = v(ff);
end
uu = [x;x+u;repmat(NaN,size(u))];
vv = [y;y+v;repmat(NaN,size(u))];

h1 = plot(uu(:),vv(:),[col ls]);

if plotarrows,
  % Make arrow heads and plot them
  hu = [x+u-alpha*(u+beta*(v+eps));x+u; ...
        x+u-alpha*(u-beta*(v+eps));repmat(NaN,size(u))];
  hv = [y+v-alpha*(v-beta*(u+eps));y+v; ...
        y+v-alpha*(v+beta*(u+eps));repmat(NaN,size(v))];
  hold on
  h2 = plot(hu(:),hv(:),[col ls]);
else
  h2 = [];
end

if ~isempty(ms), % Plot marker on base
  hu = x; hv = y;
  hold on
  h3 = plot(hu(:),hv(:),[col ms]);
  if filled, set(h3,'markerfacecolor',get(h1,'color')); end
else
  h3 = [];
end
if ~hold_state, hold off, view(2); set(ax,'NextPlot',next); end

if nargout>0, hh = [h1;h2;h3]; end
if nargout > 1
  autoscale_return = autoscale;
end