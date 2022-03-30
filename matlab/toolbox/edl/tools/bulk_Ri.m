function [Ri,FC]=bulk_Ri(T,S,U,V,Ustar,Zr,Zw);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright (c) 1999 Rutgers University.                                    %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                           %
% function [Ri]=bulk_Ri(T,S,U,V,Ustar,Zr,Zw);                               %
%                                                                           %
% This function computes Bulk Richardson Number for a vertical slice.       %
% For simplicity, assume no surface bouyancy flux.                          %
%                                                                           %
% On Input:                                                                 %
%                                                                           %
%    T           Temperature (Celsius).                                     %
%    S           Salinity (PSU).                                            %
%    U           U-momentum (m/s).                                          %
%    V           V-momentum (m/s).                                          %
%    Ustar       Tubulent friction velocity (m/s).                          %
%    Zr          Depths of rho-points (meters; negative).                   %
%    Zw          Depths of W-points (meters; negative).                     %
%                                                                           %
% On Output:                                                                %
%                                                                           %
%    Ri          Bulk Richardson number.                                    %
%    FC          Boundary layer critical function.                          %
%                                                                           %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%----------------------------------------------------------------------------
%  Set equation of state expansion coefficients.
%----------------------------------------------------------------------------

A00=+19092.56D0;  A01=+209.8925D0;   A02=-3.041638D0;   A03=-1.852732D-3;
A04=-1.361629D-5; B00=+104.4077D0;   B01=-6.500517D0;   B02=+0.1553190D0;
B03=+2.326469D-4; D00=-5.587545D0;   D01=+0.7390729D0;  D02=-1.909078D-2;
E00=+4.721788D-1; E01=+1.028859D-2;  E02=-2.512549D-4;  E03=-5.939910D-7;
F00=-1.571896D-2; F01=-2.598241D-4;  F02=+7.267926D-6;  G00=+2.042967D-3;
G01=+1.045941D-5; G02=-5.782165D-10; G03=+1.296821D-7;  H00=-2.595994D-7;
H01=-1.248266D-9; H02=-3.508914D-9;  Q00=+999.842594D0; Q01=+6.793952D-2;
Q02=-9.095290D-3; Q03=+1.001685D-4;  Q04=-1.120083D-6;  Q05=+6.536332D-9;
U00=+0.824493D0;  U01=-4.08990D-3;   U02=+7.64380D-5;   U03=-8.24670D-7;
U04=+5.38750D-9;  V00=-5.72466D-3;   V01=+1.02270D-4;   V02=-1.65460D-6;
W00=+4.8314D-4; 

grav=9.81;

%----------------------------------------------------------------------------
%  Set KPP constants.
%----------------------------------------------------------------------------

vonKar=0.41;
lmd_Cv=1.25;
lmd_betaT=-0.2;
lmd_cs=98.96;
lmd_epsilon=0.1;
lmd_Ric=0.3;
rho0=1000;
gorho0=grav/rho0;

Vtc=lmd_Cv*sqrt(-lmd_betaT)/ ...
    (sqrt(lmd_cs*lmd_epsilon)*lmd_Ric*vonKar*vonKar);

%----------------------------------------------------------------------------
%  Compute density (kg/m3) at standard one atmosphere pressure.
%----------------------------------------------------------------------------

sqrtS=sqrt(S);

den1 = Q00 + Q01.*T + Q02.*T.^2 + Q03.*T.^3 + Q04.*T.^4 + Q05.*T.^5 + ...
       U00.*S + U01.*S.*T + U02.*S.*T.^2 + U03.*S.*T.^3 + U04.*S.*T.^4 + ...
       V00.*S.*sqrtS + V01.*S.*sqrtS.*T + V02.*S.*sqrtS.*T.^2 + ...
       W00.*S.^2;

%----------------------------------------------------------------------------
%  Compute secant bulk modulus (bulk = K0 - K1*z + K2*z*z).
%----------------------------------------------------------------------------

K0 = A00 + A01.*T + A02.*T.^2 + A03.*T.^3 + A04.*T.^4 + ...
     B00.*S + B01.*S.*T + B02.*S.*T.^2 + B03.*S.*T.^3 + ...
     D00.*S.*sqrtS + D01.*S.*sqrtS.*T + D02.*S.*sqrtS.*T.^2;

K1 = E00 + E01.*T + E02.*T.^2 + E03.*T.^3 + ...
     F00.*S + F01.*S.*T + F02.*S.*T.^2 + ...
     G00.*S.*sqrtS;

K2 = G01 + G02.*T + G03.*T.^2 + ...
     H00.*S + H01.*S.*T + H02.*S.*T.^2;

