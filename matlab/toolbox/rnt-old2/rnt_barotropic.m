% (R)oms (N)umerical (T)oolbox
%
% FUNCTION [ubar,vbar] = rnt_barotropic(u,v,Hz,grd);
%
% Compute barotropic u v 
%
% INPUT:
%    u (@ u-points, N, t) baroclinic velocity
%    v (@ v-points, N, t) baroclinic velocity
%    Hz (@ rho-points, N, t) thickness of sigma layers (m)
%
% OUTPUT: ubar, vbar
% errors with actual model calculation O(1.0e-5)
% RNT - E. Di Lorenzo (edl@ucsd.edu)

function [ubar,vbar] = rnt_barotropic(u,v,Hz,grd);
[x,y,z,T]=size(u);

gridid=grd.id;
rnt_gridloadtmp;
ubar=zeros(L,Mp,1,T); vbar=zeros(Lp,M,1,T);

t=1:T;
for k=1:N
    ubar=ubar+u(:,:,k,t).*0.5.*(Hz(1:L,:,k,t)+Hz(2:Lp,:,k,t));
    vbar=vbar+v(:,:,k,t).*0.5.*(Hz(:,1:M,k,t)+Hz(:,2:Mp,k,t));
end

ubar=squeeze(ubar);
vbar=squeeze(vbar);
for t=1:T
    ubar(:,:,t)=ubar(:,:,t)./rnt_2grid(h,'r','u');
    vbar(:,:,t)=vbar(:,:,t)./rnt_2grid(h,'r','v');
end
