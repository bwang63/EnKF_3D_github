function [Ri,jd]=tsrich(cdf,sta);
% TSRICH calculates gradient Richardson Number from TSEPIC.CDF files
%
% Usage: [Ri,jd]=tsrich(cdf,sta);
%
%  Requires: SWSTATE from Rich Pawlowitz's OCEAN toolbox for
%            the calculation of density
%
swstatet=ones(size(s))*4;
[w,jd]=tsvel(cdf,sta);
[svan,sigma]=swstate(s,t,zeros(size(t)));
dens=1+sigma/1000;
dz=diff(z);
g=9.81;
N=g*(diff(dens.').')./(ones(length(jd),1)*dz);
shear=(diff(w.').')./(ones(length(jd),1)*dz);
Ri=N./(real(shear).^2 + imag(shear).^2);
