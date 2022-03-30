function ATG=adiabattempgrad(S,T,P);
% ADIABATTEMPGRAD Computes the adiabatic temperature gradient (called
%                 by POTENTIALTEMP).
%
%                 ADIABATTEMPGRAD(S,T,P) returns the gradient. Units are:
%   
%       PRESSURE        P        DECIBARS
%       TEMPERATURE     T        DEG CELSIUS (IPTS-68)
%       SALINITY        S        (IPSS-78)
%       ADIABATIC       ATG      DEG. C/DECIBAR
%
% REF: BRYDEN,H.,1973,DEEP-SEA RES.,20,401-408

% Notes: RP 29/Nov/91
%
% I have modified the FORTRAN code to make it Matlab compatible, but
% no numbers have been changed. In certain places "*" has been replaced
% with ".*" to allow vectorization.
%
% This routine is called be potentialttemp.m, and is called ATG in the
% UNESCO algorithms.

%C CHECKVALUE: ATG=3.255976E-4 C/DBAR FOR S=40 (IPSS-78),
%C T=40 DEG C,P0=10000 DECIBARS
%      IMPLICIT REAL*8 (A-H,O-Z)

      DS = S - 35.0 ;
      ATG = (((-2.1687E-16*T+1.8676E-14).*T-4.6206E-13).*P+...
((2.7759E-12*T-1.1351E-10).*DS+((-5.4481E-14*T+8.733E-12).*T-6.7795E-10).*T+...
1.8741E-8)).*P+(-4.2393E-8*T+1.8932E-6).*DS+((6.6228E-10*T-6.836E-8).*T+...
8.5258E-6).*T+3.5803E-5;
