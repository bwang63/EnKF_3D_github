function [scores,evals,expl] = f_pca(X,plotflag);
% - Principal Component Analysis of a data matrix
% 
% Usage: [scores,evals,expl] = f_pca(X,{plotflag});
%
% -----Input:-----
% X        = data matrix;    (rows = replicates, cols = variables)
% plotflag = plot PCA scores (default = 1)
%
% -----Output:-----
% scores = PC scores
% evals  = eigenvalues as a Percentage
%
% SEE ALSO: f_nmds, f_pcoa

% modified after L. Marcus's princomp.m from 'Applied Factor Analysis'
%
% by Dave Jones <djones@rsmas.miami.edu>, July-2001
% http://www.rsmas.miami.edu/personal/djones/
% ----------------- DISCLAIMER: -------------------
% This code is provided as is, with no guarantees
% and is only intended for non-commercial use.
% --------------------------------------------------

% ------------------- References: ------------------------------------
% Reyment, R. A. & K. G. Joreskog (Appendix by Leslie F. Marcus).
%   1993. Applied Factor Analysis in the Natural Sciences. 2nd Edition.
%   New York: Cambridge University Press. 371 pages.
%   Appendix available from ftp://life.bio.sunysb.edu/morphmet/matlaba.exe
% --------------------------------------------------------------------

if (nargin < 2), plotflag = 1; end; % by default don't create plot

[N,p]=size(X);   % Returns N as a row count; p as a column count.

if (size(X,2) == 1), X(N,2) = 0; end; % add col of 0's if a col vector

j=ones(N,1);       % Defines the n x 1 vector of 1's
XBAR=j'*X/N;       % Computes means
Y=X-j*XBAR;        % Computes deviations from Means
varcov=Y'*Y/(N-1); % Computes variance-covariance matrix

[U,L,U]=svd(varcov); % Singular value decomposition of varcov for eigenvalues L and eigenvectors E
% L=[diag(L) 100*cumsum(diag(L)/sum(diag(L)))]; % Eigenvalues and as percenatages

evals = diag(L);
expl = [100*(diag(L)/sum(diag(L))) 100*cumsum(diag(L)/sum(diag(L)))];
U;          % eigenvectors E
scores=Y*U; % PC scores

if (plotflag>0) 
   figure; % opens new figure window
   plot(scores(:,1),scores(:,2),'bo')  % plots column 1 x 2 of PC Scores
   xlabel('PC-1');
   ylabel('PC-2');
   title('Plot of PC-2 vs. PC-1');
end;
