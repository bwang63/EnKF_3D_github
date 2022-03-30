function [t,p,pairList,corrMC] = f_npManovaPW(yDis,x,iter,verb)
% - a posteriori, multiple-comparison tests
%
% USAGE: [t,p,pairList,corrMC] = f_npManovaPW(yDis,x,iter,verb);
%
% yDis = square symmetric distance matrix derived from response variables
% x    = matrix of integers specifying factor levels for objects
%        in yDis (column-wise)
% iter = # iterations for permutation test  (default = 0)
% verb = optionally send results to display (default = 1)
%
% t        = t-statistic
% p        = permutation-based significance
% pairList = list of the pair-wise treatment level tests
% corrMC   = corrections for multiple-comparison tests 
%           (at alpha = 0.05) via Dunn-Sidak & Bonferonni Methods
%
% See also: f_npManova, f_anosim, f_anosim2

% -----Notes:-----
% This function is used to perform _a posteriori_, multiple-comparison
% (pair-wise) tests after finding a significant factor effect
% using F_NPMANOVA. This essentially involves performing a number of 
% a single classification (M)ANOVAs using all possible pairs of
% treatment levels from the ANOVA factor specified. The t-statistic
% returned is simply the square-root of the usual F-statistic.
%
% Remember you can make additional, unplanned comparisons as well by
% recoding the treatment levels. For example, you found a significant
% treatment effect which had 4 levels (level 1 was the control). You can
% recode the levels via 'x(find(x>1)) = 2' and simply test the control
% vs. the non-control's, etc.
%
% Two methods of correction for multiple comparisons are provided. These
% are highly conservative, especially considering that at alpha = 0.05
% only 1 out of 20 tests will be found to be significant by random chance
% (Anderson, 2000).

% ----- References:-----
% Anderson, M. J. 2000. NPMANOVA: a FORTRAN computer program for non-parametric
% multivariate analysis of variance (for any two-factor ANOVA design) using
% permutation tests. Dept. of Statistics, University of Auckland.
% (http://www.stat.auckland.ac.nz/PEOPLE/marti/)
%
% Sokal, R. R. and F. J. Rohlf. 1995. Biometry - The principles and 
% practice of statistics in bioligical research. 3rd ed. W. H. 
% Freeman, New York. xix + 887 pp.

% by Dave Jones,<djones@rsmas.miami.edu> Nov-2002
% http://www.rsmas.miami.edu/personal/djones/
% ----------------- DISCLAIMER: -------------------
% This code is provided as is, with no guarantees
% and is only intended for non-commercial use.
% --------------------------------------------------


if (nargin < 3), iter  = 0; end; % default iterations for permutation test
if (nargin < 4), verb  = 0; end; % don't send output to display by default

% extract all pair-wise subsets:
[sDis,sX,pairList] = f_subsetDisPW(yDis,x);

% get # of pairwise tests:
noTests = size(pairList,1);

% 1-way ANOVA for each pair of treatment levels:
for i=1:noTests
	temp = f_npManova(sDis{i},sX{i},0,0,iter,verb);
	t(i) = sqrt(temp(1).F); % since temp(2:3).F = NaN's  [t is sqrt of F]
	p(i) = temp(1).p;       % since temp(2:3).p = NaN's
end

t = t';
p = p';

% Corrections for multiple-comparison tests: (Sokal & Rohlf, 1995:239-240)
a = 0.05; % alpha
corrMC(1) = 1 - (1 - a)^(1/noTests); % Dunn-Sidak Method
corrMC(2) = a/noTests;               % Bonferroni Method

% Uncomment this for default output to display:
% fprintf('\nMultiple-Comparison corrections for alpha  = 0.05: \n');
% fprintf('   Dunn-Sidak Method =  %6.4f \n', corrMC(1));
% fprintf('   Bonferroni Method =  %6.4f \n\n', corrMC(2));

