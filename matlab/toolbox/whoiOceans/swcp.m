function CPSW=swcp(S,T,P0);
% SWCP    Computes the specific heat of seawater.
%         CPSW=SWCP(S,T,P) is the heat capacity (in J/kg/deg C) of water
%         with salinity S (ppt), temperature T (deg C), and pressure P
%         (dbars).
%
%         Ref: Millero et. al., J. Geophys. Res. 78 (1973), 4499-4507
%              Millero et. al., UNESCO report 38 (1981), 99-188.
%

%Notes: RP (WHOI) 2/Dec/91
%        This is a straight copy of the UNESCO algorithm, with only
%        minimal editing to make it work in Matlab with arrays.

%	converted to matlab v 5.1  AN

% PRESSURE VARIATION FROM LEAST SQUARES POLYNOMIAL
% DEVELOPED BY FOFONOFF 1980.

% CHECK VALUE: CPSW = 3849.500 J/(KG DEG. C) FOR S = 40 (IPSS-78),
% T = 40 DEG C, P0= 10000 DECIBARS

%   SCALE PRESSURE TO BARS
      P=P0/10.;
%**************************
% SQRT SALINITY FOR FRACTIONAL TERMS
      SR = sqrt(abs(S));
% SPECIFIC HEAT CP0 FOR P=0 (MILLERO ET AL ,UNESCO 1981)
      A = (-1.38385E-3*T+0.1072763).*T-7.643575;
      B = (5.148E-5*T-4.07718E-3).*T+0.1770383;
      C = (((2.093236E-5*T-2.654387E-3).*T+0.1412855).*T-3.720283).*T+4217.4;
      CP0 = (B.*SR + A).*S + C;
% CP1 PRESSURE AND TEMPERATURE TERMS FOR S = 0
      A = (((1.7168E-8*T+2.0357E-6).*T-3.13885E-4).*T+1.45747E-2).*T-0.49592;
      B = (((2.2956E-11*T-4.0027E-9).*T+2.87533E-7).*T-1.08645E-5).*T+2.4931E-4;
      C = ((6.136E-13*T-6.5637E-11).*T+2.6380E-9).*T-5.422E-8;
      CP1 = ((C.*P+B).*P+A).*P;
% CP2 PRESSURE AND TEMPERATURE TERMS FOR S > 0
      A = (((-2.9179E-10*T+2.5941E-8).*T+9.802E-7).*T-1.28315E-4).*T+4.9247E-3;
      B = (3.122E-8.*T-1.517E-6).*T-1.2331E-4;
      A = (A+B.*SR).*S;
      B = ((1.8448E-11*T-2.3905E-9).*T+1.17054E-7).*T-2.9558E-6;
      B = (B+9.971E-8.*SR).*S;
      C = (3.513E-13*T-1.7682E-11).*T+5.540E-10;
      C = (C-1.4300E-12*T.*SR).*S;
      CP2 = ((C.*P+B).*P+A).*P;
% SPECIFIC HEAT RETURN
      CPSW = CP0 + CP1 + CP2;

