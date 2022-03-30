%
%=======================================================================
%  This script interpolates GRID NetCDF from coarse to fine.  It assumes
%  that the fine resolution NetCDF has been already generated from
%  "gridpak".
%=======================================================================
%

finp='/d15/arango/scrum/Damee/grid4/damee4_grid_a.nc';
ginp='/d15/arango/scrum/Damee/grid4/damee4_grid_a.nc';

fout='/d15/arango/scrum/Damee/grid7/damee7_grid_a.nc';
gout='/d15/arango/scrum/Damee/grid7/damee7_grid_a.nc';

%  Set-up masking switch.  Notice that masking is not needed in GRID
%  fields.

mask=0;

%  Set record index to zero since there are not time records.

tindex=0;

%  Set interpolation methodology.

method='linear';

%  Interpolate relevant grid fields.

[rlon,rlat,h]=trpfld(finp,ginp,gout,'h',tindex,mask,method);
status_h=nc_write(fout,'h',h)

[rlon,rlat,rmask]=trpfld(finp,ginp,gout,'mask_rho',tindex,mask,method);
ind=find(rmask < 1);
rmask(ind)=0.0;
status_rmask=nc_write(fout,'mask_rho',rmask)

[plon,plat,pmask]=trpfld(finp,ginp,gout,'mask_psi',tindex,mask,method);
ind=find(pmask < 1);
pmask(ind)=0.0;
status_pmask=nc_write(fout,'mask_psi',pmask)

[ulon,ulat,umask]=trpfld(finp,ginp,gout,'mask_u',tindex,mask,method);
ind=find(umask < 1);
umask(ind)=0.0;
status_umask=nc_write(fout,'mask_u',umask)

[vlon,vlat,vmask]=trpfld(finp,ginp,gout,'mask_v',tindex,mask,method);
ind=find(vmask < 1);
vmask(ind)=0.0;
status_vmask=nc_write(fout,'mask_v',vmask)
