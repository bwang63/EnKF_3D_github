function [evects,evals,expl] = f_pcoa(dist,fixNeg,plotflag,tuner);
% - Principal Coordinates Analysis with correction for negative eigenvalues
%
% Eigenvector coefficients represent coordinates of objects.
%
% [evects,evals,expl] = f_pcoa(dist,{fixNeg},{plotflag},{tuner});
%
% ----------------------INPUT:-----------------------------------
% dist      = [n x n] square symmetric distance matrix.
% fixNeg    = correct for negative eigenvalues (default = 1)
% plotflag  = plot results (default = 1)
% tuner     = increase if obtain imaginary eigenvectors (default = 0)
%
% ----------------------OUTPUT:-----------------------------------------
% evects    = [n x k] matrix of eigenvectors (columns), individually
%             normalized to sum of squares = eigenvalue
%
% evals     = [k x 1] vector of k eigenvalues.
% expl      = [k x 2] matrix of percent (1) & cumulative (2) variance explained
%
% SEE ALSO: f_nmds, f_pca

% Krzanowski and Marriott (1994), pp. 108-109.
% RE Strauss, 6/3/95
% originally "pcoa.m" from Richard E.Strauss's Statistical Toolbox:
% http://www.biol.ttu.edu/Faculty/FacPages/Strauss/Matlab/matlab.htm

% modified by Dave Jones<djones@rsmas.miami.edu>, April-2001
% http://www.rsmas.miami.edu/personal/djones/
% to correct for negative eigenvalues, determine % variance explained,
% calculate intrinsic dimensionality, and make plots.
%
% ----------------- DISCLAIMER: -------------------
% This code is provided as is, with no guarantees
% and is only intended for non-commercial use.
% --------------------------------------------------

% -----References:-----
% Legendre, P. & L. Legendre. 1998. Numerical ecology. 2nd English ed.
%   Elsevier Science BV, Amsterdam.

% 16-Apr-02: put abs() back into calculation of % variance explained [DJ]
% 18-Apr-02: commented out fprintf messages to dispaly

if (nargin < 2) fixNeg   = 1; end; % fix negative eigenvalues when present
if (nargin < 3) plotflag = 1; end; % plot results by default
if (nargin < 4) tuner    = 0; end; % make larger (e.g., 0.000001) if still get negative eigenvalues

% -----Check input:----- %DJ
if (f_issymdis(dist) == 0)
   error('Input DIST must be square symmetric distance matrix');
end;

n = size(dist,1);

for nloop = 1:2             % do this a maximum of 2 times
   
   gamma = zeros(n);        % Form gamma matrix (called alpha matrix in L&L,1998 eq. 9.20)
   for i=1:(n-1)
      for j=(i+1):n
         gamma(i,j) = -0.5 * dist(i,j)^2;
         gamma(j,i) = gamma(i,j);
      end;
   end;
   
   mean_col = mean(gamma);             % Convert to phi matrix (L&L,1998 eq. 9.21)
   mean_gamma = mean(mean_col);
   phi = gamma;
   for i=1:n
      mean_row = mean(gamma(i,:));
      for j=1:n
         phi(i,j) = gamma(i,j) - mean_row - mean_col(j) + mean_gamma;
      end;
   end;
   
   [evects,evals] = eigen(phi);         % Eigenanalysis
   
   k = size(evals,1);                   % Number of eigenvalues
   
   %------------------------------------------------------
   % force last 2 negative eigenvalues to 0 after Lingoes
   % correction, or else they will be a VERY small negative values:
   % Legendre & Legendre, 1998 p. 434 -> after correction should have
   % 2 null eignevalues
   if (nloop==2)
      evals(k,1)   = 0;
      evals(k-1,1) = 0;
   end;
   %-------------------------------------------------------
   
   for i=1:k % Normalize eigenvectors
      f = evals(i)/sum(evects(:,i).^2);
      evects(:,i) = sqrt((evects(:,i).^2).*f).*sign(evects(:,i));
   end;  
   
   % var=abs(evals)/sum(abs(evals))*100; <- Strauss used absolute value
   % here before correction for negative eigenvalues added by DJ
   
   varExplained  = abs(evals)/sum(abs(evals))*100; % Percent Variance Explained
   cvarExplained = cumsum(varExplained);           % Cumulative Percent Explained
   expl          = [varExplained cvarExplained];   % combine into 1 matrix
   
   % ----- Lingoes Method for Negative Eigenvalue Correction: -----
   % ----- see Legendre & Legendre, 1998 p.434 equation 9.25 ------
   
   negEvals   = evals(find(evals<0)); % negative eigenvalues
   noNegEvals = size(negEvals,1);     % number of negative eigenvalues
   minNegEval = min(negEvals);        % "largest" negative eigenvalue
   
   if (noNegEvals>0) & (nloop==1) & (fixNeg>0)
      fprintf('Correcting for %d negative eigenvalues...\n', noNegEvals);
      dist2 = sqrt((dist.^2) + (2*abs(minNegEval+tuner))); % Lingoes correction
      dist2 = dist2.*(1-eye(size(dist2))); % make diagonals = 0
      dist = dist2;                        % use this in 2nd PCoA
   else
      if (noNegEvals>0)
         % fprintf('Warning: %d negative eigenvalues present \n', noNegEvals);
         % fprintf('Interpret solution with CAUTION! \n');
      end;
      break; % exit "For Loop" if no neg eigens, corrected them, or fixNeg is false
   end;
