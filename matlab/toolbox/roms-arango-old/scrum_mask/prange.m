function found=prange(imin,imax,jmin,jmax,xp,yp,xgrd,ygrd);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Copyright (c) 1996 Rutgers University                                    %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                           %
%  function found=prange(imin,imax,jmin,jmax,xp,yp,xgrd,ygrd)               %
%                                                                           %
%  This function finds if the point (xp,yp) is inside the box defined       %
%  by the corners (imin,jmin) and (imax,jmax).                              %
%                                                                           %
%  On Input:                                                                %
%                                                                           %
%     imin      I-index of search box lower-left corner.                    %
%     imax      I-index of search box upper-right corner.                   %
%     jmin      J-index of search box lower-left corner.                    %
%     jmax      J-index of search box upper-right corner.                   %
%     xp        X-coordinate of point to search.                            %
%     yp        Y-coordinate of point to search.                            %
%     xfld      grided X-positions of field to search.                      %
%     yfld      grided Y-positions of field to search.                      %
%                                                                           %
%  On Output:                                                               %
%                                                                           %
%     found     Logical switch indicating if point (xp,yp) is inside        %
%                or outside of search polygon.                              %
%                                                                           %
%  Calls:                                                                   %
%                                                                           %
%    pinside                                                                %
%                                                                           %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%  Define closed polygon.

xs=xgrd(jmin,imin:imax-1);
ys=ygrd(jmin,imin:imax-1);

xe=xgrd(jmin:jmax-1,imax);
ye=ygrd(jmin:jmax-1,imax);

xn=xgrd(jmax,imax:-1:imin+1);
yn=ygrd(jmax,imax:-1:imin+1);

xw=xgrd(jmax:-1:jmin,imin);
yw=ygrd(jmax:-1:jmin,imin);

x=[xs'; xe; xn'; xw];
y=[ys'; ye; yn'; yw];

%  Check if point (xp,yp) is inside (found=1) of defined polygon.

found=inside(xp,yp,x,y);

return

