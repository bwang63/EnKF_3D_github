function [gauss_pt, x_zero] = lat_legendre(n, tol)

% lat_legendre returns the grid point latitudes for spherical harmonics.
%
%       INPUT:
%
% n: the order of the Legendre polynomial (94 for NCEP data)
% tol: the error tolerance for each root.
%
%       OUTPUT:
%
% gauss_pt: the latitudes (in degrees) for the Gaussian grid points.
% x_zero: the roots of the Legendre polynomial (gauss_pt = conv*asin(x_zero)
%

% $Id: lat_legendre.m,v 1.2 1997/09/04 06:07:54 mansbrid Exp $
% Copyright J. V. Mansbridge, CSIRO, Thu Sep  4 14:46:00 EST 1997

if nargin == 1
  tol = 1.e-6;
end

conv = 180/pi;
dx = 0.05/n;
x = -1:dx:(0 - dx);
len_x = length(x);
y = leg_poly(n, x);

% See how many zeros have been caught

ff = find(y == 0);
len_zeros = length(ff);
if len_zeros ~= 0
  x_zero_init = x(ff);
end

% Find regions where the Legendre polynomial changes sign. Also check that
% we have the correct number of regions.

ff = find(y(1:len_x-1).*y(2:len_x) < 0);
len_ff = length(ff);
if ((len_ff + len_zeros) ~= floor(n/2))
  error(['len_ff = ' num2str(len_ff)])
end

% Find zeros by a sort of secant method.

x_zero = zeros(len_ff, 1);
for ii = 1:len_ff
  x_0 = x(ff(ii));
  y_0 = y(ff(ii));
  x_1 = x(ff(ii) + 1);
  y_1 = y(ff(ii) + 1);
  y_new = ones(3, 1);
  while y_new(1)*y_new(3) > 0
    x_new = (y_1*x_0 - y_0*x_1)/(y_1 - y_0);
    y_new = leg_poly(n, [x_new - tol x_new x_new + tol]);
    x_0 = x_1;
    y_0 = y_1;
    x_1 = x_new;
    y_1 = y_new(2);
  end
  x_zero(ii) = x_new;
end

% Add in any extra zeros and then add in the extra bits due to symmetry.

if len_zeros ~= 0
  x_zero = sort([x_zero; x_zero_init]);
end

if rem(n, 2) == 0
  x_zero = [x_zero; -flipud(x_zero)];
else
  x_zero = [x_zero; 0; -flipud(x_zero)];
end

gauss_pt = conv*asin(x_zero);

function y = leg_poly(n, x)
y = legendre(n, x);
y = y(1, :); % get Legendre polynomial for m == 0