end;


if (nloop==2)
   noEvects = size(evects,2); % # eigenvectors
   noEvals  = size(evals,1);  % # eigenvalues
   evects   = evects(:,1:noEvects-2); % strip off last 2 null eigenvectors after Lingoes correction
   evals    = evals(1:noEvals-2);     % strip off last 2 null eigenvalues after Lingoes correction
end

% ----- Determine "Intrinsic Dimensionality": -----
% after Hany Farid's reducedim.m from:
% http://www.cs.dartmouth.edu/~farid/research/reducedim.html
ratio	= expl(:,1)/ sum(expl(:,1));
ind	= find(ratio>0.06);
dim	= length(ind);
% fprintf('Intrinsic Dimensionality = %d \n\n', dim);
% ----------------------------------------------

if (plotflag==1)        % make plots if true
   
   dist = f_unwrap(dist); % pull out as a vector, without diagonal
   
   % ----- Plot PCoA: -----
   figure;
   plot(evects(:,1),evects(:,2),'b.');
   axis([1.2*min(evects(:,1)) 1.2*max(evects(:,1)) 1.2*min(evects(:,2)) 1.2*max(evects(:,2))]);
   axis equal;
   title('Principal Coordinates Analysis');
   xlabel('Axis 1'); ylabel('Axis 2');
   labels = num2cell([1:n]); % create a cell array of object labels
   text(evects(:,1)-0.05,evects(:,2)-0.025,labels); % label the points
   
   % ----- Shepard Plot of 2-d configuration: -----
   figure;
   % euclidean distance matrix 1st 2 eigenvectors as a vector:
   edist = f_unwrap(f_euclid(real(evects(:,[1:2])'))); % discard imaginary portions
   plot(dist, edist, 'bo');
   Rs = f_corr(dist,edist)^2;
   titleVar = ['2-d Shepard Diagram (R^2 = ' num2str(Rs) ')'];
   title(titleVar);
   xlabelVar = ['Original Dissimilarites (' num2str(n) ' objects)'];
   xlabel(xlabelVar);
   ylabelVar = ['Fitted Distances (1st 2 eigenvectors)'];
   ylabel(ylabelVar);
   grid on;
   
   % ----- Scree Plot of residual variance: -----
   figure;
   stem(100-expl(:,2),'-r.');hold on; % plot residual variance
   plot(100-expl(:,2),'-b');hold off;% plot residual variance
   axis([0 (size(expl,1)) 0 1.08*max(100-expl(:,2))]);
   title('Scree Plot: Variance Explained vs. Dimensionality');
   xlabel('# Dimensions'); ylabel('Residual Variance (%)');
   
   % ----- Another way to examine Dimensionality: -----
   figure;
   for i=1:n-2
      edist = f_unwrap(f_euclid(real(evects(:,[1:i])'))); % add 1 eigenvector each loop
      Rs(i) = f_corr(dist,edist)^2;
   end;
   plot(Rs,'-k.');hold on;
   plot(Rs,'bo');hold off;
   titleVar = ['Intrinsic Dimensionality = ' num2str(dim)];
   title(titleVar);
   xlabel('# Dimensions (Eigenvectors)'); ylabel('Distance-Dissimilarity correlation (R^2)');
end;
