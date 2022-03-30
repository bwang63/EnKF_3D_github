function [shear]=shear_slice(U,V,Zr,Zw,flag);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright (c) 1999 Rutgers University.                                    %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                           %
% function [shear]=shear_slice(U,V,Zr,Zw,flag);                             %
%                                                                           %
% This function computes velocity shear squared for a vertical slice.       %
%                                                                           %
% On Input:                                                                 %
%                                                                           %
%    U           U-momentum (m/s).                                          %
%    V           V-momentum (m/s).                                          %
%    Zr          Depths of rho-points (meters; negative).                   %
%    Zw          Depths of W-points (meters; negative).                     %
%    flag        Shear computation flag:                                    %
%                  flag = 0,  => finite diferences.                         %
%                  flag = 1,  => parabolic spline reconstruction.           %
%                                                                           %
% On Output:                                                                %
%                                                                           %
%    shear       horizontal velocity shear (1/s2).                          %
%                                                                           %
%                                                                           %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if (nargin < 5),
  flag=1;
end,

[L,N]=size(U);
Np=N+1;

%---------------------------------------------------------------------------
%  Vertical velocity shear via parabolic splines reconstruction.
%---------------------------------------------------------------------------

if (flag),

%  Compute vertical metric, Hz.

  ds=1/N;
  ods=N;
  Hz(:,1:N)=(Zw(:,2:N+1)-Zw(:,1:N))*ods;

  cff6=6.0/ds;

  FC=zeros([L Np]);
  dU=zeros([L Np]);
  dV=zeros([L Np]);

  for k=1:N-1,
    cff=1.0./(2.0.*Hz(:,k+1)+Hz(:,k).*(2.0-FC(:,k)));
    FC(:,k+1)=cff.*Hz(:,k+1);
    dU(:,k+1)=cff.*(cff6.*(U(:,k+1)-U(:,k))-Hz(:,k).*dU(:,k));
    dV(:,k+1)=cff.*(cff6.*(V(:,k+1)-V(:,k))-Hz(:,k).*dV(:,k));
  end,
  dU(:,N+1)=zeros([L 1]);
  dV(:,N+1)=zeros([L 1]);
 
  for k=N:-1:1
    dU(:,k)=dU(:,k)-FC(:,k).*dU(:,k+1);
    dV(:,k)=dV(:,k)-FC(:,k).*dV(:,k+1);
  end,

  shear=dU.*dU + dV.*dV;

end,

return

