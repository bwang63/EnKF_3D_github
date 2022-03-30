function [u,x,y]=ecom_kslice(cdf,var,time,layer)
%ECOM_KSLICE:  returns horizontal slice at particular layer.
%
% Horizontal slice is at specified sigma layer at given time-step for a
% ECOM file.
%
% This function can also be used to read in 2D and 3D fields such as
% bathymetry and heat_flux.  The coordinates of u are returned as x and y.
%
% USAGE: [u,x,y]=ecom_kslice(cdf,var,[time],[layer])
%
% where 
%   cdf:  file name for netCDf file (e.g. 'ecom.cdf')
%   var:  the variable to select (eg. 'salt' for salinity)
%   time:  time step 
%   layer:  sigma layer (e.g 1 for bottom layer)
%
%    
%       Examples: 
%
%          [s,x,y]=ecom_kslice('ecom.cdf','salt',2,3);
%              returns the salinity field from the 3rd sigma level
%              at the 2nd time step.
%
%          [elev,x,y]=ecom_kslice('ecom.cdf','elev',4);
%              returns the elevation field from the 4th time step
%
%          [depth,x,y]=ecom_kslice('ecom.cdf','depth');
%              returns the depth field
%

if (nargin<2 | nargin>4),
  help ecom_kslice; return
end
% turn off warnings from NetCDf
mexcdf('setopts',0);
%
% open existing file
ncid=mexcdf('open',cdf,'nowrite');
if(ncid==-1),
  disp(['file ' cdf ' not found'])
  return
end
[name, nx]=mexcdf('diminq',ncid,'xpos');
[name, ny]=mexcdf('diminq',ncid,'ypos');
[name, nz]=mexcdf('diminq',ncid,'zpos');



%
% Acquire the grid.
%
% If "lon_rho" and "lat_rho" are present, grab them.
% Otherwise, get "x_rho" and "y_rho".
[lon_varid, rcode] = mexcdf('VARID', ncid, 'lon');
[lat_varid, rcode] = mexcdf('VARID', ncid, 'lat');
if ( (lon_varid >= 0) | (lat_varid >= 0) )
    x=ncmex('varget',ncid,'lon',[0 0],[-1 -1]);
    y=ncmex('varget',ncid,'lat',[0 0],[-1 -1]);
else
    x=ncmex('varget',ncid,'x',[0 0],[-1 -1]);
    y=ncmex('varget',ncid,'y',[0 0],[-1 -1]);
end

%if(nargout==3),
%  x=mexcdf('varget',ncid,'x',[0 0],[ny nx]);
%  y=mexcdf('varget',ncid,'y',[0 0],[ny nx]);
%end



%
% use depth=-99999  to mask points on land
%
depth=mexcdf('varget',ncid,'depth',[0 0],[ny nx]);
land=find(depth==-99999);
%
% allow for using kslice on 2D, 3D and 4D variables
%
if(nargin==4),
 [u,ierr]=mexcdf('varget',ncid,var,[(time-1) layer-1 0 0],[1 1 ny nx],1); 
elseif(nargin==3),
 [u,ierr]=mexcdf('varget',ncid,var,[(time-1) 0 0],[1 ny nx],1); 
else
 [u,ierr]=mexcdf('varget',ncid,var,[0 0],[ny nx],1); 
end

mexcdf('close',ncid);
u(land)=u(land)*NaN;

