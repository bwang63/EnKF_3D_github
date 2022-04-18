% startup file: change defaults
%

disp(['  Starting ' which(mfilename)])
addpath ../../matlab/mexcdf
addpath('../../matlab/mexcdf/mexnc','-end')
addpath('../../matlab/mexcdf/snctools','-end')

% add path to netcdf toolboxes
disp(' Adding netcdf toolboxes')
addpath ../../matlab/toolbox/netcdf
addpath ../../matlab/toolbox/netcdf/nctype
addpath ../../matlab/toolbox/netcdf/ncutility 

% add path to Wilkin scripts
addpath('../../matlab/roms_wilkin/')

disp(' ')

addpath(genpath('../../mfiles'))

warning off MATLAB:nargchk:deprecated

disp(['  Finished ' which(mfilename)])
