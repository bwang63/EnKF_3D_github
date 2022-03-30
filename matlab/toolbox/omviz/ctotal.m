function [ctot,cmean]=ctotal(cdfin,varin,tind,bounds)
% CTOTAL computes to total amount of tracer present in a given time
%        step of a ecomsi model run.  
%
%  Usage:  [ctot,cmean]=ctotal(cdfin,varin,[tind],[bounds])
%
%  where:  cdfin = ecomsi.cdf run
%          tind = single index of time (defaults to [1])
%          bounds = [imin imax jmin jmax] limits  
%                   (defaults to [1 nx 1 ny])
%          bounds may also be a 1 d array containg the indices
%            of the matrix 
%            (just make sure it has more than 4 elements!) 
%           ctot = total sum of scalar quantity c
%           cmean = mean value of ctot (ctot/volume)
%  
if(nargin==2),
  tind=1;
end
% suppress netcdf warnings
mexcdf('setopts', 0);
%
ncid=mexcdf('open',cdfin,'nowrite');
if(ncid==-1),
  disp(['file ' cdf ' not found'])
  return
end
[nam,nxr]=mexcdf('diminq',ncid,'xpos');
[nam,nyr]=mexcdf('diminq',ncid,'ypos');
[nam,nz]=mexcdf('diminq',ncid,'zpos');
if(nargin< 4),
  ix=0;
  iy=0;
  nx=nxr;
  ny=nyr;
  ind=1:(nx*ny);
elseif (length(bounds)>4),
  ix=0;
  iy=0;
  nx=nxr;
  ny=nyr;
  ind=bounds;
else
  if(bounds(2)>nxr|bounds(4)>nyr),disp('out of bounds'),return,end
  ix=bounds(1)-1;
  nx=bounds(2)-bounds(1)+1;
  iy=bounds(3)-1;
  ny=bounds(4)-bounds(3)+1;
  ind=1:(nx*ny);
end

d=mexcdf('varget',ncid,'depth',[iy ix],[ny nx]);
d=replace(d,-99999,0.);
%
% add surface elevation to depth to get total water depth
e=mexcdf('varget',ncid,'elev',[tind-1 iy ix],[1 ny nx],1);
d=d+e;

sigma=mexcdf('varget',ncid,'sigma',[0],[nz]);
dsigma=-diff(sigma);
h1=mexcdf('varget',ncid,'h1',[iy ix],[ny nx]);
h2=mexcdf('varget',ncid,'h2',[iy ix],[ny nx]);
area=h1.*h2;
ctot=zeros(nx,ny);
for j=[1:nz-1],
  c=mexcdf('varget',ncid,varin,[tind-1 j-1 iy ix],[1 1 ny nx],1); %get a layer
  ctot=ctot+dsigma(j)*c;   %multiply layer values by normalized layer thickness
end
ctot=(ctot.*d).*area;     % multiply depth-averaged values by depth and area
ctot=sum(ctot(ind));        % find basin total
cmean=ctot/sum(sum(d(ind).*area(ind))); %divide basin total by basin volume
mexcdf('close',ncid);