%----------------------------------------------------------------------------
%  Compute Brunt-Vaisala frequency (1/s2) at W-points.
%----------------------------------------------------------------------------

[L,N]=size(T);
Np=N+1;

bvf(:,1)=zeros([L 1]);

for k=1:N-1,

  bulk_up = K0(:,k+1) - ...
            Zw(:,k+2).*(K1(:,k+1)-Zw(:,k+2).*K2(:,k+1));
  bulk_dn = K0(:,k  ) - ...
            Zw(:,k+1).*(K1(:,k  )-Zw(:,k+1).*K2(:,k  ));

  den_up = (den1(:,k+1).*bulk_up) ./ (bulk_up + 0.1.*Zw(:,k+2));
  den_dn = (den1(:,k  ).*bulk_dn) ./ (bulk_dn + 0.1.*Zw(:,k+1));

  bvf(:,k+1) = -grav * (den_up-den_dn) ./ ...
               (0.5.*(den_up + den_dn) .* (Zr(:,k+1)-Zr(:,k)));

end,

bvf(:,N+1)=zeros([L 1]);

%----------------------------------------------------------------------------
%  Compute potential deinsity.
%----------------------------------------------------------------------------

pden = den1 - 1000;
clear den1

%----------------------------------------------------------------------------
%  Compute bulk Richarson number.
%----------------------------------------------------------------------------

%  Compute vertical metric, Hz.

ds=1/N;
ods=N;
Hz(:,1:N)=(Zw(:,2:N+1)-Zw(:,1:N))*ods;

%  Compute vertical derivatives via splines

cff6=6.0/ds;

FC=zeros([L Np]);
dR=zeros([L Np]);
dU=zeros([L Np]);
dV=zeros([L Np]);

for k=1:N-1,
  cff=1.0./(2.0.*Hz(:,k+1)+Hz(:,k).*(2.0-FC(:,k)));
  FC(:,k+1)=cff.*Hz(:,k+1);
  dR(:,k+1)=cff.*(cff6.*(pden(:,k+1)-pden(:,k))-Hz(:,k).*dU(:,k));
  dU(:,k+1)=cff.*(cff6.*(U(:,k+1)-U(:,k))-Hz(:,k).*dU(:,k));
  dV(:,k+1)=cff.*(cff6.*(V(:,k+1)-V(:,k))-Hz(:,k).*dV(:,k));
end,
dR(:,N+1)=zeros([L 1]);
dU(:,N+1)=zeros([L 1]);
dV(:,N+1)=zeros([L 1]);
 
for k=N:-1:1
  dR(:,k)=dR(:,k)-FC(:,k).*dR(:,k+1);
  dU(:,k)=dU(:,k)-FC(:,k).*dU(:,k+1);
  dV(:,k)=dV(:,k)-FC(:,k).*dV(:,k+1);
end,

%  Compute surface refference values.

cff1=1.0/3.0;
cff2=1.0/6.0;
Rref=pden(:,N)+ds.*Hz(:,N).*(cff1.*dR(:,N+1)+cff2.*dR(:,N));
Uref=   U(:,N)+ds.*Hz(:,N).*(cff1.*dU(:,N+1)+cff2.*dU(:,N));
Vref=   V(:,N)+ds.*Hz(:,N).*(cff1.*dV(:,N+1)+cff2.*dV(:,N));

%  Compute turbulent velocity scale.

ws=vonKar.*Ustar;

%  Compute bulk Richardson number.

FC=zeros([L Np]);
Ri=zeros([L Np]);

for k=N:-1:1,
  depth=Zw(:,N+1)-Zw(:,k);
  Rk=pden(:,k)-ds.*Hz(:,k).*(cff1.*dR(:,k)+cff2.*dR(:,k+1));
  Uk=   U(:,k)-ds.*Hz(:,k).*(cff1.*dU(:,k)+cff2.*dU(:,k+1));
  Vk=   V(:,k)-ds.*Hz(:,k).*(cff1.*dV(:,k)+cff2.*dV(:,k+1));
!
  Ritop=-gorho0.*(Rref-Rk).*depth;
  Ribot=(Uref-Uk).^2+(Vref-Vk).^2+ ...
        Vtc.*depth.*ws.*sqrt(abs(bvf(:,k)));
  Ri(:,k)=Ritop./(Ribot+1.0e-20);
  ind=find(Ribot==0);
  if (~isempty(ind)), Ri(ind,k)=NaN; end,
  FC(:,k)=Ritop-lmd_Ric*Ribot;
end,   
 
return

