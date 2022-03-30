% Possible_Axis_Names 
%
% The Matlab DODS GUI function gridcat reads the dds and das to 
% get the names of the map vectors associated with arrays in a 
% grid and then searches these for ones that might correspond to
% latitude, longitude, depth and time. This routine is sourced
% from gridcat and provides a list of possible names to search
% for. The list has been built up from names used in existing
% DODS accessible files, primarily netCDF files.
%
% Usage: Sourced from gridcat.
%
% Peter Cornillon 2/2/02
%

X_Names{1} = 'lon';
X_Names{2} = 'x';
X_Names{3} = 'coadsx';
X_Names{4} = 'eskux';
%X_Names{5} = 'xax';
%X_Names{6} = 'xt_i';
%X_Names{7} = 'xu_i';

Y_Names{1} = 'lat';
Y_Names{2} = 'y';
Y_Names{3} = 'coadsy';
Y_Names{4} = 'eskuy';
%Y_Names{5} = 'yax';
%Y_Names{6} = 'yt_j';
%Y_Names{7} = 'yu_j';


Z_Names{1} = 'depth';
Z_Names{2} = 'z';
Z_Names{3} = 'coadsz';
Z_Names{4} = 'surface';
Z_Names{5} = 'dpth';
%Z_Names{6} = 'zax';
%Z_Names{7} = 'zt_k';
%Z_Names{8} = 'zw_k';

T_Names{1} = 't';
T_Names{2} = 'coadst';
%T_Names{3} = 'time';
%T_Names{4} = 'tax';
