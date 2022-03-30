function [u,x,z] = ecom_jslice(cdf,var,time,jindex,irange)
%ECOM_JSLICE:  returns a vertical slice along j=jindex, ECOM file
%
% The variable must be 4D.
%
% USAGE:
% >> [u,x,z] = ecom_jslice(cdf,var,time,jindex,[irange])
%        u = the selected variable
%        x = distance in *km* (assuming x units in netCDF file are in meters)
%        z = depth in m
%        jindex = j index along which slice is taken
%        irange = imin and imax indices along slice (optional).  If this
%           argument is not supplied the default takes all the I indices
%           except for the first and last, which are always "land" cells.
%
% see also ISLICE, KSLICE, ZSLICE, ZSLICEUV, KSLICEUV
%    
if (nargin <4) ,
  help jslice; return
end
mexcdf('setopts',0);
ncid=mexcdf('open',cdf,'nowrite');
if(ncid==-1),
  disp(['file ' cdf ' not found'])
  return
end
[name, nx]=mexcdf('diminq',ncid,'xpos');
[name, nz]=mexcdf('diminq',ncid,'zpos');
if(exist('irange')),
  irange(1)=max(1,irange(1));
  irange(2)=min(nx-1,irange(2));
  istart=irange(1)-1;
  icount=irange(2)-irange(1)+1;
else
  istart=1
  icount=nx-2;
end
  u=mexcdf('varget',ncid,var,[(time-1) 0 (jindex-1) istart],...
       [1 nz-1 1 icount],1);
if nargout>1,
  d=mexcdf('varget',ncid,'depth',[(jindex-1) istart],[1 icount],1);
  ind=find(d==-99999.);
  d(ind)=d(ind)*nan;
  u(ind,:)=u(ind,:)*NaN;
  sigma=mexcdf('varget',ncid,'sigma',0,nz,1);
% assume we are slicing a variable defined at 
% at the center of the sigma level (t,s,u,v,km)
  sigma=0.5*(sigma(1:nz-1)+sigma(2:nz));
  h1=mexcdf('varget',ncid,'h1',[(jindex-1) istart],[1 icount],1);
  x=cumsum(h1)/1000.;
  x=x*ones(1,nz-1);
  z=d*(sigma');
  ind=find(isnan(z));
  z(ind)=zeros(size(ind));
end
mexcdf('close',ncid);
