function y = f_shuffle(x,method,grp); 
% - randomly sorts vector, matrix, or symmetric distance matrix
%
% Usage: y = f_shuffle(x,{method},{grp}) 
% 
% -----Input/Output:-----
% x      = vector, matrix, or symmetric distance matrix
%
% method = type of permutation to perform
%          (default = 1 for a regular matrix or vector)
%          (default = 2 for a symmetric distance matrix)
%          1: unrestricted permutation
%          2: unrestricted, rows & cols are permuted same the way
%          3: permutation restricted to within columns of matrix
%          4: permute order of rows only (works across the matrix)
%          5: permutation restricted to within groups defined by grp
%
% grp    = vector specifying group membership for restricted permutation
%
% y      = random permutation of x
%     
% SEE ALSO: f_randRange

% by Dave Jones<djones@rsmas.miami.edu>, Mar-2002
% http://www.rsmas.miami.edu/personal/djones/
% ----------------- DISCLAIMER: -------------------
% This code is provided as is, with no guarantees
% and is only intended for non-commercial use.
% --------------------------------------------------

% -----Notes:-----
% When permuting a symmetric distance matrix, care must be taken to
% shuffle the objects making up the matrix and not the tridiagonal
% (see references below)

% -----References (for permutation of distance matrix):-----
% Legendre, P. & L. Legendre. 1998. Numerical ecology. 2nd English ed.
%  Elsevier Science BV, Amsterdam. xv + 853 pp. [page 552]
% Sokal, R. R. and F. J. Rohlf. 1995. Biometry - The principles and 
%  practice of statistics in bioligical research. 3rd ed. W. H. 
%  Freeman, New York. xix + 887 pp. [page 817]

% 31-Mar-2002: added restricted permutation via grouping vector
% 18-Apr-2002: added switch-case handling of method options
%              and column-restricted permutation

if (nargin<2) & (f_issymdis(x)==0), method = 1; end; % default for non-symmetric matrices
if (nargin<2) & (f_issymdis(x)==1), method = 2; end; % default for symmetric matrices

[nr,nc] = size(x);

switch method   
case 1 % Permutation of a regular vector or matrix:
   y = x(randperm(length(x(:))));
   y = reshape(y,nr,nc);
   
case 2 % Permutation of rows then colums, in the same way
   if (nr~=nc)
      error('Method 2 requires a square matrix')
   end
   i = randperm(nr); % get permuted indices
   y = x(i,:);       % permute rows
   y = y(:,i);       % permute cols
   
case 3 % Permutation restricted to columns
   for i = 1:nc
      y(:,i) = f_shuffle(x(:,i),1);
   end
   
case 4 % Permute order of rows only (works across the matrix)
   i = randperm(nr); % get permuted indices
   y = x(i,:);       % permute rows
   
case 5 % Permutation restricted to groups:
   if (nargin<3)
      error('Restricted permutation requires a grouping vector');
   end
   
   % make sure inputs are compatible:
   if (prod((size(x) == size(grp)))==0);
      error('X & GRP are not of compatible sizes');
   end;
   
   grpVar = unique(grp);    % unique groups
   noGrps = length(grpVar); % # of groups
   
   for i = 1:noGrps
      y(find(grp==grpVar(i))) = x(f_shuffle(find(grp==grpVar(i))),1);
   end;
   
   % Return to column vector if necessary:
   if (size(x,1)>1) & (size(x,2)==1), y = y(:); end; 
   
otherwise  
   error('Unknown permutation method!');
end
