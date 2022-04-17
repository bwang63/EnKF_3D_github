% startup file: change defaults
%

disp(['  Starting ' which(mfilename)])

% disp(' Add netcdfAll-4.3.jar and mexcdf')
% javaaddpath('../../matlab/netcdfAll-4.3.jar')
% javaaddpath ('../../matlab/mexcdf/snctools/classes')
addpath ../../matlab/mexcdf
addpath('../../matlab/mexcdf/mexnc','-end')
addpath('../../matlab/mexcdf/snctools','-end')

% % add path for general toolboxes
% add_ocean_toolboxes('../../matlab/toolbox/')
% 
% disp(' ')

% add path to netcdf toolboxes
disp(' Adding netcdf toolboxes')
addpath ../../matlab/toolbox/seagrid
addpath ../../matlab/toolbox/netcdf
addpath ../../matlab/toolbox/netcdf/nctype
addpath ../../matlab/toolbox/netcdf/ncutility 

disp(' ')

% add path to Wilkin scripts
addpath('../../matlab/roms_wilkin/')

disp(' ')

addpath(genpath('../../mfiles'))

warning off MATLAB:nargchk:deprecated

disp(['  Finished ' which(mfilename)])
