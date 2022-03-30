function DEPTH=depth(P,LAT);
% DEPTH   Computes depth given the pressure at some latitude
%         D=DEPTH(P,LAT) gives the depth D (m) for a pressure P (dbars)
%         at some latitude LAT (degrees).
%
%         This probably works best in mid-latiude oceans, if anywhere!
%
%         Ref: Saunders, Fofonoff, Deep Sea Res., 23 (1976), 109-111
% 

%Notes: RP (WHOI) 2/Dec/91
%         I copied this directly from the UNESCO algorithms

% CHECKVALUE: DEPTH = 9712.653 M FOR P=10000 DECIBARS, LATITUDE=30 DEG
%     ABOVE FOR STANDARD OCEAN: T=0 DEG. CELSUIS ; S=35 (IPSS-78)
      X = sin(LAT/57.29578);
%**************************
      X = X.*X;
% GR= GRAVITY VARIATION WITH LATITUDE: ANON (1970) BULLETIN GEODESIQUE
      GR = 9.780318*(1.0+(5.2788E-3+2.36E-5*X).*X) + 1.092E-6.*P;
      DEPTH = (((-1.82E-15*P+2.279E-10).*P-2.2512E-5).*P+9.72659).*P;
      DEPTH=DEPTH./GR;


