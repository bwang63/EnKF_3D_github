function [c,l,sig]=axcorr(len,a,b,bias)
% AXCORR   Auto- and cross-correlation estimates for specified lag ranges.
%          [C,L]=AXCORR(LAG,A) computes the autocorrelation of sequence A
%          at lags -LAG:LAG, returning a vector of lags L with corresponding
%          correlations C. [C,L]=AXCORR(LAG,A,B) computes the cross-correlation
%          between sequences A and B, where positive lag implies A leading.
%          A and B should be of the same length.
%
%          After removal of means, a biased estimate of the correlation is
%          formed, normalized by the standard deviations of the sequences.
%          AXCORR(...,'unbiased') returns an unbiased estimate. (This
%          is sometimes helpful).
%
%          [C,L,SIG]=AXCORR(..) returns the 95% significance level. This
%          estimate depends on a correct estimation of the degrees of
%          freedom (roughly the number of independent samples). The
%          d.o.f. are estimated as
%
%                              d.o.f. = N / L2 
%
%          where N is the number of elements in A and B, and the two-sided
%          correlation length L2 is estimated (sort of) using the power
%          underneath the curve. This estimate will work best when 
%          you set LAG is large enough to include all correlated 
%          lags, but small enough to exclude most of the 
%          uncorrelated ones.
%

% Notes: RP (WHOI) 1/Dec/91 
%            - I don't know why Matlab doesn't have one of these...


% Remove the sequence means
a=(a(:)-mean(a));
if (nargin < 3),
   b=a;
   bias=1;
else
   if (isstr(b)),
      if (b=='unbiased'), bias=0; else bias=1; end;
      b=a;
   else
      b=(b(:)-mean(b));
      if (nargin==4),
         if (bias=='unbiased'), bias=0; else bias=1; end;
      else
         bias=1;
      end;
   end;
end;

N=max(size(a));
if (N ~= max(size(b)) ), error('Both vectors must have the same length!');end;


% Compute running sums
% Lagged sums are divided by N-1 rather than N-lag ... this reduces the
% mean square error at the cost of some bias in the tails

for i=-len:0,
   ind=i+len+1;
   c(ind)=a(-i+1:N).'*conj(b(1:N+i));
end;
for i=1:len,
   ind=i+len+1;
   c(ind)=a(1:N-i).'*conj(b(i+1:N));
end;

% normalize (divide by N-1 for compatability with std calculation).
l=[-len:len];
if (bias),
   c=c/((N-1)*std(a)*std(b));
else
  c=c./([N-1-abs(l)]*std(a)*std(b));
end;


% Compute significance level

alpha=0.05;     % 95% confidence interval

% Now estimate the correlation scale by getting the power under the 
% the curve, and estimating the L2 as the width of an equivalent rectangular
% peak. If this blows up because things don't seem
% to be correlated, forget it!

L2 = sqrt(sum (abs(c).^2));
if (L2<1), L2=1; end;

dof= N / L2;
disp(['Estimated degrees of freedom = ' num2str(dof) ' (N = ' int2str(N) ')']);

% Now we have the right dof, we need to estimate error limits about our
% sample estimate of the correlation coefficient r. Since
% the correlation coefficients are bounded (between [-1,1]) the actual PDF
% is very ugly, and depends on the true correlation coefficient.
%
% Happily, FISHER found that
%
%                z =  1/2 * ln | (1+r)/(1-r) |
%
%                       -1
%           ( or z = tanh  (r)     )
%
% is approximately normally distributed with variance  1/(dof-3), even
% when dof is very small. So we can easily compute error bars about any
% point, in particular the error bars if r=0 are +/-sig:

sig=tanh( sqrt(2)*erfinv(1-alpha) / sqrt(max(2,dof-3))  );

disp(['Estimated significance level = ' num2str(sig) ]);

% (note that normal percentile for p are at +/- sqrt(2)*inverf(p), contrary
% to what you might expect inverf to do!).
