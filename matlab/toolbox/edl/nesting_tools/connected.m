%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% connect the parent and child topographies 
% the variations are smoothed on nband points
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all
close all
parent_grd='/private/penven/Monterey/mb_l1_safe_grd.nc';
child_grd='/private/penven/Monterey/mb_l1_safe_grd.nc.1';
nband=40;
%
% Read in the parent grid
%
disp(' ')
disp(' Read in the parent grid...')
nc=netcdf(parent_grd);
latr_parent=nc{'lat_rho'}(:);
lonr_parent=nc{'lon_rho'}(:);
maskr_parent=nc{'mask_rho'}(:);
h_parent=nc{'h'}(:);
result=close(nc);
hmin = min(min(h_parent));
disp(['hmin = ',num2str(hmin)])
%
% Read in the child grid
%
disp(' ')
disp(' Read in the child grid...')
nc=netcdf(child_grd);
latrchild=nc{'lat_rho'}(:);
lonrchild=nc{'lon_rho'}(:);
maskrchild=nc{'mask_rho'}(:);
hchild=nc{'h'}(:);
imin=nc{'grd_pos'}(1);
imax=nc{'grd_pos'}(2);
jmin=nc{'grd_pos'}(3);
jmax=nc{'grd_pos'}(4);
refinecoeff=nc{'refine_coef'}(:);
result=close(nc);
hmin = min(min(hchild));
disp(['hmin = ',num2str(hmin)])
%
% interpole the parent top on the child grid
%
[Mp,Lp]=size(h_parent);
[igrd_r,jgrd_r]=meshgrid((1:1:Lp),(1:1:Mp));
irchild=(imin+0.5-0.5/refinecoeff:1/refinecoeff:imax+0.5+0.5/refinecoeff);
jrchild=(jmin+0.5-0.5/refinecoeff:1/refinecoeff:jmax+0.5+0.5/refinecoeff);
[ichildgrd_r,jchildgrd_r]=meshgrid(irchild,jrchild);
hparent=interp2(igrd_r,jgrd_r,h_parent,ichildgrd_r,jchildgrd_r,'cubic');
%
% connect
%
disp(' ')
disp(' Connect the topography...')
[hnew,alpha]=connect_topo(hchild,hparent,nband);
%
% make a plot
%
disp(' ')
disp(' Do a plot...')
v=[100 200 300 400 500 1000 2000 3000 4000];
contour(lonrchild,latrchild,hnew,v,'r')
hold on
contour(lonrchild,latrchild,hchild,v,'b')
contour(lonrchild,latrchild,hparent,v,'g')
handle=plot_coast('coast.dat');
set(handle,'LineWidth',2)
bounddomain(lonrchild,latrchild);
hold off
axis image
axis([min(min(lonrchild)) max(max(lonrchild)),...
      min(min(latrchild)) max(max(latrchild))])
      
disp(' ')
save_h = input('save h ? (y /n)','s');

if (save_h=='y')
  disp(' ')
  disp(' Write it down...')
  nc=netcdf(child_grd,'write');
  nc{'h'}(:)=hnew;
  result=close(nc);
end
