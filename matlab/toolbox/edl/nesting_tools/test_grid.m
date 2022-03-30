%
% Plot free surface and barotropic velocities at a given time
%
clear all
close all hidden
grdfile=('calcofi_grid.nc.2')
%grdfile=('/Drive2/Preproc/Grid/Gridfiles/Westprov_circ_medres2_grd.nc')
%grdfile=('/Drive2/TheRun/Westprov_r0.15_his.nc')

% Read in lat, lon, h, mask_rho, angle
%
h=nc_read(grdfile,'h');
[L M]=size(h);
lat=nc_read(grdfile,'lat_rho');
lon=nc_read(grdfile,'lon_rho');
mask=nc_read(grdfile,'mask_rho');
angle=nc_read(grdfile,'angle');
mask=mask./mask;
h=h.*mask;
%
% Plot the bathy
%
figure
pcolor(lon,lat,h)
colorbar
title('The western province model bathymetry')
xlabel('Longitude')
ylabel('Latitude')
shading interp
axis image
hold on 
contour(lon,lat,h,'w')
hold off
%
% Plot the resolution
%
figure
pm=nc_read(grdfile,'pn');
dx=mask./(1000.*pm);
pcolor(lon,lat,dx)
axis image
colorbar
title('The western province model resolution')
xlabel('Longitude')
ylabel('Latitude')
%
% Plot the angle with the East
%
figure
angle=mask.*angle*180/pi;
pcolor(lon,lat,angle)
shading interp
axis image
colorbar
title('The angle with the East')
xlabel('Longitude')
ylabel('Latitude')
%
% Compute the slope factor for the pressure gradient problem
%
figure
[hx,hy] = gradient(h);
dh_h=mask.*sqrt(hx.^2+hy.^2)./h;
pcolor(lon,lat,dh_h)
shading interp
axis image
colorbar
title('Dh/h')
xlabel('Longitude')
ylabel('Latitude')

%figure
%dmde=nc_read(grdfile,'dmde');
%pcolor(lon,lat,dmde)
%axis image
%colorbar
%title('DMDE')
%xlabel('Longitude')
%ylabel('Latitude')

%figure
%dndx=nc_read(grdfile,'dndx');
%pcolor(lon,lat,dndx)
%axis image
%colorbar
%title('DNDX')
%xlabel('Longitude')
%ylabel('Latitude')

figure
f=nc_read(grdfile,'f');
pcolor(lon,lat,f)
axis image
colorbar
title('f')
xlabel('Longitude')
ylabel('Latitude')

[x,y,dhdx,dhde,slope,r]=hslope(grdfile,1,1) ;








