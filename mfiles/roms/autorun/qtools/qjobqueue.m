function jobqueue = qjobqueue(jobid, clusterName)
% jobqueue = qjobqueue(jobid)
% Returns the queue of the queue job with job ID jobid or '' if the
% job does not appear in the queue.

%% Users have to setup their command for a new cluster
switch lower(clusterName)
    case 'graham'
        % the command to check job status in graham (a cluster in computecanada) is:
        % squeue -u username
        execstr = 'squeue -u wangb63'; % wangb63 is the user name in graham
        
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
        format = '(\d{6,10})(\s+)(\S+)(\s+)(\S+)(\s+)(\S+)(\s+)(\S+)(\s+)(\S+)(\s+)(\S+)(\s+)(\S+)(\s+)(\S+)(\s+)(\S+)(\s+).';
        
        % the index of job queue in the above regular expression
        jobqueue_position = 5;
        
        % the index of job id in the above regular expression
        jobid_position = 1;
    case 'catz'
        % the command to check job status in catz is:
        % ssh catz.ocean.dal.ca << HERE
        % qstat | sed -n ''s|^\\ *\\([0-9]\\{1,\\}\\).* *[0-9]\\{2\\}:[0-9]\\{2\\}:[0-9]\\{2\\}\\ *\\([^ ]*[^ 0-9][^ ]*\\)\\ .*|\\1;\\2|p'' 
        % HERE
        execstr = sprintf('ssh catz.ocean.dal.ca << HERE\n qstat | sed -n ''s|^\\ *\\([0-9]\\{1,\\}\\).* *[0-9]\\{2\\}:[0-9]\\{2\\}:[0-9]\\{2\\}\\ *\\([^ ]*[^ 0-9][^ ]*\\)\\ .*|\\1;\\2|p'' \nHERE\n');
        
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
        % 8116456;interactive@node18
        % 8113848;interactive@node16
        % 8140621;interactive@node54
        % 8140622;batch@node32
        % 8140623;batch@node27
        % '
        format = '(\d+);(\S+)\s';
        
        % the index of job queue in the above regular expression
        jobqueue_position = 2;
        
        % the index of job id in the above regular expression
        jobid_position = 1;
        
    %%%%%%%% <add your command for your clusters> %%%%%%%%
    % case ' '
    %     excestr = '';  
    %     format = '';
    %     jobqueue_position = ;
    %     jobid_position = ;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    otherwise
        error('This cluster is not available yet: %s', clusterName)
end


%% To check job status and extract information of job queue (do not have to be modified)
[status rawout] = system(execstr);
tok = regexp(rawout, format, 'tokens');

numtoken = numel(tok);
jobqueue = cell(1,numel(jobid));
for k = 1:numel(jobid)
    jobqueue{k} = '';
end

for itok = 1:numtoken
    cqid = str2double(tok{itok}{jobid_position});
    jobind = jobid == cqid;
    if any(jobind)
        if sum(jobind) == 1 % only one occurrence
            jobqueue{jobind} = tok{itok}{jobqueue_position};
        else % this jobid appears multiple times
            for k = find(jobind)
                jobqueue{k} = tok{itok}{jobqueue_position};
            end
        end
    end
end
%end

