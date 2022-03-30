function [cm] = interpcolormap(r, g, b, n, v, int_mode)

%INTERPCOLORMAP    interpolates (r, g, b) vectors to create an interpolated
%      color map containing n colors.
%
% INPUT: r,g,b - vectors of red, green, blue values in range 0-1
%        n  - number of colours in output map (default to 64)
%        v  - vector of values (0-1) corresponding to the r,g,b 
%             Default: equal spacing
%        int_mode - either 'spline' or 'linear' - type of interpolation. 
%             Default is 'spline'
%
% OUTPUT: cm - n x 3 rgb colormap
%
% Authors: Lindsay Pender & Jeff Dunn
% $Id: interpcolormap.m,v 1.1 1996/06/20 04:46:25 dunn Exp $

if  nargin < 3 | nargin > 6
   disp('cm = interpcolormap(r, g, b, {{{n}, v}, int_mode})');
   return;
end 
 
% Check the sizes of inputs

[mr, nr] = size(r);
[mg, ng] = size(g);
[mb, nb] = size(b);

if (mr == 1)
    r = r';
    [mr, nr] = size(r);
end;

if (mg == 1)
    g = g';
    [mg, ng] = size(g);
end;

if (mb == 1)
    b = b';
    [mb, nb] = size(b);
end;

if (mr ~=mg | mg ~= mb)
    error('INTERPCOLORMAP (r, g, b) must be the same length');      
end

c = [r g b];
if max(max(c)) > 1.01
  error('INTERPCOLORMAP r g b should all be in the range 0 - 1');
end
m = mr;

if nargin>=4
  if isempty(n)
    n = 64;
  end
else
  n = 64;
end

vdef = 0:m-1;
if nargin>=5
  if isempty(v) | length(v)~=m
    v = vdef;
  end
else
  v = vdef;
end

if nargin>=6
  if isempty(int_mode) | ~isstr(int_mode)
    int_mode = 'spline';
  end
else
  int_mode = 'spline';
end


if int_mode=='spline'
  % Find zeros and ones

  [i0, j0] = find(c <= 0.0);
  [i1, j1] = find(c >= 1.0);
  c1 = zeros(m, 3);
  for i = 1:length(i0)
    c1(i0(i), j0(i)) = -1;
  end

  for i = 1:length(i1)
    c1(i1(i), j1(i)) = 1;
  end

  % Interpolate

  xm = [0:n-1] * v(m) / (n - 1);
  cm = interp1(v, c, xm, int_mode);
  c1m = interp1(v, c1, xm);

  % Limit to [0 1]

  cm = change(cm, '<', 0, 0);
  cm = change(cm, '>', 1, 1);
  z = find(c1m < -0.5);
  cm(z) = zeros(1, length(z));
  o = find(c1m > 0.5);
  cm(o) = ones(1, length(o));
  
else

  c = change(c, '<', 0, 0);
  c = change(c, '>', 1, 1);
  xm = [0:n-1] * v(m) / (n - 1);
  cm = interp1(v, c, xm, int_mode);
  
end

% - - - - - End of interpcolormap.m - - - - -

