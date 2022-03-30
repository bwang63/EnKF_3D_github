function [newparamvalues, assimout] = rassim_KFilter(stepcounter, octime, datatime, ncdir, ncfiles, paramnames, paramvalues, logfid, assimargs)
% [newparamvalues assimout] = rassim_KFilter(octime, datatime, ncdir, ncfiles, sdi, paramnames, paramvalues, logfid, assimargs)
% 
% ROMS assimilation (rassim) function for combined state-parameter EnKF data assimilation that is 
% used together with the function romsassim. 
% Add options for assimilating parameters ('assimparams', referred to state
% augmentation).  Based on 'rassim_stateaugsubregions'
% 
% rassim_KFilter gets most of its parameters from a kfparams file 
% (typically KFilter_params). But additional parameters can be supplied via 
% the assimargs input (all other input arguments are supplied by the
% romsassim function and are described in rassim_template).
%
% assimargs must be a struct containing the optional fields:
%  kfparams: (cell, optional) kfparams that override the parameters in the
%       kfparams file (typically KFilter_params). The format of kfparams
%       is:
%           {kfparam1, value1, kfparam2, value2, ...}
%       where kfparam1 is the name of a kfparam and value1 is its new value
%       and kfparam2 is the name of another kfparam with a new value
%       specified by value2. Any number of kfparams can be specified this
%       way. For more information regarding the kfparams, see the file
%       KFilter_params.m.
%       example: {'solver', 'StandardEnKFopt', 'ize', 1} 
%           [sets the value of the kfparam 'solver' to 'StandardEnKFopt'
%           and that of 'ize' to 1.]
%       default: {} [no changes to kfparams]
%  kfparamsfile (char, optional) The name of a kfparams parameters file
%       (the path is not included, neither is the suffix ".m"). This file
%       is used to obtain the values for the kfparams not supplied via the
%       kfparams field (see above).
%       example: 'KFilter_params_otnbio'
%       default: 'KFilter_params'
%  verifyinput: (logical, optional): flag that turns on a more thorough
%       check of the input arguments to rassim_KFilter.
%       default: false
%  

% add options for state augmentation  -- Apr 2015, LY

% just print the arguments to screen and explain so in the log

if ~isnan(logfid)
    fprintf(logfid, '----------------------------------------------------------------------\n');
    fprintf(logfid, ' call to rassim_KFilter - KFilter_based algorithm will be performed. \n');
    fprintf(logfid, '----------------------------------------------------------------------\n');
end 
verifyinput = false;
if ~isempty(assimargs.verifyinput)
    if assimargs.verifyinput
        verifyinput = true;
    end
end
% verify and show the ensemble rst files
fprintf('arguments:\n')
fprintf('  - %d files in %s\n', numel(ncfiles), ncdir)
for k = 1:min(2, numel(ncfiles))
    fprintf('    %s\n', ncfiles{k})
end
if numel(ncfiles) > 2 
    if numel(ncfiles) > 3
        fprintf('      ...\n');
    end
    fprintf('    %s\n', ncfiles{end})
end
fprintf(' - parameters:')
if ~isempty(paramnames)
    for k = 1:numel(paramnames)
        fprintf(' %s,', paramnames{k})
    end
    fprintf('\b\n')
else
    fprintf('none\n')
end

if verifyinput
    allok = true;
    fprintf('verifying input\n')
    for k = 1:numel(ncfiles)
        if ~exist(fullfile(ncdir, ncfiles{k}), 'file')
            allok = false;
            fprintf('  - file #%d (%s) does not exist\n', k, fullfile(ncdir, ncfiles{k}))
        end
    end
    if ~allok
        error('Error verifying input.')
    end
end


%
% data assimilation using kalman filter based technique
% 
timeassim = 0; % accumulated time used for data assimilation
tic;

assimstep = stepcounter;

% PM:

%
% create the kfparams struct
%

kfparams = create_kfparamstruct; % many fields already exist here

if isfield(assimargs,'kfparamsfile')
    kfparamsfile = assimargs.kfparamsfile;
else
    error(' - The kfparamsfile was not provided');
end
fprintf(' - using parameter file ''%s''.\n', char(kfparamsfile));
eval(kfparamsfile);

% observations file
try
    kfparams.obsfile = assimargs.obsfile;
    kfparams.refdate = assimargs.refdate;
    kfparams.assimdates = assimargs.assimdates;
    kfparams.survey_time = nc_varget(kfparams.obsfile,'survey_time')+kfparams.refdate;
catch ME
    error(sprintf('Something wrong happen when reading the observation file:\n    %s',ME.message))
end

% for backwards compatibility add new fields if they do not exist
if ~isfield(kfparams,'verbose')
    kfparams.verbose = false;
end

if ~isfield(kfparams,'debug')
    kfparams.debug = false;
end

%
% call the appropriate EnKF
%
switch kfparams.local_method
    case 'local_analysis'
        fprintf('using routine: ''%s''\n', 'KFilter_assim_full_stateaug_LA')
        [newparamvalues,kfparams] = KFilter_assim_full_stateaug_LA(kfparams,octime,datatime,ncdir,ncfiles,logfid,assimstep,paramnames, paramvalues);
    case 'cov_local'
        error('cov_local option currently does not work')
end
    
timeassim = timeassim+toc;
% /PM

if ~isnan(logfid)
    fprintf(logfid, ' time with KFilter_assim = %6.2f (s) \n\n',timeassim);
end

% end of data assimilation


%newparamvalues = newparamvalues;
assimout = 'all ok';


return

