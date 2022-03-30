function fnames = changeoutputparameters(rim, outdir, basename, outspec, specialhissuffix)
% fnames = changeoutputparameters(rim, outdir, basename, outspec, specialhissuffix)
% helper function to change the names of the output (history, average,...)
% files in the ROMS main in-file
% 
% INPUT: 
% rim: a RomsInfileManager object with a valid ROMS main in-file
% outdir: the directory the output is redirected to
% basename: a string containing the 'base' name of each file name, a prefix
%     is attached to each file name (e.g. 'his_' for history files) as well
%     as the file extension '.nc'
% outspec (optional): modifies the output of the changeoutputparameters
%     (see OUTPUT for more information)
% specialhissuffix (optional): a string used as a special suffix added to
%     the file name of history files.
%
% OUTPUT:
% fnames: a cell-string containing the file names that were passed on to
%     the RomsInfileManager object. With the input argument outspec the
%     output can be refined to certain filenames.
%     E.g. for outspec = 'avg' only the name of the average file is
%     returned, for outspec = {'avg', 'his'} both average and history file
%     names are returned.
%     


if ~isa(rim, 'RomsInfileManager')
    error('First input argument must be an RomsInfileManager-object.');
end

if outdir(1) == filesep % absolute path
    if ~exist(outdir, 'dir')
        error('Directory ''%s'' does not exist.', outdir);
    end
end

if nargin < 3
    basename = 'romsrun';
end

% parameeters in main input file (ocean.in)
params = {'GSTNAME', 'RSTNAME', 'HISNAME', 'TLMNAME', 'TLFNAME', 'ADJNAME', 'AVGNAME', 'DIANAME', 'STANAME', 'FLTNAME','QCKNAME'};
prefixes = {'gst', 'rst', 'his', 'tlm', 'tlf', 'adj', 'avg', 'dia', 'sta', 'flt','qck'};

values = cellfun(@(x) fullfile(outdir, strcat(x, '_', basename, '.nc')), prefixes, 'UniformOutput', false);
if nargin >= 5 & ifile == 1
    values{2} = strcat(values{2}(1:end-3), specialhissuffix, '.nc');
end

% create output if desired
if nargout > 0
    if nargin < 4
        fnames = values;
    elseif isnumeric(outspec)
        fnames = values(outspec);
    elseif ischar(outspec)
        ind = strncmpi(params, outspec, max(3, length(outspec)));
        if ~any(ind)
            fnames = {};
        else
            fnames = values(ind);
        end
    else % cell required
        fnames = cell(1, length(outspec));
        for k = 1:length(outspec)
            ind = strncmpi(params, outspec{k}, max(3, length(outspec{k})));
            if ~any(ind)
                fnames{k} = values{ind};
            end
        end
    end
end
% apply changes
rim.scheduleParameterChanges('main', params(1:end), values(1:end));

