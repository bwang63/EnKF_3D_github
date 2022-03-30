function [mag,dir] = f_vecMagDir(u,v);
% - get magnitude & direction from u,v vector components
%
% Usage: [mag,dir] = f_vecMagDir(u,v);
%
% u,v = column vectors of Cartesian coordinates of heads
%       of vector components
%
% mag = length of vector
% dir = angle of rotation (in degrees between 0-360)
%
% See also: f_vecAngle, f_vecTrans, f_vecUV

% ----- Notes: -----
% This function is used to obtain Polar coordinates (magnitude
% & direction) of a vector given its Cartesian coordinates (U & V
% vector components). The direction is the counter-clockwise angle
% of rotation.

% ----- Details: -----
% The programs uses the Matlab function ATAN2 which relies on the
% sign of both input arguments to determine the quadrant of the result.

% ----- Author(s): -----
% by Dave Jones,<djones@rsmas.miami.edu> Sept-2001
% http://www.rsmas.miami.edu/personal/djones/
% ----------------- DISCLAIMER: -------------------
% This code is provided as is, with no guarantees
% and is only intended for non-commercial use.
% --------------------------------------------------

% Nov-2002: tune up, check input, added notes, vectorized code

% -----Check input:-----
u = u(:); % make sure they're column vectors
v = v(:);

if (size(u,1) ~= size(v,1))
	error('U and V must be of same size!');
end
% ----------------------

mag = sqrt(u.^2 + v.^2);
dir = (atan2(v,u)) .* 180/pi;
dir(find(dir>360)) = dir(find(dir>360)) - 360;
dir(find(dir<0))   = dir(find(dir<0)) + 360;

% return column vectors
mag = mag(:);
dir = dir(:);
