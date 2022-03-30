function [ubar,vbar]=vbaro(zeta,f,pm,pn);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright (c) 1997 Rutgers University.                                    %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                           %
% function [ubar,vbar]=vbaro(zeta,f,pm,pn);                                 %
%                                                                           %
% This function computes barotropic velocities from geostrophy.             %
%                                                                           %
% On Input:                                                                 %
%                                                                           %
%    zeta        Free-surface (m).                                          %
%    f           Coriolis parameter (1/s).                                  %
%    pm          Curvilinear metric in the XI-direction (1/m).              %
%    pn          Curvilinear metric in the ETA-direction (1/m).             %
%                                                                           %
%                                                                           %
% On Output:                                                                %
%                                                                           %
%    ubar        Barotropic velocity component in the XI-direction (m/s).   %
%    vbar        Barotropic velocity component in the ETA-direction (m/s).  %
%                                                                           %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[Lp,Mp]=size(f);
Lm=Lp-2;
L=Lp-1;
Mm=Mp-2;
M=Mp-1;

g=9.808;

%  Compute barotropic velocities.

for j=2:M
  for i=1:L
    u1=-g*(zeta(i  ,j  )-zeta(i  ,j-1)) ...
         *(  pn(i  ,j-1)+  pn(i  ,j  ))/(f(i  ,j-1)+f(i  ,j  ));
    u2=-g*(zeta(i+1,j  )-zeta(i+1,j-1)) ...
         *(  pn(i+1,j-1)+  pn(i+1,j  ))/(f(i+1,j-1)+f(i+1,j  ));
    u3=-g*(zeta(i+1,j+1)-zeta(i+1,j  )) ...
         *(  pn(i+1,j  )+  pn(i+1,j+1))/(f(i+1,j  )+f(i+1,j+1));
    u4=-g*(zeta(i  ,j+1)-zeta(i  ,j  )) ...
         *(  pn(i  ,j  )+  pn(i  ,j+1))/(f(i  ,j  )+f(i  ,j+1));
    ubar(i,j)=0.25*(u1+u2+u3+u4);
  end,
end,
ubar(1:L,1 )=ubar(1:L,2);
ubar(1:L,Mp)=ubar(1:L,M);

for j=1:M
  for i=2:L
    v1=g*(zeta(i  ,j  )-zeta(i-1,j  )) ...
        *(  pm(i-1,j  )+  pm(i  ,j  ))/(f(i-1,j  )+f(i  ,j  ));
    v2=g*(zeta(i+1,j  )-zeta(i  ,j  )) ...
        *(  pm(i  ,j  )+  pm(i+1,j  ))/(f(i  ,j  )+f(i+1,j  ));
    v3=g*(zeta(i+1,j+1)-zeta(i  ,j+1)) ...
        *(  pm(i  ,j+1)+  pm(i+1,j+1))/(f(i  ,j+1)+f(i+1,j+1));
    v4=g*(zeta(i  ,j+1)-zeta(i-1,j+1)) ...
        *(  pm(i-1,j+1)+  pm(i  ,j+1))/(f(i-1,j+1)+f(i  ,j+1));
    vbar(i,j)=0.25*(v1+v2+v3+v4);
  end,
end,
vbar(1 ,1:M)=vbar(2,1:M);
vbar(Lp,1:M)=vbar(L,1:M);

return

