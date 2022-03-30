function is_in=inside(x,y,xb,yb);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Copyright (c) 1996 Rutgers University                                    %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                           %
%  function is_in=inside(x,y,XB,YB)                                         %
%                                                                           %
%  Given a point (x,y) and the vectors XB and XB representing a series      %
%  of points defining the vertices of a closed polygon,  status is set      %
%  to 1 if the point is inside the polygon and 0 if outside.   A count      %
%  is made of the number of times the boundary cuts  the meridian thru      %
%  (x,y) south of (x,y).   An odd count indicates the point is inside,      %
%  even indicates outside.                                                  %
%                                                                           %
%  Reference:                                                               %
%                                                                           %
%    Reid, C., 1969: A long way from Euclid. Oceanography EMR, page 174.    %
%                                                                           %
%  Routine written by Pat J. Haley (Harvard University).                    %
%                                                                           %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%----------------------------------------------------------------------------
%  Set up the default result.
%----------------------------------------------------------------------------

def_res=0;

%----------------------------------------------------------------------------
%  Determine length of boundary.
%----------------------------------------------------------------------------

nb=max(size(xb));

if (nb <= 0),
  is_in=def_res;
  return;
end;

%----------------------------------------------------------------------------
%  Find intersections.
%----------------------------------------------------------------------------

%  Set up non-trivial segment indices.

k=1:(nb-1);
kp1=2:nb;

if ((xb(1)~=xb(nb)) | (yb(1)~=yb(nb))),
  k=[k nb];
  kp1=[kp1 1];
end;

ind=find(xb(k) == xb(kp1));

if (~isempty(ind)),
  k(ind)=[];
  kp1(ind)=[];
end;

if (isempty(k)),
  is_in=def_res;
  return;
end;

%  Determine east and west indices.

kw=k;

ind=find(xb(k) > xb(kp1));

if (~isempty(ind)),
  kw(ind)=kp1(ind);
end;

ke=k+kp1-kw;

%  Remove non-bracketting segments.

ind=find((xb(ke) <= x) | ((xb(ke) >= x) & (xb(kw) > x)));

if (~isempty(ind)),
  k(ind)=[];
  ke(ind)=[];
  kw(ind)=[];
  kp1(ind)=[];
end;

if (isempty(k)),
  is_in=def_res;
  return;
end;

%  Compute y-coordinate of the intersections.

slope=(yb(ke)-yb(kw))./(xb(ke)-xb(kw));
yc=yb(kw)+(x-xb(kw)).*slope;

%----------------------------------------------------------------------------
%  Count the number of times that the boundary cuts the meridian thru
%  (x,y) south of (x,y).  An odd count indicates the point is inside,
%  even indicates outside.
%----------------------------------------------------------------------------

%  Remove northern intersections.

ind=find(yc >= y);

if (~isempty(ind)),
  yc(ind)=[];
end;

%  Perform count and determine if point is inside.

is_in=rem(length(yc),2);

return
