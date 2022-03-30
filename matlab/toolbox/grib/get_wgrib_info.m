function get_wgrib_info
% GET_WGRIB_INFO: initialises the global variables  wgrib_dir & wgrib_name

% $Id: get_wgrib_info.m,v 1.1 2000/02/09 05:09:47 mansbrid Exp $
% Copyright J. V. Mansbridge, CSIRO, Wednesday February  9 14:37:29 EST 2000

global wgrib_dir wgrib_name

% Find the directory containing the executable.

wgrib_dir = which('grib_name_units.mat');
if length(wgrib_dir) < 20
  str = ['the directory containing the GRIB routines was not found; ' ...
	 'use addpath to make that directory accessible'];
  error(str)
end
wgrib_dir = wgrib_dir(1:length(wgrib_dir)-19);

% choose an appropriate executable.
% The 32 bit SGI binary was not made because I could not do an rlogin to a
% suitable machine for testing.

comp = computer;
switch comp
 % case 'SGI'
 % wgrib_name = 'wgrib.sgi.bin';
 case 'SGI64'
  wgrib_name = 'wgrib.sgi64.bin';
 case 'SOL2'
  wgrib_name = 'wgrib.sol2.bin';
 case 'LNX86'
  wgrib_name = 'wgrib.lnx86.bin';
 case 'SUN4'
  wgrib_name = 'wgrib.sun4.bin';
 otherwise 
  error('No suitable binary wgrib* for this computer');
end
wgrib_name = [wgrib_dir wgrib_name];
