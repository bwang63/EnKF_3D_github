function jobstatus = qjobstatus(jobid, clusterName)
% QJOBSTATUS Return the status of a queue job.
% QJOBSTATUS(jobid) Returns the status of the queue job with job ID jobid 
% or '' if the job does not appear in the queue.
% QJOBSTATUS(jobid, clusterName) may incorporate machine-dependent commands
% based on clusterName.

jobstatus = cell(1,numel(jobid));
for ijob = 1:numel(jobid)
    [status rawout] = system(sprintf('squeue --noheader --job=%d --format="%%t"', jobid(ijob)));
    if status == 0
        jobstatus{ijob} = strip(rawout);
    else
        jobstatus{ijob} = '';
    end
end

