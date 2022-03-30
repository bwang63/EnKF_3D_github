load VERT_OA x1 z1 vel1 temp1 x2 z2 

% first plot the section for the data and show
% the grids (source and destination)
figure(1); clf
subplot(3,1,1)
pcolor(x1,z1, vel1);shading flat; colorbar
hold on
% overlay the bottom of the domain
plot(x1(:,1), z1(:,1),'r');
plot(x2(:,1), z2(:,1),'g');
title 'velocity'
legend ('grid1' ,'grid2',2)
set(gca,'xlim',[-155  -110],'ylim', [-5000 0]);
ax=caxis;

subplot(3,1,2)
pcolor(x1,z1, temp1);shading flat; colorbar
rnt_contourfill(x1,z1, temp1,50); colorbar
hold on
% overlay the bottom of the domain
plot(x1(:,1), z1(:,1),'r');
plot(x2(:,1), z2(:,1),'g');
title 'temp'
set(gca,'xlim',[-155  -110],'ylim', [-5000 0]);

subplot(3,1,3)
% now show the two grids
plot(x1, z1,'.k')
hold on
plot(x2, z2,'.g')
title 'grids overlaps (source black) (dest green)'
plot(x2(:,1), z2(:,1),'m');
set(gca,'xlim',[-155  -110],'ylim', [-5000 0]);

%==========================================================
%	% try a simple griddata first
%==========================================================

temp2=griddata(x1,z1,temp1,x2,z2,'linear');
vel2=griddata(x1,z1,vel1,x2,z2,'linear');

figure(2); clf
subplot(2,1,1)
pcolor(x2,z2, vel2);shading flat; colorbar
hold on
% overlay the bottom of the domain
plot(x1(:,1), z1(:,1),'r');
plot(x2(:,1), z2(:,1),'g');
title 'velocity interp'
set(gca,'xlim',[-155  -110],'ylim', [-5000 0]);


subplot(2,1,2)
pcolor(x2,z2, temp2);shading flat; colorbar
hold on
% overlay the bottom of the domain
plot(x1(:,1), z1(:,1),'r');
plot(x2(:,1), z2(:,1),'g');
title 'temp interp'
set(gca,'xlim',[-155  -110],'ylim', [-5000 0]);

%==========================================================
%	now try oa
%==========================================================

dx=4; % degrees long.
dz=400; % meters depth
temp2oa=rnt_oa2d(x1,z1,temp1,x2,z2,dx,dz);
vel2oa=rnt_oa2d(x1,z1,vel1,x2,z2,dx,dz);

figure(3); clf
subplot(2,1,1)
pcolor(x2,z2, vel22);shading flat; colorbar
hold on
% overlay the bottom of the domain
plot(x1(:,1), z1(:,1),'r');
plot(x2(:,1), z2(:,1),'g');
title 'velocity interp'
set(gca,'xlim',[-155  -110],'ylim', [-5000 0]);


subplot(2,1,2)
pcolor(x2,z2, temp22);shading flat; colorbar
rnt_contourfill(x2,z2, temp22,50)
hold on
% overlay the bottom of the domain
plot(x1(:,1), z1(:,1),'r');
plot(x2(:,1), z2(:,1),'g');
title 'temp interp'
set(gca,'xlim',[-155  -110],'ylim', [-5000 0]);



vel1=vel1(1:end-7,:);
x1=x1(1:end-7,:);
temp1=temp1(1:end-7,:);
z1=z1(1:end-7,:);

x2=x2(1:end-3,:);
z2=z2(1:end-3,:);

[dataout,error,pmap]=rnt_oa3d(grd1.lonv,grd,zrin,tracer, ... 
                                  lonout,latout,zrout,a,b,pmap);
					    
					    
[out,grd1,grd]=rnt_grid2gridN(grd1,grd,ctlc,1,'v');					    
%/sdb/edl/ROMS-pak/matlib/rnt/rnt_oa3d.m
%/sdb/edl/ROMS-pak/matlib/rnt/rnt_grid2gridN.m
