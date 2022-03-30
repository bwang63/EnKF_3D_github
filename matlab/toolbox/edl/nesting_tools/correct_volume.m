%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% correct the volume of the child grid to be
% the same as the parent grid
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all
close all
child_grd='nestgrid1.nc';
puissance=4;
%
% Read in the children grid
%
disp(' ')
disp(' Read in the children grid...')
nc=netcdf(child_grd);
maskp=nc{'mask_psi'}(:);
[M,L]=size(maskp);
Mp=M+1;
Lp=L+1;
clear maskp
imin=nc{'grd_pos'}(1);
imax=nc{'grd_pos'}(2);
jmin=nc{'grd_pos'}(3);
jmax=nc{'grd_pos'}(4);
parent_grd=nc.parent_grid(:);
mask=nc{'mask_rho'}(2:M,2:L);
hnew=nc{'h'}(2:M,2:L);
hold=hnew;
pm=nc{'pm'}(2:M,2:L);
pn=nc{'pn'}(2:M,2:L);
alpha=nc{'alpha'}(2:M,2:L);
hcoarse=nc{'hraw'}(1,2:M,2:L);
result=close(nc);
%
% Read in the parent grid
%
disp(' ')
disp(' Read in the parent grid...')
nc=netcdf(parent_grd);
mask_par=nc{'mask_rho'}(jmin+1:jmax,imin+1:imax);
h_par=nc{'h'}(jmin+1:jmax,imin+1:imax);
pm_par=nc{'pm'}(jmin+1:jmax,imin+1:imax);
pn_par=nc{'pn'}(jmin+1:jmax,imin+1:imax);
result=close(nc);
ds_par=1./(pm_par.*pn_par);
v_par=h_par.*ds_par;
V_par=sum(sum(v_par.*mask_par));
%
% Correct the volume
%
ds_child=1./(pm.*pn);
epsilon=1;
i=0;
disp(' ')
disp('  Iterative volume correction... ')
hmin=min(min(hnew));
themin=(hnew==hmin);
while abs(epsilon)>1.e-20
  i=i+1;
  v_child=hnew.*ds_child;
  V_child=sum(sum(v_child.*mask));
  epsilon=(V_par-V_child)/V_child;
  hnew=hnew+(1-alpha.^puissance).*epsilon.*v_child./ds_child;
  hnew(themin)=hmin;
end

v_child=hnew.*ds_child;
V_child=sum(sum(v_child.*mask));
disp(' ')
disp([num2str(i),' iterations - epsilon=',...
num2str(epsilon)])
disp([' Volume coarse = ', num2str(V_par)])
disp([' Volume fine   = ', num2str(V_child)])
disp([' hmin coarse = ', num2str(hmin)])
disp([' hmin fine   = ', num2str(min(min(hnew)))])
%
%  Write the new topo down
%
disp(' ')
disp(' Write the new topo down...')
nc=netcdf(child_grd,'write');
%nc{'h'}(2:M,2:L)=hnew;
result=close(nc);
%
%  Make a plot
%
vec=(0:250:5000);
contour(hcoarse,vec,'k')
hold on
contour(hnew,vec,'r')
contour(hold,vec,'g')
hold off
figure
pcolor(hnew)
caxis([0 5000])
colorbar
shading interp
figure
pcolor(hold)
caxis([0 5000])
colorbar
shading interp




