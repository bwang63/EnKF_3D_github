function res = f_unwrap(x);
% - unwraps lower tri-diagonal (w/o diag) of symmetric distance matrix into a column vector
% Usage: res = f_unwrap(x);
%
% x   = symmetric distance matrix
% res = column vector of extracted elements
%
% SEE ALSO: f_rewrap

% -----References:-----
% after USENET article by Eugene Gall<eugenegall@aol.com>
% posted to news://comp.soft-sys.matlab

% by Dave Jones <djones@rsmas.miami.edu>
% http://www.rsmas.miami.edu/personal/djones/
% ----------------- DISCLAIMER: -------------------
% This code is provided as is, with no guarantees
% and is only intended for non-commercial use.
% --------------------------------------------------

% note how it uses "triu" but returns lower tridiagonal (DJ)

% 28-Mar-02: added checking of input

if (f_issymdis(x) == 0)
   error('Requires square symmetric distance matrix');
end;

res = x(find(~triu(ones(size(x)))));

