function out = romsassim_verifynetcdftime(ncdir, ncfiles, octime, timeindex, verbose, logfid, numtries)

if ischar(ncfiles)
    ncfiles = {ncfiles};
end
if nargin < 6 || isempty(logfid)
    logfid = 1;
end
if nargin < 7
    numtries = 10;
end

numfiles = numel(ncfiles);
out = false(1, numfiles);

for k = 1:numfiles
    cfile = fullfile(ncdir, ncfiles{k});
    if ~exist(cfile, 'file')
        fprintf('verifynetcdftime: file not found: ''%s''.\n', cfile);
        fprintf(logfid, 'verifynetcdftime: file not found: ''%s''.\n', cfile);
        continue;
    end
    if timeindex < 0
        ncoctime = try_nc_varget_log(logfid, numtries, cfile, 'ocean_time');
    else
        ncoctime = try_nc_varget_log(logfid, numtries, cfile, 'ocean_time', timeindex, 1);
    end
    if isempty(ncoctime)
        fprintf('verifynetcdftime: time could NOT be verified for ''%s'' (empty time entry).\n', cfile);
        fprintf(logfid, 'verifynetcdftime: time could not be verified for ''%s'' (empty time entry).\n', cfile);
        continue;
    end
    ncoctime = ncoctime(end);
    
    if ncoctime == octime
        out(k) = true;
        if verbose
            fprintf('verifynetcdftime: time verified for ''%s''.\n', cfile);
        end
    else
        fprintf('verifynetcdftime: time could NOT be verified for ''%s''.\n', cfile);
        fprintf(logfid, 'verifynetcdftime: time could not be verified for ''%s'' (in file: %d, checked against: %d).\n', cfile, ncoctime, octime);
    end
end

