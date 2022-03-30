%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  compute the embedded grid
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all
close all
parent_grd='/d1/manu/matlib/rnt/grid-calcofi.nc';
child_grd ='/d1/manu/SDM/grid-sdm.nc';
refinecoeff=10;

%imin=68; %monterey(15+5+1.7)
%imax=89;
%jmin=47;
%jmax=76;
%
%imin=64; %scalifbight(15+5)
%imax=84;
%jmin=30;
%jmax=58;
%
%imin=40; %monterey(15+5)
%imax=71;
%jmin=54;
%jmax=117;
%
%imin=43; %scalifbight(20+7)
%imax=63;
%jmin=14;
%jmax=46;
%
%imin=37; %38; %scalifbight(20+7+2.3)
%imax=58;
%jmin=31; %30
%jmax=73; %62;
%
%imin=21; %scalifbight(20+7+2.3+0.8)
%imax=37;
%jmin=69;
%jmax=97;
%
%imin=24; %scalifbight + Santa Barbara Channel (20+7+2.3)
%imax=45;
%jmin=60;
%jmax=81;
%
%imin=45; %calcofi + SCB (9+3)
%imax=79;
%jmin=25;
%jmax=70;
%

option = 'nena1d.1';

switch option
    
  case 'manu' 
      
    imin=45; %calcofi + SCB +SB channel (9+3+1)
    imax=85;
    jmin=60;
    jmax=105;
    
    imin=57; %calcofi +SDM (10)
    imax=79;
    jmin=10;
    jmax=30;
  
case 'nena1d.1'
    
    i = 200;
    j = 116;
    imin = i-2;
    imax = i+2;
    jmin = j-2;
    jmax = j+2;
    parent_grd='../in/roms_nena_grid_5.nc';
    child_grd ='../in/roms_nena1d_grid_1.nc';
    refinecoeff=1;
    
end

%
newtopo = 0; % newtopo =1 if we add and smooth a new topo instead 
             % of simply interpoling the parent one
topofile='/disk13/Topography/etopo2.nc';
%topofile='etopo2.nc';
rtarget=0.2;%0.15; %r maximum value for the smoothing
nband=35;    %number of point used to connect the parent to 
             %the child topos.
%
% Title
%
title=['Grid embedded in ',parent_grd,...
' - positions in the parent grid: ',num2str(imin),' - ',...
num2str(imax),' - ',...
num2str(jmin),' - ',...
num2str(jmax),'; refinement coefficient : ',num2str(refinecoeff)];
disp(title)
%
% Read in the parent grid
%
disp(' ')
disp(' Read in the parent grid...')
nc=netcdf(parent_grd);
latp_parent=nc{'lat_psi'}(:);
lonp_parent=nc{'lon_psi'}(:);
xp_parent=nc{'x_psi'}(:);
yp_parent=nc{'y_psi'}(:);
maskp_parent=nc{'mask_psi'}(:);

latu_parent=nc{'lat_u'}(:);
lonu_parent=nc{'lon_u'}(:);
xu_parent=nc{'x_u'}(:);
yu_parent=nc{'y_u'}(:);
masku_parent=nc{'mask_u'}(:);


latv_parent=nc{'lat_v'}(:);
lonv_parent=nc{'lon_v'}(:);
xv_parent=nc{'x_v'}(:);
yv_parent=nc{'y_v'}(:);
maskv_parent=nc{'mask_v'}(:);


latr_parent=nc{'lat_rho'}(:);
lonr_parent=nc{'lon_rho'}(:);
xr_parent=nc{'x_rho'}(:);
yr_parent=nc{'y_rho'}(:);
maskr_parent=nc{'mask_rho'}(:);

h_parent=nc{'h'}(:);
f_parent=nc{'f'}(:);
angle_parent=nc{'angle'}(:);
pm_parent=nc{'pm'}(:);

result=close(nc);

hmin = min(min(h_parent));
disp(' ')
disp(['  hmin = ',num2str(hmin)])
%
% Parent indices
%
[Mp,Lp]=size(h_parent);
[igrd_r,jgrd_r]=meshgrid((1:1:Lp),(1:1:Mp));
[igrd_p,jgrd_p]=meshgrid((1:1:Lp-1),(1:1:Mp-1));
[igrd_u,jgrd_u]=meshgrid((1:1:Lp-1),(1:1:Mp));
[igrd_v,jgrd_v]=meshgrid((1:1:Lp),(1:1:Mp-1));
%
% Test if correct 
%
if imin>=imax
  error(['imin >= imax - imin = ',...
         num2str(imin),' - imax = ',num2str(imax)])
