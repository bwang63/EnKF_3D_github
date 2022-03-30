function[ured,vred,lonred,latred,speed]=uv_vec2rho(u,v,lon,lat,angle,skip)
%
% put a uv current field in the carthesian frame
%
[Mp,Lp]=size(lon);
L=Lp-1;
M=Mp-1;
Lm=L-1;
Mm=M-1;
%
%  Values at rho points.
%
ugrd=0.*lon;
vgrd=0.*lon;
ugrd(:,2:L)=0.5*(u(:,1:Lm)+u(:,2:L));
ugrd(:,1)=ugrd(:,2);
ugrd(:,Lp)=ugrd(:,L);
vgrd(2:M,:)=0.5*(v(1:Mm,:)+v(2:M,:));
vgrd(1,:)=vgrd(2,:);
vgrd(Mp,:)=vgrd(M,:);
%
%  Rotation
%
cosa = cos(-angle);
sina = sin(-angle);
ssu = ugrd.*cosa + vgrd.*sina;
ssv = vgrd.*cosa - ugrd.*sina;
%
%  Skip
%
imin=floor(0.5+0.5*skip);
imax=floor(0.5+Lp-0.5*skip);
jmin=ceil(0.5+0.5*skip);
jmax=ceil(0.5+Mp-0.5*skip);
ured=ssu(jmin:skip:jmax,imin:skip:imax);
vred=ssv(jmin:skip:jmax,imin:skip:imax);
latred=lat(jmin:skip:jmax,imin:skip:imax);
lonred=lon(jmin:skip:jmax,imin:skip:imax);
speed=sqrt(ugrd.^2+vgrd.^2);
return