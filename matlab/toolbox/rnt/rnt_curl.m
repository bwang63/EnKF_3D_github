% (R)oms (N)umerical (T)oolbox
% 
% FUNCTION curl=rnt_curl(u,v,grd)
%
% Compute curl of vector (u,v) on model grid psi-points, 
% using the correct metrics.
%
% INPUT:
%   u(@ u-grid,k,t)
%   v(@ v-grid,k,t)
%
% OUTPUT:
%  curl(@ psi-grid,k,t)
%
% RNT - E. Di Lorenzo (edl@ucsd.edu)

function [curl, We]=rnt_curl(u,v,grd)

[i,j,t]=size(u);
odx=rnt_2grid(grd.pm,'r','p');
ody=rnt_2grid(grd.pn,'r','p');
f=rnt_2grid(grd.f,'r','p');
f=repmat(f, [1 1 t]);
odx=repmat(odx, [1 1 t]);
ody=repmat(ody, [1 1 t]);
rho0=1025;

dvdx=(v(2:end,:,:)-v(1:end-1,:,:)).*odx;
dudy=(u(:,2:end,:)-u(:,1:end-1,:)).*ody;

curl= dvdx - dudy;
We=curl./(f*rho0);




return
gridid=grd.id;
rnt_gridloadtmp;

[i,j,k,t]=size(u);

v1=zeros(Lp,Mp,k,t);
u1=zeros(Lp,Mp,k,t);
pm=repmat(pm,[ 1 1 k t]);
pn=repmat(pn,[ 1 1 k t]);

on_v=repmat(on_v,[1 1 k t]);
om_u=repmat(on_u,[1 1 k t]);
m=rnt_2grid(pm,'r','p');
n=rnt_2grid(pn,'r','p');
m=repmat(m,[1 1 k t]);
n=repmat(n,[1 1 k t]);

k=1:k;
t=1:t;

% psi-range
j=Jstr:JendR;
i=Istr:IendR;

% in model notations all arrays are defined in length of rho grid, 0:Lp 
v1(IV_RANGE,JV_RANGE,k,t)=v(:,:,k,t);
u1(IU_RANGE,JU_RANGE,k,t)=u(:,:,k,t);


disp ('Check curl routine scaling');
%v1=v1.*on_v;
%u1=u1.*om_u;
% -= pm = 1/dx
v1=v1.*pm;
u1=u1.*pn;

curl(i,j,k,t)= ( (v1(i,j,k,t)-v1(i-1,j,k,t)) ) - ...
                 ((u1(i,j,k,t)-u1(i,j-1,k,t)));
% remove cloumn1 and row 1 which are undefined on psi grid.
curl=curl(2:end,2:end,k,t);
%%curl=curl.*(m.*n);


