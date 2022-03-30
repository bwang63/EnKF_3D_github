function res = f_isssymdis(x);
% - determine if input is square symmetric distance matrix
%
% USAGE res = f_isssymdis(x)
% res = 1 if true, 0 if false;

% by Dave Jones <djones@rsmas.miami.edu>, Mar-2002
% http://www.rsmas.miami.edu/personal/djones/
% ----------------- DISCLAIMER: -------------------
% This code is provided as is, with no guarantees
% and is only intended for non-commercial use.
% --------------------------------------------------

% # rows and cols must be equal
% must have all 0's along diagonal
% must have >= 2 rows/columns

[noRow,noCol] = size(x);

if (noRow == noCol) & (sum(diag(x)) == 0) & (noRow>1)
   res = 1;
else
   res = 0;
end;
