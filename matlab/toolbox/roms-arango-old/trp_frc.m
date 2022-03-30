%
%=======================================================================
%  This script interpolates Forcing NetCDF from coarse to fine.  It
%  assumes that the fine resolution NetCDF has been already defined by
%  using program "netcdf/tools/ncxtr3".
%=======================================================================
%

finp='/d15/arango/scrum/Damee/grid4/damee4_coads.nc';
ginp='/d15/arango/scrum/Damee/grid4/damee4_grid_a.nc';

fout='/d15/arango/scrum/Damee/grid7/damee7_coads.nc';
gout='/d15/arango/scrum/Damee/grid7/damee7_grid_a.nc';

%  Set-up masking switch.  Notice that masking is not needed in forcing
%  fields.

mask=0;

%  Set record index to zero so all time records are processed.

tindex=0

%  Set interpolation methodology.

method='linear';

%  Interpolate all forcing fields.

[lon,lat,f]=trpfld(finp,ginp,gout,'sustr',tindex,mask,method);
status_sustr=nc_write(fout,'sustr',f)

[lon,lat,f]=trpfld(finp,ginp,gout,'svstr',tindex,mask,method);
status_svstr=nc_write(fout,'svstr',f)

[lon,lat,f]=trpfld(finp,ginp,gout,'shflux',tindex,mask,method);
status_shflux=nc_write(fout,'shflux',f)

[lon,lat,f]=trpfld(finp,ginp,gout,'swflux',tindex,mask,method);
status_swflux=nc_write(fout,'swflux',f)

[lon,lat,f]=trpfld(finp,ginp,gout,'SST',tindex,mask,method);
status_SST=nc_write(fout,'SST',f)

[lon,lat,f]=trpfld(finp,ginp,gout,'dQdSST',tindex,mask,method);
status_dQdSST=nc_write(fout,'dQdSST',f)

[lon,lat,f]=trpfld(finp,ginp,gout,'swrad',tindex,mask,method);
status_swrad=nc_write(fout,'swrad',f)

