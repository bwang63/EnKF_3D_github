function [Xscl,Yrot,m2,resid,prob] = f_procrustes(X,Y,stnd,iter,plotflag,permflag);
% - Procrustes rotation of Y to X
%
% USAGE: [Xscl,Yrot,m2,resid,prob] = f_procrustes(X,Y,stnd,iter,plotflag);
%
% X       = reference matrix (rows = observations; cols = variables)
% Y       = target matrix to rotate
% stnd    = standardize variables (default = 0)
% iter    = # iterations for permutation-based significance test (default = 0)
% plotflag = plot fitted results (default = 0);
% 
% Xscl  = centered and scaled form of X
% Yrot  = centered, scaled, and rotated form of Y
% m2    = symmetric Procrustes statistic, ranges from 0-1
%         (smaller values indicate better fit) 
% resid = structure of residuals (*.dim, *.obs, and *.sse)
% prob  = permutation-based significance of m2
%
% SEE ALSO: f_mantel, f_bioenv

% -----Notes:-----
% This function performs an orthogonal least-squares Procrustes analysis
% on 2 rectangular data matrices (X & Y) by minimizing the sum-of-squared
% distances between corresponding elements of the 2 matrices. This is done
% by translating, scaling, mirroring, and rotating Y to fit X. The symmetric
% orthogonal Procrustes statistic (m^2) is a measure of goodness-of-fit of Y
% to X after rotation and provides the residual sum-of-squares, which varies
% from 0 to 1; smaller values indicate better fit.
%
% If the # of variables (columns) in X < Y, it is padded with 0's and allows
% one to, say, rotate an ordination to an environmental variable.
%
% When STND = 1 each variable is standardized to mean 0 and variance 1 so they
% will contribute equal weight to the fitting process. This, however, may distort
% the final configurations.
%
% An optional permutation-based significance test of m^2 is performed when
% ITER > 0 to assess the statistical concordance between the 2 matrices.
%
% RESID.DIM provides the length of each observation along each dimension after
% rotation. This allows interpretation of the direction of increase when Y codes
% for, say, an environmental gradient.
%
% RESID.OBS provides the total length of each observation, which is a measure of
% goodness-of-fit for each observation; (smaller values = better fit).
%
% RESID.SSE (like M2) is a measure of total concordance between X and Y
% (smaller values = better fit)

% -----References:-----
% Legendre, P. & L. Legendre. 1998. Numerical ecology. 2nd English ed.
% Elsevier Science BV, Amsterdam.
%
% Peres-Neto, P. R. 2000. Documentation for program PROTEST.EXE. Dept. of Zoology,
% University of Toronto. Available from: http://www.zoo.utoronto.ca/jackson/software/
%
% Peres-Neto, P. R. and D. A. Jackson. 2001. How well do multivariate data sets
% match? The advantages of a Procrustean superimposition approach over the Mantel
% test. Oecologia 129: 169-178.
%
% Rohlf, F. J. and D. Slice. 1990. Extensions of the Procrustes method for the optimal
% superimposition of landmarks.  Syst. Zool. 39(1): 40-59.


% -----Details:-----
% PERMFLAG = internal flag to prevent calculation of residuals
% during a permutation run, thereby improving efficiency

% -----Author(s):-----
% by Dave Jones,<djones@rsmas.miami.edu> Oct-2002
% http://www.rsmas.miami.edu/personal/djones/
% with help from news://comp.soft-sys.matlab
% ----------------- DISCLAIMER: -------------------
% This code is provided as is, with no guarantees
% and is only intended for non-commercial use.
% --------------------------------------------------

if (nargin < 3), stnd     = 0;    end; % no standardization by default
if (nargin < 4), iter     = 0;    end; % no permutation test by default
if (nargin < 5), plotflag = 0;    end; % no plots by default
if (nargin < 6), permflag = 0;    end; % not a permutation run by default

[n,k]   =  size(X); % n = # rows (observations); k = # columns (variables)
[Yn,Yk] = size(Y);

% -----Check dimensionality:-----
if (n ~= Yn)
	error('# rows (observations) in X & Y are NOT equal!)');
elseif (Yk<k)
	error('Y has fewer columns (variables) than X');
end

if (k<Yk) % pad X with 0's if Y has more variables
	X(n,k) = 0; 
end

% -----Optionally stardardize variables:-----
if (stnd>0)
	X = f_transform(X',7)';
	Y = f_transform(Y',7)';
end;

% Rescale X & Y to a common size & jointly center:
I    = eye(n,n);
P    = ones(n,n)./n;
Xscl = (I-P)*X/(sqrt(trace((I-P)*X*X'*(I-P)))); % (Peres-Neto & Jackson eq. 2, but
Yscl = (I-P)*Y/(sqrt(trace((I-P)*Y*Y'*(I-P)))); % corrected with Rohlf & Slice eq. 2)

% Find optimal rotation matrix:
[U,W,V] = svd(Xscl'*Yscl); % singular value decomposition
S    = sign(W);            % just use signs of W, so no shearing
H    = V*S*U';             % rotation matrix (Rohlf & Slice eq. 6)
%H    = U*V'               % alternate form in Peres-Neto & Jackson
Yrot = Yscl*H;             % rotate scaled Y

% Procrustes statistic:
m2 = 1 - trace(W.*W); % (Legendre & Legendre eq. 10.30)

if (permflag==0) % don't do this during a permutation run
	% -----Residuals:-----
	% Coordinates of each residual vectors:
	% (indicates contribution along each axis)
	resid.dim = abs(Xscl - Yrot);
	
	% Total length of each residual vector:
	% (calculate distance of vector from the origin)
	resid.obs = f_euclid([[0 0]' resid.dim']); % all pairwise distances
	resid.obs = resid.obs(2:end,1); % keep only distance from origin
	
	% Residual sum-of-squares:
	resid.sse = sum(resid.obs .^ 2);
	% alternative formula (from Strauss's lstra.m):
	% resid.sse = trace((Xscl - Yrot)*(Xscl - Yrot)');
end

% -----Permutation Test:-----
if (iter>0)
   fprintf('\nPermuting the data %d times...\n',iter-1);
	% randStat = zeros(iter-1,1); % preallocate results array
	for i=1:(iter-1)
		Yperm = f_shuffle(Y,4); % randomly permute rows (observations) of Y
		[null1,null2,randStat(i)] = f_procrustes(X,Yperm,stnd,0,0,1); % collect randomized stat
	end
	j = find(randStat <= m2);  % get randomized stats <= to observed statistic
	% use <= because smaller m2 indicates BETTER fit
	prob = (length(j)+1)./(iter); % count vales & convert to probability
end

% -----Plot fitted results:-----
if (plotflag>0)
	figure;
	plot(Xscl(:,1),Xscl(:,2),'bo',Yrot(:,1),Yrot(:,2),'r.',[Xscl(:,1) Yrot(:,1)].',[Xscl(:,2) Yrot(:,2)].',':g');
	titleTxt = [['Orthogonal Procrustes Analysis  (m^2 = '] num2str(m2) [')']];
	title(titleTxt);
	xlabel('Dim 1'); ylabel('Dim 2');
	legend('Scaled X','Rotated Y','Residual');
	axis tight;
	axis(1.2*(axis)); % increase bounds of axis
	axis equal;
end



