function inds = mexinside ( x, y, xp, yp )
% MEXINSIDE:  Determines if points (x,y) are contained in polygon.
%
% This is basically the same as the INPOLYGON matlab routine, but that
% routine seems to want to die if the arrays are too large.  So I rolled
% my own.
%
% USAGE:  inds = mexinside ( x, y, xp, yp );
%
% PARAMETERS
%   xp, yp:
%      Defines the verticies of the polygon.
%   x, y:
%      Are these points in the polygon or not?
%   inds:
%      "inds" will be the same size as x and y.  A 1 at a particular
%      index means that that corresponding x and y value is inside the
%      polygon.  I will leave it to you to guess what a 0 means.
%      
