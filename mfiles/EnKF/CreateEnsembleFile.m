% function CreateEnsembleFile(kfparams,irec)
%
% create netCDF files to save assimilation results
%
% by Jiatang Hu, Mar 2010
%
% incorporated within romassim, Mar 2010

function CreateEnsembleFile(kfparams,assimstep)
    
outdir = kfparams.outdir;
if ~exist(outdir,'dir')
    mkdir(outdir);
end

runcase = kfparams.runcase;

%
% layers involved in data assimilation
%
nlayer = kfparams.nz;

% new:
fileout = fullfile(outdir, sprintf('%s_assimstep_%04d.nc', runcase, assimstep));
rnc_CreateEnsembleFile_v1(kfparams,fileout,nlayer); % works for new netcdf library
% /LY

return
