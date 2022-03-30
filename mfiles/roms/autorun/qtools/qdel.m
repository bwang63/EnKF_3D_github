function [status, message] = qdel(jobid,clusterName)

switch lower(clusterName)
    case 'graham'
        % The command used to delete a job in graham (a cluster of computecanada) is: 
        % scancel jobid
        excestr = sprintf('scancel %d', jobid);
    case 'catz'
        % The command used to delete a job in catz is: 
        % ssh catz.ocean.dal.ca << HERE
        % qdel jobid
        % HERE
        excestr = sprintf('ssh catz.ocean.dal.ca << HERE\n qdel %d\nHERE\n', jobid)
        
    %%%%%%%% <add your command for your clusters> %%%%%%%%
    % case ' '
    %     excestr = '';  
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    otherwise
        error('This cluster is not available yet: %s', clusterName)
end
[status, message] = system(excestr);



