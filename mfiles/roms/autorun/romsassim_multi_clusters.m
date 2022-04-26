 function [datadates, assimoutcontainer] = romsassim_multi_clusters(varargin)
% romsassim(options)
% A ROMS assimilation manager that performs all steps for an sequential 
% assimilation run: preparation, starting and stopping of the model etc.
% 
% Various options allow a high level of customization of romsassim. There
% are two kind of options: The first kind is followed by an argument, e.g.
%   romsassim(..., 'logfile', 'log.txt', ...)
% This kind of option is indicated by a "followed by" statement in the
% option description below. The second kind of option requires no extra
% arguments, it basically acts as a switch, e.g.
%   romsassim(..., 'constparams', ...)
%
% The option description is ordered based on importance.
% 
% Essential options:
%
% 'startdate': followed by a date number to specify the beginning of the
%     assimilation run. For example, use:
%         romsassim('startdate', datenum([2012,09,05]), ...)
%     to use 5 September 2012 as the start date. This date should
%     correspond to the date of the initial conditions used in ROMS. (The 
%     initial conditions can be specified using the 'inicond' option, see
%     below.)
% 'stopdate': followed by a date number to specify the end date of the
%     assimilation run. The difference stopdate - startdate will determine
%     the length of the assimilation run. 
% 'nens': followed by a numeric value to specify the number of ensemble
%     members used for the assimilation run. Each ensemble member will
%     require its own model simulations.
% 'assimfun': followed by a function handle to a rassim_* function that
%     performs the actual data assimilation, i.e. this function receives
%     all necessary information (model simulations and data) and then
%     performs the data assimilation and alters the model state before the
%     model ensemble is restarted again.
% 'assimfunargs': followed by any variable that is passed on to the
%     assimilation function. This option provides a way to pass on 
%     parameters directly to the function specified by the 'assimfun' 
%     option. For more information type:
%         help rassim_template
% 'logfile': followed by a filename to specify a log-file. If no log file
%     name is provided, no log file will be written.
%
% Commonly used options:
% 
% 'altsettings': followed by a function handle of an alternative settings
%     file. The standard setting file is romsassim_settings.m. The
%     alternative setting file needs to provide all the variables that
%     romsassim_settings.m provides.
% 'constparams': argument to switch off parameter variation. With the 
%     constparams option, only the first parameter set will be picked 
%     randomly, the parameters will then stay constant throughout the run.
% 'collectoutput': argument that starts the collection of output from the
%     rassim_* function (specified via the 'assimfun' option). 
%     The output of the assimilation function will be collected in a
%     cell-array and returned via the second output argument of romsassim.
%     If there is lots of output taking up much memory, it is recommended
%     to use the 'saveoutput' option (below) instead.
% 'saveoutput' argument that activates automatic saving of the output from
%     the rassim_* function (specified via the 'assimfun' option). If it is
%     active 'saveoutput' will lead to the creation of
%     romsassim_assimout*.mat files after each assimilation step in the
%     ROMS run directory (containing the ROMS *.in files).
% 'changefrcfile': argument to change forcing file (e.g., use an ensemble 
%     of wind forcing files for ensemble runs). 
%     For upwelling test case, wind file is the only forcing
%     file while for a realistic case, there could be multiple files under
%     the 'FRCNAME' in ROMS main in-file.
% 'changeinifile': argument to change initial condition file (e.g., use an 
%     ensemble of initial files for ensemble runs). 
%     (this option is added because the 'inicond' option with mask 
%     espression is not able to start the ensemble with different initial 
%     files)
% 'inicond': followed by a 2 element cell-string containing the path and
%     filename (mask) of ROMS restart files that are used as initial
%     conditions for the assimilation run. romsassim makes sure to pick a
%     date that is close to the start date of the assimilation run, one of 
%     the dates in the initial. For example, use 
%         romsassim(...,'inicond',{'/path/to/inicond','inifile.*nc'}, ...)
%     to select all the files that match the 'inifile.*nc' regular
%     expression mask in the specified directory 
%     (/path/to/inicond/inifile1.nc, /path/to/inicond/inifile2.nc, etc).
%     To specify a specific file, use the file name instead of a mask. The
%     name of the file that is used for the initial conditions is written
%     to the log file.
% 'adjustdstart': argument that activates adjustment of the DSTART variable 
%     in the ROMS main in file (ocean.in) and set it to the ocean time of the
%     initial conditions. 'adjustdstart' should be used when the file supplied
%     the 'inicond' argument is a restart file and a fresh restart (NRREC=0)
%     is attempted.
% 'restart': followed by a string containing the prefix (ID) of a previous
%     romassim data assimilation run that crashed somehow (e.g. due to a
%     shutdown of the computer) this option will lead to an attempt to
%     restart the romassim run that was terminated. 
%     The 'restart' option assumes the romassim run was interrupted before
%     the next assimilation step was performed. It will begin the restart
%     with an assimilation step.
% 'restart_noassim': followed by a string containing the prefix (ID) of a
%     previous romassim data assimilation run, this option is similar to
%     the 'restart' option, it will begin the restart with starting new
%     model simulations.
% 'logqerror': create a special entry in the end of the log file containing
%     an overview of the queue errors. If no log file is specified the
%     overview is printed to standard output.
% 'htmlstatus': print an html status table and copy it to an scp-able
%     address (see settings in romassim_settings_htmlstatus.m).
% 'iniparams': followed by cell containing a cell-string of parameter names
%     and a nens x numparameters vector of initial parameter values
% 
% Less commonly used options:
% 
% 'romsparamchanges': followed by cell, this option allows the setting of
%     some ROMS parameters prior to the assimilation run (as an alternative
%     to editing the ocean.in or bio.in file manually). The cell has the
%     following structure:
%       {infilename1, paramnames1, paramvalues1,
%        infilename2, paramnames2, paramvalues2, ...}
%     containing one or multiple infilenames, each followed by two cells.
%     infilename: a string identifying an in-file in the rpv (use 'main' 
%       for the ocean.in file; the name of the bio.in file is typically
%       specified in in the romsassim settings file).
%     paramnames: a cell string of parameter names
%     paramvalues: a cell of values for the parameters in paramnames
%     example:
%       romsassim(..., 'romsparamchanges', ...
%       {'main', {'NHIS', 'NDEFHIS'}, {'10000','50000'}})
%     to set the ocean.in file parameter NHIS to 10000 and NDEFHIS to
%     50000.
% 'constparamsif': argument to let the rassim_* function determine when to
%     draw new parameter values. With 'constparamsif' active new parameters
%     are drawn when the rassim_*.m function either returns an empty matrix
%     or the unchanged parameter matrix as its newparameters output. If
%     this is not the case, the parameters will remain constant. (This is a
%     way to redraw the parameters only after a given number of
%     assimilation steps.)
% 'rethrowerrors': rethrow errors that occur during the assimilation. This
%     option ensures that romsassim terminates with an error if an error
%     occurs internally. The standard behavior of romsassim is to display 
%     the error message and terminate gracefully after cleanup. The
%     'rethrowerrors' can be used so that other functions calling romsassim
%     can tell if an error occured while romsassim was running.
% 'rmfilesonerror': remove model input, output and log files if an error
%     occurs that stops romsassim.
% 'betaid': followed by a string that corresponds to a beta ID, this option
%     informs romsassim about the use of beta-annealing. Initial parameter
%     values will be drawn accordingly.
% 'rmallbutlog': after completing the simulation remove all input and all
%     output files except for the log-file.
% 'simmode': argument to start the assimilation run as a pure simulation,
%     i.e. no files are written - for debug purposes only.
% 'returndates': argument that makes romsassim flush out its first output
%     argument and then terminate. No assimilation will be performed.

assimoutcontainer = [];

%
% evaluate user input (type "help evaluateuserinput" for more info)
%

