function [bvf]=bvf_slice(T,S,Zr,Zw);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright (c) 1999 Rutgers University.                                    %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                           %
% function [bvf]=bvf_slice(T,S,Zr,Zw);                                      %
%                                                                           %
% This function computes Brunt-Vaisala frequency for a vertical slice.      %
%                                                                           %
% On Input:                                                                 %
%                                                                           %
%    T           Temperature (Celsius).                                     %
%    S           Salinity (PSU).                                            %
%    Zr          Depths of rho-points (meters; negative).                   %
%    Zw          Depths of W-points (meters; negative).                     %
%                                                                           %
% On Output:                                                                %
%                                                                           %
%    bvf         Brunt-Vaisala frequency (1/s2).                            %
%                                                                           %
%  Reference:                                                               %
%                                                                           %
%  Jackett, D. R. and T. J. McDougall, 1995, Minimal Adjustment of          %
%    Hydrostatic Profiles to Achieve Static Stability, J. of Atmos.         %
%    and Oceanic Techn., vol. 12, pp. 381-389.                              %
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

return

