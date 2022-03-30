function [data,x,y,t,grd] = roms_zslice(file,var,time,depth,grd)
% $Id$
% Get a constant-z slice out of a ROMS history, averages or restart file
% [data,x,y] = roms_zslice(file,var,time,depth,grd)
%
% Inputs
%    file = his or avg nc file
%    var = variable name
%    time = time index in nc file
%    depth = depth in metres of the required slice
%    grd (optional) is the structure of grid coordinates from get_roms_grd 
%
% Outputs
%    
%    data = the 2d slice at requested depth 
%    x,y = horizontal coordinates
%    t = time in days for the data
%
% John Wilkin

depth = -abs(depth);

% open the history or averages file
%nc = netcdf(file);

if ~nc_isvar(file,var)
  error([ 'Variable ' var ' is not present in file ' file])
end

% get the time
time_variable = nc_attget(file,var,'time');
if isempty(time_variable)
  time_variable = 'scrum_time'; % doubt this is really of any use any more 
end

if nc_varsize(file,time_variable)<time
  disp(['Requested time index ' int2str(time) ' not available'])
  disp(['There are ' int2str(nc_varsize(file,time_variable)) ...
    ' time records in ' file])
  error(' ')
end
t = roms_get_date(file,time); % gets output in matlab datenum convention

% check the grid information
if nargin<5 | (nargin==5 & isempty(grd))
  % no grd input given so try to get grd_file name from the history file
  grd_file = file;
  grd = roms_get_grid(grd_file,file);
else
  if isstr(grd)
    grd = roms_get_grid(grd,file);
  else
    % input was a grd structure but check that it includes the z values    
    if ~isfield(grd,'z_r')
      error('grd does not contain z values');
    end
  end
end

% get the data to be zsliced
data = nc_varget(file,var,[time-1 0 0 0],[1 -1 -1 -1]);

% slice at requested depth
[data,x,y] = roms_zslice_var(data,1,depth,grd);

switch roms_cgridpos(size(data),grd)
  case 'u'
    mask = grd.mask_u;
  case 'v'
    mask = grd.mask_v;
  case 'psi'
    mask = grd.mask_psi;
  case 'rho'
    mask = grd.mask_rho;
end

% Apply mask to catch shallow water values where the z interpolation does
% not create NaNs in the data
if 1
dry = find(mask==0);
mask(dry) = NaN;
data = data.*mask;
end
