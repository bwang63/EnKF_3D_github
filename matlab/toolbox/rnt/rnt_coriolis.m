% (R)oms (N)umerical (T)oolbox
%
% FUNCTION f=rnt_coriolis(lat);
%
% Comute coriolis parameter
%
%   omega=2*pi/(24*60*60);
%   f=2*omega*sin ( lat/180*pi);
%
% RNT - E. Di Lorenzo (edl@gatech.edu)

function f=rnt_coriolis(lat)

omega=2*pi/(24*60*60);
f=2*omega*sin ( lat/180*pi);
