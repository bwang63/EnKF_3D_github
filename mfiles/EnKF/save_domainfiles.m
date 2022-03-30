function save_domainfiles(matfilesdir, gridname, grdm)
% save the grid information temporally in order to be used later 
N=grdm.N;

mask = grdm.mask_rho;
mask(mask == 0) = nan;
save(fullfile(matfilesdir, sprintf('data_domain_mask_%s.mat',gridname) ), 'mask') % mask of one layer

% create a domain mask for whole water column
maskwc = permute(repmat(mask,[1,1,N]),[3,1,2]);
save(fullfile(matfilesdir, sprintf('data_domain_maskwc_%s.mat',gridname) ),'maskwc') % mask of one layer

lon = grdm.lon_rho;
lat = grdm.lat_rho;
save(fullfile(matfilesdir, sprintf('data_domain_grid_%s.mat',gridname) ), 'lat', 'lon')

bathymetry = grdm.h;
save(fullfile(matfilesdir, sprintf('data_domain_bathymetry_%s.mat',gridname)),'bathymetry')

srho = grdm.s_rho;
save(fullfile(matfilesdir, sprintf('data_domain_srho_%s.mat',gridname)),'srho')

hc = grdm.hc;
save(fullfile(matfilesdir, sprintf('data_domain_hc_%s.mat',gridname)),'hc')

rhostretch = grdm.Cs_r;
save(fullfile(matfilesdir, sprintf('data_domain_rhostretch_%s.mat',gridname)),'rhostretch')

