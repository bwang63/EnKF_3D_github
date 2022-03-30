%  This script add sea surface salinity (SSS) to an existing FORCING
%  NetCDF file.  The SSS will for the salt correction flux in the
%  model.

global IPRINT

IPRINT=0;
IWRITE=1;
IPLOT=1;

Fname='/n2/arango/Damee/grid6/damee6_coads.nc';
Gname='/n2/arango/Damee/grid6/damee6_grid_c.nc';

jan='/n2/arango/Damee/grid6/OA/oa6_lev_jan.nc';
feb='/n2/arango/Damee/grid6/OA/oa6_lev_feb.nc';
mar='/n2/arango/Damee/grid6/OA/oa6_lev_mar.nc';
apr='/n2/arango/Damee/grid6/OA/oa6_lev_apr.nc';
may='/n2/arango/Damee/grid6/OA/oa6_lev_may.nc';
jun='/n2/arango/Damee/grid6/OA/oa6_lev_jun.nc';
jul='/n2/arango/Damee/grid6/OA/oa6_lev_jul.nc';
aug='/n2/arango/Damee/grid6/OA/oa6_lev_aug.nc';
sep='/n2/arango/Damee/grid6/OA/oa6_lev_sep.nc';
oct='/n2/arango/Damee/grid6/OA/oa6_lev_oct.nc';
nov='/n2/arango/Damee/grid6/OA/oa6_lev_nov.nc';
dec='/n2/arango/Damee/grid6/OA/oa6_lev_dec.nc';

%---------------------------------------------------------------------
%  Get domain dimension.
%---------------------------------------------------------------------

s=nc_read(jan,'salt');
[Im,Jm,Km]=size(s);

rlon=nc_read(Gname,'lon_rho');
rlat=nc_read(Gname,'lat_rho');
rmask=nc_read(Gname,'mask_rho');
ind=find(rmask<0.5);

%---------------------------------------------------------------------
%  Read in sea surface salinity from OA files.
%---------------------------------------------------------------------

s=nc_read(jan,'salt');  SSS(:,:, 1)=s(:,:,Km);
s=nc_read(feb,'salt');  SSS(:,:, 2)=s(:,:,Km);
s=nc_read(mar,'salt');  SSS(:,:, 3)=s(:,:,Km);
s=nc_read(apr,'salt');  SSS(:,:, 4)=s(:,:,Km);
s=nc_read(may,'salt');  SSS(:,:, 5)=s(:,:,Km);
s=nc_read(jun,'salt');  SSS(:,:, 6)=s(:,:,Km);
s=nc_read(jul,'salt');  SSS(:,:, 7)=s(:,:,Km);
s=nc_read(aug,'salt');  SSS(:,:, 8)=s(:,:,Km);
s=nc_read(sep,'salt');  SSS(:,:, 9)=s(:,:,Km);
s=nc_read(oct,'salt');  SSS(:,:,10)=s(:,:,Km);
s=nc_read(nov,'salt');  SSS(:,:,11)=s(:,:,Km);
s=nc_read(dec,'salt');  SSS(:,:,12)=s(:,:,Km);

%---------------------------------------------------------------------
%  Write out sea surface salinity into FORCING NetCDF file.
%---------------------------------------------------------------------

if (IWRITE),

  Tsss=15:30:345;
  [status]=wrt_sss(Fname,SSS,Tsss);

end,

%---------------------------------------------------------------------
%  Plot sea surface salinity.
%---------------------------------------------------------------------

if (IPLOT),

  for n=1:12,
    figure;
    sss=reshape(SSS(:,:,n),Im,Jm);
    if (~isempty(ind)), sss(ind)=NaN; end,
    pcolor(rlon,rlat,sss); shading interp; colorbar;
    title(['Time Record: ',num2str(n)]);
  end,

end,
