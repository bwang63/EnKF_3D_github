function romsassim_printstatus(fid, curstep, totalsteps, qjobid, qjobstatus,clusterStatus)

fprintf(fid, '---------------------------------------\n');
fprintf(fid, 'STATUS %s (%d/%d)\n', datestr(now), curstep, totalsteps);
for k = 1:numel(qjobid)
    fprintf(fid, ' %3d: ',k);
    if isempty(qjobstatus{k})
        fprintf(fid, 'waiting\n');
    elseif strcmp(qjobstatus{k}, clusterStatus{1})
        fprintf(fid, 'running id: %d\n', qjobid(k));
    elseif strcmp(qjobstatus{k}, clusterStatus{2})
        fprintf(fid, 'queued\n');
    else
        fprintf(fid, '"%s"\n', qjobstatus{k});
    end
end
fprintf(fid, '---------------------------------------\n');

