% This romsassim settings file contains parameters for the function romsassim
%

% % PARAMETERS

% romstimemode determines the expected behavior of ROMS
% romstimemode = 0 (standard):
% ROMS is expected to "accumulate time", so that if a run starts at an 
% ocean_time of 800 and ntimes is set to 830, ROMS runs 30 steps from 800
% to 830 (older versions of ROMS do this)
% romstimemode = 1:
% ROMS does not accumulate time, so that if a run starts at an ocean_time 
% of 800 and ntimes is set to 830, ROMS runs 830 steps from 800 to 1630
% (newer versions of ROMS do this)
% romstimemode = 2:
% mixed mode; do not accumulate time for the first (starting) step then DO 
% accumulate time for the following restarts 
% (this is only useful under special circumstances)
% romstimemode = 0; % LY: use this option for upwelling case which starts 
% from DSTART=0; but it failed for GOM where ocean_time is not 0,
% ntimes=ocean_time/86400+stepsize_we_want becomes too large that exceeds
% the boundary time limit.
romstimemode = 2; % LY: use mode 1 first then mode 0. 


% If set to true this option will adjust the NRST variable to account for
% values of DSTART and the reference date. If set to false, NRST will be 
% set to the number of steps from the current start to the next stop
% (equal to NTIMES for romstimemode = 1).
% It is recommended to set adjustnrst to true. 
adjustnrst = true;  

% If set to true this option will adjust the LDEFOUT variable in the
% ROMS main in file (ocean.in). LDEFOUT is set to "T" for the initial 
% simulation (until the first stop) and then set to "F" for all subsequent 
% simulations. 
% LDEFOUT = T :create new output files when starting from a restart file
% LDEFOUT = F :append data to existing output files when starting from a restart file
adjustldefout = true;

% resubmit jobs after a queue error occurs
resubmitonerror = true;

% save information about errors that occurred 
% errors are saved in mat files named: romsassim_error_<prefix>.mat
% where <prefix> is the prefix (ID) of a run which is specified below.
% This feature is useful when several romassim runs are performed in sequence
% to identify error sources in runs that were started earlier.
saveerrors = true;

% log the parameter values before they enter
% (only active if a logging is activated by the user)
logparamvalues = true; 

% log the job queue (where the job is processed) for each job
% (only active if a logging is activated by the user)
logjobqueue = true; 

% verify before each assimilation step if the ocean_time is correct
% This is a way to check if the model run finished or was stopped
% unexpectedly e.g. due to an error.
verifynetcdftime = true;

% a threshold number of failed restarts after which romsassim will give up
% attempting to restart the run and quit.
numfailedrestartthresh = 4;

% adjust the ROMS NTSAVG parameter at the beginning of the simulation. If
% adjustntsavg == true, NTSAVG is set to the first timestep of the
% simulation
adjustntsavg = false;

% length of a pause in the main loop (after each pause, a qstat will be
% performed)
pauseint = 10; % in seconds

if ~performrestart
    % prefix appended to filenames
    prefix =  'EnKF_UPW_2kfilesV2';
end

% ROMS step size; should be consistent with that in ocean*.in file
dt = 180;

% threshold used to determine when 2 assimilation dates are too close to
% each other to warrant a new restart
timestepthresh = 2; % in units of dt

% monitor output file activity and delete/restart a job after a time threshold
% of inactivity has passed
checklastfilechange = true;

% the output file to be checked
lastfilechangetype = 'his';

% time threshold for checklastfilechange 
% (only active when checklastfilechange = true)
lastfilechangethresh = 15*60; % in seconds 

% keep a log of all incidents where jobs needed to be restarted due to 
% inactivity 
% (only active when checklastfilechange = true)
logfchangeerror = true;

% number of processors used for each job (NtileI*NtileJ)
np = 8;

% use the RomsParameterVariation to manage parameters in different in-files
% - refer to RomsParameterVariation for descriptions of functions under rpv
rpv = RomsParameterVariation();
% add the bio model input file if needed to perturb parameters there; 
% 'BPARNAM' is a string in ocean.in file to identify bio parameters file 
rpv.addInfile('bio', 'BPARNAM');  
% add parameters with specific distribution to the in-file
rpv.addParameters('bio', 'PhyIS', {'uniform', [0.25 1.75]*0.015}); 
rpv.addParameters('bio', 'ZooGR', {'uniform', [0.25 1.75]*0.6}); 
rpv.addParameters('bio', 'Vp0',  {'uniform', [0.25 1.75]*1.0}); 
rpv.addParameters('bio', 'PhyMR',  {'uniform', [0.25 1.75]*0.1}); 
rpv.addParameters('bio', 'Chl2C_m',  {'uniform', [0.25 1.75]*0.0535}); 

% name of the bio parameter in-file in rpv (linking to BPARNAM)
bioparam = 'bio';

% break function (function used to stop the ROMS runs at given times, e.g.
% to switch the physical model state)
% switch use on or off
usebreakfun = false;

if usebreakfun
    % define break function here
    bfun = [];
end

% move avg and restart files to a different directory after each simulation
% step
% (this functionality is only needed in special cases)
mvncfiles = false;
if mvncfiles
    % name of the subdirectory to move the avg and restart files to
    mvncfilessubdir = 'avghis';
    % cell-str containing masks matching the files that are being moved
    mvncfilesmask = {'avg_*.nc', 'his_*.nc'};
end

%
% % DIRECTORIES
%

% main directory with the runfiles
rundir = fullfile('/misc/7/output/bwang/EnKF_3D_Nature_Primer/out/', prefix); 

if writefiles
    % create rundir now
    mkdir(rundir);
end

%
% all paths are relative to rundir
% 

% the executable file of ROMS (e.g. oceanM)
executable = '../../in/executable/oceanM'; 

% the main in-file (e.g. ocean.in)
maininfile = '../../in/infiletemplates/ocean_upw.in'; 

% the biological parameter file (bio_Fennel.in)
bioparamfile = '../../in/infiletemplates/bio_Fennel_upw.in'; 

% directory for the netcdf output files
outdir = fullfile('nc_out'); % this directory is inside the rundir.

basename = [prefix,'_'];   % prefix for the file names.
