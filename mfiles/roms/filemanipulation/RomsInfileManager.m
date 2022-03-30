classdef RomsInfileManager < handle
% This class manages any number or ROMS in-files (*.in) connected to a main
% in-file and allows to perform parameter changes for them.
%
% the typical workflow is as follows
% 1) once: set the main in-file (using the constructor of this class or the
%    function setMainInfile) and add other in-files that need changes in
%    their parameters (using the function addSubInfile). Make sure that
%    (relative) paths to other files that are listed in the in-files stay
%    valid.
%
% 2) whenever a copy of the in-files with new parameters is needed:
%    schedule one or multiple parameter changes (using the function
%    scheduleParameterChanges) and create the copys in a given directory
%    (using the function writeOut)
%
% LIST OF FUNCTIONS
%
% setMainInfile(FILENAME)
%  Set the main in-file to FILENAME which must be the path to an existing
%  main in-file. The constructor can also be used to perform this task.
%
% getMainInfile()
%  Get the path of the main in-file.
%
% setRelativePath(PATHNAME)
%  Make this object of RomsInfileManager use relative path names. All
%  paths become relative to PATHNAME and further calls to
%  functions that require files or pathes as input must be relative to
%  PATHNAME. The constructor can also be used to perform this task.
%  Note: If you decide to use relative paths, use this method before
%  setting the main in-file or adding any in-files.
%
% addSubInfile(NAME, FILENAME, INFILELINK)
%  Add a new in-file
%  INPUT:
%   NAME: a string that acts as ID used to refer to the in-file
%   FILENAME: file name of the in-file
%   INFILELINK: the name of a variable in the main in-file that refers to
%        the in-file
%
% rmSubInfile(NAME)
%  Remove the in-file with the name NAME.
%
% scheduleParameterChanges(NAME, PARAMETERS, VALUES)
%  Schedule the change of one or multiple parameters in one of the
%  in-files.
%  INPUT:
%   NAME: name of the in-file or 'main' for the main in-file.
%   PARAMETERS: a string with one parameter name or a cell-string
%        containing multiple parameter names.
%   VALUES: values for the parameters specified in the previous argument,
%        values can be a vector (for purely numeric values) or a cell
%        containing strings and numeric values.
%
% writeOut(WRITEDIR, PREFIX) or writeOut(PREFIX)
%  Write out all the in-files with the scheduled parameter changes into the
%  directory WRITEDIR or, if ommitted, into the directory that was
%  specified as the realtive path (using setRelativePath). The string
%  PREFIX is appended to the filenames of all in-files that are written.
%
% subInfileName(NAME)
%  Returns the file name of the in-file that is known to the
%  RomsInfileManager as NAME (specified when added the in-file).
%
% Written by Jann Paul Mattern

    properties (SetAccess = protected)
        SubInfiles = struct('name', 'main', 'path', {''}, 'infilelink', 'main', 'changes', struct('parameters', {}, 'values', {}));
        relPath = '';
    end
    methods
        function obj = RomsInfileManager(arg1, arg2)
            if nargin == 1
                obj.setMainInfile(arg1);
            elseif nargin == 2
                if ~exist(arg1, 'dir')
                    error('Path ''%s'' does not exist.', arg1)
                end
                obj.relPath = arg1;
                try
                    obj.setMainInfile(arg2);
                catch someerror
                    obj.relPath = '';
                    rethrow(someerror);
                end
            end
        end
        function addSubInfile(obj, name, filename, infilelink)
            if isempty(obj.SubInfiles(1).path)
                error('No main in-file set yet.')
            elseif any(strcmpi({obj.SubInfiles.name}, name))
                error('Infile file with name ''%s'' already exists.', name)
            elseif ~obj.existRelative(filename, 'file')
                error('File ''%s'' does not exist.', filename)
            elseif strcmpi({obj.SubInfiles.infilelink}, infilelink)
                error('Infile file with link ''%s'' already exists.', infilelink)
            elseif ~obj.isMainInfileParameter(infilelink)
                error('Link (variable) ''%s'' does not exist in in-file.', infilelink)
            end

            obj.SubInfiles(length(obj.SubInfiles)+1) = struct('name', name, 'path', filename, 'infilelink', infilelink, 'changes', struct('parameters', {}, 'values', {}));
        end
        function rmSubInfile(obj, name)
            ind = strcmpi({obj.SubInfiles.name}, name);
            if ind == 1
                error('Main in-file cannot be removed.')
            end
            obj.SubInfiles = obj.SubInfiles(~ind);
        end
        function scheduleParameterChanges(obj, name, parameters, values, safe)
            if isempty(obj.SubInfiles(1).path)
                error('No main in-file set yet.')
            elseif ~iscellstr(parameters)
                error('Second argument must be cellstring of parameter names.')
            elseif ischar(values) || numel(values) ~= numel(parameters)
                error('The number of variables does not match the number of values.')
            end
            if isempty(parameters)
                return;
            end
            if nargin < 5
                safe = true;
            end
            % deal with 'auto' argument
            if strcmpi(name, 'auto')
                paramfileindex = nan(1,numel(parameters));
                % find file index for each parameter
                for iparam = 1:numel(parameters)
                    for ifile = 1:numel(obj.SubInfiles)
                        if rif_isvar(obj.absolutePath(ifile), parameters{iparam})
                            %fprintf('%s --> %s\n', parameters{iparam}, obj.absolutePath(ifile))
                            paramfileindex(iparam) = ifile;
                            break
                        end
                    end
                    if isnan(paramfileindex(iparam))
                        error('The parameter ''%s'' does not exist in any of the in-files.', parameters{iparam})
                    end
                end
                uparamfileindex = unique(paramfileindex);
                % one call to scheduleParameterChanges for each file
                for ufileindex = uparamfileindex
                    cindex = paramfileindex == ufileindex;
                    cname = obj.SubInfiles(ufileindex).name;
                    % debug output:
