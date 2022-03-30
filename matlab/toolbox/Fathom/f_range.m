function minMax = f_range(x);
% - return the min and max values of a vector
%
% USAGE: minMax = f_range(x);

% -----Author(s):-----
% by Dave Jones,<djones@rsmas.miami.edu> Dec-2002
% http://www.rsmas.miami.edu/personal/djones/
% with help from news://comp.soft-sys.matlab
% ----------------- DISCLAIMER: -------------------
% This code is provided as is, with no guarantees
% and is only intended for non-commercial use.
% --------------------------------------------------

[nr,nc] = size(x);

if (nr ~= 1) & (nc ~= 1)
	error('X must be a row or column vector');
end

x = x(:);
minMax = [min(x) max(x)];

