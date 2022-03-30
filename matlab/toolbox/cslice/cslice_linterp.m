function yi = cslice_linterp(x, y, xi)

% LINTERP Linear lnterpolation.
%  LINTERP(X,Y,XI) linearly interpolates column vector X and
%   matrix Y of the same height, yielding matrix YI, whose rows
%   correspond to the XI values.  XI values beyond the range of X
%   are extrapolated linearly from the ends of X.  If XI is a
%   scalar integer value greater than 1, it represents the number
%   of values to interpolate evenly between the ends of X,
%   including the endpoints themselves.

% Charles R. Denham, 1988, 1990.
%	Copyright (c) 1990 by the MathWorks, Inc.

% Help and demonstration plot if no input arguments.

if nargin < 1
   help cslice_linterp
   n = 11; ni = 20;
   x = rand(n, 1); y = rand(n, 1);
   xi = rand(ni, 1);
end

c = computer;
ismac = strcmp(c, 'MAC');

% Sorting.

[m, n] = size(y); oldm = m;
if m == 1, y = y(:); [m, n] = size(y); end

[x, k] = sort(x(:)); y = y(k, :);
[xi, i] = sort(xi); [i, k] = sort(i);

% Derivatives.

dx = diff(x); dy = diff(y);
f = find(dx == 0);
if any(f)
   dy(f, :) = 0 .* dy(f, :); dx(f) = 1 + dx(f);
end
dx = dx * ones(1, n);   % Expand dx to size of dy.
dydx = dy ./ dx;

% Interpolation.

yyi = zeros(length(xi), n);
i = 1;
for j = 1:length(xi)
   if ismac
      if rem(j, 200) == 0
         disp(['At value ' int2str(j)])
      end
   end
   while i < length(x)-1
      if xi(j) <= x(i+1), break, end
      i = i + 1;
   end
   yyi(j, :) = y(i, :) + (xi(j) - x(i)) .* dydx(i, :);
end
yyi = yyi(k, :);   % In order of original xi.

% Plot if demonstration.

if nargin < 1
   hold off
   plot(x, y, 'r-', xi(k), yyi, 'g*');
   xlabel('x or xi'), ylabel('y or yi')
   title('LINTERP: y(x) = solid; interpolated yi(xi) = *')
  else
   yi = yyi;
end
