function theResult = Plot1(varargin)

% Plot1 -- Plot in first set of axes.
%  Plot1(...) plots in the first set of axes, using
%   the syntax of plot().  The 'YAxisLocation' is
%   set to 'left'.
%  Plot1 (no argument) switches to the first axes.
%  Plot1('demo') demonstrates itself.
 
% Copyright (C) 1997 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.
 
% Version of 24-Apr-1997 10:59:23.

if nargin == 1 & isequal(varargin{1}, 'demo')
   delete(get(gcf, 'Children'))
   x1 = 0:10;
   x2 = 0:30;
   y1 = 3 .* x1;
   y2 = sin(2 .* pi .* x2 ./ max(x2));
   h1 = plot1(x1, y1, 'r+-');
   label1('Red x', 'xlabel')
   label1('Red y (+ --- +)', 'ylabel')
   set(gca, 'ButtonDownFcn', 'plot2, disp(''## Green Focus'')')
   p = get(gca, 'Position');
   p(4) = 0.95 .* p(4);
   set(gca, 'Position', p)
   h2 = plot2(x2, y2, 'go-');
   label2('Green x', 'xlabel')
   label2('Green y (o --- o)', 'ylabel')
   set(gca, 'ButtonDownFcn', 'plot1, disp(''## Red Focus'')')
   set(gcf, 'Name', 'Click To Switch Focus')
   plot1
   return
end

theAxes = sort(findobj(gcf, 'Type', 'axes'));
while length(theAxes) < 1
   theAxes = [theAxes axes];
end
axes(theAxes(1))

if nargin > 0
   varargout = cell(1, nargout);
   v = vargstr('plot', length(varargin), length(varargout));
   eval(v)
end

theDefaultColor = get(0, 'DefaultAxesColor');
if length(theAxes) > 1
   set(theAxes(2), 'Color', theDefaultColor)
end
set(theAxes(1), 'Color', 'none', ...
                'XAxisLocation', 'bottom', ...
                'YAxisLocation', 'left')

if nargout > 0, theResult = varargout{1}; end
