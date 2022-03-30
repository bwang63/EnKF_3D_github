function [u,y,z] =ecom_islice(cdf,var,time,iindex,jrange)
%ECOM_ISLICE  returns a vertical slice along i=iindex 
%           from an ECOMxx.CDF or POM.CDF file.
%
%     The variable must be a function of x, y, z and time: (e.g. salinity)
%       USAGE: [u,y,z]=islice(cdf,var,time,iindex,[jrange])
%        u = the selected variable
%        y = distance in *km* (assuming y units in netCDF file are in meters)
%        z = depth in m
%        iindex = I index along which slice is taken
%        jrange = jmin and jmax indices along slice (optional).  If this
%           argument is not supplied the default takes all the J indices
%           except for the first and last, which are always "land" cells.
%
%
% see also JSLICE, KSLICE, ZSLICE, ZSLICEUV, KSLICEUV
%
if (nargin < 4) ,
  help islice; return
end
mexcdf('setopts',0);
ncid=mexcdf('open',cdf,'nowrite');
if(ncid==-1),
  disp(['file ' cdf ' not found'])
  return
end
[name, ny]=mexcdf('diminq',ncid,'ypos');
[name, nz]=mexcdf('diminq',ncid,'zpos');
if(exist('jrange')),
  jrange(1)=max(1,jrange(1));
  jrange(2)=min(ny-1,jrange(2));
  jstart=jrange(1)-1;
  jcount=jrange(2)-jrange(1)+1;
else
  jstart=1
  jcount=ny-2;
end
u=mexcdf('varget',ncid,var,[(time-1) 0 jstart (iindex-1)],...
      [1 nz-1 jcount 1],1);
if nargout>1,
  d=mexcdf('varget',ncid,'depth',[jstart (iindex-1)],[jcount 1],1);
  ind=find(d==-99999.);
  d(ind)=d(ind)*0;
  u(ind,:)=u(ind,:)*NaN;
  sigma=mexcdf('varget',ncid,'sigma',0,nz,1);
  sigma=0.5*(sigma(1:nz-1)+sigma(2:nz));
  h2=mexcdf('varget',ncid,'h2',[jstart (iindex-1)],[jcount 1],1);
  y=cumsum(h2)/1000.;
  y=y*ones(1,nz-1);
  z=d*(sigma');
  ind=find(isnan(z));
  z(ind)=zeros(size(ind));
end
mexcdf('close',ncid);
