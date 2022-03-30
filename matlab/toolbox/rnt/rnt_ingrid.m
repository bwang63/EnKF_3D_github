function [lon_d,lat_d, data,I,J]=rnt_ingrid(lon_d,lat_d, data, lon_gr,lat_gr,dx,dy)


% subsample domain of data needed for destination grid 
[I]=find(  lon_d(:,1) >=  min(lon_gr(:))-dx  & lon_d(:,1) <= max(lon_gr(:))+dx);
J=find( lat_d(1,:) >=  min(lat_gr(:))-dy  & lat_d(1,:) <= max(lat_gr(:))+dy );
data=data(I,J);
lon_d=lon_d(I,J);
lat_d=lat_d(I,J);

