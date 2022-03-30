% (R)oms (N)umerical (T)oolbox
%
% FUNCTION [Ipos,Jpos]=rnt_hindices2(Xpos,Ypos,Xgrd,Ygrd,Angler);
%
%  Given position vectors Xpos and Ypos    ,  this routine
%  finds the corresponding indices Ipos and Jpos of the  model grid
%  (Xgrd,Ygrd) cell containing each requested position. Angler is the
%  angle of orientation of the grid. Angler can be equal to zero
%  or a constant.
%  NOTE:
%      in matlab indices the grid arrays
%      Xgrd(1:Lp,1:Mp)
%      in fortran ROMS arrays are defined
%      Xgrd(0:Lp-1,0:Mp-1)
%  this implies that if you want to use the indices computed by
%  this routine in ROMS you need to subtract 1 to the output
%  Ipos = Ipos -1;
%  Jpos = Jpos -1;
%
% This rouintes uses a fortran mexfile rnt_hindices_mex.f, which uses
% code developped by Hernan G. Arango and Alexander F. Shchepetkin.
%
% RNT - E. Di Lorenzo (edl@ucsd.edu)
function [Ipos,Jpos]=rnt_hindices2(Xpos,Ypos,Xgrd,Ygrd,Angler);
  
  Xpos=Xpos(:);
  Ypos=Ypos(:);
  
  [I,J] = size(Xgrd);
  [I1,J1] = size(Ygrd);
  if I1~=I | J~=J1
    disp (' RNT_HINDICES - Inconsistent size of grid arrays - STOP');
  end
  if length(Angler) ==1
    Angler=repmat(Angler, [I J]);
  end
  
  %[Ipos,Jpos]=rnt_hindices_mex(Xpos,Ypos,Xgrd,Ygrd,Angler);
  
  [Ipos,Jpos]=rnt_hindicesCart_mex2(Xpos,Ypos,Xgrd,Ygrd,Angler);
  
  return  %%%%%%%%%%%  NOTE !!!!!!!!!!!!!!!!!!!!!!!!!!!!
  
  
  % test data
  load rnt_griddata_TestData
  [lon,lat]=meshgrid(-124.4:.02: -120.9,  31.3:.02:34.2);
  Xgrd=lonr;
  Ygrd=latr;
  Angler=angler;
  Ypos=lat(4);
  Xpos=lon(4);
  
  [Ipos,Jpos]=rnt_hindices(Xpos,Ypos,Xgrd,Ygrd,angler);
  
  [Ipos,Jpos]=rnt_hindicesCart_mex2(Xpos,Ypos,Xgrd,Ygrd,angler);
  I=fix( Ipos ); J=fix( Jpos );
  
  i=I;
  j=J;
  
  X=[Xgrd(i,j)  Xgrd(i+1,j)    Xgrd(i,j+1) Xgrd(i+1,j+1) ];
  Y=[Ygrd(i,j)  Ygrd(i+1,j)    Ygrd(i,j+1) Ygrd(i+1,j+1)];
  XI=[0 1 0 1];
  
  d1= sqrt((X(1) - Xpos).^2 + (Y(1) - Ypos).^2);
  d2= sqrt((X(2) - Xpos).^2 + (Y(2) - Ypos).^2);
  d3= sqrt((X(3) - Xpos).^2 + (Y(3) - Ypos).^2);
  d4= sqrt((X(4) - Xpos).^2 + (Y(4) - Ypos).^2);
  
  sumd=d1+d2+d3+d4; sumd=sumd/3;
  a1=1-d1/sumd; a2=1-d2/sumd; a3=1-d3/sumd; a4=1-d4/sumd;
  
  dx = a4*0 + a1*1.0 + a2*0.0 + a3*1.0
  dy = a4*0 + a2*1.0 + a3*0.0 + a4*1.0
  
  dx = a1*0 + a2*1.0 + a3*1.0 + a4*0
  dy = a1*0 + a2*0 +   a3*1.0 + a4*1.0
  
  Ipos = a1*II(1) + a2*II(2) + a3*II(3) + a4*II(4);
  Jpos = a1*JJ(1) + a2*JJ(2) + a3*JJ(3) + a4*JJ(4);
  
  return
  
  Ipos2 = griddata(X,Y,XI, lonp(1),latp(1));
  
  ang=angler(1);
  ang=theta;
  Xhat=X.*cos(ang) + Y.*sin(ang);
  Yhat=Y.*cos(ang) - X.*sin(ang);
  
  c=earthdist(X(1), Y(1), X(2),Y(2));
  a=earthdist(X(1), Y(1), X(1),Y(2));
  theta= acos(a/c);
  
%%%
  a=X(2)-X(1);    b=Y(2) - Y(1);
  c=sqrt(a.*a + b.*b);
  theta= acos(a/c);
  ang=theta;
  Xhat=X.*cos(ang) + Y.*sin(ang);
  Yhat=Y.*cos(ang) - X.*sin(ang);
  
  X1=lonp(1).*cos(ang) + latp(1).*sin(ang);
  Y1=latp(1).*cos(ang) - lonp(1).*sin(ang);
  
  [X1 - Xhat(1) ]/ [Xhat(2) - Xhat(1) ]
  
  [X1 - Xhat(1) ]/ [Xhat(2) - Xhat(1) ]
  
  return
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  % test data
  load rnt_hindices_TestData
  [Ipos,Jpos]=rnt_hindices(Xpos,Ypos,lonr,latr,angler);
  
  [Ipos,Ipos_good]
  [Jpos,Jpos_good]
  
  rnt_griddata.m

