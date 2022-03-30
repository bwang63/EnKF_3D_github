function [lon, lat, bathy] = extract_bathy(lonmin,lonmax,latmin,latmax);
%function [lon, lat, bathy] = extract_bathy(lonmin,lonmax,latmin,latmax);
%
%
% MATLAB version of extract.f provided by Guillaume Ramillien to read
% his bathy_nz_v4
%
% I guess this is Niwa confidential stuff ???? - Steve
%

load bathy_nz_v4 

jy = find(lat_grd>latmin & lat_grd<latmax);
jx = find(lon_grd>lonmin & lon_grd<lonmax);

lon = lon_grd(jx);
lat = lat_grd(jy);
bathy = bathy_grd(jy,jx);

