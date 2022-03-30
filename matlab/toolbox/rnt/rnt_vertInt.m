% (R)oms (N)umerical (T)oolbox
%
% FUNCTION [tracerV,tracerVavg,tracerVol] = rnt_vertInt(tracer,grd,varargin);
%
% Compute vertical integral of tracer
%
% INPUT:
%    tracer (@ r-points, N, t) baroclinic velocity
%
% OUTPUT: tracerV, tracerVavg is the depth average
%  tracerVol is the volume integral
% errors with actual model calculation O(1.0e-5)
% RNT - E. Di Lorenzo (edl@ucsd.edu)

function [tracerV, tracerVavg,tracerVol] = rnt_vertInt(tracer,grd,varargin);
[x,y,z,T]=size(tracer);


    mask=repmat(grd.maskr,[1 1 grd.N]);
    in=find(~isnan(mask));

   % dx metrics
    dx=1./grd.pm;
    dx=repmat(dx,[1 1 grd.N]).*mask;

    % dy metrics
    dy=1./grd.pn;
    dy=repmat(dy,[1 1 grd.N]).*mask;
    


 

tracerV=zeros(grd.Lp,grd.Mp,1,T); 

for t=1:T;
    [zr,zw,dz]=rnt_setdepth(0,grd);
    volume = dx.*dy.*dz;    
    tmp = tracer(:,:,:,t).*volume;
    tracerVol(t) = sum(tmp(in));
    
    tracerV(:,:,1,t) = sum( tracer(:,:,:,t).*dz , 3) ;
    tracerVavg(:,:,1,t)=tracerV(:,:,1,t)./grd.h;
    
    
end

