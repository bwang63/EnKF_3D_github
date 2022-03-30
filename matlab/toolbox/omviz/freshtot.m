function [ctot,cmean,fthick,x,y]=freshtot(cdfin,tind,bounds,s0)
% FRESHTOT computes to total amount of fresh water present in a given time
%        step of a ecomsi model run.  
%
%  Usage: [ftot,fmean,fthick,x,y]=freshtot(cdfin,tind,bounds,s0)
%
%  where:  cdfin = ecomsi.cdf run
%          tind = single index of time (defaults to [1])
%          bounds = [imin imax jmin jmax] limits  
%                   (defaults to [1 nx 1 ny]) if -1 is specified
%          bounds may also be a 1 d array containg the indices
%            of the matrix 
%            (just make sure it has more than 4 elements!) 
%           ftot = total sum of scalar quantity c
%           fmean = mean value of ctot (ctot/volume)
%           fthick = depth-integrated fresh water  (freshwater thickness)
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
if(nargin< 4 | bounds==-1),
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
x=mexcdf('varget',ncid,'x',[iy ix],[ny nx]);
y=mexcdf('varget',ncid,'y',[iy ix],[ny nx]);
iland=find(d==-99999.);
d(iland)=zeros(size(iland));
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
  c=mexcdf('varget',ncid,'salt',[tind-1 j-1 iy ix],[1 1 ny nx],1); %get a layer
  c=(s0-min(c,s0))/s0;
%  ibad=find(c>s0);   % don't count salinities greater than the reference salinity!
%  c(ibad)=0*c(ibad);
  ctot=ctot+dsigma(j)*c;   %multiply layer values by normalized layer thickness
end
mexcdf('close',ncid);
fthick=(ctot.*d);     % integrated fresh water
ctot=fthick.*area;
ctot=sum(ctot(ind));        % find basin total
cmean=ctot/sum(sum(d(ind).*area(ind))); %divide basin total by basin volume
fthick=max(fthick,0.);
fthick(iland)=fthick(iland)*nan;
