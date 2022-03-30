function [Qstar,trc,ccor,H,p1,p2,centroids] = f_cap(yDis,x,rank,iter,plt,verb)
% - Canonical Analysis of Principal Coordinates using ANY distance matrix
%
% USAGE: [crds,trc,ccor,H,p1,p2,centroids] = f_cva(yDis,x,{rank},{iter},{plt},{verb})
%
% -----Input/Output:-----
% yDis = square symmetric distance matrix derived from response variables
% 
% x    = (1) vector of integers specifying group membership for objects in yDis,
%        (2) ANOVA design matrix specified by dummy coding, or
%        (3) matrix of explanatory variables (rows = observations, cols = variables)
%
% rank = optionally rank distances in yDis  (default = 0)
% iter = # iterations for permutation test  (default = 0)
% plt  = optionally plot results            (default = 1)
% verb = optionally send results to display (default = 1)
%
% crds = coordinates of canonical axes (= Qstar)
% trc  = trace statistic
% ccor = canonical eigenvalues (1st value is greatest root statistic)
% p1   = randomized probability of trace statistic
% p2   = randomized probability of greatest root statistic
% centroids = centroids of groups defined in x
%
% SEE ALSO: f_designMatrix, f_anosim, f_anosim2, f_mantel, manova1
%
% -----Notes:-----
% This program performs nonparametric Multiple Discriminant Analysis on ANY symmetric
% distance matrix when the input for X is (1) a vector specifying group membership. It
% performs generalized Conical Variates Analysis when X is (2) an ANOVA design matrix or
% (3) a matrix of explanatory variables.
%
% Use f_designMatrix to create an ANOVA design matrix for input as X; the matrix should be
% full rank (not singular) and DO NOT include an intercept term (a column all 1's).
%
% The program asks the user to specify how many axes of Q to retain for the analysis (m).
% Examine the EIGENVALUES and '% VARIATION EXPLAINED' output in the command window and
% try to include as much information in Q as possible with as few axes as possible.

% -----References:-----
% Anderson, M. J. 2002. CAP: a FORTRAN program for canonical analysis of principal
%  coordinates. Dept. of Statistics University of Auckland.
%  http://www.stat.auckland.ac.nz/PEOPLE/marti/
% Anderson, M. J. and T. J. Willis. 2002. Canonical analysis of principal coordinates:
%  and ecologically meaningful approach for constrained ordination. Ecology (In Press).
% Legendre, P. & L. Legendre. 1998. Numerical ecology. 2nd English ed.
%  Elsevier Science BV, Amsterdam. pp.616-631.

% -----Testing:-----
% This program has been tested against the numerical example in Legendre & Legendre
% (1998:p.626) and provides similar output. It has also been tested against Anderson's
% DISTCVA using Fisher's 'Iris' data and provides the same p-values and an identical
% canonical plot (except for a change in sign in canonical axis I). However, the canonical
% correlations of DISTCVA are scaled differently (method unknown). The "% variation explained"
% for each canonical axis, calculated by F_CAP, are almost identical to that computed by 
% MANOVA1.M in Matlab's Statistical Toolbox (version 3) for the "Iris" data.

% -----Dependencies:-----
% ortha.m (included in Jones' Toolbox)
% by Andrew Knyazev<knyazev@na-net.ornl.gov> and Rico Argentati
% http://www-math.cudenver.edu/~aknyazev/software/MATLAB/

% by Dave Jones,<djones@rsmas.miami.edu> Apr-2002
% http://www.rsmas.miami.edu/personal/djones/
% ----------------- DISCLAIMER: -------------------
% This code is provided as is, with no guarantees
% and is only intended for non-commercial use.
% --------------------------------------------------

% July-2002: Renamed f_cap (was f_cva) for consistency with Anderson's CAP;
%            Improved display of resuts

if (nargin < 3), rank  = 0; end; % don't rank distances by default
if (nargin < 4), iter  = 0; end; % default iterations for permutation test
if (nargin < 5), plt   = 1; end; % make plot by default
if (nargin < 6), verb  = 1; end; % send output to display by default

n = size(yDis,1);

% -----Check input:-----
if n ~= size(x,1), error('yDis & X need same # of rows'); end;

if (f_issymdis(yDis) == 0)
   error('Input yDIS must be a square symmetric distance matrix');
end;

% When x is a vector specifying group membership:
if (size(x,1)==1) | (size(x,2)==1) 
   grps = x(:);                % make sure it's a column vector
   x = f_designMatrix(grps,1); % create ANOVA design matrix w/o intercept term
else
   grps = []; % grouping vector not provided
end
% ----------------------

% Optionally rank distances:
if (rank>0), yDis = f_ranks(yDis); end;

% Hat (Projection) matrix:
% H = x*(inv(x'*x))*x';
%
% Find H without taking inverse using QR decomposition & some fancy
% algebraic substitution (courtesy news://comp.soft-sys.matlab):
[Q1,R1] = qr(x,0);
H       = Q1*Q1';

% Compute Q via PCoA:
[Q,evals,expl] = f_pcoa(yDis,0,0); % this calculates A & G matrices

[posRows,posCols] = find(evals >= 0); % get row indices of positive eigenvalues
noPos = size(evals(posRows,:),1);     % # of positive eigenvalues

% Show eigenvalues and '% variance explained':
fprintf('\n-------------------------------\n');
fprintf('        Matrix Q: \n')
fprintf('-------------------------------\n');
fprintf(' + Eigenvalues:   %% Explained:   Axis: \n')
disp(num2str([evals(posRows,:) expl(posRows,2)   [1:noPos]']));
fprintf('\n-------------------------------\n');

% Get user to specify # axes to retain:
inputText = ['Specify # of Axes in Q to retain (1-' num2str(noPos) ') ? '];
m = input(inputText);
if (m>noPos) | (m<1)
   error(['Invalid input...select a value between 1 and ' num2str(noPos)]);
end

% Subset of Q:
Qm = Q(:,1:m);

% Orthonormalize canonical axes (Qm) to reference
% space of model matrix or explanatory variables (H):
Qstar = ortha(H,Qm);

% Canonical trace statistic:
trc = (sum(diag(Qm'*H*Qm)));

% Canonical eigenvalues:
ccor = eig(Qm'*H*Qm);

% Greatest root statistic:
grs = ccor(1);

%-----Permutation tests:-----
if iter>0
   fprintf('\nPermuting the data %d times...\n',iter-1);
   [nr,nc] = size(Qm);
   randStat = zeros(iter-1,1); % preallocate results array
   
   for i = 1:(iter-1) % observed value is considered a permutation
      
      % The following permutation keeps the coordinates defining an observation
      % intact, but permutes their row order, then column order:
      QmPermed = f_shuffle(Qm,4);         % permute order of rows (across columns)
      QmPermed = f_shuffle(QmPermed',3)'; % permute order of columns (across rows)
      
      randTrc(i) = (sum(diag(QmPermed'*H*QmPermed))); % permuted trace stat
      randCcor   = eig(QmPermed'*H*QmPermed); % permuted canonical eigenvalues
      randGrs(i) = randCcor(1);               % permuted greatest root stat
      
   end
   j1 = find(randTrc >= trc); % get randomized stats >= to observed statistic
   j2 = find(randGrs >= grs);  
   
   p1 = (length(j1)+1)./(iter); % count values & convert to probability
   p2 = (length(j2)+1)./(iter); 
end;
%-----------------------------

% -----Create Canonical Plot:-----
if (plt>0)
   figure;
   hold on;
   
   % If 'a priori' groups are specified, plot groups separately w/ centroid:
   if (length(grps(:))>0)
      
      centroids = f_centroid(Qstar,grps); % get centroid for each group
      uGrps  = unique(grps);              % unique groups
      noGrps = length(uGrps);             % # unique groups
      
      title('Canonical Discriminant Analysis');
      % plot points
      for j = 1:noGrps
         [gRows,ignore] = find(grps==uGrps(j)); % get row indices for each group
         plot(Qstar(gRows,1),Qstar(gRows,2),f_symb(j),'MarkerFaceColor',f_rgb(j),'MarkerEdgeColor',f_rgb(j));
      end
      % plot centroids afterwards, so won't be behind any points:
      for j = 1:noGrps
         h = text(centroids(j,1),centroids(j,2),num2str(j));
         set(h,'HorizontalAlignment','center','FontWeight','bold','FontSize',10,'Color',[0 0 0]);
      end
      
   else % 'a priori' groups not specified:
      % can't plot centroids w/o 'a priori' groups
      plot(Qstar(:,1),Qstar(:,2),'bo');      
      title('Canonical Variates Analysis');
   end
   
   box on;
   axis([1.1*min(Qstar(:,1)) 1.1*max(Qstar(:,1)) 1.1*min(Qstar(:,2)) 1.1*max(Qstar(:,2))]);
   % axis equal;
   
   can1 = sprintf('%2.2f',(ccor(1)/sum(ccor))*100);
   can2 = sprintf('%2.2f',(ccor(2)/sum(ccor))*100);
   xText = ['Canonical Axis I (' num2Str(can1) ' %)'];
   yText = ['Canonical Axis II (' num2Str(can2) ' %)'];   
   xlabel(xText);
   ylabel(yText);   
   
   hold off;   
end;
% --------------------------------

% -----Send output to display:-----
if (iter>0) & (verb>0)
   fprintf('\n==================================================\n');
   if (x>2)
      fprintf(' Nonparametric Canonical Variates Analysis: \n');
   else
      fprintf(' Nonparametric Canonical Discriminant Analysis:\n');
   end
   fprintf('--------------------------------------------------\n');
   fprintf('Trace Stat    = %-3.4f  p =  %3.5f \n',trc,p1);
   fprintf('Greatest Root = %-3.4f  p =  %3.5f \n',grs,p2);
   fprintf('No. of permutations = %d \n',iter);
   fprintf('--------------------------------------------------\n');
   fprintf('No. of axes of Q used (m) = %d \n',m);
   fprintf('Canonical Correlations:\n');
   fprintf('  %-3.4f',ccor);
   fprintf('\n==================================================\n');
end;
% ---------------------------------

