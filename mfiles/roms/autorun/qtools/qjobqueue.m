function jobstatus = qjobqueue(jobid, clusterName)
% QJOBQUEUE Return queue-related information of a queue job.
% QJOBQUEUE(jobid) Returns the host of the queue job with job ID jobid 
% or '' if the job does not appear in the queue.
% QJOBQUEUE(jobid, clusterName) may incorporate machine-dependent commands
% based on clusterName.

jobstatus = cell(1,numel(jobid));
for ijob = 1:numel(jobid)
    [status rawout] = system(sprintf('squeue --noheader --job=%d --format="%%B"', jobid(ijob)));
    if status == 0
        jobstatus{ijob} = strip(rawout);
    else
        jobstatus{ijob} = '';
    end
end

