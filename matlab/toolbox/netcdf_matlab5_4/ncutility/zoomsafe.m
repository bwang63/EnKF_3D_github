function zoomsafe(varargin)

% ZoomSafe -- Safe zooming with the mouse.
%  ZoomSafe('demo') demonstrates itself with an interactive
%   line.  Zooming occurs with clicks that are NOT on the line.
%  ZoomSafe('on') initiates safe-zooming in the current window.
%   Zooming occurs with each click in the current-axes, except
%   when clicking on an object with a non-empty "ButtonDownFcn".
%   Thus, it is safe to select such an interactive object without
%   the annoyance of simultaneous zooming.
%  ZoomSafe('on', 'all') applies any new axis limits to all the
%   axes in the figure.
%  ZoomSafe('all') same as ZoomSafe('on', 'all').
%  ZoomSafe (no argument) same as ZoomSafe('on').
%  ZoomSafe('off') turns it off.
%  ZoomSafe('out') zooms fully out.
%  ZoomSafe(theAmount, theDirection) applies theAmount of zooming
%   to theDirection: 'x', 'y', or 'xy' (default).
%
%   "Click-Mode"   (Macintosh Action)   Result
%   "normal"       (click)              Zoom out x2, centered on click.
%   "extend"       (shift-click)        Zoom in x2, centered on click.
%   "alt"          (option-click)       Center on click without zooming.
%   "open"         (double-click)       Zoom fully out.
%
%  Use click-drag to map the zooming to a rubber-rectangle.
 
% Copyright (C) 1997 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.
 
% Version of 19-Jun-1997 08:42:57.
% Version of 16-Jul-1997 10:27:06.

if nargin < 1, varargin = {'on'}; end

if isstr(varargin{1}) & ~isempty(varargin{1}) & ...
      any(varargin{1}(1) == '0123456789.')
   varargin{1} = eval(varargin{1});
end

if ~isstr(varargin{1})
   theAmount = varargin{1};
   varargin{1} = 'manual';
end

theFlag = logical(0);
isAll = logical(0);

theOldXLim = get(gca, 'XLim');
theOldYLim = get(gca, 'YLim');

switch varargin{1}
case 'manual'
   isAll = (nargin > 2);
   theDirection = 'xy';
   if nargin > 1, theDirection = varargin{2}; end
   theXLim = get(gca, 'XLim');
   theYLim = get(gca, 'YLim');
   if theAmount == 0
      axis tight
      switch theDirection
      case 'x'
         set(gca, 'YLim', theYLim)
      case 'y'
         set(gca, 'XLim', theXLim)
      case 'xy'
      otherwise
      end
      theAmount = 1;
      theXLim = get(gca, 'XLim');
      theYLim = get(gca, 'YLim');
   end
   cx = mean(theXLim);
   cy = mean(theYLim);
   dx = diff(theXLim) ./ 2;
   dy = diff(theYLim) ./ 2;
   switch theDirection
   case 'x'
      theXLim = cx + [-dx dx] ./ theAmount;
   case 'y'
      theYLim = cy + [-dy dy] ./ theAmount;
   case 'xy'
      theXLim = cx + [-dx dx] ./ theAmount;
      theYLim = cy + [-dy dy] ./ theAmount;
   otherwise
   end
   set(gca, 'XLim', theXLim, 'YLim', theYLim);
   theFlag = 1;
case 'demo'
   x = (0:30) ./ 30;
   y = rand(size(x)) - 0.5;
   for i = 2:-1:1
      subplot(1, 2, i)
      theLine = plot(x, y, '-o');
      set(theLine, 'ButtonDownFcn', 'disp(''## hello'')')
      set(gcf, 'Name', 'ZoomSafe Demo')
   end
   zoomsafe on all
case 'all'
   zoomsafe on all
case 'on'
   isAll = (nargin > 1);
   if ~isAll
      set(gcf, 'WindowButtonDownFcn', 'zoomsafe down')
     else
      set(gcf, 'WindowButtonDownFcn', 'zoomsafe down all')
   end
