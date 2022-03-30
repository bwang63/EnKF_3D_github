%
%=======================================================================
%  This script interpolates Climatology NetCDF from coarse to fine.  It
%  assumes that the fine resolution NetCDF has been already defined by
%  using program "netcdf/tools/ncxtr3".
%=======================================================================
%

finp='/d15/arango/scrum/Damee/grid4/damee4_Lclm_a.nc';
ginp='/d15/arango/scrum/Damee/grid4/damee4_grid_a.nc';

fout='/d15/arango/scrum/Damee/grid7/damee7_Lclm_a.nc';
gout='/d15/arango/scrum/Damee/grid7/damee7_grid_a.nc';

%  Set-up masking switch.  Notice that masking is not needed in
%  climatology fields

mask=0;

%  Set record index to zero so all time records are processed.

tindex=0;

%  Set interpolation methodology.

method='linear';

%  Interpolate all climatology fields.

[lon,lat,f]=trpfld(finp,ginp,gout,'temp',tindex,mask,method);
status_temp=nc_write(fout,'temp',f)

[lon,lat,f]=trpfld(finp,ginp,gout,'salt',tindex,mask,method);
status_salt=nc_write(fout,'salt',f)

[lon,lat,f]=trpfld(finp,ginp,gout,'SSH',tindex,mask,method);
status_SSH=nc_write(fout,'SSH',f)

