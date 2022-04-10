function [newparamvalues, assimout] = rassim_KFilter(stepcounter, octime, datatime, ncdir, ncfiles, paramnames, paramvalues, logfid, assimargs)
% rassim_KFilter gets most of its parameters from a kfparams file 
% (typically KFilter_params). But additional parameters can be supplied via 
% the assimargs input (all other input arguments are supplied by the
% romsassim function and are described in rassim_template).

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

if ~isnan(logfid)
    fprintf(logfid, ' time with KFilter_assim = %6.2f (s) \n\n',timeassim);
end

% end of data assimilation


assimout = 'all ok';


return