inopts = { {'clusterName','char','Graham'},...
                {'clusterStatus','cell',{''}},...
                {'stopdate', 'numeric', datenum([2006 01 01])}, ...
                {'startdate', 'numeric', datenum([2006 01 01])}, ...
                {'nens','int',10}, ...
                {'simmode','exist'}, ...
                {'assimfun','none',@rassim_template}, ...
                {'assimfunargs','none',[]}, ...
                {'logfile','char',''}, ...
                {'constparams','exist'}, ...
                {'returndates','exist'}, ...
                {'collectoutput','exist'}, ...
                {'changefrcfile','exist'}, ...
                {'changebryfile','exist'}, ...
                {'changeinifile','exist'}, ...
                {'inicond','cell',{'', ''},[1 2]}, ...
                {'brycond','cell',{''}}, ...
                {'frccond','cell',{''}}, ...
                {'idxffiles','int',1},...
                {'rethrowerrors', 'exist'}, ...
                {'rmfilesonerror', 'exist'}, ...
                {'logqerror', 'exist'}, ...
                {'htmlstatus', 'exist'}, ...
                {'altsettings', 'char', 'romsassim_settings'}, ...
                {'rmallbutlog', 'exist'}, ...
                {'betaid', 'char', ''}, ...
                {'iniparams', 'cell', {}}, ...
                {'romsparamchanges', 'cell', {}}, ...
                {'constparamsif', 'exist'}, ...
                {'saveoutput','exist'}, ...
                {'restart_noassim','char',''}, ...
                {'restart','char',''}, ...
                {'adjustdstart','exist'}, ...
                };
[clusterName, clusterStatus, stopdate, startdate, nens, simulationmode, assimfun, assimfunargs, logfile, constparams, returndates, collectoutput, changefrcfile,changebryfile,changeinifile,inicond,brycond,frccond,idxffiles,rethrowerrors, rmfilesonerror, logqerror, htmlstatus, settingsfile, rmallbutlog, betaid, iniparams, romsparamchanges, constparamsif, saveoutput, restart_prefix, restart_prefix_alt, adjustdstart] = evaluateuserinput(varargin, inopts);

if simulationmode
    fprintf('  -- DEBUG ON --\n')
    jobidcounter = 1;
    errorprob = 0;
    jobreadyprob = 0.9;
    writefiles = false;
else
    writefiles = true;
end

if ~isempty(restart_prefix) % option restart_noassim is active
    if ~isempty(restart_prefix_alt)
        error('Options restart and restart_noassim cannot be active at the same time.')
    end
    performrestart = true;
    restart_performassimstep = false;
elseif ~isempty(restart_prefix_alt) % option restart is active
    performrestart = true;
    restart_performassimstep = true;
    restart_prefix = restart_prefix_alt;
    clear restart_prefix_alt
else
    performrestart = false;
    clear restart_prefix
    clear restart_prefix_alt
end

% prescribe initial values of perturbed parameters, not generated randomly
if ~isempty(iniparams)
    userspecifiediniparams = true;
    if numel(iniparams) ~= 2
        error('Invalid input for ''iniparams'', must be a 2 element cell.')
    elseif ~iscellstr(iniparams{1})
        error('Invalid input for ''iniparams'', first element must be a cell-string.')
    elseif ~isnumeric(iniparams{2})
        error('Invalid input for ''iniparams'', second element must be numeric.')
    elseif numel(iniparams{1}) ~= size(iniparams{2},2)
        error('Invalid input for ''iniparams'', number of parameter names does not match number of initial parameters.')
    elseif size(iniparams{2},1) ~= nens
        error('Invalid input for ''iniparams'', number of parameter sets is not equal to nens.')
    end
else
    userspecifiediniparams = false;
end

% either constparams or constparamsif
if constparamsif && constparams
    error('Options constparams and constparamsif cannot be active at the same time.')
end

%
% load further options from settings file
%
if performrestart
    writefiles = false; % turn off temporarily
    prefix = restart_prefix;
end
eval(settingsfile)  % evaluate romsassim_settings_prep_*

% number of processors used for each job (NtileI*NtileJ)
for k = 1:numel(romsparamchanges)
    if ~isempty(find(strcmp('NtileI', romsparamchanges{k}))) & ~isempty(find(strcmp('NtileJ', romsparamchanges{k})))
        np = str2num(romsparamchanges{k+1}{1})*str2num(romsparamchanges{k+1}{2}); 
    end
end

%
logfile = fullfile(rundir,logfile); % create full path of logfile

if performrestart
    fprintf('romsassim: attempting restart (initializing regularly, some of the logfile output is overwritten later)\n');
    fprintf('romsassim: resuming run with prefix: ''%s''\n', restart_prefix);
    writefiles = ~simulationmode;
    % overwrite prefix
    clear restart_prefix
end

if htmlstatus
    romsassim_settings_htmlstatus;
end
if ~exist('romstimemode', 'var')
    romstimemode = 0; 
end
if ~exist('adjustntsavg', 'var')
    adjustntsavg = false; 
end
if ~exist('adjustldefout', 'var') 
    adjustldefout = adjustdstart; 
end
if ~exist('saveerrors', 'var')
    saveerrors = true; 
end
if ~exist('nrreczeropref', 'var')
    nrreczeropref = true; 
end

% overwrite certain options if in simulation mode
if simulationmode
    verifynetcdftime = false;
    pauseint = 1;
    logjobqueue = false;
    mvncfiles = false;
end

% overwrite useinifile if present
useinifile = ~isempty(inicond{1});
if useinifile && changeinifile
    inifilename = fullfile(inicond{1},inicond{2});
    [ipathstr,ifilename,ifileext] = fileparts(inifilename);           
    inifiles = cell(1,nens);
    for k = 1:nens
        inifiles{k} = fullfile([ipathstr,'/',ifilename,sprintf('_ens%04d.nc',k)]);
    end 
end

%
% initialize logfile and write information to log
%
if ~isempty(logfile)
    keeplog = true;
    if performrestart
        fid = fopen(logfile, 'a');
        fprintf(fid, '== ROMSASSIM RESTART ===========================================================================================\n');
        fprintf(fid, 'romsassim: attempting restart\n(initializing regularly, some of the logfile output below is overwritten later)\n');
    else
        fid = fopen(logfile, 'w');
        fprintf(fid, '== ROMSASSIM LOGFILE\n\n');
    end
end

