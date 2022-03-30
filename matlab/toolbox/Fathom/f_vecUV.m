function [u,v] = f_vecUV(mag,dir);
% - returns U,V components of a vector given its magnitude & direction
%
% Usage: [u,v] = f_vecUV(mag,dir);
%
% mag = column vector specifying magnitude of vectors (in arbitrary units)
% dir = column vector indicating angle of rotation (in degrees from 0-360)
%
% u,v = Cartesian coordinates of heads of vector components
%
% See also: f_vecAngle, f_vecMagDir, f_vecTrans

% by Dave Jones,<djones@rsmas.miami.edu> Sept-2001
% http://www.rsmas.miami.edu/personal/djones/
% ----------------- DISCLAIMER: -------------------
% This code is provided as is, with no guarantees
% and is only intended for non-commercial use.
% --------------------------------------------------

% ----- Notes: -----
% This function is used to obtain Cartesian coordinates (the U,V vector
% components) of a vector given its Polar coordinates (magnitude & direction).

% Nov-2002: tune-up, check input, added notes

% -----Check input:-----
mag = mag(:); % make sure they're column vectors
dir = dir(:);

if (size(mag,1) ~= size(dir,1))
	error('MAG and DIR must be of same size!');
end

if (min(dir)<0) | (max(dir>360))
	error('DIR must range from 0-360 degrees');
end
% ----------------------

u = mag .* cos(dir * pi/180); 
v = mag .* sin(dir * pi/180);

