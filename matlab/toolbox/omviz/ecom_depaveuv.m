function [wmean,x,y]=ecom_depaveuv(cdfin,tind,bounds)
% ECOM_DEPAVEUV computes the depth-averaged value of velocity at
%        a given time step of a ECOM model run.
%
%  Usage:  [wmean,x,y]=ecom_depaveuv(cdf,[tstep],[bounds])
%
%  where:  cdf = ecomsi.cdf run
%          var = variable to depth-average
%          tstep = time step (default = 1)
%          bounds = [imin imax jmin jmax] limits
%                   (default = [1 nx 1 ny])
%
%          wmean = depth-averaged velocity
%          x = x locations of the returned array wmean
%          y = y locations of the returned array wmean
%
%  Example 1:  [wmean,x,y]=ecom_depave('ecomsi.cdf');
%
%       computes the depth-averaged velocity at the 1st time step
%       over the entire domain.
%
%  Example 2:  [wmean,x,y]=ecom_depave('ecomsi.cdf',10);
%
%       computes the depth-averaged velocity at the 10th time step
%       over the entire domain.
%
%  Example 3:  [wmean,x,y]=ecom_depave('ecomsi.cdf',10,[10 30 30 50]);
%
%       computes the depth-averaged velocity at the 10th time step
%       in the subdomain defined by i=10:30 and j=30:50.
%
%  
if(nargin==1),
  tind=1;
end
cdfid1=mexcdf('open',cdfin,'nowrite');
if(cdfid1==-1),
  disp(['file ' cdf ' not found'])
  return
end
[nam,nxr]=mexcdf('diminq',cdfid1,'xpos');
[nam,nyr]=mexcdf('diminq',cdfid1,'ypos');
[nam,nz]=mexcdf('diminq',cdfid1,'zpos');
if(nargin< 3),
  ix=0;
  iy=0;
  nx=nxr;
  ny=nyr;
else
  if(bounds(2)>nxr|bounds(4)>nyr),disp('out of bounds'),return,end
  ix=bounds(1)-1;
  nx=bounds(2)-bounds(1)+1;
  iy=bounds(3)-1;
  ny=bounds(4)-bounds(3)+1;
end
depth=mexcdf('varget',cdfid1,'depth',[iy ix],[ny nx]);
x=mexcdf('varget',cdfid1,'x',[iy ix],[ny nx]);
y=mexcdf('varget',cdfid1,'y',[iy ix],[ny nx]);
ang=mexcdf('varget',cdfid1,'ang',[iy ix],[ny nx]);
sigma=mexcdf('varget',cdfid1,'sigma',[0],[nz]);
dsigma=-diff(sigma);
h1=mexcdf('varget',cdfid1,'h1',[iy ix],[ny nx]);
h2=mexcdf('varget',cdfid1,'h2',[iy ix],[ny nx]);
area=h1.*h2;
wmean=zeros(nx,ny);
for j=[1:nz-1],
  u=mexcdf('varget',cdfid1,'u',[tind-1 j-1 iy ix],[1 1 ny nx],1); %get a layer
  v=mexcdf('varget',cdfid1,'v',[tind-1 j-1 iy ix],[1 1 ny nx],1); %get a layer
  u=u(1:nx-1,:)+.5*diff(u);
  u(nx,:)=u(nx-1,:);
  v=v(:,1:ny-1)+.5*diff(v')';
  v(:,ny)=v(:,ny-1);
  w=u+sqrt(-1)*v;
  wmean=wmean+dsigma(j)*w;  %multiply layer values by normalized layer thickness
end
dind=find(depth==-99999 | depth==0);
wmean(dind)=wmean(dind)*NaN;
wmean=wmean.*exp(sqrt(-1)*ang);
mexcdf('close',cdfid1);
