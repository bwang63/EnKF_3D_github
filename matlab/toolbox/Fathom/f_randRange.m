function res = f_randRange(minval,maxval,n);
% - returns n random integers ranging from min to max
%
% USAGE: res = f_randRange(min,max,n);
%
% -----Input/Output:-----
% min, max = integers specifying range of random #'s
% n        = number of random #'s to return
% res      = column vector of random integers
%
% SEE ALSO: f_shuffle

% by Dave Jones,<djones@rsmas.miami.edu> Mar-2002
% http://www.rsmas.miami.edu/personal/djones/
% ----------------- DISCLAIMER: -------------------
% This code is provided as is, with no guarantees
% and is only intended for non-commercial use.
% --------------------------------------------------

% -----Credits:----
% modified after randRange by Ione Fine<ifine@psy.ucsd.edu>, 7/2000 
% http://www-psy.ucsd.edu/~ifine

if (nargin < 3), error('Not enough input parameters');  end;
if (nargin < 4), kind = 1; end; % Use Uniform distribution by default

if (minval>maxval), error('MIN is greater than MAX !'); end;

vec = rand(n,1); % column vector of random #'s

% convert range minval:maxval
vec = ceil((1+maxval-minval)*vec); 
vec(find(vec+1==1)) = 1; % make any zeros into ones 
res = vec+minval-1; 