case 'down'
   isAll = (nargin > 1);
   switch get(gco, 'Type')
   case {'figure', 'axes'}
      thePointer = get(gcf, 'Pointer');
      set(gcf, 'Pointer', 'watch')
      theRBRect = rbrect;
      x = sort(theRBRect([1 3]));
      y = sort(theRBRect([2 4]));
      theXLim = get(gca, 'XLim');
      theYLim = get(gca, 'YLim');
      theLimRect = [theXLim(1) theYLim(1) theXLim(2) theYLim(2)];
      switch get(gcf, 'SelectionType')
      case 'normal'
         theFlag = 1;
         theAmount = [2 2];   % Zoom-in by factor of 2.
      case 'extend'
         theFlag = 1;
         theAmount = [0.5 0.5];
      case 'open'
         if ~isAll
            zoomsafe out
           else
            zoomsafe out all
         end
         set(gcf, 'Pointer', 'arrow')
         return
      otherwise
         theAmount = [1 1];
         x = [mean(x) mean(x)];
         y = [mean(y) mean(y)];
      end
      if diff(x) == 0 | diff(y) == 0
         cx = mean(x);
         cy = mean(y);
         dx = diff(theXLim) ./ 2;
         dy = diff(theYLim) ./ 2;
         x = cx + [-dx dx] ./ theAmount(1);
         y = cy + [-dy dy] ./ theAmount(2);
        else
         r1 = theLimRect;
         r2 = theRBRect;
         switch get(gcf, 'SelectionType')
         case 'normal'
            r4 = maprect(r1, r2, r1);
         case 'extend'
            r4 = maprect(r2, r1, r1);
         otherwise
            r4 = r1;
         end
         x = r4([1 3]);
         y = r4([2 4]);
      end
      set(gca, 'XLim', sort(x), 'YLim', sort(y))
      theFlag = 1;
      switch thePointer
      case {'watch', 'circle'}
         thePointer = 'arrow';
      otherwise
      end
      set(gcf, 'Pointer', thePointer)
      set(gcf, 'Pointer', 'arrow')
   otherwise
   end
case 'motion'
case 'up'
case 'off'
   set(gcf, 'WindowButtonDownFcn', '');
case 'out'
   isAll = (nargin > 1);
   theFlag = 1;
   axis tight
otherwise
   temp = eval(varargin{1});
   switch class(temp)
   case 'double'
      if ~isAll
         zoomsafe(temp)
        else
         zoomsafe(temp, 'all')
      end
   otherwise
      warning('## Unknown option')
   end
end

% Synchronize the other axes.

if isAll & theFlag & 1
   theGCA = gca;
   theXLim = get(theGCA, 'XLim');
   theYLim = get(theGCA, 'YLim');
   theAxes = findobj(gcf, 'Type', 'axes');
   for i = 1:length(theAxes)
      if theAxes(i) ~= theGCA
         axes(theAxes(i))
         x = get(gca, 'XLim');
         y = get(gca, 'YLim');
         if all(x == theOldXLim)
            set(theAxes(i), 'XLim', theXLim)
         end
         if all(y == theOldYLim)
            set(theAxes(i), 'YLim', theYLim)
         end
      end
   end
   axes(theGCA)
end

function rect4 = MapRect(rect1, rect2, rect3)

% MapRect -- Map rectangles.
%  MapRect(rect1, rect2, rect3) returns the rectangle
%   that is to rect3 what rect1 is to rect2.  Each
%   rectangle is given as [x1 y1 x2 y2].
%  MapRect('demo') demonstrates itself by showing
%   that maprect(r1, r2, r1) ==> r2.
 
% Copyright (C) 1997 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.
 
% Version of 19-Jun-1997 08:33:39.

if nargin < 1, help(mfilename), rect1 = 'demo'; end

if strcmp(rect1, 'demo')
   rect1 = [0 0 3 3];
   rect2 = [1 1 2 2];
   rect3 = rect1;
   r4 = maprect(rect1, rect2, rect3);
   begets('MapRect', 3, rect1, rect2, rect3, r4)
   return
end

if nargin < 3, help(mfilename), return, end

r4 = zeros(1, 4);
i = [1 3];
for k = 1:2
   r4(i) = polyval(polyfit(rect1(i), rect2(i), 1), rect3(i));
   i = i + 1;
end

if nargout > 0
   rect4 = r4;
  else
   disp(r4)
end
