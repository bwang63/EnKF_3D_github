function [BVFRQ,Pbar,E]=bvfreq(S,T,P,smooth);
% BVFREQ    Computes the Brunt-Vaisala (or buoyancy) frequency.
%           [BV,Pv,N2]=BVFREQ(S,T,P) computes the buoyancy frequency
%           BV (cycles per hour) and N2 (N^2 in rad^2/sec^2) at
%           pressures Pv (dbars), given a profile of salinity S (ppt)
%           Temperature (deg C), and pressure P (dbars).
%
%           BVFREQ(...,SMOOTH) computes gradients by computing a best fit      
%           over SMOOTH consecutive points (default is no smoothing, 
%           i.e. SMOOTH=2). The returned vectors are smaller than the
%           input vectors by SMOOTH-1 elements.
%

%Notes: RP (WHOI) 2/dec/91
%         I pretty much completely re-wrote this routine to take advantage
%         of the Matlab vectorizations, adding the SMOOTH parameter.
%C CHECKVALUE: BVFRQ=14.57836 CPH E=6.4739928E-4 (RAD/SEC)^2.
%C            S(1)=35.0, T(1)=5.0, P(1)=1000.0
%C            S(2)=35.0, T(2)=4.0, P(2)=1002.0
%C  ********NOTE RESULT CENTERED AT PAV=1001.0 DBARS **********
%
%	Modified for matlab5		AEN
% ----------------------------------------------------------------------


if (nargin<4),   smooth=2; end;

% create P so that we smooth over all data in each column 
P=P(:);
N=length(P)-smooth+1;   
ii=ones(smooth,1)*[1:N]+[0:smooth-1]'*ones(1,N);

S=reshape(S(ii),smooth,N);  % form matrices, with each column representing
T=reshape(T(ii),smooth,N);  % all the data smoothed into one N2 estimate
P=reshape(P(ii),smooth,N);

Pbar=ones(smooth,1)*mean(P);   % mean elements in each column

% We want potential temperatures at Pbar
theta=pottemp(S,T,P,Pbar);

% get specific volume anomaly for each matrix element
[stericanom,sigma]=swstate(S,theta,Pbar);

% compute slope
delP=P-Pbar;
dVdP=sum( stericanom.*delP )./sum( delP.*delP )*1e-8;

% specific volume = 1./(1000. + sigmabar)
Vbar=(1)./(1000.+mean(sigma) );


E= -(9.80655^2)*dVdP./(Vbar.*Vbar)*1e-4;
BVFRQ=572.9578*sign(E).*sqrt(abs(E));

Pbar=Pbar(1,:);



   
