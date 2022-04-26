clear; clc

% add path and toolbox that will be used
run('../local/startup.m')

% check your configuration (edit)
% If set to true, data assimilation will not be started, instead a series of tests is performed.
% It is recommeded to perform a configuration check before running the first data assimilation experiment.
perform_configuration_check = false;

% the name of the supercomputer/cluster
clusterName = 'graham'; % (edit)

% Cell array of 3 status codes used by the workload manager.
% the first status means that the job is running,
% the second status means that the job is waiting
% the third status means that the job has errors
% may need (edit) if slurm is not used to submit jobs
clusterStatus = {'R','PD','F'};

% puts the settings of the random number generator used by RANDN etc to
% their default values so that they produce the same random numbers as
% if you restarted MATLAB.
rng('default')

% number of ensemble members
nens = 20;

% startdate of the ensemble runs
startdate = datenum(2006,01,01);

% stopdate of the ensemble runs
stopdate = datenum(2006,06,25);

% reference date of the ensemble runs
refdate = datenum(2006,01,01);

% data assimilation case name
prefix = 'EnKF_UPW_2kfiles'; % (edit)
logfile = ['log_',prefix,'.txt']; % The name of logfile, its full path will be provided in romsassim_settings_2kfiles.m (rundir)

%
% observations
%
obsfile = '/home/wangb63/scratch/EnKF_3D_Nature_Primer/in/roms_input/UPW_super_obs_satellite_in-situTN.nc'; % (edit)
% the date to perform data assimilate
assimdates = [[datenum('16-Mar-2006'):2:datenum('09-Apr-2006')] [datenum('15-May-2006'):2:datenum('08-Jun-2006')]];

%
% initial condition
%
% - if use an ensemble of initial conditions, the option 'changeinifile'
% has to be added in 'furtheroptions' for romsassim
inidir = '/home/wangb63/scratch/EnKF_3D_Nature_Primer/in/roms_input'; % (edit)
inicond = {inidir 'upw_ini.nc'}; % (edit)

%
% atmospheric forcing file
%
% - if use an ensemble of forcing files, the option 'changefrcfile'
% has to be added in 'furtheroptions' for romsassim
frcdir = '/home/wangb63/scratch/EnKF_3D_Nature_Primer/in/roms_input/wind_forcing/'; % (edit)
frccond = {[frcdir,'upw_suvstr_3hourly_180d_2Lm_06.nc']}; % (edit)

% indexes to atmospheric forcing files that will be changed,
% i.e., frccond{idxffiles}
idxffiles = [1];

% NOTE: should only leave one forcing file name in
% /in/infiletemplates/ocean_*.in file, because the 'changefrcfile' is only
% able to grab and overwrite the first line under 'FRCNAME'.

%
% open boundary condition
%
% - if use an ensemble of open boundary files, the option 'changebryfile'
% has to be added in 'furtheroptions' for romsassim
brydir = '';
brycond = {''};

%
% the romsassim settings file
%
altsettings = 'romsassim_settings_2kfiles';

%
% assimilation function
%
% assimfun = @rassim_template;  % ensemble run w/o DA
assimfun = @rassim_KFilter;    % KFilter-based DA

%
% prepare the 1st rassim function
%
% in this test case, we have two assimilation steps. In the first step, we
% assimilate the physical observations, e.g. SSH and SST, to update both
% physical and biological variables. In the second step, we assimilate only
% biological observations, e.g. surface chlorophyll and in-situ NO3
% profiles to update biological variables. Therefore, we have two rassim
% functions.
assimfunargs1.verifyinput = true;
assimfunargs1.kfparamsfile = 'KFilter_2steps_1';
assimfunargs1.obsfile = obsfile;
assimfunargs1.assimdates = assimdates;
assimfunargs1.refdate = refdate;

%
% prepare the 2nd rassim function
%
% set some options used for rassim_KFilter
assimfunargs2.verifyinput = true;
assimfunargs2.kfparamsfile = 'KFilter_2steps_2';
assimfunargs2.obsfile = obsfile;
assimfunargs2.assimdates = assimdates;
assimfunargs2.refdate = refdate;

%
% combine
%
assimfunargs = {@rassim_KFilter, assimfunargs1, @rassim_KFilter, assimfunargs2};


% clear large variables
clear assimfunargs1 assimfunargs2


% cell containing further options for romsassim
furtheroptions = {'saveoutput', 'logqerror', 'changefrcfile'};

%
% call romsassim
%
% startmode = 0; start a new DA application
%
% startmode = 1; restart a previous DA application that was determined
%     It assumes the romassim run was interrupted before the next
%     assimilation step was performed. It will begin the restart with an
%     assimilation step.
%
% startmode = 2; this option is similar to startmode = 1
%     it will begin the restart with forecast step

startmode = 0;


if perform_configuration_check
    % do not start assimilation
    startmode = -1;

    fprintf('\nchecking configuration\n\nTo turn off this check, set "perform_configuration_check = false" in "%s".\n\n', [mfilename('fullpath'), '.m'])
    check_configuration(assimfunargs, nens, inicond, frccond, brycond, altsettings, furtheroptions);
end


switch startmode
    case 0
        romsassim_multi_clusters('clusterName',clusterName,...
            'clusterStatus',clusterStatus,...
            'nens', nens, ...
            'startdate', startdate, ...
            'stopdate', stopdate, ...
            'assimfun', assimfun, ...
            'assimfunargs', assimfunargs, ...
            'inicond', inicond, ...
            'brycond', brycond, ...
            'frccond', frccond, ...
            'idxffiles',idxffiles,...
            'logfile', logfile, ...
            'altsettings', altsettings, ...
            furtheroptions{:}); % cold start
    case 1
        romsassim_multi_clusters('clusterName',clusterName,...
            'clusterStatus',clusterStatus,...
            'nens', nens, ...
            'startdate', startdate, ...
            'stopdate', stopdate, ...
            'assimfun', assimfun, ...
            'assimfunargs', assimfunargs, ...
            'inicond', inicond, ...
            'brycond', brycond, ...
            'frccond', frccond, ...
            'idxffiles',idxffiles,...
            'logfile', logfile, ...
            'altsettings', altsettings, ...
            'restart', prefix,...
            furtheroptions{:});
    case 2
        romsassim_multi_clusters('clusterName',clusterName,...
            'clusterStatus',clusterStatus,...
            'nens', nens, ...
            'startdate', startdate, ...
            'stopdate', stopdate, ...
            'assimfun', assimfun, ...
            'assimfunargs', assimfunargs, ...
            'inicond', inicond, ...
            'brycond', brycond, ...
            'frccond', frccond, ...
            'idxffiles',idxffiles,...
            'logfile', logfile, ...
            'altsettings', altsettings, ...
            'restart_noassim', prefix,...
            furtheroptions{:});
end

if ~perform_configuration_check
    disp('Jobs Done')
end
