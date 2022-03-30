function [cmean,x,y]=depave(cdfin,varin,tind,bounds)
% DEPAVE computes the depth-averaged value of a 4D variable at 
%        a given time step of a ECOM model run.  
%
%  Usage:  [cmean,x,y]=depave(cdf,var,[tstep],[bounds])
%
%  where:  cdf = ecomsi.cdf run
%          var = variable to depth-average
%          tstep = time step (default = 1)
%          bounds = [imin imax jmin jmax] limits  
%                   (default = [1 nx 1 ny])
%          
%          cmean = depth-averaged quantity
%          x = x locations of the returned array cmean
%          y = y locations of the returned array cmean
%
%  Example 1:  [smean,x,y]=depave('ecomsi.cdf','salt');
%
%       computes the depth-averaged salinity at the 1st time step 
%       over the entire domain.
%
%  Example 2:  [smean,x,y]=depave('ecomsi.cdf','salt',10);
%
%       computes the depth-averaged salinity at the 10th time step 
%       over the entire domain.
%
%  Example 3:  [smean,x,y]=depave('ecomsi.cdf','salt',10,[10 30 30 50]);
%
%       computes the depth-averaged salinity at the 10th time step 
%       in the subdomain defined by i=10:30 and j=30:50.

if(nargin==2),
  tind=1;
end
% suppress netcdf warnings
mexcdf('setopts', 0);
%
cdfid1=mexcdf('open',cdfin,'nowrite');
if(cdfid1==-1),
  disp(['file ' cdf ' not found'])
  return
end
[nam,nxr]=mexcdf('diminq',cdfid1,'xpos');
[nam,nyr]=mexcdf('diminq',cdfid1,'ypos');
[nam,nz]=mexcdf('diminq',cdfid1,'zpos');
if(nargin< 4),
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
sigma=mexcdf('varget',cdfid1,'sigma',[0],[nz]);
dsigma=-diff(sigma);
h1=mexcdf('varget',cdfid1,'h1',[iy ix],[ny nx]);
h2=mexcdf('varget',cdfid1,'h2',[iy ix],[ny nx]);
area=h1.*h2;
cmean=zeros(nx,ny);
for j=[1:nz-1],
  c=mexcdf('varget',cdfid1,varin,[tind-1 j-1 iy ix],[1 1 ny nx],1); %get a layer
  cmean=cmean+dsigma(j)*c;   %multiply layer values by normalized layer thickness
end
mexcdf('close',cdfid1);
dind=find(depth==-99999 | depth==0);
cmean(dind)=cmean(dind)*NaN;
