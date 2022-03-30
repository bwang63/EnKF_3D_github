function [i,j,i_extra,j_extra,index_marker]=closest(X,Y,xi,yi)
%       [I,J,I_EXTRA,J_EXTRA,INDEX_MARKER]=CLOSEST(X,Y,XI,YI)
%	finds I,J indicies of coordinate arrays X and Y that give the 
%	point(s) closest to the input points(s) XI,YI.
%	The point(s) of interest XI,YI may be specified as a pair
%	points, a pair of vectors, or a matrix XY with two columns
%	i.e. [I,J]=CLOSEST(X,Y,XY).  This last option allows the
%	direct output of GINPUT to be used as the input XY,
%	e.g. [I,J]=CLOSEST(X,Y,GINPUT)
%       If there are a number of points that are exactly the same
%       distance from a given input point then I and J will be the
%       coordinates of the first such point.  The full set of indices
%       will be returned in I_EXTRA and J_EXTRA.  In the case where XI
%       and YI are vectors then the vector INDEX_MARKER specifies the
%       correspondence between (I_EXTRA, J_EXTRA) and (XI, YI), namely:
%       (I_EXTRA(k), J_EXTRA(k)) is a closest point to
%       (XI(INDEX_MARKER(k)), YI(INDEX_MARKER(k))).
%
%	John Wilkin, 4 November 93 & Jim Mansbridge 19 march 1996

if nargin == 3
  yi = xi(:,2);
  xi = xi(:,1);
end

len_xi = length(xi);
i = zeros(1, len_xi);
j = i;
i_extra = [];
j_extra = [];
index_marker = [];

for k=1:len_xi
  dist = abs( (xi(k)-X) + sqrt(-1)*(yi(k)-Y));
  [ii,jj] = findm(dist==min(dist(:)));
  i(k) = ii(1);
  j(k) = jj(1);
  i_extra = [i_extra ii'];
  j_extra = [j_extra jj'];
  index_marker = [index_marker k*ones(1,length(ii))];
end
