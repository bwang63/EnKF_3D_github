function [u,x,y,jd]=ecom_zslice(cdf,var,time,zuser)
% ECOM_ZSLICE  Returns a matrix containing a horizontal slice at a specified depth
%           at a given time step from an ECOMxx.CDF or POM.CDF file.
%           Regions of grid that are shallower than requested value are
%           returned as NaNs.
%
%       USAGE: [u,x,y,jd]=zslice(cdf,var,time,zuser)
%
%   where zuser is a depth in meters (e.g -10.)
%
% see also ZSLICEUV, ISLICE, JSLICE, KSLICE, KSLICEUV
% hint: use PSLICE or EXTCONTOUR to plot the results of ZSLICE 

% Rich Signell  (rsignell@usgs.gov)
% Changes:
%  Dec 16, 1997:  Fixed problem with sigma levels not being correctly 
%                 centered.  Now T,S, RHO, U, V are computed in the 
%                 center of the vertical grids, and W, Q, and L are
%                 computed at the tops of the vertical grids.  Also,
%                 now if the user selects a zlevel that is below the
%                 sea surface but above the top model data point, the
%                 value at the top data point is returned. If the user
%                 selects a value that is above the bottom but below
%                 the bottom-most grid level, the bottom value is used.
%                 An alternative, would be to use a log-layer formulation
%                 for velocity components.

if (nargin<2 | nargin>4),
  help zslice; return
end
mexcdf('setopts',0);
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
% If "lon" and "lat" are present, grab them.
% Otherwise, get "x" and "y".
[lon_varid, rcode] = mexcdf('VARID', ncid, 'lon');
[lat_varid, rcode] = mexcdf('VARID', ncid, 'lat');
if ( (lon_varid >= 0) | (lat_varid >= 0) )
    x=ncmex('varget',ncid,'lon',[0 0],[-1 -1]);
    y=ncmex('varget',ncid,'lat',[0 0],[-1 -1]);
else
    x=ncmex('varget',ncid,'x',[0 0],[-1 -1]);
    y=ncmex('varget',ncid,'y',[0 0],[-1 -1]);
end


%if(nargout>2),
%  x=mexcdf('varget',ncid,'x',[0 0],[ny nx]);
%  y=mexcdf('varget',ncid,'y',[0 0],[ny nx]);
%end




depth=mexcdf('varget',ncid,'depth',[0 0],[ny nx]);
elev=mexcdf('varget',ncid,'elev',[(time-1) 0 0],[1 ny nx],1);
dind=find(depth==-99999);
igood=find(depth~=-99999);

% use total depth (depth+elev) for sigma model
tdepth=depth+elev;

sigma=mexcdf('varget',ncid,'sigma',0,nz);
n=length(sigma);

% vertical location of grid cell centers (s,rho,u,v,etc, but not w)
sigma2=sigma(1:n-1)+0.5*diff(sigma);

% add on the bottom, so that interpolations between the bottom grid
% cell center and the bottom can be made
sigma2(n)=-1;

% grab 3d slab (all values) at a given time step
uz=mexcdf('varget',ncid,var,[(time-1) 0 0 0],[1 nz ny nx],1); %3d slab

% get time stuff
if(nargout>3)
[nam,nt]=mexcdf('diminq',ncid,'time');
base_date=[0 0 0 0 0 0];
base_date(1:3)=mexcdf('attget',ncid,'global','base_date');
t=mexcdf('varget',ncid,'time',time-1,1);
jd0=julian(base_date);
jd=jd0+t;
end

% Close file
mexcdf('close',ncid);

% Reshape the 3D array so each grid cell's vertical profile is a column.
uz=reshape(uz,nx*ny,n).';

% Assign bottom half of bottom grid cell the same 
% value as at the grid cell center.  
uz(n,:)=uz(n-1,:);   

% Form an array the same shape as uz that contains the depths of the
% grid cell centers.  (multiply sigma by total depth (depth +elev))
switch var
case {'w','kh','km'}
   zlev=sigma*(tdepth(:)');
otherwise
   zlev=sigma2*(tdepth(:)');
end
% find all the values of zlev that are less than the requested depth
% zind consists of zeros and ones.  One if the cell depth is less
% than (below) the requested z level, zero if cell level is greater.
zind=zlev < zuser;

% find the indices IK of the cells that are just above the required level 
dz=diff(zind);
dz(n,:)=zeros(size(dz(n-1,:)));
ik=find(dz==1);

% find the indices ISUM where the requested depth is between two data values
isum=find(sum(dz));
u=zeros(nx*ny,1);

% do linear interpolation
u(isum)=uz(ik)+(uz(ik+1)-uz(ik)).*(zuser-zlev(ik))./(zlev(ik+1)-zlev(ik));

% find requested values that are above top data value but below surface
iabove=find(zlev(1,:) < zuser & zuser < elev(:)');

% assign top data value to requested values above it
u(iabove)=uz(1,iabove);

% find requested values that are above the free surface & mask 'em
itoohigh=find(zuser > elev(:)');
u(itoohigh)=uz(1,itoohigh)*nan;

% put back in matrix form
u=reshape(u,nx,ny);

% mask values where the total depth is less than the requested depth
tind=find(-tdepth > zuser);
u(tind)=u(tind)*NaN;

% mask land values 
u(dind)=u(dind)*NaN;

