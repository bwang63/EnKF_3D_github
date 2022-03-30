function [E,P]=ep(rfd,Qlat)
% EP: computes evap and precip accumulation
% [E,P]=EP(rfd,Qlat) computes precipitation and evaporation 
% accumulation from rainfall rate rfd and latent heat 
% flux Qlat. Assumes hourly input. 
%
% INPUT:   rfd - precip rate  [mm/min]
%          Qlat - latent heat flux  [W/m^2]
%
% OUTPUT:  P - precip accumulation  [m] 
%          E - evaporation accumulation  [m]

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 8/5/99: version 2.0
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% compute P
P=cumsum(rfd)./1000; % convert mm to m
dt=60; % for hourly data, dt = 60 min
P=P.*dt;

% compute E
Le=2.5e6; % heat of vaporization (W/m^2)
pw=1025; % density of seawater (kg/m^3) at 32 psu, 10 degC, 0 db
dt=3600; % seconds per hour
E=cumsum(Qlat).*dt./(Le.*pw);



