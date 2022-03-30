function [F]=state(S,T,Z);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright (c) 1998 Rutgers University.                                    %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                           %
% function [F]=state(S,T,Z);                                                %
%                                                                           %
% This function computes quantities associated with nonlinear equation of   %
% state for seawater.                                                       %
%                                                                           %
% On Input:                                                                 %
%                                                                           %
%    T           Potential Temperature (Celsius)                            %
%    S           Salinity (PSU)                                             %
%    Z           Depth (meter, negative)                                    %
%                                                                           %
% On Output:                                                                %
%                                                                           %
%    F           Equation of state fields (structure array)                 %
%                  F.den1     standard 1 atm density                        %
%                  F.den      "in situ" density                             %
%                  F.bulk     secant bulk modulus                           %
%                  F.alpha    Thermal expansion                             %
%                  F.beta     Saline contraction                            %
%                  F.gamma    Adiabatic and isentropic compressibility      %
%                  F.svel     Sound speed                                   %
%                                                                           %
% Check Values: (T=3 C, S=35.5 PSU, Z=-5000 m)                              %
%                                                                           %
%     alpha = 2.1014611551470D-04 (1/Celsius)                               %
%     beta  = 7.2575037309946D-04 (1/PSU)                                   %
%     gamma = 3.9684764511766D-06 (1/Pa)                                    %
%     den   = 1050.3639165364     (kg/m3)                                   %
%     den1  = 1028.2845117925     (kg/m3)                                   %
%     sound = 1548.8815240223     (m/s)                                     %
%     bulk  = 23786.056026320     (Pa)                                      %
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
Z=-abs(Z);

%----------------------------------------------------------------------------
%  Compute density (kg/m3) at standard one atmosphere pressure.
%----------------------------------------------------------------------------

sqrtS=sqrt(S);

F.den1 = Q00 + Q01.*T + Q02.*T.^2 + Q03.*T.^3 + Q04.*T.^4 + Q05.*T.^5 + ...
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

F.bulk = K0 - K1.*Z + K2.*Z.^2;

%----------------------------------------------------------------------------
%  Compute "in situ" density anomaly (kg/m3).
%----------------------------------------------------------------------------

F.den = (F.den1.*F.bulk) ./ (F.bulk + 0.1.*Z);

%----------------------------------------------------------------------------
%  Compute thermal expansion (1/Celsius), saline contraction (1/PSU),
%  and adiabatic and isentropic compressibility (1/Pa) coefficients.
%----------------------------------------------------------------------------

%  Compute d(F.den1)/d(S) and d(F.den1)/d(T) derivatives.

Dden1DS = U00 + U01.*T + U02.*T.^2 + U03.*T.^3 + U04.*T.^4 + ...
          V00.*1.5.*sqrtS + V01.*1.5.*sqrtS.*T + V02.*1.5.*sqrtS.*T.^2 + ...
          W00.*2.*S;

Dden1DT = Q01 + Q02.*2.*T + Q03.*3.*T.^2 + Q04.*4.*T.^3 + Q05.*5.*T.^4 + ...
          U01.*S + U02.*2.*S.*T + U03.*S.*3.*T.^2 + U04.*S.*4.*T.^3 + ...
          V01.*S.*sqrtS + V02.*S.*sqrtS.*2.*T;

%  Compute d(bulk)/d(S), d(bulk)/d(T), and d(bulk)/d(P) derivatives.

DbulkDS = B00 + B01.*T + B02.*T.^2 + B03.*T.^3 + ...
          D00.*1.5.*sqrtS+ D01.*1.5.*sqrtS.*T + D02.*1.5.*sqrtS.*T.^2 - ...
          F00.*Z - F01.*Z.*T - F02.*Z.*T.^2 - ...
          G00.*Z.*1.5.*sqrtS + ...
          H00.*Z.^2 + H01.*Z.^2.*T + H02.*Z.^2.*T.^2;


DbulkDT = A01 + A02.*2.*T + A03.*3.*T.^2 + A04.*4*T.^3 + ...
          B01.*S + B02.*S.*2.*T + B03.*S.*3.*T.^2 + ...
          D01.*S.*sqrtS + D02.*S.*sqrtS.*2.*T - ...
          E01.*Z - E02.*Z.*2.*T - E03.*Z.*3.*T.^2 - ...
          F01.*Z.*S - F02.*Z.*S.*2.*T + ...
          G02.*Z.^2 + G03.*Z.^2.*2.*T + ...
          H01.*Z.^2.*S + H02.*Z.^2.*S.*2.*T;

DbulkDP = -K1 + K2.*2.*Z;

wrk = F.den .* (F.bulk + 0.1.*Z).^2;

%  Compute thermal expansion (1/Celsius), saline contraction (1/PSU),
%  and adiabatic and isentropic compressibility (1/Pa) coefficients.

F.alpha = -(DbulkDT.*0.1.*Z.*F.den1 + ...
            Dden1DT.*F.bulk.*(F.bulk + 0.1.*Z)) ./ wrk;

F.beta  =  (DbulkDS.*0.1.*Z.*F.den1 + ...
            Dden1DS.*F.bulk.*(F.bulk + 0.1.*Z)) ./ wrk;

F.gamma = -0.1.*F.den1 .* (DbulkDP.*Z - F.bulk) ./ wrk;

clear DbulkDP DbulkDS DbulkDT Dden1DP Dden1DS Dden1DT wrk

%----------------------------------------------------------------------------
%  Compute sound speed.
%----------------------------------------------------------------------------

svel2=abs(10000.0./(F.den.*F.gamma));
F.svel=sqrt(svel2);

return
