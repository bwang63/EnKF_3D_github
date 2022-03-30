function [index,distance]=gridgen_nearest_pts(x,y,x0,y0,dist);
% NEAREST_PTS:  Finds indices of the arrays x,y, that are closest to a point.
%
% Identical to nearxy except for the fact that this routine will handle the
% case of multiple points occupying the same point in space.  The indices to
% all such points will be returned.
%
% Usage:
%        [index,distance]=nearest_pts(x,y,x0,y0) finds the closest point and
%                                           the distance
%        [index,distance]=nearest_pts(x,y,x0,y0,dist) finds all points closer tan
%                                           the value of dist.
%
% See also NEARXY
%
distance=sqrt((x-x0).^2+(y-y0).^2);
if (nargin > 4),
  index=find(distance<=dist);     %finds points closer than dist
 else
	index=find(distance==min(distance));  % finds closest point
end
distance=distance(index);


