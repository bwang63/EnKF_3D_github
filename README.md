# EnKF_3D_github
The `MATLAB` code included in this repository is used to perform the deterministic formulation of Ensemble Kalman Filter (DEnKF) in the Regional Ocean Modelling System (ROMS; https://www.myroms.org/wiki/Documentation_Portal).

This set of code was developed by the MEMG group (http://memg.ocean.dal.ca/index.html) in Dalhousie University, Canada

The code in this repository is configured for a 3-dimensional ocean biogeochemical model (using ROMS) in an idealized channel that experiences the wind-driven
upwelling as in Yu et al. (2018). This code will initiate the ensemble runs with the perturbed wind forcing and biological parameters, then assimilate observations to update the model
state variables, and restart the ensemble runs from the updated initial state. In this application, we have two assimilation steps. In the first step, we
assimilate the physical observations (i.e., sea surface height, sea surface temperature, and in-situ profiles of temperature) to update both physical and
biological model state variables (i.e., temperature and NO3). In the second step, we assimilate the biological observations (i.e., surface chlorophyll and
in-situ profiles of NO3) to update only biological model state variables (i.e., chlorophyll, phytoplankton, zooplankton, and NO3)

## Subdirectories
`matlab` -- toolbox directory, e.g. netcdf

`mfiles` -- data assimilation code directory

         main -- data assimilation setting up scripts

              main.m -- the main driver

              romsassim_settings_2kfiles.m -- settings about ROMS model

              KFilter_2steps_*.m -- settings about the data assimilation
                                    (in this application, we have two KFilter_2steps_*.m scripts becuase we have two update steps)

         EnKF -- data assimilation functions

         roms -- ROMS interface scripts

         local -- scripts to add toolbox

         helper -- helper routines

`in` -- input files directory

        executable -- executable file of ROMS

        infiletemplates -- input files of ROMS

        input_forcing -- input forcing files


`out` -- output files directory

`matfiles` -- temporary matrixes saved and used in data assimilation

`figures` -- reading output directory

**_note_**: The first 2 directories (i.e., `matlab` and `mfiles`) contain codes for data assimilation and are suggested being saved under the home directory on the clusters. The last 4 directories contain data and are typical large in size. Therefore they are suggested being saved under a different directory, e.g. the scratch directory. The path of `in`, `out`, and `matfiles` directories will be specified by users in the setting up scripts:

1). to specify the path of in and out directories in the script `./main/romsassim_settings_2kfiles.m`
```matlab
% main directory with the runfiles
rundir = fullfile('/misc/7/output/bwang/EnKF_3D_Nature_Primer/out/', prefix); % (edit)

if writefiles
    % create rundir now
    mkdir(rundir);
end

%
% all paths are relative to rundir
%

% the executable file of ROMS (e.g. oceanM)
executable = '../../in/executable/oceanM'; % (edit)

% the main in-file (e.g. ocean.in)
maininfile = '../../in/infiletemplates/ocean_upw.in'; % (edit)

% the biological parameter file (bio_Fennel.in)
bioparamfile = '../../in/infiletemplates/bio_Fennel_upw.in'; % (edit)

% directory for the netcdf output files
outdir = fullfile('nc_out'); % this directory is inside the rundir.
```

2) to specify the path of matfiles directory in `./main/KFilter_2step_*m`
```matlab
% path of the sub-directory matfile: matrixes created and used in data
% assimilation will be saved under this directory, e.g. distance and
% horizontal localization coefficient
%
kfparams.matfilesdir = '/misc/7/output/bwang/EnKF_3D_Nature_Primer/matfiles'; % (edit)
if ~exist(kfparams.matfilesdir,'dir')
    mkdir(kfparams.matfilesdir)
end
```
And the `out` and `matfiles` directories will be created by the code if they don't exist.

## To start a new data assimilation run
### Step 1: Register at the ROMS website (www.myroms.org) and download the source code

### Step 2: Prepare the model input files and save them in the `in` directory (the path of these files will be specified in step 5)
#### 1) The executable file of ROMS (e.g., oceanM or romsM in the latest version of ROMS)
- Set options <MY_ROOT_DIR> <MY_ROMS_SRC> in the build script (`in/executable/build.sh`). These options will tell the script where the ROMS source code is
- Set options <FORT> to specify the compiler that will be used, e.g. ifort
- Compile ROMS by running the following command in terminal:

