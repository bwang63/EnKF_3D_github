%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  compute the forcing file of the embedded grid
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all
close all
parent_grd='calcofi_grid.nc.1';
child_grd ='calcofi_grid.nc.2';
parent_frc='forc-sb-rsmSep97-Sep01.nc.1';
child_frc ='forc-sb-rsmSep97-Sep01.nc.2';
%
% Title
%
title=['Forcing file for the embedded grid :',child_frc,...
' using parent forcing file: ',parent_frc];
disp(' ')
disp(title)
%
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
%
% Read in the parent forcing file
%
disp(' ')
disp(' Read in the parent forcing file...')
nc = netcdf(parent_frc);

smst = nc{'sms_time'}(:);
smsc = nc{'sms_time'}.cycle_length(:);
shft = nc{'shf_time'}(:);
shfc = nc{'shf_time'}.cycle_length(:);
swft = nc{'swf_time'}(:);
swfc = nc{'swf_time'}.cycle_length(:);
sstt = nc{'sst_time'}(:);
sstc = nc{'sst_time'}.cycle_length(:);
srft = nc{'srf_time'}(:);
srfc = nc{'srf_time'}.cycle_length(:);

result=close(nc);
%
% Create the forcing file
%
disp(' ')
disp(' Create the forcing file...')
create_forcing(child_frc,parent_frc,child_grd,title,smst,...
                         shft,swft,srft,sstt,smsc,...
                         shfc,swfc,srfc,sstc)
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
                        
np=netcdf(parent_frc);
nc=netcdf(child_frc,'write');
disp('the wind...')
for tindex=1:length(smst)
  nestvar3d(np,nc,igrd_u,jgrd_u,ichildgrd_u,jchildgrd_u,'sustr',tindex)
  nestvar3d(np,nc,igrd_v,jgrd_v,ichildgrd_v,jchildgrd_v,'svstr',tindex)
end
disp('heat flux...')
for tindex=1:length(shft)
  nestvar3d(np,nc,igrd_r,jgrd_r,ichildgrd_r,jchildgrd_r,'shflux',tindex)
end
disp('freshwater flux...')
for tindex=1:length(swft)
  nestvar3d(np,nc,igrd_r,jgrd_r,ichildgrd_r,jchildgrd_r,'swflux',tindex)
end
disp('sst correction...')
for tindex=1:length(sstt)
  nestvar3d(np,nc,igrd_r,jgrd_r,ichildgrd_r,jchildgrd_r,'SST',tindex)
  nestvar3d(np,nc,igrd_r,jgrd_r,ichildgrd_r,jchildgrd_r,'dQdSST',tindex)
end
disp('shortwave radiation...')
for tindex=1:length(srft)
  nestvar3d(np,nc,igrd_r,jgrd_r,ichildgrd_r,jchildgrd_r,'swrad',tindex)
end
result=close(np);
result=close(nc);
disp(' ')
disp(' Done ')
%
% Make a plot
%
disp(' ')
disp(' Make a plot...')
test_forcing(child_frc,'shflux',[1 6],3)
