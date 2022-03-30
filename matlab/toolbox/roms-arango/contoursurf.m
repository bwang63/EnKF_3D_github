function CS=contoursurf(arg1,arg2,arg3,arg4);
%  CONTOURSURF contouring over non-rectangular surface.
%        This is an extension of contourc.
%        CONTOURSURF calculates the contour matrix C for use by EXTCONTOUR
%        to draw the actual contour plot.
%        C = CONTOURSURF(Z) computes the contour matrix for a contour plot
%        of matrix Z treating the values in Z as heights above a plane.
%        C = CONTOURSURF(X,Y,Z), where X and Y are vectors, specifies the X- 
%        and Y-axes for the contour computation. X and Y can also be matrices of 
%        the same size as Z, in which case they specify a surface in an 
%        identical manner as SURFACE.
%        CONTOURSURF(Z,N) and CONTOURSURF(X,Y,Z,N) compute N contour lines, 
%        overriding the default automatic value.
%        CONTOURSURF(Z,V) and CONTOURSURF(X,Y,Z,V) compute LENGTH(V) contour 
%        lines at the values specified in vector V.
%  
%        The contour matrix C is a two row matrix of contour lines. Each
%        contiguous drawing segment contains the value of the contour, 
%        the number of (x,y) drawing pairs, and the pairs themselves.  
%        The segments are appended end-to-end as
%  
%            C = [level1 x1 x2 x3 ... level2 x2 x2 x3 ...;
%                 pairs1 y1 y2 y3 ... pairs2 y2 y2 y3 ...]
%  
%        See also EXTCONTOUR.

% Author: R. Pawlowicz (IOS) rich@ios.bc.ca
%         12/12/94


 
if (nargin <=2 ),
 numarg_for_call='arg1';
 for ii=2:nargin,
  numarg_for_call=[numarg_for_call ',arg' int2str(ii)];
 end;
 zz=arg1;
else
 numarg_for_call='arg3';
 for ii=4:nargin,
  numarg_for_call=[numarg_for_call ',arg' int2str(ii)];
 end;
 zz=arg3;
end; 

eval(['CS=contourc(' numarg_for_call ');']);
[Ny,Nx]=size(zz);
 
% Find data values and check curve orientation.
 
ii=ones(1,size(CS,2));
k=1;
while (k < size(CS,2)),
  nl=CS(2,k);
  
  % Now this is a little bit of magic needed to make the filled contours
  % work. Essentially I draw the *closed* contours so that the "high" side is
  % always on the right. To test this, I take the cross product of the
  % first vector with a vector to a corner point and test the sign
  % against the elevation change. There are several special cases:
  % (1) If the contour line goes through a point (which happen when -Infs
  % are around), and (2) when the contour level equals the level on the high
  % side (this always seems to happen in 'simple test' cases!). We take
  % care of (1) by choosing other points, and we take care of (2) by adding
  % eps to the data before comparing with the contour data.
  
  if ( CS(:,k+1)==CS(:,k+nl) & nl>1 ),
    lev=CS(1,k);
    x1=CS(1,k+1); y1=CS(2,k+1);
    x2=CS(1,k+2); y2=CS(2,k+2);
    vx1=x2-x1; vy1=y2-y1;
    cpx=round(x1); cpy=round(y1);
    if ( [cpx cpy]==[x1 y1] ),
      cpx=round(x2); cpy=round(y2);
      if ( [cpx cpy]==[x2 y2]),
         if ( ~([cpx cpy]==round([x1 y1])) ),
           cpx=round(x1);
         else
           cpx=round(x1)+y2-y1;
           cpy=round(y1)-x2+x1;
         end;
       end;
    end;
    vx2=cpx-x1; vy2=cpy-y1;
%    if (sign(zz(cpy,cpx)-lev+epslev)==0) disp('lev=0'); end;
%    if (sign(vx1*vy2-vx2*vy1)==0) disp('cross=0'); end;
    if ( sign(zz(cpy,cpx)-lev+eps) == sign(vx1*vy2-vx2*vy1)  ),
      CS(:,k+[1:nl])=fliplr(CS(:,k+[1:nl]));
    end; 
  end;
  ii(k)=0;
  k=k+1+nl;
end;

% Data from integer coords to data coords. There are 3 cases
% (1) Matrix X/Y
% (2) Vector X/Y
% (3) no X/Y. (do nothing);

if (nargin>2 & min(size(arg1))>1 ),
 
 X=CS(1,ii)';   Y=CS(2,ii)';
 cX=ceil(X);    fX=floor(X);
 cY=ceil(Y);    fY=floor(Y);
 
 Ibl=cY+(fX-1)*Ny;    Itl=fY+(fX-1)*Ny;
 Itr=fY+(cX-1)*Ny;    Ibr=cY+(cX-1)*Ny;
 
 dy=cY-Y; dx=X-fX;
 
 % Correct for possible conflicts in matlabs [1 1 1 ] indexing. This
 % probably will *never* happen in real life, but turns up annoyingly
 % often in "simple" test cases.
 if (Nx*Ny == length(Ibl) ),
   Ibl=[1;Ibl];   Itl=[1;Itl];
   Itr=[1;Itr];   Ibr=[1;Ibr];
   dx=[0;dx];     dy=[0;dy];
   Csave=CS(:,1); 
   ii(1)=1;  
 end;
 
 CS(1,(ii)) = [ arg1(Ibl).*(1-dx).*(1-dy) + arg1(Itl).*(1-dx).*dy ...
             + arg1(Itr).*dx.*dy         + arg1(Ibr).*dx.*(1-dy)]';
 CS(2,(ii)) = [ arg2(Ibl).*(1-dx).*(1-dy) + arg2(Itl).*(1-dx).*dy ...
             + arg2(Itr).*dx.*dy         + arg2(Ibr).*dx.*(1-dy) ]';

 if (exist('Csave')),
  CS(:,1)=Csave;
 end;
 
elseif (nargin>2 & min(size(arg1))==1 ),
 X=CS(1,ii);  Y=CS(2,ii);
 cX=ceil(X); fX=floor(X);
 cY=ceil(Y); fY=floor(Y);

 dy=cY-Y;    dx=X-fX;

 if (size(arg1,2)==1), 
   CS(1,ii)=[arg1(fX)'.*(1-dx)+arg1(cX)'.*dx];
 else
   CS(1,ii)=[arg1(fX).*(1-dx)+arg1(cX).*dx];
 end;
 
 if (size(arg2,2)==1), 
   CS(2,ii)=[arg2(fY)'.*dy+arg2(cY)'.*(1-dy)]; 
 else
   CS(2,ii)=[arg2(fY).*dy+arg2(cY).*(1-dy)]; 
 end;
 
end;
             
              

