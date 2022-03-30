function romsassim_logqerrorsummary(fid, qerrorlog)

fprintf(fid, '== queue error summary =================================\n');
if isempty(qerrorlog)
    fprintf(fid, 'No queue errors occured.\n');
else
    hosts = {qerrorlog.host};
    [uhosts dump unum] = unique(hosts);
    maxhostlen = max(4, max(cellfun(@length, uhosts)));
    ids = [qerrorlog.jobid];
    maxidlen = max(6, ceil(log10(max(ids))));
    
    fstring1 = sprintf('  %%%ds  status  %%%ds\n', maxidlen, maxhostlen);
    fstring2 = sprintf('  %%%dd  %%6s  %%%ds\n', maxidlen, maxhostlen);
    fprintf(fid, '%d queue error(s) occured.\n', numel(qerrorlog));
    fprintf(fid, 'log:\n');
    fprintf(fid, fstring1, 'job-id', 'host');
    for k = 1:numel(qerrorlog)
        fprintf(fid, fstring2, qerrorlog(k).jobid, qerrorlog(k).status, qerrorlog(k).host);
    end
    
    fstring1 = sprintf('  %%%ds  #errors\n', maxhostlen);
    fstring2 = sprintf('  %%%ds  %%7d\n', maxhostlen);
    fprintf(fid, '\nhost summary:\n');
    fprintf(fid, fstring1, 'host');
    for k = 1:numel(uhosts)
        fprintf(fid, fstring2, uhosts{k}, sum(unum==k));
    end
end
fprintf(fid, '========================================================\n');



