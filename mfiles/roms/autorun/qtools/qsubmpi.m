function [status, jobid] = qsubmpi(execfile, rundir, clusterName, pausetime)
% QSUBMPI Submit an MPI job to the queue.
% 
% [status, jobid] = QSUBMPI(execfile, rundir, clusterName, pausetime)
%
% INPUT:
% execfile: the executable file that is submitted.
% rundir: the directory execfile is in.
% clusterName: the cluster/supercomputer on which the model is run.
% pausetime (optional): number of seconds to pause before continuing. 
% 
% OUTPUT:
% status: the return status of qsub, an error is indicated by status > 0.
% jobid: the job ID of the submitted job or NaN if status > 0;

%
% submit a job
% typical output is:
% 'Submitted batch job 58635353'
%
execstr = sprintf('cd %s; sbatch %s', rundir, execfile);
[status, output] = system(execstr);

if status ~= 0
    error('Error submitting the job using "%s".', execstr)
end

tok = regexpi(output, '.* job +(\d+)', 'tokens');

if ~isempty(tok) 
    jobid = str2double(tok{1}{1});
else
    error('Could not parse sbatch output "%s".', output)
end

% do not submit jobs in rapid succession
if nargin < 4
    pause(1)
else
    pause(pausetime)
end

