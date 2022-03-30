function [w,jd,depth]=ecomvel(cdf,i,j,lev,iind)
% ECOMVEL extracts a velocity time series from a 4D netCDF ECOM output file.
%
%   USAGE:  [u,jd,depth]=ecomvel(cdf,i,j,lev,[tind]);
%
% cdf = cdf file e.g. 'ecomsi.cdf'
% (i,j) = station location in grid coordinates
% lev = sigma level from which to extract time series (0 is surface)
% w = complex vector of velocity with dimension time
% jd = time vector  (digital Julian day)
% depth = depth of time series (meters)

% Rich Signell (rsignell@usgs.gov)

% 3-27-96 fixed bug that was returning a slightly bad depth value 
%         due to averaging the sigma levels twice

ncid=mexcdf('open',cdf,'nowrite');
[nam,nz]=mexcdf('diminq',ncid,'zpos');
[nam,nt]=mexcdf('diminq',ncid,'time');
if(exist('iind')==1),
  istart=min(iind);
  icount=min(max(iind),nt)-istart+1;
else
  istart=0;
  icount=nt;
end
sigma=mexcdf('varget',ncid,'sigma',0,nz);
depth=mexcdf('varget',ncid,'depth',[j-1 i-1],[1 1]);
depth=.5*(sigma(lev)+sigma(lev+1))*depth;

base_date=[0 0 0 0 0 0];
base_date(1:3)=mexcdf('attget',ncid,'global','base_date');
t=mexcdf('varget',ncid,'time',istart,icount);
jd0=julian(base_date);
jd=jd0+t;

ang=mexcdf('varget',ncid,'ang',[j-1 i-1],[1 1],1);
u=mexcdf('varget',ncid,'u',[istart lev-1 j-1 i-1],[icount 1 1 2],1);
v=mexcdf('varget',ncid,'v',[istart lev-1 j-1 i-1],[icount 1 2 1],1);

w=mean(u)+sqrt(-1)*mean(v);       %average u and v to center of grid
w=w(:);
w=w.*exp(sqrt(-1)*ang);   %rotate vectors from grid coordinates to E,N  
