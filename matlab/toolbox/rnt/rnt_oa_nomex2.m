function [field,pmap]=rnt_oa_nomex(lon_d,lat_d, data, lon_gr,lat_gr,maskgr,xcorr,ycorr,dx,dy,varargin)


if nargin == 11
   pmap=varargin{1};
   COMPUTE_PMAP =0;
else
   COMPUTE_PMAP =1;
end

tic;

% subsample domain of data needed for destination grid 
I = find(lon_d(:,1)  >=  min(lon_gr(:))-dx  & lon_d(:,1) <= max(lon_gr(:))+dx);
J = find(lat_d(1,:)  >=  min(lat_gr(:))-dy  & lat_d(1,:) <= max(lat_gr(:))+dy );

data=data(I,J);
lon_d=lon_d(I,J);
lat_d=lat_d(I,J);

data = rnt_fill(lon_d,lat_d,data,dx,dy);

field = interp2(lon_d',lat_d',data',lon_gr,lat_gr,'cubic');

toc;
