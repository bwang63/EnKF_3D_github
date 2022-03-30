%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Compute initial file of the embedded grid
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all
close all

option = 'nena1d.1';

switch option
  
  case 'nena1d.1'
    
    parent_grd = '../in/roms_nena_grid_5.nc';
    child_grd = '../in/roms_nena1d_grid_1.nc';
    parent_ini = '../in/nena.nc';
    child_ini = '../in/nena1d_1.nc';
    doplots = 0;

  case 'manu'

    parent_grd='calcofi_grid.nc.1';
    child_grd ='calcofi_grid.nc.2';
    parent_ini='calcofi_init.nc.1';
    child_ini ='calcofi_init.nc.2';
    tindex=1;

end

% Title
%
title=[ 'Initial file for the embedded grid :',child_ini,...
      ' using parent initial file: ',parent_ini];
disp(' ')
disp(title)

% Read in the embedded grid
%
disp(' ')
disp(' Read in the embedded grid...')
nc=netcdf(child_grd);
%parent_grd=nc.parent_grid(:);
imin=nc{'grd_pos'}(1);
imax=nc{'grd_pos'}(2);
jmin=nc{'grd_pos'}(3);
jmax=nc{'grd_pos'}(4);
refinecoeff=nc{'refine_coef'}(:);
result=close(nc);
nc=netcdf(parent_grd);
Lp=length(nc('xi_rho'));
Mp=length(nc('eta_rho'));
result=close(nc);

% Read in the parent initial file
%
disp(' ')
disp(' Read in the parent initial file...')
nc = netcdf(parent_ini);
theta_s = nc{'theta_s'}(:);
theta_b = nc{'theta_b'}(:);
Tcline = nc{'Tcline'}(:);
N = length(nc('s_rho'));
time = nc{'ocean_time'}(tindex);
result=close(nc);

% Create the initial file
%
disp(' ')
disp(' Create the initial file...')
ncini=create_inifile(child_ini,child_grd,parent_ini,title,...
                     theta_s,theta_b,Tcline,N,time,'clobber');

% parent indices
%
[igrd_r,jgrd_r]=meshgrid((1:1:Lp),(1:1:Mp));
[igrd_p,jgrd_p]=meshgrid((1:1:Lp-1),(1:1:Mp-1));
[igrd_u,jgrd_u]=meshgrid((1:1:Lp-1),(1:1:Mp));
[igrd_v,jgrd_v]=meshgrid((1:1:Lp),(1:1:Mp-1));
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
np=netcdf(parent_ini);
disp('u...')
for zindex=1:N
  nestvar4d(np,ncini,igrd_u,jgrd_u,ichildgrd_u,jchildgrd_u,'u',zindex,tindex)
end
disp('v...')
for zindex=1:N
  nestvar4d(np,ncini,igrd_v,jgrd_v,ichildgrd_v,jchildgrd_v,'v',zindex,tindex)
end
disp('zeta...')
nestvar3d(np,ncini,igrd_r,jgrd_r,ichildgrd_r,jchildgrd_r,'zeta',tindex)
disp('ubar...')
nestvar3d(np,ncini,igrd_u,jgrd_u,ichildgrd_u,jchildgrd_u,'ubar',tindex)
disp('vbar...')
nestvar3d(np,ncini,igrd_v,jgrd_v,ichildgrd_v,jchildgrd_v,'vbar',tindex)
disp('temp...')
for zindex=1:N
  nestvar4d(np,ncini,igrd_r,jgrd_r,ichildgrd_r,jchildgrd_r,'temp',zindex,tindex)
end
disp('salt...')
for zindex=1:N
  nestvar4d(np,ncini,igrd_r,jgrd_r,ichildgrd_r,jchildgrd_r,'salt',zindex,tindex)
end

result=close(np);
result=close(ncini);

%
%  Vertical corrections
%
disp(' ')
disp(' Vertical corrections... ')

nc=netcdf(child_ini,'write');
theta_s = nc{'theta_s'}(:);
theta_b = nc{'theta_b'}(:);
Tcline = nc{'Tcline'}(:);
grd_file = nc.grd_file(:);
ng=netcdf(grd_file);
hold=squeeze(ng{'hraw'}(1,:,:));
hnew=ng{'h'}(:);
result=close(ng);
disp('u...')
nc{'u'}(1,:,:,:)=rbuild(squeeze(nc{'u'}(1,:,:,:)),theta_s,theta_b,...
                          Tcline,hold,theta_s,theta_b,Tcline,hnew,N,'u');
disp('v...')
nc{'v'}(1,:,:,:)=rbuild(squeeze(nc{'v'}(1,:,:,:)),theta_s,theta_b,...
                          Tcline,hold,theta_s,theta_b,Tcline,hnew,N,'v');
disp('temp...')
nc{'temp'}(1,:,:,:)=rbuild(squeeze(nc{'temp'}(1,:,:,:)),theta_s,theta_b,...
                          Tcline,hold,theta_s,theta_b,Tcline,hnew,N,'r');
disp('salt...')
nc{'salt'}(1,:,:,:)=rbuild(squeeze(nc{'salt'}(1,:,:,:)),theta_s,theta_b,...
                          Tcline,hold,theta_s,theta_b,Tcline,hnew,N,'r');
result=close(nc);

%
% Make a plot
%
disp(' ')
disp(' Make a plot...')
test_clim(child_ini,'temp',1)

