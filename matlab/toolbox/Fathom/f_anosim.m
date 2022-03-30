function [r,p] = f_anosim(xDis,grps,rank,iter,pw,plt);
% - 1-way Analysis of Similarity (ANOSIM)
%
% USAGE: [r,p] = f_anosim(xDis,grps,{rank},{iter},{pw},{plt});
%
% -----Input:-----
% xDis = symmetric distance matrix
% grps = row vector designating group membership for objects in xDis
%        e.g., grps = [1 1 2 2 3 3 2];
% rank = optionally rank distances in xDis (default = 1)
% iter = # iterations for randomized probabilities (default = 1000)
% pw   = do pairwise tests (default = 1);
% plt  = make diagnostic plot (default = 0);
%
% -----Output:-----
% r    = strength of relationship (ranges from -1 to 1)
% p    = permutation-based probability of no difference between groups
%        (one-tailed)
%
% SEE ALSO: f_anosim2, f_npManova, f_mantel, f_modelMatrix

% -----Notes:-----
% This functions performs a multivariate ANOSIM by computing an unstandardized
% Mantel Statistic between a {ranked} distance matrix and a model matrix; the
% model matrix is derived from a row vector designating group membership. Results are
% equivalent to Clarke's method. The permutation test permutes the rows/columns
% of the distance matrix xDis. Pairwise tests between each group are also optionally run.
% Permutation tests are based on the complete permutation distribution when it is
% < 5000, otherwise it is randomly sampled the number of times specified by ITER.
%
% ANOSIM assmumes that under the null hypothesis distances within groups are smaller
% than those between groups,thus significant differences can arise between groups having
% different dispersions but identical centroids. Diagnostic boxplots are provided
% as a way to check this and prevent type I error.
%
% This program has been tested against 'Primer 5 for Windows' and gives
% the same results.

% -----References:-----
% Clarke, K. R. 1993. Non-parametric multivariate analyses of changes
%   in community structure. Aust. J. Ecol. 18: 117-143.
% Clarke, K. R. 2002. Personal Communication.
% Legendre, P. & L. Legendre. 1998. Numerical ecology. 2nd English ed.
%   Elsevier Science BV, Amsterdam. pp.552;561-562

% by Dave Jones,<djones@rsmas.miami.edu> Mar-2002
% http://www.rsmas.miami.edu/personal/djones/
% ----------------- DISCLAIMER: -------------------
% This code is provided as is, with no guarantees
% and is only intended for non-commercial use.
% --------------------------------------------------

% 25-Mar-02: overhauled randomization tests, added pair-wise tests
% 27-Mar-02: make call to f_multicomb
% 04-Arp-02: added diagnostic boxplots

if (nargin < 3), rank = 1;    end; % rank distances by default
if (nargin < 4), iter = 1000; end; % default iterations
if (nargin < 5), pw   = 1;    end; % do pairwise tests by default
if (nargin < 6), plt  = 0;    end; % don't make diagnostic plots by default

% -----Check input:-----
if (f_issymdis(xDis) == 0)
   error('Input X must be a square symmetric distance matrix');
end;

grps = grps(:)'; % make sure it's a row vector
if size(xDis,1) ~= length(grps), error('X & GRPS have incompatible sizes'); end;

% Optionally rank distances:
if (rank>0), xDis = f_ranks(xDis); end;

% Create model matrix, then unwrap
z = f_unwrap(f_anosimModel(grps));

%-----Compute global R as unstandardized Mantel Statistic:-----
xx = f_unwrap(xDis); % unwrap
r  = sum(xx .* z);   % sum of cross-product for Global R

%-----Global R randomization test:-----
if iter>0
   randStat = zeros(iter-1,1); % preallocate results array
   for i = 1:(iter-1) % randomize (iter-1) times for correct p-value
      xx = f_unwrap(f_shuffle(xDis)); % permute then unwrap
      randStat(i) = sum(xx .* z);     % collect randomized stat
   end
   if (r>=0)
      j = find(randStat >= r); % get randomized stats >= to observed statistic
   else % need to handle negative R's as a lower-tail test
      j = find(randStat <= r); % get randomized stats <= to observed statistic
   end;
   p = (length(j)+1)./(iter); % count vales & convert to Global probability
   
   cPermG = f_multicomb(grps,1,1); % # of complete Global permutations (for display)
   aPermG = iter;                  % get of actual Global permutations (for display)
end;
%-----------------------------

