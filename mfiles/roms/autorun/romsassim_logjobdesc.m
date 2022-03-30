function romsassim_logjobdesc(fid, jobids, jobqueues);

nens = numel(jobids);
if nargin < 3 % no jobqueues
    fprintf(fid, '  queue job summary (format: "(index): jobid"):\n    ');
    for k = 1:nens
        fprintf(fid, ' (%2d):%7d', k, jobids(k));
        if mod(k,10) == 0 && k ~= nens
            fprintf(fid, '\n    ');
        end
    end
    fprintf(fid, '\n');
else
    fprintf(fid, '  queue job summary (format: "(index): jobid [jobqueue]"):\n    ');    
    for k = 1:nens
        fprintf(fid, ' (%2d):%7d [%s]%s', k, jobids(k), jobqueues{k}, blanks(max(0,30-length(jobqueues{k}))));
        if mod(k,3) == 0 && k ~= nens
            fprintf(fid, '\n    ');
        end
    end
    fprintf(fid, '\n');
end

