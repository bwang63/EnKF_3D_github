%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  compute the OA files of the embedded grid
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all
close all
child_grd='/private/penven/Monterey/mb_l1_safe_grd.nc.1';
month(1:12,1:3)=['jan'; 'feb'; 'mar' ;'apr'; 'may'; 'jun'; ...
                 'jul'; 'aug'; 'sep'; 'oct'; 'nov'; 'dec'];
for i=1:12;

parent_oa=['/disk4/pierrick/OA/MB_L1_LEV/oa_mb_l1_lev_',month(i,:),'94.nc'];
child_oa=['/disk4/pierrick/OA/MB_L2_EMB/oa_mb_l2_emb_lev_',month(i,:),'94.nc'];

%
% Title
%
title=['OA file for the embedded grid :',child_grd,...
' using parent OA file: ',parent_oa];
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
%
% Read in the parent oa file 
%
disp(' ')
disp(' Read in the parent oa file...')
np=netcdf(parent_oa);
latr_parent=np{'lat_rho'}(:);
lonr_parent=np{'lon_rho'}(:);
zout=np{'zout'}(:);
time=np{'time'}(:);
%
% parent indices
%
[Mp,Lp]=size(latr_parent);
[ioa_r,joa_r]=meshgrid((1:1:Lp),(1:1:Mp));
%
% the children indices
%
irchild=(imin+0.5-0.5/refinecoeff:1/refinecoeff:imax+0.5+0.5/refinecoeff);
jrchild=(jmin+0.5-0.5/refinecoeff:1/refinecoeff:jmax+0.5+0.5/refinecoeff);
[ichildoa_r,jchildoa_r]=meshgrid(irchild,jrchild);
%
% Create the oa file
%
disp(' ')
disp(' Create the oa file...')
result=create_oa(child_oa,parent_oa,child_grd,title,zout,time);
%
% Fill the oa file
%
disp(' ')
disp(' Fill the OA file...')
nc=netcdf(child_oa,'write');
nc{'refine_coef'}(:)=refinecoeff;
nc{'grd_pos'}(:) = [imin,imax,jmin,jmax];
%
% interpolations
%
disp(' ')
disp(' Do the interpolations...')
lonrchild=interp2(ioa_r,joa_r,lonr_parent,ichildoa_r,jchildoa_r,'cubic');
latrchild=interp2(ioa_r,joa_r,latr_parent,ichildoa_r,jchildoa_r,'cubic');
nc{'lon_rho'}(:)=lonrchild;
nc{'lat_rho'}(:)=latrchild;
for zindex=1:length(zout)
  disp(['level = ',num2str(zindex)])
  nestvar4d(np,nc,ioa_r,joa_r,ichildoa_r,jchildoa_r,'temp',zindex,1)
  nestvar4d(np,nc,ioa_r,joa_r,ichildoa_r,jchildoa_r,'salt',zindex,1)
end
result=close(nc);
result=close(np);

end;
