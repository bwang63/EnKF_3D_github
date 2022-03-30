function THETA=pottemp(S,T0,P0,PR);
% POTTEMP Potential temperature from in-situ measurements.
%          THETA=POTTEMP(S,TO,PO,PR) computes the potential temp.
%          at a reference pressure PR (dbars) corresponding to the 
%          salinity S (ppt) and temperature TO (deg C) at pressure 
%          PO (dbars). The formula has been copied from the UNESCO
%          algorithms (See comments for details).
%
%          if PR is omitted, it is assumed to be zero.
%
%          S, T0, P0 can be vectors or matrices. If S (T) is a scalar,
%          and T (S) is a vector or matrix, we assume that the scalar
%          value corresponds to all values in the vector. 
%  
%          If P0 is a vector, and one of S,T0 is a matrix, we assume
%          that elements of P0 correspond with all row entries in the
%          matrices.
%
% REF: BRYDEN,H.,1973,DEEP-SEA RES.,20,401-408
%      FOFONOFF,N.,1977,DEEP-SEA RES.,24,489-491

% Converted to 8 char length function names and for version 5.1 (AN)

if (nargin==3), PR=0; end;

[NS,MS]=size(S);
[NT,MT]=size(T0);
if ((NS==1 & MS==1) & (NT ~=1 | MT ~=1) ),
   S=S*ones(NT,MT);
   [NS,MS]=size(S);
elseif ((NT==1 & MT==1) & (NS ~=1 | MS ~=1) ),
   T0=T0*ones(NS,MS);
   [NT,MT]=size(T0);
end;

[NP,MP]=size(P0);
if (MP==1), P0=P0*ones(1,MT); 
elseif (NP==1), P0=P0'*ones(1,MT); end;



% Notes: RP 29/Nov/91
%
% I have modified the FORTRAN code to make it Matlab compatible, but
% no numbers have been changed. In certain places "*" has been replaced
% with ".*" to allow vectorization.
%
% This routine calls adiabatt.m (renamed from ATG).

%C ***********************************
%C TO COMPUTE LOCAL POTENTIAL TEMPERATURE AT PR
%C USING BRYDEN 1973 POLYNOMIAL FOR ADIABATIC LAPSE RATE
%C AND RUNGE-KUTTA 4-TH ORDER INTEGRATION ALGORITHM.
%C UNITS:      
%C       PRESSURE        P0       DECIBARS
%C       TEMPERATURE     T0       DEG CELSIUS (IPTS-68)
%C       SALINITY        S        (IPSS-78)
%C       REFERENCE PRS   PR       DECIBARS
%C       POTENTIAL TMP.  THETA    DEG CELSIUS 
%C CHECKVALUE: THETA= 36.89073 C,S=40 (IPSS-78),T0=40 DEG C,
%C P0=10000 DECIBARS,PR=0 DECIBARS
%C             
%C      SET-UP INTERMEDIATE TEMPERATURE AND PRESSURE VARIABLES
%      IMPLICIT REAL*8 (A-H,O-Z)
      P=P0;
      T=T0;
%C**************
      H = PR - P;
      XK = H.*adiabatt(S,T,P) ;
      T = T + 0.5*XK;
      Q = XK  ;
      P = P + 0.5*H ;
      XK = H.*adiabatt(S,T,P) ;
      T = T + 0.29289322*(XK-Q) ;
      Q = 0.58578644*XK + 0.121320344*Q ;
      XK = H.*adiabatt(S,T,P) ;
      T = T + 1.707106781*(XK-Q);
      Q = 3.414213562*XK - 4.121320344*Q;
      P = P + 0.5*H ;
      XK = H.*adiabatt(S,T,P) ;
      THETA = T + (XK-2.0*Q)/6.0;
