% (R)oms (N)umerical (T)oolbox
% 
% FUNCTION rnt_config
%
% Edits the configuration file
%
% RNT - E. Di Lorenzo (edl@ucsd.edu)


function rnt_config
tmp_configfile=which('rnt_gridinfo');

disp(['Edit this file   nedit ',tmp_configfile,' &']);
%edit (tmp_configfile);
