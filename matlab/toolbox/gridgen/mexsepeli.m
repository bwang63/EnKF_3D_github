function [x, y, perturb, ierror] = mexsepeli ( x, y, l2, m2, seta, sxi )
% MEXSEPELI:  solves differential equation for grid generation.
%
% "Mexsepeli" solves for the 2nd order finite difference approximation
% to the separable elliptic equation arising from conformal mapping and
% grid generation.  Whew.
%
% USAGE:  
% [x,y] = mexsepeli(x,y,l2,m2,seta,sxi);
% or
% [x,y,perturb,ierror] = mexsepeli(x,y,l2,m2,seta,sxi);
%
% OUTPUT PARAMETERS:
%   x, y:
%      x and y coordinates of solution grid.  It is the ENTIRE Arakawa
%      staggered grid.
%   perturb (not yet implemented): 
%   ierror (not yet implemented):
%
% INPUT PARAMETERS:
%   x, y:
%      Same size as x and y output parameters, but only filled in on
%      the border.
%   l2, m2:
%      In the fortran code, the x and y grids are zero-based, ranging
%      from [0...L2, 0...M2].  Since the matlab codes are 1-based, 
%      "l2" and "m2" will both be one less than their dimension lengths
%      going into the fortran code.  Just accept it, Chester.
%   seta, sxi:
%      digitized points on boundaries 1 and 3, 2 and 4 respectively.
%      These will always be between 0 and 1.  Actually, I don't even
%      think we need to include these.  The fortran code doesn't seem
%      to really require it, but I get an error that I can't track
%      down when I don't include it.  Oh well.
% 
