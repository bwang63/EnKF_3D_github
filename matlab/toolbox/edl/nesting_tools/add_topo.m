function h=add_topo(grdname,toponame)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% add a topography (here etopo2) to a ROMS grid
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%
%  read grid
%
nc=netcdf(grdname);
lon=nc{'lon_rho'}(:);
lat=nc{'lat_rho'}(:);
result=close(nc);
latmin=min(min(lat));
latmax=max(max(lat));
lonmin=min(min(lon));
lonmax=max(max(lon));
%
%  read topo
%
nc=netcdf(toponame);
tlon=nc{'topo_lon'}(:);
i=find(tlon>=lonmin-0.5 & tlon<=lonmax+0.5);
tlon=tlon(i);
tlat=nc{'topo_lat'}(:);
j=find(tlat>=latmin-0.5 & tlat<=latmax+0.5);
tlat=tlat(j);
topo=-nc{'topo'}(j,i);
result=close(nc);
%
%  interpole topo
%
h=interp2(tlon,tlat,topo,lon,lat,'cubic');
return
