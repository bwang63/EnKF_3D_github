function [r,p] = f_mantel(xDis,yDis,rank,iter)
% - standardized Mantel statistic for 2 symmetric distance matries
%
% Usage: [r,p] = f_mantel(x,y,{rank},{iter});
%
% -----Input:-----
% x = symmetric distance matrix (permuted in randomization test)
% y = symmetric distance matrix (MODEL MATRIX in hypothesis tests)
% rank = optionally rank distances (default = 0)
% iter = number of iterations to use for 1-tailed randomization test (default = 0)
%
% -----Output:----- 
% r = standardized Mantel statistic
% p = randomized probability
%
% -----Notes:-----
% A) Matrix Y can be a model matrix for hypothesis testing. 
% B) The randomization test permutes the objects making up matrix X.
% C) X & Y must be derived INDEPENDENTLY.
%
% SEE ALSO: f_modelMatrix, f_anosim, f_bioenv, f_procrustes

% by Dave Jones,<djones@rsmas.miami.edu> Mar-2002
% http://www.rsmas.miami.edu/personal/djones/
% ----------------- DISCLAIMER: -------------------
% This code is provided as is, with no guarantees
% and is only intended for non-commercial use.
% --------------------------------------------------
%
% 18-Mar-02: make proper call to f_shuffle for distance matrix &
%            corrected calculation of p-value
% 27-Mar-02: made x the permuted matrix

% -----References:-----
% Legendre, P. & L. Legendre. 1998. Numerical ecology. 2nd English ed.
%   Elsevier Science BV, Amsterdam. xv + 853 pp. (page 552)

if (nargin < 3), rank = 0; end; % don't rank by default
if (nargin < 4), iter = 0; end; % don't perform randomization test

% -----Check input:-----
if (f_issymdis(xDis) == 0) | (f_issymdis(yDis) == 0)
   error('Input X & Y must be square symmetric distance matrices');
end;

% Optionally rank distances:
if rank>0
   xDis = f_ranks(xDis);
   yDis = f_ranks(yDis);
end;   

xx    = f_unwrap(xDis); % unwrap
yy    = f_unwrap(yDis);
noVar = length(yy);  % get number of elements

% Standardize:
xx = f_transform(xx',7)';
yy = f_transform(yy',7)';

% Take sum of cross-products, divide by n-1:
r = (sum(xx.*yy))/(noVar-1);

%-----Randomization Test:-----
randStat = zeros(iter-1,1); % preallocate results array
if iter>0
   for i = 1:(iter-1) % iter-1 for correct p-value
      xx = f_unwrap(f_shuffle(xDis));       % permute then unwrap
      xx = f_transform(xx',7)';             % standardize
      randStat(i) = (sum(xx.*yy))/(noVar-1); % collect randomized stat
   end
   if (r>=0)
      j = find(randStat >= r); % get randomized stats >= to observed statistic
   else % need to handle negative r's as a lower-tail test
      j = find(randStat <= r); % get randomized stats <= to observed statistic
   end;
   p = (length(j)+1)./(iter); % count vales & convert to probability
end;
%-----------------------------

if (nargout==0)
   fprintf('\nR = %3.4f \nProb = %3.4f (%3.0f iterations) \n',r,p,iter);
end