end
if jmin>=jmax
  error(['jmin >= jmax - jmin = ',...
         num2str(jmin),' - jmax = ',num2str(jmax)])
end
if jmax>(Mp-1)
  error(['jmax > M - M = ',...
         num2str(Mp-1),' - jmax = ',num2str(jmax)])
end
if imax>(Lp-1)
  error(['imax > L - L = ',...
         num2str(Lp-1),' - imax = ',num2str(imax)])
end
%
% the children indices
%
ipchild=(imin:1/refinecoeff:imax);
jpchild=(jmin:1/refinecoeff:jmax);
irchild=(imin+0.5-0.5/refinecoeff:1/refinecoeff:imax+0.5+0.5/refinecoeff);
jrchild=(jmin+0.5-0.5/refinecoeff:1/refinecoeff:jmax+0.5+0.5/refinecoeff);
[ichildgrd_p,jchildgrd_p]=meshgrid(ipchild,jpchild);
[ichildgrd_r,jchildgrd_r]=meshgrid(irchild,jrchild);
[ichildgrd_u,jchildgrd_u]=meshgrid(ipchild,jrchild);
[ichildgrd_v,jchildgrd_v]=meshgrid(irchild,jpchild);
%
% interpolations
%
disp(' ')
disp(' Do the interpolations...')
lonpchild=interp2(igrd_p,jgrd_p,lonp_parent,ichildgrd_p,jchildgrd_p,'cubic');
latpchild=interp2(igrd_p,jgrd_p,latp_parent,ichildgrd_p,jchildgrd_p,'cubic');
xpchild=interp2(igrd_p,jgrd_p,xp_parent,ichildgrd_p,jchildgrd_p,'cubic');
ypchild=interp2(igrd_p,jgrd_p,yp_parent,ichildgrd_p,jchildgrd_p,'cubic');

lonuchild=interp2(igrd_u,jgrd_u,lonu_parent,ichildgrd_u,jchildgrd_u,'cubic');
latuchild=interp2(igrd_u,jgrd_u,latu_parent,ichildgrd_u,jchildgrd_u,'cubic');
xuchild=interp2(igrd_u,jgrd_u,xu_parent,ichildgrd_u,jchildgrd_u,'cubic');
yuchild=interp2(igrd_u,jgrd_u,yu_parent,ichildgrd_u,jchildgrd_u,'cubic');


lonvchild=interp2(igrd_v,jgrd_v,lonv_parent,ichildgrd_v,jchildgrd_v,'cubic');
latvchild=interp2(igrd_v,jgrd_v,latv_parent,ichildgrd_v,jchildgrd_v,'cubic');
xvchild=interp2(igrd_v,jgrd_v,xv_parent,ichildgrd_v,jchildgrd_v,'cubic');
yvchild=interp2(igrd_v,jgrd_v,yv_parent,ichildgrd_v,jchildgrd_v,'cubic');

lonrchild=interp2(igrd_r,jgrd_r,lonr_parent,ichildgrd_r,jchildgrd_r,'cubic');
latrchild=interp2(igrd_r,jgrd_r,latr_parent,ichildgrd_r,jchildgrd_r,'cubic');
xrchild=interp2(igrd_r,jgrd_r,xr_parent,ichildgrd_r,jchildgrd_r,'cubic');
yrchild=interp2(igrd_r,jgrd_r,yr_parent,ichildgrd_r,jchildgrd_r,'cubic');
maskrold=interp2(igrd_r,jgrd_r,maskr_parent,ichildgrd_r,jchildgrd_r,'nearest');

hchild=interp2(igrd_r,jgrd_r,h_parent,ichildgrd_r,jchildgrd_r,'cubic');
anglechild=interp2(igrd_r,jgrd_r,angle_parent,ichildgrd_r,jchildgrd_r,'cubic');
fchild=interp2(igrd_r,jgrd_r,f_parent,ichildgrd_r,jchildgrd_r,'cubic');
pmchild=interp2(igrd_r,jgrd_r,pm_parent,ichildgrd_r,jchildgrd_r,'cubic');
%
% Create the grid file
%
disp(' ')
disp(' Create the grid file...')
[Mchild,Lchild]=size(latpchild);
create_grid(Lchild,Mchild,child_grd,parent_grd,title)
%
% Fill the grid file
%
disp(' ')
disp(' Fill the grid file...')
nc=netcdf(child_grd,'write');
nc{'refine_coef'}(:)=refinecoeff;
nc{'grd_pos'}(:) = [imin,imax,jmin,jmax];
nc{'lat_u'}(:)=latuchild;
nc{'lon_u'}(:)=lonuchild;
nc{'x_u'}(:)=xuchild;
nc{'y_u'}(:)=yuchild;

