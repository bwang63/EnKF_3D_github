function [F,t,R2,yfit,b,resid] = f_mregress(x,y,iter,perm,verb);
% - Multiple Linear Regression via Least Squares Estimation
%
% Usage: [F,t,r2,yfit,b,resid] = f_mregress(x,y,{iter},{perm},{verb})
%
% x    = matrix of independent variables         (column-wise);
% y    = column vector of dependent variable
% iter = # of iterations for permutation test    (default = 0)
% perm = permute residuals instead of raw data   (default = 1)
% verb = verbose output of results to display    (default = 1)
%
% F.stat   = F-statistic
% F.para_p = parametric  p-value for 1-tailed test of F.stat
% F.perm_p = permutation p-value for 1-tailed test of F.stat
% t.stat   = t-statistic for partial regression coefficients
% t.para_p = parametric  p-value for 1-tailed test of t.stats
% t.perm_p = permuttion  p-value for 1-tailed test of t.stats
%
% R2    = coefficient of multiple determination (goodness-of-fit)
% yfit  = fitted values of y
% b     = regression coefficients (1st value is y-intercept)
% resid = residuals

% -----Notes:-----
% This function solves the equation such that:
% y = b(0) + b(1)*(X(:,1)) + b(2)*(X(:,2)) ...+ b(k)*(X(:,k))
% where k = # of predictor variables.
%
% The regression coefficients are computed using Least Squares estimation
% (via the "\" operator), which is preferred over methods that require
% taking the inverse of a matrix. R2, the coefficient of multiple determination,
% is a measure of goodness-of-fit and gives the proportion of variance of
% Y explained by X.
%
% Parametric (and optional permutation) tests of significance for the F- and
% t-statistics are performed. The permutation test is conducted when iter > 0
% and allows for permutation of either the raw data or the residuals of the
% full regression model. Permutation of the raw data involves random permutation
% of the rows (= observations) of Y relative to the rows of X. The permutation
% test is preferred over the parametric test when the data are non-normal.
% Permutation of the residuals (vs. the raw data) is preferred when data have
% extreme values (i.e., outliers).
%
% This function has been tested against Legendre & Casgrain's
% regressn.exe program and gives similar output.

% -----Dependencies:-----
% Calculation of parametric p-values for F and t require fpdf.m and
% tcdf.m from the Matlab Statistics Toolbox, respectively; these 
% could be replaced by df.m and dt.m from the free Stixbox Toolbox.

% -----References:-----
% Legendre, P. & L. Legendre. 1998. Numerical ecology. 2nd English ed.
%   Elsevier Science BV, Amsterdam. xv + 853 pp. (pp.517, 606-612)
% Legendre, P. 2002. Program for multiple linear regression (ordinary or
%   through the origin) with permutation test - User's notes. Depart. of
%   Biological Sciences, University of Montreal. 11 pages. Available from:
%   <http://www.fas.umontreal.ca/biol/legendre/>
% Neter, J., W. Wasserman, & M. H. Kutner. 1989. Applied linear regression
%   models. 2nd Edition. Richard D. Irwin, Inc. Homewood, IL.

% by Dave Jones <djones@rsmas.miami.edu>, June-2001
% http://www.rsmas.miami.edu/personal/djones/
% portions after posts to news://comp.soft-sys.matlab
% ----------------- DISCLAIMER: -------------------
% This code is provided as is, with no guarantees
% and is only intended for non-commercial use.
% --------------------------------------------------

% Oct-2002: overhauled permutation test, added calculation of F,t,& R2,
%           & tabular display of results

if (nargin < 3), iter = 0; end; % set default iterations to 0
if (nargin < 4), perm = 1; end; % permute residuals by default
if (nargin < 5), verb = 1; end; % set default verbose to 0

% Add the y-intercept vector to x (add a column of 1's):
uno = ones(length(x(:,1)),1); % unit vector (Neter 6.17)
j = uno*uno';                 % unit matrix (Neter 6.18)
xOld = x; % keep copy of original x for permutation test;
x = [uno,x]; 

[n,k] = size(x); % n = # observations; k =  # predictor variables

% Check that x & y have compatible dimensions:
if (n ~= size(y,1)), 
	error('The number of rows in Y must equal the number of rows in X.'); 
end 

b     = x\y;      % get regression coefficients via Least Squares Estimation
yfit  = x*b;      % fitted values of y
resid = y - yfit; % residuals

% ========== ANOVA (See Neter et al., 1989:Chapter 7): =========
% Sum-of-Squares Total: (Neter 7.29)
SSt = y'*y - (1/n)*(y'*j*y);

% Sum-of-Squares Error: (Neter 7.30)
SSe = y'*y - b'*x'*y;

% Sum-of-Squares of Regression model: (Neter 7.31)
SSr = (b'*x'*y) - (1/n)*(y'*j*y);

% Mean Square Regression model: (Neter 7.32)
MSr = SSr/(k-1);

% Mean Square Error: (Neter 7.33)
MSe = SSe/(n-k);

% F-ratio: (for significance tests; Neter 7.34b)
F.stat = MSr/MSe;

% R^2 = Coefficient of Multiple Determination, a goodness-of-fit: (Neter 7.35)
R2 = SSr/SSt; % alteranatively, R2 = 1 - SSe/SSt

% Get estimated variance-covariance matrix: (Neter 7.43)
s2bMatrix = MSe*f_inv((x'*x));
s2b = diag(s2bMatrix); % extract variances for individual coefficients

% t-statistic for partial regression coefficients: (Neter 7.46b)
t.stat = b./sqrt(s2b); t.stat = t.stat';

% Parametric p-value for F:
F.para_p = 1 - fcdf(F.stat,k,n-k); % (one-tailed)

% Parametric p-values for t:
t.para_p = 1 - tcdf(abs(t.stat),(n-1)*ones(length(t),1)); % (one-tailed)

% ==============================================================

%-----Permutation Test for F- and t-statistics (One-Tailed):-----
rand('state',sum(100*clock)); % set random generator to new state
noCoefs = length(t.stat);     % # coefficients, excluding intercept
if (iter > 0)
	fprintf('\nPermuting the data %d times...\n',iter-1);
	
	% preallocate results array:
	randF = zeros(iter,1);
	for m=1:noCoefs % variable # of coefficients
		randT{m} = zeros(iter,1); 
	end
	
	% random permutation:
	for i = 1:(iter-1)               
		if (perm>0) % permute residuals:
			residPerm = f_shuffle(resid);
			[tempF,tempT] = f_mregress(xOld,residPerm,0,0,0); % need temporary variable since using structures
		else        % permute raw data:
			yPerm = f_shuffle(y,4);                   % randomize order of rows only
			[tempF,tempT] = f_mregress(xOld,yPerm,0,0,0); % need temporary variable since using structures
		end
		randF(i) = tempF.stat;  % keep list of randomized stats (move from structure to vector)
		for m=1:noCoefs
			randT{m}(i) = tempT.stat(m); % move from  structure to cell array
		end
	end
	
	
	% compute permuted p-values:
	jF = find(randF >= F.stat);                % get randomized values >= to F statistic
	
	for m = 1:noCoefs
		if (t.stat(m) >= 0) % right-tailed test:
			jT{m} = find(randT{m} >= t.stat(m)); % get randomized values >= to t statistic
		else % left-tailed test:
			jT{m} = find(randT{m} <= t.stat(m)); % get randomized values <= to t statistic
		end
		t.perm_p(m) = (length(jT{m})+1)./iter;  % count those vales & convert to probability 
	end
	
	F.perm_p = (length(jF)+1)./iter;           % count those vales & convert to probability 
else
	F.perm_p = NaN;
	for m=1:noCoefs
		t.perm_p(m) = NaN;
	end
end
%-------------------------------

if (verb>0)% send output to display:
	
	fprintf('=====================================================================\n');
	fprintf(' Multiple Linear Regression via QR Factorization:\n');
	fprintf('---------------------------------------------------------------------\n');
	fprintf('R2            F-stat        parametric-p  permutation-p \n');
	fprintf('---------------------------------------------------------------------\n');
	fprintf('%-13.5f %-13.5f %-13.5f %-13.5f \n',R2,F.stat,F.para_p,F.perm_p);
	fprintf('---------------------------------------------------------------------\n');
	fprintf('\n');
	fprintf('---------------------------------------------------------------------\n');
	fprintf('Variable      b             t-stat        parametric-p  permutation-p\n');
	fprintf('---------------------------------------------------------------------\n');
	
	for m=1:noCoefs
		if (m==1)
			fprintf('%13s %-13.5f %-13.5f %-13.5f %-13.5f \n',['intercept'],b(m),t.stat(m),t.para_p(m),t.perm_p(m));
		else
			fprintf('%13d %-13.5f %-13.5f %-13.5f %-13.5f \n',(m-1),b(m),t.stat(m),t.para_p(m),t.perm_p(m));
		end
	end
	
	fprintf('---------------------------------------------------------------------\n\n');
	if (perm>0)
		fprintf('# permutations of residuals = %5d \n',iter-1);	
	else
		fprintf('# permutations of rawdata = %5d \n',iter-1);	
	end
	fprintf('All significance tests are one-tailed \n');
	fprintf('=====================================================================\n');
end


