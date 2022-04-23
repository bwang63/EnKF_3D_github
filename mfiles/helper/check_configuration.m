function status = check_configuration(assimfunargs, inicond, frccond, brycond, altsettings)

if numel(assimfunargs) >= 4
    fprintf('Checking both "%s" and "%s", there may be duplicate issues.\n', assimfunargs{2}.kfparamsfile, assimfunargs{4}.kfparamsfile)
end

main_fullpath = which('main');

status = 0;

% check inicond

if ~isempty(inicond)
    if ~isdir(inicond{1})
        status = status + 1;
        warning('Initial conditions directory "%s" does not exist (check "inidir" in "%s").', inicond{1}, main_fullpath)
    else
        try
            % will terminate with an error if no initial conditions found
            % Output argument "ctl" (and maybe others) not assigned during call to "roms_timectl".
            ctl = roms_timectl(inicond{1}, inicond{2});
        catch
            status = status + 1;
            warning('No initial condition files found (check "inicond" in "%s").', main_fullpath)
        end
    end
end

% check frccond

if ~isempty(frccond)
    for ifrc = 1:length(frccond)
        if ~isfile(frccond{ifrc})
            warning('Forcing file "%s" does not exist (check "frccond" in "%s").', frccond{ifrc}, main_fullpath)
            status = status + 1;
            break
        end
    end
end

% check brycond

if ~isempty(brycond)
    for ibry = 1:length(brycond)
        if ~isfile(brycond{ibry}) && length(brycond{ibry}) > 0
            warning('Boundary file "%s" does not exist (check "brycond" in "%s")', brycond{ibry}, main_fullpath)
            status = status + 1;
            break
        end
    end
end

% check assimfunargs

if numel(assimfunargs) >= 2
    status = status + check_assimfunargs(assimfunargs{2});
end
if numel(assimfunargs) >= 4
    status = status + check_assimfunargs(assimfunargs{4});
end

% check altsettings
if ~isempty(altsettings)
    s = which(altsettings);
    if isempty(s)
        warning('Settings file "%d" does not exist (check altsettings in "%s").', s, main_fullpath)
        status= status + 1;
    else
        % currently, altsettings needs 2 variables: performrestart and writefiles
        performrestart = false;
        writefiles = false;
        eval(altsettings)
        tmp = split(rundir, '/');
        tmp2 = join(tmp(1:end-2), '/');
        rundir_base = tmp2{1};
        if ~isdir(rundir_base)
            warning('Directory "%s" does not exist (check "rundir" in "%s").', rundir_base, s)
            status = status + 1;
        end
        if ~isfile(executable)
            warning('Executable "%s" does not exist (check "executable" in "%s").', executable, s)
            status = status + 1;
        end
        if ~isfile(maininfile)
            warning('Main in-file "%s" does not exist (check "maininfile" in "%s").', maininfile, s)
            status = status + 1;
        end
        if ~isfile(bioparamfile)
            warning('Biological in-file "%s" does not exist (check "bioparamfile" in "%s").', bioparamfile, s)
            status = status + 1;
        end
    end
end


if status == 0
    fprintf('No configuration issues found.\n')
else
    fprintf('%d configuration issues found (see above).\n', status)
end

end


function status = check_assimfunargs(assimfunargstruct)

main_fullpath = which('main');
status = 0;

if ~isfield(assimfunargstruct, 'obsfile')
    warning('No observation file specified.')
    status= status + 1;
elseif ~isfile(assimfunargstruct.obsfile)
    warning('Observation file "%s" does not exist (check "obsfile" in "%s").', assimfunargstruct.obsfile, main_fullpath)
    status= status + 1;
end

s = which(assimfunargstruct.kfparamsfile);
if isempty(s)
    warning('KF-params file (kfparamsfile) "%d" does not exist (check kfparamsfile definition in "%s").', assimfunargstruct.kfparamsfile, main_fullpath)
    status= status + 1;
else
    % given that it is a file, it should be safe
    loadedfile = false;
    try
        % currently, kfparamsfile may need 2 variables: kfparamsfile and ncdir
        ncdir = 'test';
        kfparamsfile = 'test';
        eval(assimfunargstruct.kfparamsfile)
        loadedfile = true;
    catch
        warning('Error running "%s" (check settings and paths in "%s")', assimfunargstruct.kfparamsfile, s)
        status= status + 1;
    end
    if loadedfile
        if ~isdir(kfparams.matfilesdir)
            warning('Mat-file directory "%s" does not exist (check kfparams.matfilesdir in "%s")', kfparams.matfilesdir, s)
            status= status + 1;
        end
        if ~isfile(kfparams.grd_file)
            warning('Grid file "%s" does not exist (check kfparams.grd_file in "%s")', kfparams.grd_file, s)
            status= status + 1;
        end
    end
end

end

