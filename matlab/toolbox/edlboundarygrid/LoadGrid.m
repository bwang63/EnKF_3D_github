function grid=LoadGrid(gridfile);

nc=netcdf(gridfile);
grid.lonr=nc{'lon_rho'}(:)';
grid.latr=nc{'lat_rho'}(:)';
grid.maskr=nc{'mask_rho'}(:)';
grid.h=nc{'h'}(:)';
grid.hraw=nc{'hraw'}(1,:,:)';
