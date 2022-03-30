function xDis = f_rewrap(x);
% - reverse effect of f_unwrap
%
% USAGE: xDis = f_rewrap(x)
%
% -----Input/Output:-----
% x    = lower tridiagonal extracted from a symmetric
%        distance matrix by f_unwrap
% xDis = square symmetric distance matrix
%
% SEE ALSO: f_unwrap

%-----Notes:-----
% This function reverses the effect of f_unwrap by taking a column
% vector defining the lower tridiagonal of a square symmetric
% distance matrix (usually obtained from f_unwrap) and wraps it up 
% into square symmetric form.
%
% This code uses only ONE loop and the algorithm exploits the pattern
% between the size of the lower tridiagonal of a square symmetric matrix
% (sans the main diagonal) and the expected dimensions of the full matrix:
%
% dim of full matrix  = 2 3 4  5  6  7...etc
%                       --------------------
% size of tridiagonal = 1 3 6 10 15 21...etc

% by Dave Jones <djones@rsmas.miami.edu>, Mar-2002
% http://www.rsmas.miami.edu/personal/djones/
% ----------------- DISCLAIMER: -------------------
% This code is provided as is, with no guarantees
% and is only intended for non-commercial use.
% --------------------------------------------------

x = x(:); % make sure it's a column vector
sizeX = length(x); % size of tridiagonal

% -----Get dimensions of symmetric matrix:-----
if (sizeX == 1)
   dim = 2;
else        
   dimVar  = 2; sizeVar = 1; % initialize variables
   while (sizeVar < sizeX);
      dimVar  = dimVar + 1; % step thru table shown above
      sizeVar = (dimVar-1) + sizeVar;
      if (sizeVar == sizeX)
         dim = dimVar;
      elseif(sizeVar > sizeX)
         error('Input vector wrong size !');
      end;
   end;
end;
% ---------------------------------------------

xDis = zeros(dim,dim); % preallocate results matrix

ai = find(~triu(ones(dim))); % get indices for lower diagonal
bi = find(~tril(ones(dim))); % get indices for upper diagonal

xDis(ai) = x;         % fill lower tridiagonal
xDis(bi) = flipud(x); % fill upper tridiagonal
