function out = get_forecastens_innovation_full_rst(kfparams,timeind,ncdir,ncfiles,D)
% extract model forecast ensemble (only for observed variables in observed grid cells)
%

nen = kfparams.nen;
nx = kfparams.nx;
ny = kfparams.ny;
nz = kfparams.nz;
%
n_obs = kfparams.n_obs;
nobs = sum(n_obs(:));
%
obsvarnames = kfparams.obsvarname;

%
% read forecast ensemble of state variables from ncfiles
%
out = zeros(nobs,nen);
for i_ens = 1:nen
    icount = 1;
    nc_model = netcdf(fullfile(ncdir,ncfiles{i_ens}));
    for ivar = 1:numel(obsvarnames)     
        i1 = icount;
        i2 = icount + n_obs(ivar) - 1;
        icount = icount + n_obs(ivar);
        
        index = D.Lgrid_3D(i1:i2);
        varname = obsvarnames{ivar};
        if numel(size(nc_model{varname}))==3 % for variable w/o vertical dimension, i.e., SSH
            tempr = nc_model{varname}(timeind,:,:);
            index = index - nx*ny*(nz-1);
        else
            tempr = nc_model{varname}(timeind,:,:,:);
            tempr = permute(tempr,[2,3,1]);
        end

        out(i1:i2,i_ens) = tempr(index(:));
    end
    close(nc_model)
end