```
./build.sh
```
**_note_**: the CPP options used in the model are defined in the head file (e.g., upwelling.h). The head file is specified by the option <ROMS_APPLICATION> in the build script

#### 2) The input script of ROMS (e.g., ocean_upw.in or roms_\*.in in the latest version of ROMS)
- Type '(edit)' to search for the settings that need changes to run this application. Other settings might have been tested for other applications

#### 3) The input script of biological component (e.g., bio_Fennel_upw.in, no changes required for our testing case but users are encouraged to test different parameter values)
#### 4) The metadata variable definition file (varinfo_upw.dat, available in the ~in~ directory or in the ROMS source code: ROMS/External/varinfo.dat)
#### 5) The model grid file (e.g., upw_grd.nc, available in https://drive.google.com/drive/folders/1shdtK2iL6aRak70kQOvcS460DafGkrq9?usp=sharing)
#### 6) The model forcings (available in https://drive.google.com/drive/folders/1shdtK2iL6aRak70kQOvcS460DafGkrq9?usp=sharing):
- atmospheric forcing (e.g., the wind forcing, upw_suvstr_3hourly_180d_2Lm_06_\*.nc)
- initial condition (e.g., upw_ini.nc)
- open boundary condition (not applicable in this testing case)

#### 7) The observation file (e.g., UPW_super_obs_satellite_in-situTN.nc, available in https://drive.google.com/drive/folders/1shdtK2iL6aRak70kQOvcS460DafGkrq9?usp=sharing)

### Step 3: A template of jobs submission script has to be provided if run the data assimilation in a new cluster/supercomputer
- `mfiles/roms/autorun/filemanipulation/templatefiles/mpirun_clusterName.template`

**_note_**: The clusterName should be in lower case.

Here is the template used in graham of computecanada '/mfiles/roms/autorun/filemanipulation/templatefiles/mpirun_graham.template'
```
#!/bin/bash
#
# Project identification
#
#SBATCH --account=rrg-ab    # this is your account name
#
# MAX. JOB LENGTH
#
#SBATCH --time=00-02:00           # time (DD-HH:MM)
#
# NODES, CORES/NODE
#
#SBATCH --ntasks=<<NP>>
#
#SBATCH --mem-per-cpu=4700M      # memory; default unit is megabytes
#
# ENVIRONMENT VARIABLES
#
#SBATCH --export=ALL
#
# DO NOT RESTART AUTOMATICALLY
#
#SBATCH --no-requeue
#
# JOB NAME
#
#SBATCH --job-name=<<QNAME>>
#
# EMAIL JOB RESULTS
#
#SBATCH --mail-type=ALL
#SBATCH --mail-user="wangb@gmail.com"
#
# LOG FILE NAMES
#
#SBATCH --output=%x-%j.out
#
# LOAD NETCDF LIBRARY
module load StdEnv/2016.4
module load netcdf-fortran/4.4.4

# MOVE TO PROJECT DIRECTORY
cd <<DIR>>

# SEND JOB
#
srun <<EXECUTABLE>> <<INFILE>> <<OUTFILE>>

```

**_note_**: If the cluster is not using [slurm](https://slurm.schedmd.com/) as a workload manager, four Matlab scripts need to be adapted for other workload managers:
- `mfiles/roms/autorun/qtools/qdel.m`  -- to delete jobs from cluster
- `mfiles/roms/autorun/qtools/qjobqueue.m`  -- to check job host
- `mfiles/roms/autorun/qtools/qjobstatus.m` -- to check job status
- `mfiles/roms/autorun/qtools/qsubmpi.m` -- to submit jobs

### Step 4: Set up the data assimilation experiment
Go to the `main` directory and change settings in the setting up scripts (i.e. `main.m`,`romsassim_settings_1kfiles.m`, `KFilter_2steps_*.m`)
Search for '(edit)' to find settings that likely require changes to run this application. Other settings might have been tested for other applications.

### Step 5: Run the main driver `main.m` in `mfiles/main/`

**_note_**: Running `main.m` will submit jobs to the workload manager, create a new directory, and create, modify and delete files in the newly created directory.
The name an location of the newly created directory is set by the `rundir` variable in `mfiles/main/KFilter_2steps_1.m`.
For testing purposes, the number of jobs submitted to the workload manager can be reduced by decreasing the number of ensemble members (set by the variable `nens` in `mfiles/main/main.m`).

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
