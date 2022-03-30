%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  compute the climatology of the embedded grid
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


clear all
close all
tic
child_grd='usw15_grid.nc.2';
parent_clim='usw15_Lclm.nc.1';
child_clim='usw15_Lclm.nc.2';

correc=1;  % correc = 1 if we have a different topo in the 
          % child grid then correction will be necessary


%
% Title
%
title=['Climatology file for the embedded grid :',child_clim,...
' using parent forcing file: ',parent_clim];
disp(' ')
disp(title)
%
% Read in the embedded grid
%
disp(' ')
disp(' Read in the embedded grid...')
nc=netcdf(child_grd);
parent_grd=nc.parent_grid(:);
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
%
% Read in the parent climatology file
%
disp(' ')
disp(' Read in the parent climatology file...')
nc = netcdf(parent_clim);
theta_s = nc{'theta_s'}(:);
theta_b = nc{'theta_b'}(:);
Tcline = nc{'Tcline'}(:);
N = length(nc('s_rho'));
ttime = nc{'tclm_time'}(:);
tcycle = nc{'tclm_time'}.cycle_length(:);
stime = nc{'sclm_time'}(:);
scycle = nc{'sclm_time'}.cycle_length(:);
utime = nc{'ssh_time'}(:);
ucycle = nc{'ssh_time'}.cycle_length(:);
vtime = nc{'ssh_time'}(:);
vcycle = nc{'ssh_time'}.cycle_length(:);
sshtime = nc{'ssh_time'}(:);
sshcycle = nc{'ssh_time'}.cycle_length(:);
result=close(nc);
%
% Create the climatology file
%
disp(' ')
disp(' Create the climatology file...')
ncclim=create_climfile(child_clim,child_grd,parent_clim,title,...
                     theta_s,theta_b,Tcline,N,...
                     ttime,stime,utime,vtime,sshtime,...
                     tcycle,scycle,ucycle,vcycle,sshcycle,'clobber');

disp(' !!! encountered a RETURN command !!! ')
return
%
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
np=netcdf(parent_clim);

disp('u...')
for tindex=1:length(utime)
  for zindex=1:N
    nestvar4d(np,ncclim,igrd_u,jgrd_u,ichildgrd_u,jchildgrd_u,'u',zindex,tindex)
  end
end
disp('v...')
for tindex=1:length(vtime)
  for zindex=1:N
    nestvar4d(np,ncclim,igrd_v,jgrd_v,ichildgrd_v,jchildgrd_v,'v',zindex,tindex)
  end
end
disp('zeta...')
for tindex=1:length(sshtime)
  nestvar3d(np,ncclim,igrd_r,jgrd_r,ichildgrd_r,jchildgrd_r,'SSH',tindex)
end
disp('ubar...')
for tindex=1:length(utime)
  nestvar3d(np,ncclim,igrd_u,jgrd_u,ichildgrd_u,jchildgrd_u,'ubar',tindex)
end
disp('vbar...')
for tindex=1:length(vtime)
  nestvar3d(np,ncclim,igrd_v,jgrd_v,ichildgrd_v,jchildgrd_v,'vbar',tindex)
end
disp('temp...')
for tindex=1:length(ttime)
  for zindex=1:N
    nestvar4d(np,ncclim,igrd_r,jgrd_r,ichildgrd_r,jchildgrd_r,'temp',zindex,tindex)
  end
end
disp('salt...')
for tindex=1:length(stime)
  for zindex=1:N
    nestvar4d(np,ncclim,igrd_r,jgrd_r,ichildgrd_r,jchildgrd_r,'salt',zindex,tindex)
  end
end

result=close(np);
result=close(ncclim);
%
%  Vertical corrections
%
if (correc==1)
disp(' ')
disp(' Vertical corrections... ')

nc=netcdf(child_clim,'write');
theta_s = nc{'theta_s'}(:);
theta_b = nc{'theta_b'}(:);
Tcline = nc{'Tcline'}(:);
grd_file = nc.grd_file(:);
ng=netcdf(grd_file);
hold=squeeze(ng{'hraw'}(1,:,:));
hnew=ng{'h'}(:);
result=close(ng);

disp('u...')
for tindex=1:length(utime)
disp(['u - step: ',num2str(tindex),' - total :',num2str(length(utime))])
nc{'u'}(tindex,:,:,:)=rbuild(squeeze(nc{'u'}(tindex,:,:,:)),theta_s,theta_b,...
                          Tcline,hold,theta_s,theta_b,Tcline,hnew,N,'u');
end
disp('v...')
for tindex=1:length(vtime)
disp(['v - step: ',num2str(tindex),' - total :',num2str(length(vtime))])
nc{'v'}(tindex,:,:,:)=rbuild(squeeze(nc{'v'}(tindex,:,:,:)),theta_s,theta_b,...
                          Tcline,hold,theta_s,theta_b,Tcline,hnew,N,'v');
end
disp('temp...')
for tindex=1:length(ttime)
disp(['temp - step: ',num2str(tindex),' - total :',num2str(length(ttime))])
nc{'temp'}(tindex,:,:,:)=rbuild(squeeze(nc{'temp'}(tindex,:,:,:)),theta_s,theta_b,...
                          Tcline,hold,theta_s,theta_b,Tcline,hnew,N,'r');
end
disp('salt...')
for tindex=1:length(stime)
disp(['salt - step: ',num2str(tindex),' - total :',num2str(length(stime))])
nc{'salt'}(tindex,:,:,:)=rbuild(squeeze(nc{'salt'}(tindex,:,:,:)),theta_s,theta_b,...
                          Tcline,hold,theta_s,theta_b,Tcline,hnew,N,'r');
end
end
%
% Make a plot
%
disp(' ')
disp(' Make a plot...')
test_clim(child_clim,'temp',6)
toc
