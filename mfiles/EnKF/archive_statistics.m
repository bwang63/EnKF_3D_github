% function outassim = archive_statistics(kfparams,assiminfo,irec)
%
% save assimilation results in *.mat file
%
% by Jiatang Hu, Jan 2010
%
% incorporated within romassim, Feb 2010

function outassim = archive_statistics(kfparams,assiminfo,irec)
    
outdir = kfparams.outdir;

runcase = kfparams.runcase;

outassim.outprefix = runcase;

outassim.rmse_f = assiminfo.rmse_f;
outassim.corr_f = assiminfo.corr_f;
outassim.bias_f = assiminfo.bias_f; 
outassim.mad_f  = assiminfo.mad_f;

outassim.rmse_a = assiminfo.rmse_a;
outassim.corr_a = assiminfo.corr_a;
outassim.bias_a = assiminfo.bias_a; 
outassim.mad_a  = assiminfo.mad_a; 

% new code:
fileout = fullfile(outdir, sprintf([runcase,'_kfparams_assimstep_%04d.mat'], irec));
save(fileout, 'kfparams', 'outassim','-v7.3')
% /PM
return

