function rif_setvar(infilename, newfilename, variables, values, tryntimes)
% rif_setvar(infilename, newfilename, parameters, values)
% Changes the values of ROMS in-file parameters and writes them into a new
% file (copying over all unchanged parameters, too).
% NOTE: For performance reasons this function does not check if the
% variable actually exist, use the function rif_isvar for that
% purpose.
% 
% INPUT:
% infilename: the name of the in-file.
% newfilename: the name of the new in-file with changed parameters that is
%     created by rif_setvar.
% parameters: a string or a cell-string specifying the parameters that are
%     changed.
% values: a vector or cell specifying the values of the parameters.
% tryntimes: (optional) number of times to try to edit the files if edit 
%     fails (e.g. due to network issues) 
%
% example:
% rif_setvar('old.in', 'new.in', {'alpha', 'beta', 'gamma'}, ...
%     {'3', 3.1415, 'string'})
if nargin < 5
    tryntimes = 1;
end
if ischar(variables)
    mode = 1; % only one variables
    numvars = 1;
    % transform values to string if necessary
    if isnumeric(values)
        values = strrep(sprintf('%e', values), 'e', 'd');
    end
elseif iscellstr(variables)
    mode = 2; % variables names in a cellstr
    numvars = numel(variables);
    if ischar(values) || numel(values) ~= numvars
        error('rif_setvar:InvalidInput', 'The number of variables does not match the number of values.')
    end
    if iscell(values) % else it should be a vector
        mode = 3; 
    end
elseif isstruct(variables)
    mode = 4; % variables and values come in one struct
    varnames = fieldnames(variables);
    numvars = numel(varnames);
    if nargin > 3 && ~isempty(values)
        error('rif_setvar:InvalidInput', 'Just 3 input arguments required for struct input.')
    end
else
    error('rif_setvar:InvalidInput', 'Third argument must either be a string, a cellstring or a struct.')
end

sedstr = 'sed';
for k = 1:numvars
    if mode == 1
        cvariable = variables;
        cvalue = values;
    elseif mode == 2
        cvariable = variables{k};
        cvalue = strrep(sprintf('%e', values(k)), 'e', 'd');
    elseif mode == 3
        cvariable = variables{k};
        if ~ischar(values{k})
            cvalue = strrep(sprintf('%e', values{k}), 'e', 'd');
        else
            cvalue = values{k};
        end
    elseif mode == 4
        cvariable = varnames{k};
        if ~ischar(variables.(cvariable))
            cvalue = strrep(sprintf('%e', variables.(cvariable)), 'e', 'd');
        else
            cvalue = variables.(cvariable);
        end
    end
    sedstr = strcat(sedstr, sprintf(' -e ''s|^\\(\\ *%s\\ *=\\{1,2\\}\\ *\\)\\([^!]*\\)|\\1%s |g''', cvariable, cvalue));
end

sedstr = strcat(sedstr, sprintf(' < %s > %s', infilename, newfilename));
for k = 1:tryntimes
    status = system(sedstr);
    if status == 0
        break;
    end
    pause(.1)
end


