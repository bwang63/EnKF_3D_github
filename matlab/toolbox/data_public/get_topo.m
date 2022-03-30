function [lon,lat,d] = get_topo(f,ax);
% [lon,lat,d] = get_topo(f,ax) gets bathymetry in range of axis vector 
% from ncfile f 
%
% e.g. f = [data_public '/topo/terrainbase.nc'];
%      f = [data_public '/topo/topo_ngdc.nc'];
% John Wilkin 23 March 98

lon = getnc(f,'lon');
lat = getnc(f,'lat');
x = findinrange(lon,ax(1:2));
y = findinrange(lat,ax(3:4));
lon = lon(x);
lat = lat(y);
x = range(x);
y = range(y);
d = getnc(f,'height',[y(1) x(1)],[y(2) x(2)],[1 1]);
