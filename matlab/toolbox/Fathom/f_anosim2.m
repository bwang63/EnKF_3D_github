function [r,p] = f_anosim2(dis,fac1,fac2,rank,iter);
% - 2-way crossed ANOSIM with no replication
%
% USAGE: [r,p] = f_anosim2(dis,fac1,fac2,{rank},iter);
%
% dis  = symmetric distance matrix
%
% fac1 = vectors of integers (or chars) specifying factors for
% fac2   rows/cols of distance matrix;
%        (e.g., fac1 = [1 1 1 2 2 2 3 3]; fac2 = ['abcabcac'])
%
% rank   = optionally rank distances (default = 1)
% iter   = iterations for permutation test (default = 0)
%
% r = strength of treatment effect (averaged across all blocks)
% p = permutation-based significance test 
%
%>> FAC1 & FAC2 must be equal to row/col size of DIS

% -----Notes:-----
% This procedure handles missing data in a 2-way layout design
% that would occur when one (or more) of the treatment levels
% is missing from a block.
%
% The one-tailed randomization-based significance test permutes
% the treatment labels SEPARATELY within each block.

% by Dave Jones<djones@rsmas.miami.edu>, Apr-2002
% http://www.rsmas.miami.edu/personal/djones/
% ----------------- DISCLAIMER: -------------------
% This code is provided as is, with no guarantees
% and is only intended for non-commercial use.
% --------------------------------------------------

% -----References:-----
% Clarke, K. R. and R. M. Warwick. 1994. Similarity-based testing
% for community pattern: the two-way layout with no replication.
% Mar. Bio. 118: 167-176.

% -----Testing:-----
% This program has been tested against 'Primer 5 for Windows'
% and gives the same results.

% -----Check Input:-----
fac1 = fac1(:); % make sure it's a col vector
fac2 = fac2(:);    

if (f_issymdis(dis) == 0)
   error('Input DIS must be a square symmetric distance matrix');
end;

if (length(fac1) ~= length(fac2)), 
   error('FAC1 & FAC2 must be of EQUAL SIZE!');
end;

if (size(dis,1) ~= length(fac1)),
   error('Size of DIS not compatible with FAC1 & FAC2');
end;
% ---------------------

if (nargin < 4), rank = 1; end; % rank distances by default
if (nargin < 5), iter = 0; end; % no permutation test by default

% Observed statistics, no permutation:
r(1) = f_anosim2Blk(dis,fac1,fac2,rank,0);
r(2) = f_anosim2Blk(dis,fac2,fac1,rank,0);

%-----Permutation Test:-----
if iter>0
   fprintf('(Please wait...running %d permutations for each of 2 factors.) \n\n',iter);
   for m = 1:2
      
      if (m==1) % swap factor_1 with factor_2
         block = fac1; Rx = fac2;
      else
         block = fac2; Rx = fac1;
      end;
      
      randStat = zeros(iter-1,1); % preallocate results array
      
      for i = 1:(iter-1)
         randStat(i) = f_anosim2Blk(dis,block,Rx,rank,1); % collect permuted stat
      end
      
      if (r(m) >= 0)
         j(m) = length(find(randStat >= r(m))); % get permuted stats >= to observed statistic
      else % need to handle negative R's as a lower-tail test
         j(m) = length((randStat <= r(m))); % get permuted stats <= to observed statistic
      end;
      
      p(m) = (j(m)+1)./(iter); % count vales & convert to probability
   end;
end;
%-----------------------------


% -----Send results to display:-----
fprintf('\n============================================================\n');
fprintf('Results of 2-way crossed ANOSIM (no replication):\n');
fprintf('------------------------------------------------------------\n\n');
fprintf('Strength of ''%s'' effect (averaged across all ''%s'' blocks): \n',upper(inputname(3)),upper(inputname(2)));
fprintf('  R = %5.4f ',r(1));
if iter>0
   fprintf('p = %5.4f (%d iterations) \n',p(1),iter);
   fprintf('  # permuted statistics greater than or equal to R = %d',j(1))   
end;
fprintf('\n\n');

fprintf('Strength of ''%s'' effect (averaged across all ''%s'' blocks): \n',upper(inputname(2)),upper(inputname(3)));
fprintf('  R = %5.4f ',r(2));
if iter>0
   fprintf('p = %5.4f (%d iterations) \n',p(2),iter);
   fprintf('  # permuted statistics greater than or equal to R = %d',j(2))   
end;
fprintf('\n');
fprintf('\n============================================================\n\n');