%-----Pair-wise Tests:-----
if (pw>0) & (iter>0)   % optionally run pairwise tests:
   
   [subX,subGrps] = f_anosimSub(xDis,grps,1);
   noTests = size(subX,2); % # of pairwise tests to make
   
   for k = 1:noTests; %%--Do for each pair-wise test--%%
      subXX   = f_unwrap(subX{k}); % unwrap
      subZ    = f_unwrap(f_anosimModel(subGrps{k})); % model matrix
      
      % Calculate pair-wise R for this subset:
      subR(k) = sum(subXX .* subZ);
      rr(k)  = subR(k); % collect for later display
      
      %-----Permutation or Randomization Testing:-----
      % Generate complete permutation distribution if < 5000:
      [nPerms,pd] = f_multicomb(subGrps{k},1,5000);
      
      cPerm(k)  = nPerms; % get number of complete perms (for display)
      
      if (isnan(pd)<1) %%--Complete permutation distribution returned:--%%
         permSubR = zeros(nPerms,1); % preallocate results array
         
         for m = 1:nPerms %%--Do for each possible permutation of subX{k}--%%
            % Permute this subset:
            permSubX = subX{k}(pd(m,:),:);
            permSubX = permSubX(:,pd(m,:));
            
            permSubXX = f_unwrap(permSubX); % unwrap
            
            % Calculate pairwise R of subX{k} for this permutation:
            permSubR(m) = sum(permSubXX .* subZ);
         end;
         
         jj    = find(permSubR >= subR(k)); % get permuted stats >= to observed stat
         pp(k) = length(jj)./nPerms;        % count vales & convert to probability
         
         aPerm(k)  = nPerms; % get number of actual perms (for display)
         
      else %%--Randomly sample permutation distribution:--%%
         permSubR = zeros(iter-1,1); % preallocate results array
         
         for n = 1:(iter-1) %%--Randomize (iter-1) times for correct p-value:--%%
            permSubX  = f_shuffle(subX{k}); % randomize this subset
            permSubXX = f_unwrap(permSubX); % unwrap
            
            % Calculate pairwise R of subX{k} for this randomization:
            permSubR(n) = sum(permSubXX .* subZ);
         end;
         
         jj     = find(permSubR >= subR(k)); % get permuted stats >= to observed stat
         pp(k)  = (length(jj)+1)./iter;      % count vales & convert to probability
         
         aPerm(k) = iter; % get number of actual perms (for display)
         
      end;    
      %-----------------------------------------------
   end;
end;

% -----Send output to display:-----
fprintf('\n==================================================\n');
fprintf('         1-way ANOSIM RESULTS:\n');
fprintf('--------------------------------------------------\n');
fprintf('Groupings:\n %s\n\n',num2str(grps));
fprintf('Global Test:\n');
fprintf('  R = %3.4f  p = %3.4f (%2.0f of %2.0f possible perms) \n',r,p,aPermG,cPermG);

if pw>0
   fprintf('\nPair-Wise Tests:\n');
   for ii = 1:noTests
      txt = [num2str(unique(subGrps{ii})) ':'];
      fprintf('  %s R = %3.4f  p = %3.4f (%2.0f of %2.0f possible perms) \n',txt, rr(ii),pp(ii),aPerm(ii),cPerm(ii));
   end;
end;
fprintf('\n==================================================\n');


% ----- Optional diagnostic boxplot: -----
% Note: boxplot doesn't use NaN's in it's calculations   
if plt>0
   grpsVar = unique(grps);    % unique groups
   noGrps  = length(grpsVar); % # groups
   
   for t = 1:noGrps % extract distances from each group separately
      index = find(grps == grpsVar(t)); % subset indices of group to extract
      
      % Extract subset of distance matrix corresponding to this group:
      sDis = xDis(index,:);
      sDis = sDis(:,index);
      
      cellDis{t} = f_unwrap(sDis); % collect as a column vector
      
   end;
   
   noMax = max(cellfun('length',cellDis)); % maximum size of a group
   bp = zeros(noMax,noGrps); % matrix for box-plotting
   bp(:) = NaN; % initialized with NaN's, since matrix with cols with unequal # rows
   
   for u = 1:noGrps % fill box-plot matrix with unwrapped distances
      bp(1:length(cellDis{u}),u) = cellDis{u};
   end
   
   bp = sort(bp); % sort values increasing
   figure;
   boxplot(bp,1);
   title('ANOSIM Diagnostic Plot');
   xlabel('Group');
   ylabel('Within-Group Distance');
end;