%                     cindex2 = find(cindex);
%                     fprintf('%s: %s', cname, parameters{cindex2(1)})
%                     for k = 2:numel(cindex2)
%                         fprintf(', %s', parameters{cindex2(k)})
%                     end
%                     fprintf('\n')
                    % /debug output
                    obj.scheduleParameterChanges(cname, parameters(cindex), values(cindex));
                end
                return
            end
            
            ind = find(strcmpi({obj.SubInfiles.name}, name), 1);
            if isempty(ind)
                error('Name does not match name of any in-file.')
            end

            if isempty(obj.SubInfiles(ind).changes)
                numoldchanges = 0;
            else
                numoldchanges = length(obj.SubInfiles(ind).changes.parameters);
            end
            numnewchanges = length(parameters);
            if safe
                keepparams = true(1,numnewchanges);

                for k = 1:numnewchanges
                    if ~rif_isvar(obj.absolutePath(ind), parameters{k})
                        error('The parameter ''%s'' does not exist in sub in-file %s (%s).', parameters{k}, obj.SubInfiles(ind).name, obj.SubInfiles(ind).path)
                    elseif ind == 1 && any(strcmpi({obj.SubInfiles.infilelink}, parameters{k}))
                        error('The parameter ''%s'' acts as a link for one sub in-file.', parameters{k})
                    elseif iscell(values) && ~((isnumeric(values{k}) && numel(values{k}) == 1) || ischar(values{k}))
                        error('The value for parameter ''%s'' is invalid.', parameters{k})
                    end
                    if numoldchanges > 0
                        ind2 = strcmpi(obj.SubInfiles(ind).changes.parameters, parameters{k});
                        if any(ind2)
                            %warning('A scheduled change for the parameter ''%s'', already exists, it will be overwritten.', parameters{k})
                            keepparams(k) = false;
                            if isnumeric(values)
                                obj.SubInfiles(ind).changes.values{ind2} = values(k);
                            else
                                obj.SubInfiles(ind).changes.values{ind2} = values{k};
                            end
                        end
                    end
                end
                if ~all(keepparams)
                    if ~any(keepparams)
                        return
                    end
                    parameters = parameters(keepparams);
                    values = values(keepparams);

                end

            end
            obj.addNewChanges(ind, parameters, values);

            %             obj.SubInfiles(ind).changes.parameters %%%%%%%%%%%%%%%%%%%%%%%%%
            %             obj.SubInfiles(ind).changes.values
        end
        function newmaininfilename = writeOut(obj, writedir, prefix)
            if nargin == 2
                if isempty(obj.relPath)
                    error('No directory for relative pathnames specified, please supply a directory to write to.')
                end
                prefix = writedir;
                writedir = obj.relPath;
            end

            if ~exist(writedir, 'dir')
                error('Directory ''%s'' does not exist.', writedir)
            end

            numinfiles = length(obj.SubInfiles);
            newpath = cell(1, numinfiles);
            newfile = cell(1, numinfiles);
            for k = 1:numinfiles
                oldpath = obj.absolutePath(k);
                [olddir oldfilename fileextension] = fileparts(oldpath);

                newfile{k} = strcat(prefix, oldfilename, fileextension);
                newpath{k} = fullfile(writedir, newfile{k});
            end

            % create output
            if isempty(obj.relPath)
                newmaininfilename = newpath{1};
            else
                [olddir oldfilename fileextension] = fileparts(newpath{1});
                newmaininfilename = strcat(oldfilename, fileextension);
            end

            % add links as changes to main file
            obj.addNewChanges(1, {obj.SubInfiles(2:end).infilelink}, newfile(2:end));

            for k = 1:numinfiles
                oldpath = obj.absolutePath(k);
                if ~isempty(obj.SubInfiles(k).changes)
                    rif_setvar(oldpath, newpath{k}, obj.SubInfiles(k).changes.parameters, obj.SubInfiles(k).changes.values)
                    obj.SubInfiles(k).changes = struct('parameters', {}, 'values', {});
                else
                    copyfile(oldpath, newpath{k})
                end
            end
        end
        function name = subInfileName(obj, maininfilelink)
            try
                ind = find(strcmp({obj.SubInfiles.infilelink}, maininfilelink), 1);
            catch
                error('Input must be a string.')
            end
            if ~isempty(ind)
                name = obj.SubInfiles(ind).name;
            else
                name = '';
            end
        end
        function disp(obj)
            fprintf('RomsInfileManager\n')
            if ~isempty(obj.SubInfiles(1).path)
                fprintf('    main in-file: ''%s''\n', obj.SubInfiles(1).path)
                if length(obj.SubInfiles) > 1
                    fprintf('\n    sub in-files:\n')
                    for k = 2:length(obj.SubInfiles)
                        fprintf('      %s: ''%s''\n', obj.SubInfiles(k).name, obj.SubInfiles(k).path)
                    end
                end
            end
            fprintf('\n')
        end
        function printScheduledChanges(obj)
            for isubinfile = 1:numel(obj.SubInfiles)
                if isubinfile == 1
                    fprintf('   main in-file: %s (''%s'')\n', obj.SubInfiles(isubinfile).name, obj.SubInfiles(isubinfile).path)
                else
                    fprintf('   sub in-file:  %s (''%s'')\n', obj.SubInfiles(isubinfile).name, obj.SubInfiles(isubinfile).path)
                end
                for ichange = 1:numel(obj.SubInfiles(isubinfile).changes.parameters)
                    if ischar(obj.SubInfiles(isubinfile).changes.values{ichange})
                        fprintf('      parameter: %s <-- %s\n', obj.SubInfiles(isubinfile).changes.parameters{ichange}, obj.SubInfiles(isubinfile).changes.values{ichange})
                    else
                        fprintf('      parameter: %s <-- %g\n', obj.SubInfiles(isubinfile).changes.parameters{ichange}, obj.SubInfiles(isubinfile).changes.values{ichange})
                    end
                end
            end
        end
        % getter and setter
        function obj = setMainInfile(obj, filename)
            if length(obj.SubInfiles) > 1
                error('There are sub in-files currently associated with the main in-file.\nUse rmSubInfile(name) to remove sub in-files.')
            elseif ~obj.existRelative(filename, 'file')
                error('File ''%s'' does not exist.', filename)
            end
            obj.SubInfiles(1).path = filename;
        end
        function out = getMainInfile(obj)
            out = obj.SubInfiles(1).path;
        end
        function obj = setRelativePath(obj, pathname) % not using a regular set method, as it doesn't work for the main in-file
            if ~isempty(obj.SubInfiles(1).path)
                error('Cannot change relative path: A main file is already set.')
            elseif ~exist(pathname, 'dir')
                error('Path ''%s'' does not exist.', pathname)
            end
            obj.relPath = pathname;
        end
    end
    methods (Hidden = true)
        function out = isMainInfileParameter(obj, paramname)
            out = rif_isvar(obj.absolutePath(1), paramname);
        end
        function out = existRelative(obj, arg1, arg2)
            if isempty(obj.relPath)
                out = exist(arg1, arg2);
            else
                out = exist(fullfile(obj.relPath, arg1), arg2);
            end
        end
        function out = absolutePath(obj, index)
            out = fullfile(obj.relPath, obj.SubInfiles(index).path);
        end
        function addNewChanges(obj, infileind, parameters, values)
            if isempty(obj.SubInfiles(infileind).changes)
                numoldchanges = 0;
            else
                numoldchanges = length(obj.SubInfiles(infileind).changes.parameters);
            end
            numnewchanges = length(parameters);
            obj.SubInfiles(infileind).changes(1).parameters(numoldchanges+1:numoldchanges+numnewchanges) = parameters;
            if iscell(values)
                obj.SubInfiles(infileind).changes.values(numoldchanges+1:numoldchanges+numnewchanges) = values;
            else
                obj.SubInfiles(infileind).changes.values(numoldchanges+1:numoldchanges+numnewchanges) = cell(1, numnewchanges);
                for k = 1:numnewchanges
                    obj.SubInfiles(infileind).changes.values{numoldchanges+k} = values(k);
                end
            end
        end
    end
end