nc{'lat_v'}(:)=latvchild;
nc{'lon_v'}(:)=lonvchild;
nc{'x_v'}(:)=xvchild;
nc{'y_v'}(:)=yvchild;

nc{'lat_rho'}(:)=latrchild;
nc{'lon_rho'}(:)=lonrchild;
nc{'x_rho'}(:)=xrchild;
nc{'y_rho'}(:)=yrchild;

nc{'lat_psi'}(:)=latpchild;
nc{'lon_psi'}(:)=lonpchild;
nc{'x_psi'}(:)=xpchild;
nc{'y_psi'}(:)=ypchild;

nc{'hraw'}(1,:,:)=hchild;
nc{'angle'}(:)=anglechild;
nc{'f'}(:)=fchild;
nc{'spherical'}(:)='T';
result=close(nc);
%
%  Compute the metrics
%
disp(' ')
disp(' Compute the metrics...')
[pm,pn,dndx,dmde]=get_metrics(child_grd);
%
%  Add topography
%
disp(' ')
if newtopo == 1
  disp(' Add topography...')
  hnew=add_topo(child_grd,topofile);
else
  disp(' Just interp parent topography...')
  hnew=hchild;
end
%
% Compute the mask
%
%maskrchild=(hnew>=0.);
maskrchild=maskrold;
maskrchild(Mchild,:)=maskrold(Mchild,:);
maskrchild(1,:)=maskrold(1,:);
maskrchild(:,1)=maskrold(:,1);
maskrchild(:,Lchild)=maskrold(:,Lchild);
[maskuchild,maskvchild,maskpchild]=uvp_mask(maskrchild);
%
%  Smooth the topography
%
if newtopo == 1
  hnew = smoothgrid(hnew,hmin,rtarget);
  disp(' ')
  disp(' Connect the topography...')
  [hnew,alpha]=connect_topo(hnew,hchild,nband);
end
%
%  Write it down
%
disp(' ')
disp(' Write it down...')
nc=netcdf(child_grd,'write');
%nc{'alpha'}(:)=alpha;
nc{'h'}(:)=hnew;
nc{'pm'}(:)=pm;
nc{'pn'}(:)=pn;
nc{'dndx'}(:)=dndx;
nc{'dmde'}(:)=dmde;
nc{'mask_u'}(:)=maskuchild;
nc{'mask_v'}(:)=maskvchild;
nc{'mask_psi'}(:)=maskpchild;
nc{'mask_rho'}(:)=maskrchild;
result=close(nc);
disp(' ')
disp(['  Size of the grid:  L = ',...
      num2str(Lchild),' - M = ',num2str(Mchild)])
%
% make a plot
%
disp(' ')
disp(' Do a plot...')
warning off
themask=maskr_parent./maskr_parent;
warning on
pcolor(lonr_parent,latr_parent,h_parent.*themask)
axis image 
colorbar
shading interp
hold on
lonbox=cat(1,lonp_parent(jmin:jmax,imin),  ...
                lonp_parent(jmax,imin:imax)' ,...
                lonp_parent(jmax:-1:jmin,imax),...
                lonp_parent(jmin,imax:-1:imin)' );
latbox=cat(1,latp_parent(jmin:jmax,imin),  ...
                latp_parent(jmax,imin:imax)' ,...
                latp_parent(jmax:-1:jmin,imax),...
                latp_parent(jmin,imax:-1:imin)' );
plot(lonbox,latbox,'k')
loncbox=cat(1,lonpchild(1:Mchild,1),  ...
                lonpchild(Mchild,1:Lchild)' ,...
                lonpchild(Mchild:-1:1,Lchild),...
                lonpchild(1,Lchild:-1:1)' );
latcbox=cat(1,latpchild(1:Mchild,1),  ...
               latpchild(Mchild,1:Lchild)' ,...
                latpchild(Mchild:-1:1,Lchild),...
                latpchild(1,Lchild:-1:1)' );

plot(loncbox,latcbox,'w--')
hold off

figure
warning off
themask=maskrchild./maskrchild;
warning on
pcolor(lonrchild,latrchild,themask.*hnew)
shading interp
axis image 
colorbar
hold on
contour(lonrchild,latrchild,hnew,[100 200 500 1000 2000 4000],'k')
contour(lonrchild,latrchild,hchild,[100 200 500 1000 2000 4000],'k--')
handle=plot_coast('coast.dat');
set(handle,'LineWidth',2)
plot(lonbox,latbox,'k')
plot(loncbox,latcbox,'w--')
hold off
axis([min(min(lonrchild)) max(max(lonrchild)),...
      min(min(latrchild)) max(max(latrchild))])
