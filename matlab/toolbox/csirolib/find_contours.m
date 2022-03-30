function cont = find_contours(cs, n)
% find_contours.m returns a vector of monotonic increasing contours levels.
% cs may be the contour matrix as returned by contourf or contoursc.
% Alternatively cs may be the array of values for which the contour levels
% are to be found. The two cases are distinguished by checking whether cs is
% a 2xN matrix. If a second argument is passed then this is used to
% determine the approximate number of contour levels for the second case.

% $Id: find_contours.m,v 1.2 1997/11/20 04:11:25 mansbrid Exp $
% Copyright J. V. Mansbridge, CSIRO, Thu Jun 19 16:07:09 EST 1997

si_cs = size(cs);

if nargin == 0 | nargin > 2
  error('find_contours must be passed either 1 or 2 arguments')
end

if (length(si_cs) == 2) & (si_cs(1) == 2) & (nargin == 1)
  % cs is the 2xN matrix as returned by contourf or contoursc.
  ncols = size(cs, 2);
  cont = zeros(ncols, 1);

  % Store the contour levels in cont.

  ii = 1;
  count = 0;
  while ii < ncols
    count = count + 1;
    cont(count) = cs(1, ii);
    ii = ii + cs(2, ii) + 1;
  end
  cont = cont(1:count);

  % Sort cont and eliminate repeated contour levels.

  cont = sort(cont);
  dd = find(diff(cont)~=0);
  dd = dd(:);
  dd = [1; dd+1];
  cont = cont(dd);
else
  if nargin == 1
    n = 10;
  end
  xmin = nanmin(cs(:));
  xmax = nanmax(cs(:));
  inc = (xmax - xmin)/n;
  y = log10(inc);
  n_exp = floor(y);
  if n_exp >= 0
    levs_base = [1 2 2.5 4 5 7.5 10];
  else
    levs_base = [1 2 4 5 8 10];
  end
  levs = log10(levs_base);
  z = mod(y, 1);
  [junk, ii] = min(abs(levs - z));
  inc = 10^n_exp*levs_base(ii);
  cont = (inc*floor(xmin/inc):inc:inc*ceil(xmax/inc))';
end
