%
%=======================================================================
%  This script interpolates initial NetCDF from coarse to fine.  It
%  assumes that the fine resolution NetCDF has been already defined by
%  using program "netcdf/tools/ncxtr3".
%=======================================================================
%

finp='/e1/arango/Damee/grid4/damee4_his_02.nc';
ginp='/d15/arango/scrum/Damee/grid4/damee4_grid_a.nc';

fout='/d15/arango/scrum/Damee/grid7/damee7_ini_a.nc';
gout='/d15/arango/scrum/Damee/grid7/damee7_grid_a.nc';

%  Set-up masking switch.  Activate Land/Sea Masking.

mask=1;

%  Set record index to be processed.

tindex=128;

%  Set interpolation methodology.

method='linear';

%  Interpolate all initial fields.

[lon,lat,f]=trpfld(finp,ginp,gout,'zeta',tindex,mask,method);
if (mask),
  ind=find(~isnan(f) < 1);
  f(ind)=0.0;
end,
status_zeta=nc_write(fout,'zeta',f)

[lon,lat,f]=trpfld(finp,ginp,gout,'ubar',tindex,mask,method);
status_ubar=nc_write(fout,'ubar',f)

[lon,lat,f]=trpfld(finp,ginp,gout,'vbar',tindex,mask,method);
status_vbar=nc_write(fout,'vbar',f)

[lon,lat,f]=trpfld(finp,ginp,gout,'temp',tindex,mask,method);
status_temp=nc_write(fout,'temp',f)

[lon,lat,f]=trpfld(finp,ginp,gout,'salt',tindex,mask,method);
status_salt=nc_write(fout,'salt',f)

[lon,lat,f]=trpfld(finp,ginp,gout,'u',tindex,mask,method);
status_u=nc_write(fout,'u',f)

[lon,lat,f]=trpfld(finp,ginp,gout,'v',tindex,mask,method);
status_v=nc_write(fout,'v',f)

%[lon,lat,f]=trpfld(finp,ginp,gout,'w',tindex,mask,method);
%status_v=nc_write(fout,'w',f)

