function status=pinside(x,y,XB,YB)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Copyright (c) 1996 Rutgers University                                    %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                           %
%  function status=pinside(x,y,XB,YB)                                       %
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
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%  Return if empty vector.

if (isempty(XB) | isempty(YB)),
  status=1;
  return
end

%  Determine number of points.

nb=length(XB);

%  Find intersections.

nc=0;
for k=1:nb 
  kp1=k+1-k*fix(k/nb);
  kw=k;
  if (XB(k) ~= XB(kp1)),
    if (XB(k) > XB(kp1)), kw=kp1; end
    ke=k+kp1-kw;
    if (x <= XB(ke)),
      if (x < XB(ke) & x <= XB(kw)),
        break,
      else
        nc=nc+1;
        slope=(YB(ke)-YB(kw))/(XB(ke)-XB(kw));
        yc(nc)=YB(kw)+(x-XB(kw))*slope;
      end,
    end,
  end,
end

%  Count the number of times that the boundary cuts the meridian thru
%  (x,y) south of (x,y).  An odd count indicates the point is inside,
%  even indicates outside.

status=0;
if (nc > 0),
  ind=find(yc < y);
  if (rem(length(ind),2) > 0), status=1; end,
end,
return
