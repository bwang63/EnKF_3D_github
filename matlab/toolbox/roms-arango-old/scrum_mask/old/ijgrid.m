function [I,J]=ijgrid(xp,yp,xgrd,ygrd)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Copyright (c) 1996 Rutgers University                                    %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                           %
%  function [I,J]=ijgrid(xp,yp,xgrd,ygrd)                                   %
%                                                                           %
%  This function finds the (I,J) cell containing the point (xp,yp).         %
%                                                                           %
%  On Input:                                                                %
%                                                                           %
%    xp         X-location of point to search.                              %
%    yp         Y-location of point to search.                              %
%    xgrd       X-locations of grid (real matrix).                          %
%    ygrd       Y-locations of grid (real matrix).                          %
%                                                                           %
%  On Output:                                                               %
%                                                                           %
%    I          lower left I-location of grid cell containing (xp,yp).      %
%    J          lower left J-location of grid cell containing (xp,yp).      %
%                                                                           %
%  Calls:  prange                                                           %
%                                                                           %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%  Initialize IJ-cell.

I=0;
J=0;

%  Find number of grid points:

[jm,im]=size(xgrd);

%  First, check if (xp,yp) is inside of the poligon defined by the boundaries
%  of (xgrd,ygrd).

imin=1;
imax=im;
jmin=1;
jmax=jm;
found=prange(imin,imax,jmin,jmax,xp,yp,xgrd,ygrd);

%----------------------------------------------------------------------------
%  If found inside grid polygon, subdivide polygon to accelerate the
%  search.  Exit semi-infinity loop when found IJ-cell containing (xp,yp).
%----------------------------------------------------------------------------

if (found == 1),
  np=im*jm;
  n=0;
  loop=0;
  while ((n < np) & (loop == 0)),
    n=n+1;
    if ((imax-imin) > 1),
      itry=fix((imax+imin)/2);
      found=prange(imin,itry,jmin,jmax,xp,yp,xgrd,ygrd);
      if (found == 1),
        imax=itry;
      else
        imin=itry;
      end,
    end,
    if ((jmax-jmin) > 1),
      jtry=fix((jmax+jmin)/2);
      found=prange(imin,imax,jmin,jtry,xp,yp,xgrd,ygrd);
      if (found == 1),
        jmax=jtry;
      else
        jmin=jtry;
      end,
    end,
    if (((imax-imin) == 1) & ((jmax-jmin) == 1)),
      I=imin;
      J=jmax;
      loop=1;
    end,
  end,
end,

%----------------------------------------------------------------------------
%  If inside domain, select closest index to point (xp,yp).
%----------------------------------------------------------------------------

if (I ~= 0 & J ~= 0),
  Ip=min([im I+1]);
  Jp=min([jm J+1]);
  ibox=[I; Ip; Ip; I];
  jbox=[J; J; Jp; Jp];
  xbox=[xgrd(J,I); xgrd(J,Ip); xgrd(Jp,Ip); xgrd(Jp,I)];
  ybox=[ygrd(J,I); ygrd(J,Ip); ygrd(Jp,Ip); ygrd(Jp,I)];
  d=sqrt((xbox-xp).*(xbox-xp) + (ybox-yp).*(ybox-yp));
  dmin=min(min(d));
  index=find(d == dmin);
  I=min(ibox(index));
  J=min(jbox(index));
end,

%----------------------------------------------------------------------------
%  If outside domain, select closest index to point (xp,yp).
%----------------------------------------------------------------------------

if ((I == 0) & (J == 0)),
  inorth=find(ygrd(jm,:) <= yp);
  isouth=find(ygrd( 1,:) >= yp);

%  Southern edge.
  
  if (isempty(inorth) & ~isempty(isouth)),

    J=1;
    is=find(xgrd(J,:) <= xp);
    if (~isempty(is)),
      I=max(is);
    else
      I=1;
    end,

%  Northern edge.
 
  elseif (~isempty(inorth) & isempty(isouth)),

    J=jm;
    in=find(xgrd(J,:) <= xp);
    if (~isempty(in)),
      I=max(in);
    else
      I=1;
    end,

  else

    jwest=find(xgrd(:, 1) >= xp);
    jeast=find(xgrd(:,im) <= xp);

%  Western edge.

    if (isempty(jeast) & ~isempty(jwest)),

      I=1;
      jw=find(ygrd(:,I) <= yp);
      if (~isempty(jw)),
        J=max(jw);
      end,


%  Eastern edge.

    elseif (~isempty(jeast) & isempty(jwest)),

      I=im;
      je=find(ygrd(:,I) <= yp);
      if (~isempty(je)),
        J=max(je);
      end,
    end,
  end,
end,

return
