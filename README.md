# Ensemble Kalman filter application for an ocean biogeochemical model in an idealized 3-dimensional channel
The Matlab code included in this repository is used to perform the deterministic formulation of the Ensemble Kalman Filter (DEnKF) in the Regional Ocean Modelling System [ROMS](https://www.myroms.org/wiki/Documentation_Portal).

This set of code was developed by the [MEMG group](http://memg.ocean.dal.ca/index.html) in Dalhousie University, Canada.

The code in this repository is configured for a 3-dimensional ocean biogeochemical model (using ROMS) in an idealized channel that experiences wind-driven
upwelling as in Yu et al. (2018). This code will initiate the ensemble runs with perturbed wind forcing and biological parameters, then assimilate observations to update the model
state variables, and restart the ensemble runs from the updated initial state. In this application, we have two assimilation steps. In the first step, we
assimilate the physical observations (i.e., sea surface height, sea surface temperature, and in-situ profiles of temperature) to update both physical and
biological model state variables (i.e., temperature and NO₃). In the second step, we assimilate the biological observations (i.e., surface chlorophyll and
in-situ profiles of NO₃) to update only biological model state variables (i.e., chlorophyll, phytoplankton, zooplankton, and NO₃)

## To start a new data assimilation run

Before you start, be aware that is application is build for a cluster, requires [Matlab](https://www.mathworks.com/products/matlab.html), a FORTRAN compiler (to compile ROMS), and MPI or OpenMP to [run ROMS on multiple nodes](https://www.myroms.org/wiki/Parallelization).

### Step 1: Download the ROMS code

Register at the [ROMS website](https://www.myroms.org) and download the source code.

### Step 2: Prepare the model input files and save them in the `in` directory (the path of these files will be specified in step 4)

#### 2.1) The ROMS executable (typically `oceanM` or `romsM`)
- Set options `<MY_ROOT_DIR>` `<MY_ROMS_SRC>` in the build script (typically `in/executable/build.sh` or `in/executable/build_roms.sh`). These options will tell the script where the ROMS source code is.
- Set options `<FORT>` to specify the FORTRAN compiler that will be used, e.g. `ifort`.
- Compile ROMS by running the following command in terminal:
```
./build.sh
```
or

```
./build_roms.sh
```

**_Note_**: the CPP options used in the model are defined in the header file (e.g., `upwelling.h`). The header file is specified by the option `<ROMS_APPLICATION>` in the build script.

#### 2.2) The ROMS input file
- Open `in/infiletemplates/roms_upwelling.in` in a text editor.
- Search for '(edit)' to find settings that need changes to run this application. Note that only the paths of the varinfo file and the grid file have to be specified. The paths to other input and output files will be generated by the MATLAB script. 

#### 2.3) The model grid file
- Download the model grid file `upw_grd.nc` (available [here](https://drive.google.com/drive/folders/1VAH-YpFQ8ujcLahLpeTLHV2PD33YHYZc?usp=sharing)) and place it into the `in/roms_input/` directory.

#### 2.4) The model forcings
- Download the wind forcing files `upw_suvstr_3hourly_180d_2Lm_06_\*.nc`, available [here](https://drive.google.com/drive/folders/1VAH-YpFQ8ujcLahLpeTLHV2PD33YHYZc?usp=sharing), and place them into the `in/roms_input/wind_forcing/` directory (alternatively, adjust the `frccond` variable in `mfiles/main/main.m` to point to the files).
- Download the initial condition `upw_ini.nc` file, available [here](https://drive.google.com/drive/folders/1VAH-YpFQ8ujcLahLpeTLHV2PD33YHYZc?usp=sharing), and place it into the `in/roms_input/` directory (alternatively, adjust the `inicond` variable in `mfiles/main/main.m` to point to the file).
- Note, that open boundary condition are not required in this test case, but can be used (and modified by data assimilation) by changing the configuration.

#### 2.5) The observation file
- Download the observation file `UPW_super_obs_satellite_in-situTN.nc`, available [here](https://drive.google.com/drive/folders/1VAH-YpFQ8ujcLahLpeTLHV2PD33YHYZc?usp=sharing), and place it into the `in/roms_input/` directory (alternatively, adjust the `obsfile` variable in `mfiles/main/main.m` to point to the file).

#### 2.6) The input file of ocean biogeochemical model
- No changes to the input file of ocean biogeochemical model (`in/infiletemplates/bio_Fennel_upw.in`) are required in this test case, but users are encouraged to test different parameter values.

### Step 3: Template of a job submission script

This application uses [Slurm](https://slurm.schedmd.com/) as the default workload manager with which model simulations are run on a cluster (see note below, if another workload manager is used).
The Slurm `sbatch` command requires job submission scripts which are typically cluster-specific, and this application requires a template job submission script, which should be named `mfiles/roms/filemanipulation/templatefiles/mpirun_<clusternamelowercase>.template`, where `<clusternamelowercase>` is the name of the cluster in lower case letters.
Example job submission scripts are located in `mfiles/roms/filemanipulation/templatefiles/`, a simple template may look like this:
```
#!/bin/bash
#SBATCH --ntasks=<<NP>>
#SBATCH --export=ALL
#SBATCH --no-requeue
#SBATCH --job-name=<<QNAME>>
#SBATCH --output=<<OUTFILE>>

# move to the project directory
cd <<DIR>>

# run executable
mpirun <<EXECUTABLE>> <<INFILE>>
```
Note here, that expressions in `<<>>` (`<<DIR>>`, `<<EXECUTABLE>>`, `<<INFILE>>`, etc.) will be replaced with appropriate paths when running the data assimilation. The "`cd <<DIR>>`" statement is currently required to be in the job submission script template, and so is a statement that is starting the ROMS executable ("`mpirun <<EXECUTABLE>> <<INFILE>>`" in the example above).

**_Note_**: If the cluster is not using Slurm as a workload manager, four Matlab scripts need to be adapted for other workload managers:
- `mfiles/roms/autorun/qtools/qdel.m`  -- to delete jobs from cluster
- `mfiles/roms/autorun/qtools/qjobqueue.m`  -- to check job host
- `mfiles/roms/autorun/qtools/qjobstatus.m` -- to check job status
- `mfiles/roms/autorun/qtools/qsubmpi.m` -- to submit jobs

### Step 4: Set up the data assimilation experiment

Go to the `main` directory and change settings in the scripts `main.m`,`romsassim_settings_1kfiles.m`, and `KFilter_2steps_*.m`.
Search for '(edit)' to find settings that likely require changes to run this application. Other settings might have been tested for other applications.

### Step 5: Run a configuration check (optional)

In `mfiles/main/main.m`, set
```
perform_configuration_check = true;
```
and then run `main.m` in Matlab to perform an optional configuration check, testing that the paths and file names are set correctly.
When this test produces no warnings, move to step 6 to start a data assimilation run.

### Step 6: Run the main driver `main.m` in `mfiles/main/`

In `mfiles/main/main.m`, turn off the configuration check by setting
```
perform_configuration_check = false;
```
then run `main.m` to perform a data assimilation run.

**_Note_**: Running `main.m` will submit jobs to the workload manager, create a new directory, and create, modify and delete files in the newly created directory.
The name and location of the newly created directory is set by the `rundir` variable in `mfiles/main/KFilter_2steps_1.m`.
For testing purposes, the number of jobs submitted to the workload manager can be reduced by decreasing the number of ensemble members (set by the variable `nens` in `mfiles/main/main.m`).

### Step 7: Customize the data assimilation

After completing the first data assimilation run, feel free to modify the configuration or data assimilation settings or even change the ROMS configuration to perform data assimilation in a differnet model domain.


## Guide to the subdirectories
`matlab` -- toolbox directory, e.g. netcdf

`mfiles` -- data assimilation code directory

         main -- data assimilation setting up scripts

              main.m -- the main driver

              romsassim_settings_2kfiles.m -- settings for the ROMS model

              KFilter_2steps_*.m -- settings for the data assimilation
                                    (in this application, we have two KFilter_2steps_*.m scripts becuase we have two update steps)

         EnKF -- data assimilation functions

         roms -- ROMS interface scripts

         local -- scripts to add toolbox

         helper -- helper routines

`in` -- input files directory

        executable -- executable file of ROMS

        infiletemplates -- input files of ROMS

        roms_input -- input forcing files


`out` -- output files directory

`matfiles` -- temporary matrices saved and used in data assimilation

`figures` -- reading output directory

**_Note_**: The first 2 directories (i.e., `matlab` and `mfiles`) contain codes for data assimilation and are suggested being saved under the home directory on the clusters. The last 4 directories contain data and are typically large in size. Therefore they are suggested being saved under a different directory, e.g. the scratch directory. The path of `in`, `out`, and `matfiles` directories will be specified by users in the set-up scripts:

1). to specify the paths of in and out directories in the script `./main/romsassim_settings_2kfiles.m`
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
executable = '../../in/executable/romsM'; % (edit)

% the main in-file (e.g. ocean.in)
maininfile = '../../in/infiletemplates/roms_upwelling.in'; % (edit)

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
```
And the `out` directory will be created by the code if it does not exist (and its parent directory exists).

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
