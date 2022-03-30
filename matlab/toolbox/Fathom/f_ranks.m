function res = f_ranks(x);
% - ranks data in x (with averaging of ties)
% USAGE: res = f_ranks(x)
%
% x can be a vector or symmetric distance matrix

% -----Credits:-----
% originally Ranks.m by Lutz Duembgen, 23.02.1999

% edited by Dave Jones<djones@rsmas.miami.edu>, 2001
% http://www.rsmas.miami.edu/personal/djones/
% ----------------- DISCLAIMER: -------------------
% This code is provided as is, with no guarantees
% and is only intended for non-commercial use.
% --------------------------------------------------

% 26-Mar-02: added special handling of symmetric distance matrices

% Symmetric distance matrix requires special handling:
if (sum(diag(x)) == 0) & (size(x,1) == size(x,2))
   x = f_unwrap(x);
   symDis = 1;
else
   symDis = 0;
end

n = length(x);
res = zeros(size(x));

[hv,ar] = sort(x);

a = 1;
for b=2:n
   if hv(b) > hv(a)
      hv(a:b-1) = (a+b-1)/2;
      a = b;
   end;
end;
hv(a:n) = (a+n)/2;
res(ar) = hv;

% Convert back to symmetric distance matrix:
if symDis>0, res = f_rewrap(res); end;
   