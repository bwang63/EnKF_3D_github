function out = unix_statlastfilechange(fname, otherdate, noerrors)

if ~exist(fname,'file')
    out = -9999; % if the output file is not created, the script will delete this job and resubmit it
else
    cmdstr = sprintf('stat --format=%%z %s', fname);
    [status message] = unix(cmdstr);
    
    if status ~= 0
        error('Unix error: %s', message)
    end
    
    % message example:
    % 2009-11-24 16:39:11.000000000 -0400
    try
        if isempty(message) % LY: empty message is produced from time to time when starting the ensemble from node55.
            % is it due to the communication within the system?... don't know why... just add this statement to be safe for now.
            out = datenum(now);
        else
            out = datenum(message(1:19));
        end
    catch anerror
        warning('Cannot parse ''%s''.', message(1:19));
        if nargin > 2 && noerrors
            fprintf('unix_statlastfilechange output will be set to ''now'' because of problem.')
            out = now;
        else
            rethrow(anerror);
        end
    end
end
 out = (otherdate-out)*86400;
