function [status, message] = qdel(jobid, clusterName)
% QDEL Cancel a queue job.
% 
% QDEL(jobid) cancels the queue job with job ID jobid.
% QDEL(jobid, clusterName) cancels the queue job with job ID jobid, 
% with machine-dependent commands based on clusterName.

[status, message] = system(sprintf('scancel %d', jobid(ijob)));

