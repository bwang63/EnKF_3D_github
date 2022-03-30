function out = get_forecastens_innovation_full_hisfile(kfparams,datadates,ncdir,hisfiles,D)
% extract model forecast ensemble (only for observed variable)
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
    
    filehis=fullfile(ncdir,hisfiles{i_ens});
    [ncdir_his,filename_his,fileext] = fileparts(filehis);
    fhis = roms_getfilenames(ncdir_his,[filename_his,fileext]);
    ctlhis = rnt_timectl(fhis,'ocean_time',datevec(kfparams.refdate));
    
    for idate = 1:numel(datadates)
        timeidx = find(ctlhis.datenum==datadates(idate));
        if isempty(timeidx)
            warning('No corresponding date of %s was found in history file \n', datestr(datadates(idate)))
        end
        
        ncfile =  ctlhis.file{ctlhis.fileind(timeidx)};
        nc_model = netcdf(ncfile);
        
        for ivar = 1:numel(obsvarnames)
            i1 = icount;
            i2 = icount + n_obs(idate,ivar) - 1;
            icount = icount + n_obs(idate,ivar);
            
            index = D.Lgrid_3D(i1:i2);
            varname = obsvarnames{ivar};
            if numel(size(nc_model{varname}))==3 % for variable w/o vertical dimension, i.e., SSH
                tempr = nc_model{varname}(ctlhis.ind(timeidx),:,:);
                index = index - nx*ny*(nz-1);
            else
                tempr = nc_model{varname}(ctlhis.ind(timeidx),:,:,:);
                tempr = permute(tempr,[2,3,1]);
            end
            
            out(i1:i2,i_ens) = tempr(index(:));
        end
        close(nc_model)
    end
end



