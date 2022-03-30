function [status, jobid] = qsubmpi(execfile, rundir,clusterName)

% Submits an MPI job to the queue and returns its status and job ID.
% 
% INPUT:
% execfile: the executable file that is submitted.
% rundir: the directory execfile is in.
% clusterName: the cluster/supercomputer on which the model is run
% 
% OUTPUT:
% status: the return status of qsub, an error is indicated by status > 0.
% jobid: the job ID of the submitted job or NaN if status > 0;

%% Users have to setup their command for a new cluster
switch lower(clusterName)
    case 'graham'
        % the command to check job status in graham (a cluster in computecanada) is:
        % squeue -u username
        execstr1 = 'squeue -u wangb63'; % wangb63 is the user name in graham
        
        % the regular expression of output information from the cluster
        % the typical output in graham is:
        %
        % '            JOBID     USER              ACCOUNT           NAME  ST  TIME_LEFT NODES CPUS TRES_PER_N MIN_MEM NODELIST (REASON)
        % 58633330  wangb63   rrg-kfennel-ab_cpu matlab_EnKF_2k  PD   20:45:00     1    1        N/A     60G  (Priority)
        % 58634351  wangb63   rrg-kfennel-ab_cpu EnKF_UPW_2kfil  PD   10:00:00     1    8        N/A   2000M  (Priority)
        % 58634352  wangb63   rrg-kfennel-ab_cpu EnKF_UPW_2kfil  PD   10:00:00     1    8        N/A   2000M  (Priority)
        % 58634354  wangb63   rrg-kfennel-ab_cpu EnKF_UPW_2kfil  PD   10:00:00     1    8        N/A   2000M  (Priority)
        % 58634355  wangb63   rrg-kfennel-ab_cpu EnKF_UPW_2kfil  PD   10:00:00     1    8        N/A   2000M  (Priority)
        % '
        format1 = '(\d{6,10})(\s+)(\S+)(\s+)(\S+)(\s+)(\S+)(\s+)(\S+)(\s+)(\S+)(\s+)(\S+)(\s+)(\S+)(\s+)(\S+)(\s+)(\S+)(\s+).';
        
        % the command to submit a job in graham (a cluster in computecanada) is:
        % cd rundir
        % sbatch execfile
        execstr2 = sprintf('cd %s; sbatch %s', rundir, execfile);
        
        % the regular expression of output information from the cluster
        % the typical output in graham is:
        %
        % 'Submitted batch job 58635353
        % '
        format2 = '.* job +(\d+)';
        
        % the index of job id in the above regular expression
        jobid_position = 1;
    case 'catz'
        % the command to check job status in catz is:
        % ssh catz.ocean.dal.ca << HERE
        % qstat | sed -n ''s|^\\ *\\([0-9]\\{1,\\}\\).*\\ \\([a-zA-Z]\\{1,\\}\\)\\ .*|\\1;\\2|p'' 
        % HERE
        execstr1 = sprintf('ssh catz.ocean.dal.ca << HERE\n qstat | sed -n ''s|^\\ *\\([0-9]\\{1,\\}\\).*\\ \\([a-zA-Z]\\{1,\\}\\)\\ .*|\\1;\\2|p'' \nHERE\n');
        
        % the regular expression of output information from the cluster
        % the typical output in catz is:
        %
        % 'ssh: /misc/3/software/test/matlab2017a/bin/glnxa64/libcrypto.so.1.0.0: no version information available (required by ssh)
        % ssh: /misc/3/software/test/matlab2017a/bin/glnxa64/libcrypto.so.1.0.0: no version information available (required by ssh)
        % Pseudo-terminal will not be allocated because stdin is not a terminal.
        % +---------------------------------------------------+
        % |Please type qrsh to get an interactive session with|
        % |the least loaded compute node                      |
        % |                                                   |
        % |http://catz.ocean.dal.ca/monitor - load status     |
        % |                                                   |
        % +---------------------------------------------------+
        % 8116456;r
        % 8113848;r
        % 8140621;r
        % 8140622;r
        % 8140623;r
        % '
        format1 =  '(\d+);(\w+)\s';
        
        % the command to submit job in catz is:
        % ssh catz.ocean.dal.ca << HERE
        % bash -l
        % cd rundir
        % qsub execfile
        % HERE
        execstr2 = sprintf('ssh catz.ocean.dal.ca << HERE\nbash -l\ncd %s\nqsub %s\nHERE\n', rundir,execfile);
        
        % the regular expression of output information from the cluster
        % the typical output in catz is:
        
        % 'ssh: /misc/3/software/test/matlab2017a/bin/glnxa64/libcrypto.so.1.0.0: no version information available (required by ssh)
        % ssh: /misc/3/software/test/matlab2017a/bin/glnxa64/libcrypto.so.1.0.0: no version information available (required by ssh)
        % Pseudo-terminal will not be allocated because stdin is not a terminal.
        % +---------------------------------------------------+
        % |Please type qrsh to get an interactive session with|
        % |the least loaded compute node                      |
        % |                                                   |
        % |http://catz.ocean.dal.ca/monitor - load status     |
        % |                                                   |
        % +---------------------------------------------------+
        % +---------------------------------------------------+
        % |Please type qrsh to get an interactive session with|
        % |the least loaded compute node                      |
        % |                                                   |
        % |http://catz.ocean.dal.ca/monitor - load status     |
        % |                                                   |
        % +---------------------------------------------------+
        % Your job 8140632 ("EnKF_UPW_2kfilesV2_0010") has been submitted
        format2 = '.* job +(\d+) .*';
        
        % the index of job id in the above regular expression
        jobid_position = 1;
        
    %%%%%%%% <add your command for your clusters> %%%%%%%%
    % case ' '
    %     excestr1 = '';  
    %     format1 = '';
    %     excestr2 = '';  
    %     format2 = '';
    %     jobid_position = ;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    otherwise
        error('This cluster is not available yet: %s', clusterName)
