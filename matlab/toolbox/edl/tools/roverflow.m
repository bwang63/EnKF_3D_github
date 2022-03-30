function [r,t]=roverflow(y,z);

[im,km]=size(z);
for k=1:km;
  ysec(:,k)=y(:);
end,

%  Set density and temperature.

tmin=0;
tmax=5;
Tcoef=1;
R0=0;
yc=60;
ydecay=2;

t=tmax-0.5*(tmax-tmin).*(1.0+tanh((ysec-yc)./ydecay));
r=R0+Tcoef.*t;

figure(3);
pcolor(ysec,z,r); shading interp; colormap(cool(64)); colorbar;
ymax=max(max(ysec));
zmin=min(min(z));
set(gca,'xlim',[0 ymax],'ylim',[zmin 0]);
title('Overflow Density');
xlabel('Y (km)');
ylabel('depth (m)');

figure(4);
pcolor(ysec,z,t); shading interp; colormap(hot(64)); colorbar;
ymax=max(max(ysec));
zmin=min(min(z));
set(gca,'xlim',[0 ymax],'ylim',[zmin 0]);
title('Overflow Temperature');
xlabel('Y (km)');
ylabel('depth (m)');

return
