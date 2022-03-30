function invX = f_inv(X)
% - matrix inversion via "\" (left division)
%
% USAGE: invX = f_inv(X)
%
% X    = input matrix, preferably a square symmetric matrix
% invX = generalized inverse of matrix X
%
% See also: inv, pinv, qr, slash, \, mldivide

invX = X\eye(size(X));

% by Dave Jones<djones@rsmas.miami.edu>, Oct-2002
% http://www.rsmas.miami.edu/personal/djones/
% ----------------- DISCLAIMER: -------------------
% This code is provided as is, with no guarantees
% and is only intended for non-commercial use.
% --------------------------------------------------

% -----References:-----
% See Matlab online documentation for "\"