end

%% To submit a new job and extract information of job id (do not have to be modified)
%
% Before submitting a new job, we have to know the current jobs which are already on the cluster
%
status = -1; 
while status ~=0
    [status output] = system(execstr1);
end

tok = regexp(output, format1, 'tokens');
numtoken1 = numel(tok);

for itok = 1:numtoken1
    cqid = str2double(tok{itok}{jobid_position});
    nowjobids(itok) = cqid;
end

%
% submit a job
%
[status, output] = system(execstr2);

jobid = nan;
if status == 0
    tok = regexpi(output, format2, 'tokens');
    
    if ~isempty(tok) 
        jobid = str2double(tok{1}{jobid_position});
    else
        warning('The jobid was failed to be recognized')
        status = 1;
    end
end

if status ~= 0 % job submission or recognition failed 
    % When other users submitted a lot of jobs simultaneously in the
    % cluster, the batch job submission might fail.
    % But sometimes it gives an error message while the job gets submitted. 
    % In this case, we will firstly check whether a new jobid appear. 
    % We will delete this recently appeared jobid before resubmitting
    fprintf('\nThe existed jobids are: \n')
    for ijob = 1:numel(nowjobids)
        fprintf('%d\n', nowjobids(ijob))
    end
    
    nrepeat = 5;  ncount=1; 
    while status~=0 && ncount<nrepeat
        warning('(ncount = %d) Something went wrong when submitting the job!\n', ncount)
        status = -1;
        while status ~= 0
            [status output] = system(execstr1);
        end
        tok = regexp(output, format1, 'tokens');
        numtoken2 = numel(tok);
        
        if numtoken1 ~= numtoken2
            for itok = 1:numtoken2
                cqid = str2double(tok{itok}{jobid_position});
                ind = find(nowjobids == cqid);
                if isempty(ind)
                    warning(' -- Jobid: %d is submitted but not recognized \n', cqid);
                    % delete the job
                    status = -1;
                    while status ~=0
                        [status, output] = qdel(cqid,clusterName);
                    end
                    warning(' -- Jobid: %d was deleted before resubmitting \n', cqid);
                end
            end
        else
            warning(' The job is really not submitted \n');
        end
        
        % resubmit job
       [status, output] = system(execstr2);
       ncount = ncount+1; 
       if status==0
            tok = regexpi(output, format2, 'tokens');
            if ~isempty(tok) 
                jobid = str2double(tok{1}{jobid_position});
            else
                warning('The jobid was failed to be recognized')
                status == 1;
            end
       end
    end
    
    fprintf('\n')
end

