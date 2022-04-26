#!/bin/bash -l
#SBATCH --job-name=matlab_EnKF_2kfiles
#SBATCH --account=rrg-kfennel-ab # adjust this to match the accounting group you are using to submit joB
#SBATCH --time=00-10:45         # time (DD-HH:MM)     
#SBATCH --ntasks=1
#SBATCH --mem-per-cpu=60G             # adjust this according to your the memory requirement per node you need
#SBATCH --mail-user=wangbin31415926@gmail.com # adjust this to match your email address
#SBATCH --mail-type=ALL

# Choose a version of MATLAB by loading a module:
ulimit -s unlimited
module load StdEnv/2016.4
module load matlab/2020a

# Remove -singleCompThread below if you are using parallel commands:
matlab -nodisplay -singleCompThread -r 'main'

# srun matlab -nodisplay -singleCompThread -r 'myplot'