if keeplog
    fprintf(fid, 'PARAMETERS\n');
    fprintf(fid, ' %s = %d (%s)\n','startdate',startdate,datestr(startdate));
    fprintf(fid, ' %s = %d (%s)\n','stopdate',stopdate,datestr(stopdate));
    fprintf(fid, ' %s = %d\n','nens',nens);
    fprintf(fid, ' %s = %d\n','simulationmode',simulationmode);
    fprintf(fid, ' %s = %s\n','assimfun',func2str(assimfun));
    fprintf(fid, ' %s = %s\n','logfile',logfile);
    fprintf(fid, ' %s = %d\n','constparams',constparams);
    fprintf(fid, ' %s = %d\n','constparamsif',constparamsif);
    fprintf(fid, ' %s = %d\n','returndates',returndates);
    fprintf(fid, ' %s = %d\n','collectoutput',collectoutput);
    fprintf(fid, ' %s = %d\n','saveoutput',saveoutput);
    fprintf(fid, ' %s = %d\n','changefrcfile',changefrcfile);
    fprintf(fid, ' %s = %d\n','changebryfile',changebryfile);
    fprintf(fid, ' %s = %d\n','changeinifile',changeinifile);
    fprintf(fid, ' %s = {%s, %s}\n','inicond',inicond{1},inicond{2});
    fprintf(fid, ' %s = %d (only active if initial conditions are supplied)\n', 'adjustdstart', adjustdstart);
    fprintf(fid, ' %s = %d\n','rethrowerrors',rethrowerrors);
    fprintf(fid, ' %s = %d\n','rmfilesonerror',rmfilesonerror);
    fprintf(fid, ' %s = %d\n','rmallbutlog',rmallbutlog);
    fprintf(fid, ' %s = %d (only active if resubmitonerror is active)\n','logqerror',logqerror);
    fprintf(fid, ' %s = %d\n','htmlstatus', htmlstatus);
    fprintf(fid, ' %s = %s %s\n','data', 'observations read from', assimfunargs{2}.obsfile);
    fprintf(fid, ' %s = ''%s'' (not used if empty)\n', 'betaid', betaid);
    fprintf(fid, ' %s = %dx%d cell (not used if empty)\n', 'iniparams', size(iniparams,1), size(iniparams,2));
    fprintf(fid, ' %s = %dx%d cell (not used if empty)\n', 'romsparamchanges', size(romsparamchanges,1), size(romsparamchanges,2));
    fprintf(fid, '\n');
    fprintf(fid, 'PARAMETERS from settings file\n');
    fprintf(fid, ' %s = %s\n','prefix',prefix);
    fprintf(fid, ' %s = %d\n','romstimemode',romstimemode);
    fprintf(fid, ' %s = %d\n','useinifile',useinifile);
    fprintf(fid, ' %s = %d\n', 'adjustldefout', adjustldefout);
    fprintf(fid, ' %s = %d\n','resubmitonerror',resubmitonerror);
    fprintf(fid, ' %s = %d\n','logparamvalues',logparamvalues);
    fprintf(fid, ' %s = %d\n','logjobqueue',logjobqueue);
    fprintf(fid, ' %s = %d\n','verifynetcdftime',verifynetcdftime);
    fprintf(fid, ' %s = %d\n','pauseint',pauseint);
    fprintf(fid, ' %s = %d\n','dt',dt);
    fprintf(fid, ' %s = %d\n','timestepthresh',timestepthresh);
    fprintf(fid, ' %s = %d\n','checklastfilechange',checklastfilechange);
    fprintf(fid, ' %s = %d (only used if checklastfilechange is active)\n','lastfilechangethresh',lastfilechangethresh);
    fprintf(fid, ' %s = %d (only active if checklastfilechange is active)\n','logfchangeerror',logfchangeerror);
    fprintf(fid, ' %s = %d\n','saveerrors',saveerrors);
    fprintf(fid, ' %s = %d\n','np',np);
    fprintf(fid, ' %s = %s\n','rpv','[RomsParameterVariation object] (see ACTIVE MODEL PARAMETERS for more info)');
    fprintf(fid, ' %s = %s\n','bioparam',bioparam);
    fprintf(fid, ' %s = %d\n','adjustntsavg',adjustntsavg);
    fprintf(fid, ' %s = %d\n','usebreakfun',usebreakfun);
    if usebreakfun; fprintf(fid, ' %s = %s [BreakFunctionInterface object]\n','bfun',bfun.toString()); end
    fprintf(fid, ' %s = %d\n','mvncfiles',mvncfiles);
    fprintf(fid, '\n');
    fprintf(fid, 'FILES & DIRECTORIES from settings file\n');
    fprintf(fid, 'settings file used: ''%s''\n',settingsfile);
    fprintf(fid, ' %s = %s\n','rundir',rundir);
    fprintf(fid, ' %s = %s\n','executable (relative to rundir)',executable);
    fprintf(fid, ' %s = %s\n','maininfile (relative to rundir)',maininfile);
    fprintf(fid, ' %s = %s\n','bioparamfile (relative to rundir)',bioparamfile);
    fprintf(fid, ' %s = %s\n','outdir (relative to rundir)',outdir);
    fprintf(fid, '\n');
end

if writefiles && ~performrestart
    fprintf(' - creating outdir ''%s''\n', fullfile(rundir, outdir))
    mkdir(fullfile(rundir, outdir));
end
if mvncfiles
    if ~performrestart
        mkdir(fullfile(rundir, outdir, mvncfilessubdir));
    end
    mvncfilesstr = sprintf(' ; do mv $file `echo $file | sed ''s|\\\\(.*\\\\)\\\\.nc|%s/\\\\1_%%03d.nc|''` ; done', mvncfilessubdir);
    for k = 1:numel(mvncfilesmask)
        mvncfilesstr = [sprintf('%s ', mvncfilesmask{k}), mvncfilesstr];
    end
    mvncfilesstr = sprintf('cd %s ; for file in %s', fullfile(rundir, outdir), mvncfilesstr);
    if isempty(mvncfilesmask)
        mvncfiles = false;
    end
    clear mvncfilesmask;
end

if ~isempty(romsparamchanges) 
    fprintf(fid, 'performing initial parameter changes specified by ''romsparamchanges''\n');
    filespecs = {'main', bioparam}; 
    r = RomsInfileManager(rundir, maininfile);
    for k = 1:3:numel(romsparamchanges)
        if ~ischar(romsparamchanges{k})
            error('Invalid format of ''romsparamchanges''.')
        end
        filespecind = find(strcmp(filespecs, romsparamchanges{k}));
        if filespecind == 1  % make changes in maininfile (ocean.in) specified by 'romsparamchanges'
            [pathstr,filename,fileext] = fileparts(maininfile);
            maininfile = ['copy_',filename,fileext];
        elseif filespecind == 2  % make changes in bioparamfile (bio_fennel*.in) 
            r.addSubInfile(bioparam, bioparamfile, 'BPARNAM');
            [pathstr,filename,fileext] = fileparts(bioparamfile); 
            bioparamfile = ['copy_',filename,fileext];
        else
            error('Invalid format of ''romsparamchanges''.')
        end
        r.scheduleParameterChanges(filespecs{filespecind}, romsparamchanges{k+1}, romsparamchanges{k+2});
    end
    fprintf(fid, ' - creating copies now\n');
    r.writeOut('copy_');
    fprintf(fid, 'CHANGES TO FILE NAMES DUE TO romsparamchanges\n');
    fprintf(fid, ' %s = %s\n','maininfile (relative to rundir)',maininfile);
    fprintf(fid, ' %s = %s\n','bioparamfile (relative to rundir)',bioparamfile);
    fprintf(fid, 'done\n');
    clear filespecs filespecind pathstr filename fileext oldfile r
end
r = RomsInfileManager(rundir, maininfile);
r.addSubInfile(bioparam, bioparamfile, 'BPARNAM');

if userspecifiediniparams
    paramnames = iniparams{1};
    paramvalues = iniparams{2};
    if ~(constparams)
        % check if rpv parameters are the same 
        if ~isequal(paramnames, rpv.activeParametersFrom(bioparam))
            error('Parameter names supplied do not match active parameter names of RomsParameterVariation object.')
        end
    end
    if constparamsif
        constparamsif_renewparameters = false;
    end
else
    paramnames = rpv.activeParametersFrom('all');
    paramvalues = nan(nens, numel(paramnames));
    paramvalues_temp = nan(nens, numel(paramnames)); % LY: temporal storage
    if constparamsif
        constparamsif_renewparameters = true;
    end
end

if ~isempty(betaid) && ~performrestart
    if keeplog
        fprintf(fid, 'using beta-annealing to create initial parameter values.\nresetting betaid ''%s''.\n', betaid);
    end
    rautil_betaanneal_init(betaid);
end

if resubmitonerror && logqerror
    qerrorcount = 0;
    qerrors = struct([]);
end
if checklastfilechange && logfchangeerror
    fchangeerrorcount = 0;
    fchangeerrors = struct([]);
end
if keeplog
    fprintf(fid, 'ACTIVE MODEL PARAMETERS (used for parameter variation)\n');
    for k = 1:numel(paramnames)
        fprintf(fid, ' %15s,', paramnames{k});
        if mod(k,5) == 0
            fprintf(fid, '\n');
        end
    end
    fprintf(fid, '\b\n\n');
end
if logparamvalues && userspecifiediniparams
    fprintf(fid, 'INITIAL VALUES OF MODEL PARAMETERS\n');
    if ~isempty(paramnames)
        fprintf(fid, 'parameter values:\n');
        for k = 1:numel(paramnames)
            fprintf(fid, '%15s:', paramnames{k});
            for k2 = 1:nens
                fprintf(fid, ' %9.6f,', paramvalues(k2, k));
                if mod(k2, 10) == 0 && k2 < nens
                    fprintf(fid, '\n%s', blanks(16));
                end
            end
            fprintf(fid, '\b\n');
        end
    else
        fprintf(fid, '  (no parameters)\n');
    end
end
if htmlstatus && htmlstatuswritehis
    if performrestart
        histpostfun(0, datestr(now,31), prefix, 'restarted run');
    else
        histpostfun(0, datestr(now,31), prefix, 'started run');
    end
end

%
% calculate stop dates
%

% stoptimes
if iscell(assimfunargs)
    datadates = assimfunargs{2}.assimdates;
else
    datadates = assimfunargs.assimdates;
