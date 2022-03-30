function [lon,lat,Cd,dz]=bot_drag(gname,fname,Cdmax,Zo,tindex);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright (c) 1998 Rutgers University.                                    %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                           %
% function [lon,lat,Cd,dz]=bot_drag(fname,Cdmax,Zo,tindex)                  %
%                                                                           %
% This function computes and plots bottom drag coefficient using            %
% natural logarithmic law.                                                  %
%                                                                           %
% On Input:                                                                 %
%                                                                           %
%    gname       Grid NetCDF file name (character string).                  %
%    fname       History NetCDF file name (character string).               %
%    Cdmax       Upper bound bottom drag coefficient (plotting only).       %
%    Zo          Bottom roughness (around 0.01 m).                          %
%    tindex      Time index (integer).                                      %
%                                                                           %
% On Output:                                                                %
%                                                                           %
%    lon         Longitude grid.                                            %
%    lat         Latitude grid.                                             %
%    Cd          Bottom drag coefficient (nondimensional).                  %
%    dz          Bottom thickness (m).                                      %
%                                                                           %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Deactivate printing information when reading data from NetCDF file.

global IPRINT

IPRINT=0;

% Check arguments.

if (nargin < 3),
 Zo=0.01;
end,

if (nargin < 4)
 tindex=1;
end,

%  Read in bottom topography.

h=nc_read(fname,'h');

% Read in (lon,lat) positions.

lon=nc_read(fname,'lon_rho');
lat=nc_read(fname,'lat_rho');

% Compute depths a rho-points.

z_r=depths(fname,gname,1,0,tindex);

% Compute bottom drag.

vonKar=0.41;
dz=h+z_r(:,:,1);
Cd=vonKar./log(dz./Zo);
Cd=Cd.*Cd;

% Plot drag coefficients.

figure;
pcolor(lon,lat,dz); shading interp; colorbar;
grid on;
title('Bottom Layer Thickness (m)');
xlabel(['Min = ',num2str(min(min(dz))),'  Max = ',num2str(max(max(dz)))]);

figure;
pcolor(lon,lat,Cd); shading interp; colorbar;
grid on;
title('Bottom Drag Coefficient');
xlabel(['Min = ',num2str(min(min(Cd))),'  Max = ',num2str(max(max(Cd)))]);

figure;
ind=find(Cd>Cdmax);
C=Cd; C(ind)=Cdmax;
pcolor(lon,lat,C); shading interp; colorbar;
grid on;
title('Upper Bounded Bottom Drag Coefficient');
xlabel(['Min = ',num2str(min(min(C))),'  Max = ',num2str(max(max(C)))]);

return