end
datadates(datadates>=stopdate) = []; 
datadates(datadates<=startdate) = [];
datadates = [datadates(:)', stopdate]; % append stop date

if usebreakfun
    xvec = ' x'; % needed later

    bfundates = bfun.getBreakDates([startdate, stopdate]);
    if bfundates(1) == startdate
        bfundates(1) = [];
    end
    temp = union(datadates, bfundates);
    % unfortunately union does not properly return this info so the next steps are required
    isdatadate = ismember(temp, datadates);
    isbfundate = ismember(temp, bfundates);
    datadates = temp; % copy back
end

if ~exist('adjustnrst', 'var')
    adjustnrst = false; 
end
if adjustnrst
    dstart = str2double(strrep(rif_getvar(fullfile(rundir,maininfile), 'DSTART'), 'd', 'e'));
    fprintf('adjustnrst: DSTART=%f\n', dstart);
    refdatestr = rif_getvar(fullfile(rundir,maininfile), 'TIME_REF');
    refdate = datenum(refdatestr(1:8),'yyyymmdd');
    fprintf('adjustnrst: reference date ''%s'' is translated to %s.\n', refdatestr(1:end-1), datestr(refdate));
    refdateplusdstart = refdate + dstart;
    if keeplog
        fprintf(fid, 'adjustnrst: DSTART=%f\n', dstart);
        fprintf(fid, 'adjustnrst: reference date ''%s'' is translated to %s.\n', refdatestr(1:end-1), datestr(refdate));
        fprintf(fid, 'adjustnrst: date of DSTART (refdate + dstart): %s.\n', datestr(refdateplusdstart));
    end
end

if useinifile
    [inifile, nrrec, octime, timediffdays,octime_unit] = findrestartfile(inicond{1}, inicond{2}, startdate, nrreczeropref); % output ocean_time unit
    if nrrec == 1 
        nrrec = 0;
        fprintf('Make the nrrec from 1 to 0 becuase initial file is used');
    end
    if nrrec > 0
        fprintf('Note that NRREC=%d (greater than zero) which can cause problems if NDEFAVG and other parameters are not set correctly.\n', nrrec);
    end
    if keeplog
        fprintf(fid, '\n');
        fprintf(fid, 'OUTPUT of findrestartfile\n');
        fprintf(fid, ' %s = %s\n','inifile',inifile);
        fprintf(fid, ' %s = %d\n','nrrec',nrrec);
        fprintf(fid, ' %s = %d\n','octime',octime);
        fprintf(fid, ' %s = %s\n','octime_unit',octime_unit); 
        fprintf(fid, ' if octime_unit is not in seconds, it will be converted to seconds for calculation below'); 
        fprintf(fid, '\n');
    end
    if timediffdays ~= 0
        startdate = startdate + timediffdays;
        fprintf('scheduler: adjusting timekeeping due to %1.2f day offset between startdate and date in restartfile\n', timediffdays);
        fprintf('scheduler: new startdate: %d (%s)\n', startdate, datestr(startdate));
        if keeplog
            fprintf(fid, 'scheduler: adjusting timekeeping due to %1.2f day offset between startdate and date in restartfile\n', timediffdays);
            fprintf(fid, 'scheduler: new startdate: %d (%s)\n', startdate, datestr(startdate));
        end
    end
end

% translate to steps
stopsteps = round((datadates-startdate)*86400 / dt);
if usebreakfun
    ind = true(1,numel(stopsteps));
    for k = 1:numel(stopsteps)
        if stopsteps(k) < timestepthresh
            if ~isbfundate(k)
                ind(k) = false;
                if keeplog
                    fprintf(fid,'scheduler: stop date %s (timestep: %d) is removed because it is too close to start date.\n', datestr(datadates(k)), stopsteps(k));
                end
            elseif isdatadate(k) % both
                isdatadate(k) = false;
                if keeplog
                    fprintf(fid,'scheduler: stop date %s (timestep: %d) is removed as a regular stop date because it is too close to start date (it still remains a stop date for the break function).\n', datestr(datadates(k)), stopsteps(k));
                end
            end
        else
            break;
        end
    end
    for k = 1:numel(stopsteps)-2
        if stopsteps(k+1) - stopsteps(k) < timestepthresh
            if isbfundate(k) && isbfundate(k+1) % should never happen
                error('Two break function dates are too close to each other.') 
            end
            if isdatadate(k) && isdatadate(k+1)
                if ~isbfundate(k)
                    ind(k) = false;
                    if keeplog
                        fprintf(fid,'scheduler: stop date %s (timestep: %d) is removed because it is too close to next date %s (timestep: %d)\n', datestr(datadates(k)), stopsteps(k), datestr(datadates(k+1)), stopsteps(k+1));
                    end
                else
                    isdatadate(k) = false;
                    if keeplog
                        fprintf(fid,'scheduler: stop date %s (timestep: %d) is removed as a regular stop date because it is too close to next date %s (timestep: %d; it still remains a stop date for the break function)\n', datestr(datadates(k)), stopsteps(k), datestr(datadates(k+1)), stopsteps(k+1));
                    end
                end 
            elseif stopsteps(k) == stopsteps(k+1) && ind(k)
                isbfundate(k) = false;
                isbfundate(k+1) = true;
                isdatadate(k) = false;
                isdatadate(k+1) = true;
                
                ind(k) = false;
                if keeplog
                    fprintf(fid,'scheduler: stop date %s and %s (both timestep: %d) are merged\n', datestr(datadates(k)), datestr(datadates(k+1)), stopsteps(k+1));
                end
            end
        end
    end
    if stopsteps(end) == stopsteps(end-1)
        ind(end-1) = false;
        if keeplog
            fprintf(fid,'scheduler: stop date %s (timestep: %d) is removed because it shares its timestep with the end date (timestep: %d)\n', datestr(datadates(end-1)), stopsteps(end-1), stopsteps(end));
        end
    end
    stopsteps = stopsteps(ind);
    datadates = datadates(ind);
    isdatadate = isdatadate(ind);
    isbfundate = isbfundate(ind);
    numstartsall = numel(datadates);
    numstarts = sum(isdatadate);
else
    ind = true(1,numel(stopsteps));
    for k = 1:numel(stopsteps)
        if stopsteps(k) < timestepthresh
            ind(k) = false;
            if keeplog
                fprintf(fid,'scheduler: stop date %s (timestep: %d) is removed because it is too close to start date.\n', datestr(datadates(k)), stopsteps(k));
            end
        else
            break; 
        end
    end
    if numel(stopsteps)>=2
        for k = 1:numel(stopsteps)-2
            if stopsteps(k+1) - stopsteps(k) < timestepthresh
                ind(k) = false;
                if keeplog
                    fprintf(fid,'scheduler: stop date %s (timestep: %d) is removed because it is too close to next date %s (timestep: %d)\n', datestr(datadates(k)), stopsteps(k), datestr(datadates(k+1)), stopsteps(k+1));
                end
            end
        end

        if stopsteps(end) == stopsteps(end-1)
            ind(end-1) = false;
            if keeplog
                fprintf(fid,'scheduler: stop date %s (timestep: %d) is removed because it shares its timestep with the end date (timestep: %d)\n', datestr(datadates(end-1)), stopsteps(end-1), stopsteps(end));
            end
        end
    end
    stopsteps = stopsteps(ind);
    datadates = datadates(ind);
    numstarts = numel(datadates);
    numstartsall = numstarts;
end
%if usebreakfun
%    isdatadate = isdatadate(ind);
%    isbfundate = isbfundate(ind);
%    numstartsall = numstarts;
%    numstarts = sum(isdatadate); % overwrite
%end

% return if returndates is true
if returndates
    if keeplog
        fclose(fid);
    end
    datadates = datadates(1:end-1); % take off stop date
    return;
end

if keeplog && ~performrestart
    fprintf(fid, 'scheduler: %d dates between start: %s and stop: %s\n', numstartsall-1, datestr(startdate), datestr(stopdate));
    if usebreakfun
        fprintf(fid, '                                                    data breakfun\n');
        for k = 1:numstartsall-1
            fprintf(fid, '%3d) %20s --> %20s   %s   %s\n', k, datestr(datadates(k)), datestr((stopsteps(k)*dt)/86400+startdate), xvec(isdatadate(k)+1), xvec(isbfundate(k)+1));
        end
    else
        for k = 1:numstartsall-1
            fprintf(fid, '%3d) %20s --> %20s\n', k, datestr(datadates(k)), datestr((stopsteps(k)*dt)/86400+startdate));
        end
    end
end

if simulationmode
    fprintf('scheduler: %d dates between start: %s and stop: %s\n', numstartsall-1, datestr(startdate), datestr(stopdate));
    if usebreakfun
        fprintf('                                                    data breakfun\n');
        for k = 1:numstartsall-1
            fprintf('%3d) %20s --> %20s   %s   %s\n', k, datestr(datadates(k)), datestr((stopsteps(k)*dt)/86400+startdate), xvec{isdatadate(k)+1}, xvec{isbfundate(k)+1});
        end
    else
        for k = 1:numstartsall-1
            fprintf('%3d) %20s --> %20s\n', k, datestr(datadates(k)), datestr((stopsteps(k)*dt)/86400+startdate));
        end
    end
end

if useinifile
%%%%%% convert octime to seconds    
    switch octime_unit(1:3)
      case 'day'
        fac = 86400;
      case 'hou'
        fac = 3600;
      case 'sec'
        fac = 1;
      otherwise
        warning(' ')
        disp(['Got time units of ' octime_unit])
        disp(['but don''t have a rule for converting to seconds'])
        return
    end
%%%%%%%
    octime=octime*fac;
    stopstepsoctime = octime + stopsteps*dt; 
    if adjustdstart
        dstart = octime/86400;
        %stopstepsoctime = stopsteps*dt;
        fprintf('option adjustdstart is active, setting DSTART = %d\n', dstart);
        if keeplog
            fprintf(fid, 'option adjustdstart is active, setting DSTART = %d\n', dstart);
        end
        if adjustnrst
            refdateplusdstart = refdate + dstart; 
        end
    elseif romstimemode == 0
        stopsteps = stopsteps + octime / dt;
        if keeplog
            fprintf(fid, 'scheduler: using ini-file %s; adding %d to all dates (romstimemode == 0, adjustdstart == false)\n', inifile, octime/dt);
        end
    end
else
    stopstepsoctime = stopsteps*dt;
end
if adjustntsavg
    r.scheduleParameterChanges('main', {'NTSAVG'}, {octime/dt});
    if keeplog
        fprintf(fid, 'option adjustntsavg is active, setting NTSAVG = %d\n', octime/dt);
    end
end

if changefrcfile % change the forcing file (i.e., wind forcing file) before the assimilation starts
    nffiles = numel(frccond);  % number of unique forcing files
    if nffiles==1  % e.g., for upwelling test case, wind forcing is the only forcing file
        [wpathstr,wfilename,wfileext] = fileparts(frccond{1});           
        frcfiles = cell(1,nens);
        for k = 1:nens
            frcfiles{k} = fullfile([wpathstr,'/',wfilename,sprintf('_%04d',k),wfileext]);%changeoutputparameters(r, outdir, subprefix{k}, 'rst');
        end
    else
        frcfile = frccond;      
        frcfiles = cell(1,nens);
        for k = 1:nens
            for iidx = 1:numel(idxffiles)
                [wpathstr,wfilename,wfileext] = fileparts(frccond{idxffiles(iidx)});
                frcfile{idxffiles(iidx)} = fullfile([wpathstr,'/',wfilename,sprintf('_%04d',k),wfileext]);%changeoutputparameters(r, outdir, subprefix{k}, 'rst');                
            end  
        
            ffile = frcfile{1};
            for inf = 2:nffiles               
                ffile = [ffile,' \\\',sprintf('\n %s',frcfile{inf})]; % the sed editor used in rif_setvar requires 3 backslashes for a regular backslash. 
                % when using only 1 backslash, the backslash is escaped in system operator; while 2 backslashes produce error 'sed: -e expression #1, char 100: unterminated `s' command'
            end
            frcfiles{k} = ffile;
        end
    end
end

if changebryfile % change the bry file before the assimilation starts
    nffiles = numel(brycond);  % number of unique bry files
    if nffiles==1  % e.g., if there is only 1 boundary file
        [bpathstr,bfilename,bfileext] = fileparts(brycond{1});           
        bryfiles = cell(1,nens);
        for k = 1:nens
            bryfiles{k} = fullfile([bpathstr,'/',bfilename,sprintf('_ens%04d',k),bfileext]);%changeoutputparameters(r, outdir, subprefix{k}, 'rst');
        end
    else      
        bryfile = brycond; 
        bryfiles = cell(1,nens);
        for k = 1:nens
            for iidx = 1:nffiles
                [bpathstr,bfilename,bfileext] = fileparts(brycond{iidx});
                bryfile{iidx} = fullfile([bpathstr,'/',bfilename,sprintf('_ens%04d',k),bfileext]);%changeoutputparameters(r, outdir, subprefix{k}, 'rst');                
            end  
        
            bfile = bryfile{1};
            for inf = 2:nffiles               
                bfile = [bfile,' \|\',sprintf('\n %s',bryfile{inf})]; % the sed editor used in rif_setvar requires 3 backslashes for a regular backslash. 
                % when using only 1 backslash, the backslash is escaped in system operator; while 2 backslashes produce error 'sed: -e expression #1, char 100: unterminated `s' command'
            end
            bryfiles{k} = bfile;
        end
    end
end

% initialize loop related variables
jobids = nan(1, nens);
jobready = true(1,nens);
jobrestarts = -1;
jobstatus = cell(1,nens);
restartfiles = cell(1,nens);
newrunfiles = cell(1,nens);
subprefix = cell(1,nens);
if exist('basename', 'var')
    if ~ischar(basename)
        error('Variable basename (possibly initialized in the settings file) must be a string.')
    end
    basename = strrep(basename, ' ', '_');
    for k = 1:nens
        subprefix{k} = sprintf('%s%04d', basename, k);
    end
    clear basename
else
    for k = 1:nens
        subprefix{k} = sprintf('esp%04d', k);
    end
end
if logjobqueue
    jobqueues = cell(1,nens);
    jobqueuerecorded = false(1,nens);
end
if checklastfilechange
    jobstarttime = nan(1,nens);
end
if usebreakfun 
    stopcounter = 0;
end 

if performrestart
    % initializing restart files and updating r
    for k = 1:nens
        restartfiles(k) = changeoutputparameters(r, outdir, subprefix{k}, 'rst');
    end
    
    % check if directories exist
    if keeplog
        fprintf(fid, 'romsassim: preparing for restart now\n   performing checks:\n');
    end
    if ~exist(rundir, 'dir')
        if keeplog
            fprintf(fid, ' ! cannot find rundir ''%s''\n', rundir);
        end
        error('Cannot find rundir ''%s''.', rundir)
    end
    if ~exist(fullfile(rundir, outdir), 'dir')
        if keeplog
            fprintf(fid, ' ! cannot find outdir ''%s''\n', fullfile(rundir, outdir));
        end
        error('Cannot find outdir ''%s''.', fullfile(rundir, outdir))
    end
    for k = 1:nens
        if ~exist(fullfile(rundir, restartfiles{k}), 'file')
            if keeplog
                fprintf(fid, ' ! cannot find restart file %d ''%s''\n', k, fullfile(rundir, restartfiles{k}));
            end
            error('Cannot find restart file %d ''%s''.', k, fullfile(rundir, restartfiles{k}))
        end
    end
    % read restart time entries
    allok = true;
    for k = 1:nens
        tmp = try_nc_varget_log(fid, 10, fullfile(rundir, restartfiles{k}), 'ocean_time');
        if k == 1
            restart_octime = tmp(end);
        else
            if restart_octime ~= tmp(end)
                if keeplog
                    fprintf(fid, ' ! last ocean_time entries in restart file %d and %d differ (%s and %s)\n', 1, k, restart_octime, tmp(end));
                end
                if allok
                    fprintf('Last ocean_time entries in restart file %d and %d differ.\n', 1, k);
                    allok = false;
                    fprintf('   %s: octime=%d\n', restartfiles{1}, restart_octime);
                    fprintf('   %s: octime=%d\n', restartfiles{k}, tmp(end));
                else
                    fprintf('   %s: octime=%d\n', restartfiles{k}, tmp(end));
                end
            end
        end
    end
    if ~allok
        error('Cannot restart - last ocean_time entries in restart files differ.')
    end
    if userspecifiediniparams
        if keeplog
            fprintf(fid, ' ! initial parameters are specified, ensure that these are suitable for restarting.\n'); %TODO
        end
        warning('Initial parameters are specified, ensure that these are suitable for restarting.')
    end
    
    
    % find current time step 
    tmp = find(stopstepsoctime == restart_octime);
    if isempty(tmp)
        if keeplog
            fprintf(fid, ' ! invalid ocean_time in restart files (does not match time in data; restart_octime == %d).\n', restart_octime);
        end
        fprintf('A problem occurred, printing stopstepsoctime:\n')
        disp(stopstepsoctime)
        error('Cannot restart - invalid ocean_time in restart files (does not match time in data; restart_octime == %d).', restart_octime)
    end
    
    if keeplog
        fprintf(fid, '   done performing checks\n');
    end
    
    jobrestarts = tmp-1;
    performrunrestart = false;
    
    if usebreakfun
        stopcounter = tmp;
        assimstepcounter = sum(stopstepsoctime(isdatadate) <= restart_octime);
    else
        assimstepcounter = jobrestarts + 1;
    end
    if restart_performassimstep
        assimstepcounter = assimstepcounter - 1;
    end
    
    if keeplog
        fprintf(fid, 'romsassim: restarting now\n');
    end
    clear restart_octime
else
    assimstepcounter = 0;
    performrunrestart = false;
end
counter = 0;
continuerunning = true;
errormemory.erroroccured = false;
errormemory.error = [];
errormemory.message = '';
errormemory.newerror = true;

fprintf(' - starting main loop\n\n');
if keeplog
    fprintf(fid, '\nromsassim: starting main loop\n\n');
end

if collectoutput
    assimoutcontainer = cell(1,numstarts-1);
end
if verifynetcdftime
    numfailedrestarts = zeros(1,nens);
end

% main loop
while continuerunning
    if usebreakfun
        if stopcounter == numstartsall
            break; % end is reached, just continue to monitor the last run
        end
        if stopcounter > 0
            if performrestart
                performassimstep = false;
                performrestart = false;
            else
                if isbfundate(stopcounter) && ~restart_performassimstep
                    fprintf('scheduler: performing stop for break function.\n');
                    if keeplog
                        fprintf(fid, 'scheduler: performing stop for break function.\n');
                    end
                    if keeplog
                        bfun.performBreak(datadates(stopcounter), rundir, restartfiles, fid);
                    else
                        bfun.performBreak(datadates(stopcounter), rundir, restartfiles, 1);
                    end
                    if isdatadate(stopcounter)
                        fprintf('scheduler: data is available, too; performing double-stop.\n');
                        if keeplog
                            fprintf(fid, 'scheduler: data is available, too; performing double-stop.\n');
                        end
                    end
                end
                performassimstep = isdatadate(stopcounter);
            end
        else
            performassimstep = false;
        end
        stopcounter = stopcounter + 1;
    else
        if performrestart
            performassimstep = restart_performassimstep;
            performrestart = false;
        else
            if jobrestarts+1 == numstarts
                break; % end is reached, just continue to monitor the last run
            end
            performassimstep = jobrestarts > -1;
        end
    end
    if mvncfiles
        if jobrestarts > -1
            if keeplog
                fprintf(fid, 'mvncfiles: moving files.\n');
            end
            fprintf('mvncfiles: moving files.\n');
            sprintf(mvncfilesstr, jobrestarts)
            system(sprintf(mvncfilesstr, jobrestarts));
        end
    end
    % DA step
    if performassimstep
        assimstepcounter = assimstepcounter + 1;
        fprintf('%s: assimilation step %d\n', datestr(now), assimstepcounter)
        if keeplog
            fprintf(fid,'assimilation step %d\n', assimstepcounter);
            if logparamvalues
                if ~isempty(paramnames)
                    fprintf(fid, 'parameter values:\n');
                    for k = 1:numel(paramnames)
                        fprintf(fid, '%15s:', paramnames{k});
                        for k2 = 1:nens
                            fprintf(fid, ' %9.6f,', paramvalues(k2, k)); % print out the parameter values used before the assimilation step
                            if mod(k2, 10) == 0 && k2 < nens
                                fprintf(fid, '\n%s', blanks(16));
                            end
                        end
                        fprintf(fid, '\b\n');
                    end
                else
                    fprintf(fid, '  (no parameters)\n');
                end
            end
        end
        if ~simulationmode
            try
                if collectoutput || constparamsif  
                    if iscell(assimfunargs)  % assimfunargs is a cell containing mutlpile assimfunction arguments for different assimfunctions
                        for iassimF = 1:numel(assimfunargs)/2
                            if iassimF == 1
                                [out1, assimout] = assimfun(assimstepcounter, stopstepsoctime(jobrestarts+1), datadates(jobrestarts+1), rundir, restartfiles, paramnames, paramvalues, fid, assimfunargs{iassimF*2}); % updated by physical variables definded in 1st kfparamsfile in assimfunargs{2}
                            else
                                [out1, assimout] = assimfun(assimstepcounter, stopstepsoctime(jobrestarts+1), datadates(jobrestarts+1), rundir, restartfiles, paramnames, out1       , fid, assimfunargs{iassimF*2}); % updated by biological variables definded in 2nd kfparamsfile in assimfunargs{4}
                            end
                        end
                    else
                        [out1, assimout] = assimfun(assimstepcounter, stopstepsoctime(jobrestarts+1), datadates(jobrestarts+1), rundir, restartfiles, paramnames, paramvalues, fid, assimfunargs);
                    end
                    
                    if constparamsif
                        constparamsif_renewparameters = ~(isempty(out1) || isequalwithequalnans(paramvalues,out1));
                    end
                    if collectoutput
                        assimoutcontainer{jobrestarts+1} = assimout;
                    end
                    if saveoutput 
                        save(fullfile(rundir,sprintf('/stats_out/romsassim_assimout%03d.mat', assimstepcounter)),'paramvalues','paramnames');
                    end
                else
                    if iscell(assimfunargs)  % assimfunargs is a cell containing mutlpile assimfunction arguments for different assimfunctions
                        for iassimF = 1:numel(assimfunargs)/2
                            assimfun(assimstepcounter, stopstepsoctime(jobrestarts+1), datadates(jobrestarts+1) ,rundir, restartfiles, paramnames, paramvalues, fid, assimfunargs{iassimF*2});                            
                        end
                    else
                        assimfun(assimstepcounter, stopstepsoctime(jobrestarts+1), datadates(jobrestarts+1) ,rundir, restartfiles, paramnames, paramvalues, fid, assimfunargs);
                    end
                end
            catch assimerror
                errormemory.erroroccured = true;
                errormemory.error = assimerror;
                errormemory.newerror = false;
                warning('testautorestart:assimError', 'Error in assimfun.')
                printstacktrace(2, assimerror);
                if keeplog
                    fprintf(fid, '\nerror: Error in assimilation routine.\n');
                    fprintf(fid, '-- begin stack trace --\n');
                    printstacktrace(fid, assimerror);
                    fprintf(fid, '-- end stack trace --\n');
                end
                fprintf('terminating simulation\n')
                if keeplog
                    fprintf(fid, 'scheduler: terminating simulation!\n');
                end
                continuerunning = false;
                break
            end
        end
    end
    % /DA step

    % start jobs
    if jobrestarts > -1
        stepsize = stopsteps(jobrestarts+2) - stopsteps(jobrestarts+1);
    else
        if useinifile && romstimemode == 0 && ~adjustdstart
            stepsize = stopsteps(1) - octime / dt; 
        else
            stepsize = stopsteps(1);
        end
    end

    if romstimemode == 0 || romstimemode == 2
        ntimesnrstvalues = [1 1]*stopsteps(jobrestarts+2);
    elseif romstimemode == 1
        if jobrestarts > -1
            ntimesnrstvalues = [1 1]*(stopsteps(jobrestarts+2)-stopsteps(jobrestarts+1));
        else
            ntimesnrstvalues = [1 1]*stopsteps(jobrestarts+2);
        end
    end
    if adjustnrst
        fprintf('adjustnrst: date of DSTART (refdate + dstart): %s.\n', datestr(refdateplusdstart));
        if jobrestarts > -1
            if romstimemode == 0 && ~adjustdstart
                prevdatenum = (stopsteps(jobrestarts+1)*dt)/86400+startdate-octime/86400;
            else
                prevdatenum = (stopsteps(jobrestarts+1)*dt)/86400+startdate;
            end
        else
            prevdatenum = startdate;
        end
        fprintf('adjustnrst: date in initial file: %s.\n', datestr(prevdatenum));
        nrst = (prevdatenum-refdateplusdstart)*86400/dt;
        fprintf('adjustnrst: number of steps between date of DSTART and date in initial file: %d.\n', nrst); 
        if keeplog
            fprintf(fid, 'adjustnrst: date in initial file: %s.\n', datestr(prevdatenum));
            fprintf(fid, 'adjustnrst: number of steps between date of DSTART and date in initial file: %d.\n', nrst);
        end
        nrst = nrst + stepsize;
        fprintf('adjustnrst: adding stepsize=%d, to get NRST=%d\n', stepsize, nrst);
        if keeplog
            fprintf(fid, 'adjustnrst: adding stepsize=%d, to get NRST=%d\n', stepsize, nrst);
        end
        ntimesnrstvalues(2) = nrst;
    end

    nextoctime = stopstepsoctime(jobrestarts+2);
    %if adjustdstart
    %    nextoctime = nextoctime + dstart*dt; 
    %end
    if keeplog
        if romstimemode == 0
            nextdatenum = (stopsteps(jobrestarts+2)*dt)/86400+startdate-octime/86400;
        else
            nextdatenum = (stopsteps(jobrestarts+2)*dt)/86400+startdate;
        end
        fprintf(fid,'scheduler: next stop date %s (NTIMES = %d, ocean_time = %d)\n', datestr(nextdatenum), ntimesnrstvalues(1), nextoctime);
        fprintf(fid, 'scheduler: stepsize = %d\n', stepsize);
        fprintf(fid, '%s: starting runs 1 - %d\n', datestr(now), nens);
    end

    
    % begin loop

    for k = 1:nens
        r.scheduleParameterChanges('main', {'NTIMES', 'NRST'}, ntimesnrstvalues);
        if adjustntsavg
            r.scheduleParameterChanges('main', {'NTSAVG'}, {octime/dt})
        end
        if jobrestarts > -1
            r.scheduleParameterChanges('main', {'ININAME', 'NRREC'}, {restartfiles{k}, -1});
        else
            if useinifile
                if changeinifile
                    r.scheduleParameterChanges('main', {'ININAME', 'NRREC'}, {inifiles{k}, nrrec});
                else
                    r.scheduleParameterChanges('main', {'ININAME', 'NRREC'}, {inifile, nrrec});
                end
            end
        end
        if changefrcfile
            r.scheduleParameterChanges('main', {'FRCNAME'}, {frcfiles{k}});
            if k==1
                fprintf(fid, 'modify forcing files');
            end
        end 
        
        if changebryfile
            r.scheduleParameterChanges('main', {'BRYNAME'}, {bryfiles{k}});
            if k==1
                fprintf(fid, 'modify boundary files');
            end
        end         
                    
        if adjustdstart
            r.scheduleParameterChanges('main', {'DSTART'}, {dstart})
        end
        if adjustldefout
            if jobrestarts > -1
                r.scheduleParameterChanges('main', {'LDEFOUT'}, {'F'})
            else
                r.scheduleParameterChanges('main', {'LDEFOUT'}, {'T'})
            end
        end
        if constparams 
            if jobrestarts == -1
                % draw and write initial parameters
                if userspecifiediniparams
                    r.scheduleParameterChanges('auto', paramnames, paramvalues(k,:));
                elseif isempty(betaid)
                    paramvalues(k,:) = rpv.scheduleParameterChanges(r); % draw new parameters (for jobrestarts==-1 only) 
                else
                    paramvalues(k,:) = rautil_betaanneal(betaid, 1);
                    r.scheduleParameterChanges('auto', paramnames, paramvalues(k,:));
                end
                %fprintf('DEBUG --------------------\n')
                %paramvalues
                %r.printScheduledChanges()
                %fprintf('/DEBUG -------------------\n')
            else
                % reuse 'old' parameter values
                r.scheduleParameterChanges('auto', paramnames, paramvalues(k,:));
            end
        elseif constparamsif 
            if constparamsif_renewparameters
                if keeplog && k == 1
                    fprintf(fid, 'constparamsif: redrawing parameters now\n');
                end
                % draw new parameters
                paramvalues(k,:) = rpv.scheduleParameterChanges(r);
            end
        else
            % draw new parameters
            paramvalues(k,:) = rpv.scheduleParameterChanges(r); 
        end
        restartfiles(k) = changeoutputparameters(r, outdir, subprefix{k}, 'rst'); % parameters relative to rundir
            
        if writefiles
            newmaininfile = r.writeOut(subprefix{k}); % write out the in-files with the scheduled parameter changes
        end
        
        newrunfiles{k} = fullfile(rundir, sprintf('%srunfile.sh', subprefix{k}));      
        templatefile=['../roms/filemanipulation/templatefiles/mpirun_' lower(clusterName) '.template']; 
        
        if jobrestarts == -1 && writefiles
            createrunfiledir(newrunfiles{k}, rundir, executable, newmaininfile, sprintf('%s.out', subprefix{k}), np, subprefix{k}, templatefile, true, ...
                fullfile(rundir, sprintf('stdout%04d.txt', k)), fullfile(rundir, sprintf('stderr%04d.txt', k)));  
        end
        
        fprintf('%s: starting run %d', datestr(now), k)
        if simulationmode
            status = (rand < errorprob)*1;
            jobid = jobidcounter;
            jobidcounter = jobidcounter + 1;
        else
             pause(6)  % When there are a lot of jobs submitted simultaneously by other users, the batch job submission might fail. 
                            % To be safe, we add a pause of a few seconds between submitting the jobs
             [status, jobid] = qsubmpi(newrunfiles{k}, rundir, clusterName);
            
            if checklastfilechange
                jobstarttime(k) = now;
            end
        end
        jobready(k) = false;
        if status == 0
            jobids(k) = jobid;
            fprintf(' id:%d\n', jobids(k))
        else
            fprintf('\n')
            errormemory.erroroccured = true;
            errormemory.message = 'Error submitting job to queue (status ~= 0).';
            errormemory.newerror = true; 
            warning('Error submitting job to queue.')
            if keeplog
                fprintf(fid, 'Warning: Error submitting for run %d to queue.\n', k);
            end
            fprintf('terminating simulation\n')
            if keeplog
                fprintf(fid, 'scheduler: terminating simulation!\n');
            end
            continuerunning = false;
            break
        end
    end
    if ~continuerunning
        break
    end
    % /start jobs
    
    % wait for jobs
    if logjobqueue
        for k = 1:nens
            jobqueues{k} = '';
        end
        jobqueuerecorded(:) = false;
    end
    if keeplog && ~logjobqueue
        romsassim_logjobdesc(fid, jobids);
    end
    jobrestarts = jobrestarts + 1;
    
    % start waiting loop
    while ~all(jobready)
        statuschange = false;
        if ~simulationmode
            % Sometimes the cluster will give empty status while the simulation is still running (weird!)...
            % the following lines are to double check if the job has actually finished
            nrepeat = 5;  ncount=1;
            while (any(cellfun('isempty',jobstatus(~jobready))) && ncount<nrepeat) | ncount == 1
                ncount = ncount+1;
                jobstatus(~jobready) = qjobstatus(jobids(~jobready),clusterName);
            end
        end
        if logjobqueue
            if ~all(jobqueuerecorded)
                jobqueues(~jobqueuerecorded) = qjobqueue(jobids(~jobqueuerecorded),clusterName);
            end
        end
        for k = 1:nens
            if logjobqueue
                if ~jobqueuerecorded(k) && ~isempty(jobqueues{k})
                    jobqueuerecorded(k) = true;
                    if keeplog && all(jobqueuerecorded)
                        romsassim_logjobdesc(fid, jobids, jobqueues);
                    end
                end
            end
            if ~jobready(k) && jobrestarts < numstartsall
                if simulationmode
                    jobready(k) = rand < jobreadyprob;
                else
                    jobready(k) = isempty(jobstatus{k});
                end
                if jobready(k)
                    fprintf('%s: finished run %d\n', datestr(now), k);
                    if keeplog
                        fprintf(fid,'%s: finished run %d\n', datestr(now), k);
                    end
                    statuschange = true;

                    if verifynetcdftime
                        allok = romsassim_verifynetcdftime(rundir, restartfiles(k), nextoctime, -1, false, fid);
                        if allok
                            numfailedrestarts(k) = 0;    
                        else
                            numfailedrestarts(k) = numfailedrestarts(k) + 1;
                            if numfailedrestarts(k) > numfailedrestartthresh
                                fprintf('verifynetcdftime: job %d: number of failed restarts exceeds threshold; terminating simulation!\n', k);
                                if keeplog
                                    fprintf(fid, 'verifynetcdftime: job %d: number of failed restarts exceeds threshold; terminating simulation!\n', k);
                                end
                                errormemory.erroroccured = true;
                                errormemory.message = 'Number of failed restarts exceeds threshold.';
                                errormemory.newerror = true;
                                continuerunning = false;
                                break
                            else
                                performrunrestart = true;
                            end
                        end
                    end
                elseif resubmitonerror && ~simulationmode
                    if any(jobstatus{k} == clusterStatus{3}) % check for error status
                        fprintf('scheduler: queue indicates error for job %d; resubmitting!\n', k);
                        if keeplog
                            fprintf(fid, 'scheduler: queue indicates error for job %d (status: %s); resubmitting the job.\n', k, jobstatus{k});
                        end
                        if logqerror
                            qerrorcount = qerrorcount + 1;
                            qerrors(qerrorcount).jobid = jobids(k);
                            qerrors(qerrorcount).status = jobstatus{k};
                            if logjobqueue && jobqueuerecorded(k)
                                qerrors(qerrorcount).host = jobqueues{k};
                            else
                                qerrors(qerrorcount).host = qjobqueue(jobids(k));
                            end
                        end
                        performrunrestart = true;
                    elseif strcmp(jobstatus{k}, clusterStatus{2})
                        if checklastfilechange
                            jobstarttime(k) = now;
                        end
                    elseif checklastfilechange && (now-jobstarttime(k))*86400 > lastfilechangethresh %&& exist(fullfile(rundir, sprintf('%s.out', subprefix{k})), 'file')
                        lastfilechange = unix_statlastfilechange(fullfile(rundir, outdir, sprintf('%s_%s.nc', lastfilechangetype, subprefix{k})), now, true);
                        if lastfilechange > lastfilechangethresh
                            fprintf('checklastfilechange: last change in %s file for job %d exceeds threshold (%ds); deleting job.\n', upper(lastfilechangetype), k, round(lastfilechange));
                            if keeplog
                                fprintf(fid, 'checklastfilechange: last change in %s file for job %d exceeds threshold (%ds); deleting job.\n', upper(lastfilechangetype), k, round(lastfilechange));
                                fprintf(fid, 'checklastfilechange: output file: ''%s''; unix_statlastfilechange reading: %g\n', fullfile(rundir, outdir, sprintf('%s_%s.nc', lastfilechangetype, subprefix{k})), lastfilechange);
                            end
                            qdel(jobids(k),clusterName);
                            if logfchangeerror
                                fchangeerrorcount = fchangeerrorcount + 1;
                                fchangeerrors(fchangeerrorcount).jobid = jobids(k);
                                fchangeerrors(fchangeerrorcount).status = jobstatus{k};
                                if logjobqueue && jobqueuerecorded(k)
                                    fchangeerrors(fchangeerrorcount).host = jobqueues{k};
                                else
                                    fchangeerrors(fchangeerrorcount).host = qjobqueue(jobids(k));
                                end
                            end
                            performrunrestart = true;
                        end
                    end
                end
                if performrunrestart
                    performrunrestart = false;
                    fprintf('%s: restarting run %d', datestr(now), k)
                    if keeplog
                        fprintf(fid,'%s: restarting run %d', datestr(now), k);
                    end
                    [status, jobid] = qsubmpi(newrunfiles{k}, rundir, clusterName);
                    
                    if checklastfilechange
                        jobstarttime(k) = now;
                    end
                    jobready(k) = false;
                    if status == 0
                        jobids(k) = jobid;
                        fprintf(' id:%d\n', jobids(k))
                        if keeplog
                            fprintf(fid,' id:%d\n', jobids(k));
                        end
                    else
                        fprintf('\n')
                        warning('testautorestart:qsubError', 'Error submitting job to queue.')
                        fprintf('terminating simulation\n')
                        errormemory.erroroccured = true;
                        errormemory.message = 'Error submitting job to queue (status ~= 0).';
                        errormemory.newerror = true;
                        if keeplog
                            fprintf(fid, '\nerror: Error submitting job to queue.\n');
                            fprintf(fid, 'scheduler: terminating simulation!\n');
                        end
                        continuerunning = false;
                        break
                    end
                end
            end
        end
        if ~continuerunning
            break
        end
        if ~statuschange
            pause(pauseint)
        end
        counter = counter + 1;
        
        % status message
        if mod(counter, 5) == 0
            romsassim_printstatus(1, jobrestarts+1, numstartsall+1, jobids, jobstatus, clusterStatus);
            
            if htmlstatus
                romsassim_printhtmlstatus(htmlstatustmpfile, prefix, jobrestarts+1, numstarts+1, jobids, jobstatus);
                [stat, mesg] = unix_scp(htmlstatustmpfile, htmlstatustdest, htmlstatusscpport);
                if stat ~= 0
                    fprintf('error sending HTML status file:\n');
                    fprintf(mesg);
                end
            end
        end
        
    end
    if logjobqueue
        if ~all(jobqueuerecorded) && keeplog
            romsassim_logjobdesc(fid, jobids, jobqueues);
        end
    end
    % /wait for jobs
end

if mvncfiles
    if keeplog
        fprintf(fid, 'mvncfiles: moving files.\n');
    end
    fprintf('mvncfiles: moving files.\n');
    sprintf(mvncfilesstr, jobrestarts)
    system(sprintf(mvncfilesstr, jobrestarts));
end
if logqerror
    if keeplog
        romsassim_logqerrorsummary(fid, qerrors);
    else
        romsassim_logqerrorsummary(1, qerrors);
    end
end
if logfchangeerror
    if keeplog
        romsassim_logerrorsummary(fid, 'last file change error summary', fchangeerrors);
    else
        romsassim_logerrorsummary(1, 'last file change error summary', fchangeerrors);
    end
end

if errormemory.erroroccured 
    if htmlstatus && htmlstatuswritehis
        histpostfun(1, datestr(now,31), prefix, 'terminated with error');
    end

    if rmfilesonerror
        if rmallbutlog
            romsassim_erasetrace({fullfile(rundir, outdir), rundir, logfile}, true);
        else
            romsassim_erasetrace({fullfile(rundir, outdir), rundir, logfile});
        end
    end
    
    if saveerrors
        % new feature: saving error information
        errorinfo = rmfield(errormemory, 'erroroccured');
        if keeplog
            fprintf(fid, 'option ''saveerrors'' is active, saving error information in ''%s''.\n', fullfile(rundir, sprintf('romsassim_error_%s', prefix)));
        end
        save(fullfile(rundir, sprintf('romsassim_error_%s', prefix)), '-struct', 'errorinfo')
    end
    if rethrowerrors
        if keeplog
            fprintf(fid, 'scheduler: option ''rethrowerrors'' is active, error will be rethrown.\n');
            fclose(fid);
        end
        if errormemory.newerror
            error(errormemory.message);
        else
            rethrow(errormemory.error); 
        end
    end
else
    if htmlstatus
        romsassim_printhtmlstatus(htmlstatustmpfile, prefix, -1, numstarts+1, jobids, jobstatus);
        [stat, mesg] = unix_scp(htmlstatustmpfile, htmlstatustdest, htmlstatusscpport);
        if stat ~= 0
            fprintf('error sending HTML status file:\n');
            fprintf(mesg);
        end
        if htmlstatuswritehis
            histpostfun(0, datestr(now,31), prefix, 'finished run');
        end
    end
    if rmallbutlog
        try        
            romsassim_erasetrace({fullfile(rundir, outdir), rundir, logfile}, true, true); % perform time analysis
        catch anerror
            fprintf('error removing files\n')
            if keeplog
                fprintf(fid, 'error removing files.\n');
                printstacktrace(fid, anerror);
            end
        end
    end
end

if keeplog
    fprintf(fid, ' -- END OF LOG --\n');
    fclose(fid);
end

if nargout > 0
    datadates = datadates(1:end-1); % take off stop date again
end
