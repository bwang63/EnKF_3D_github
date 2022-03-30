function [data,z,lon,lat,t] = roms_islice(file,var,time,iindex,grd)
% $Id$
% Get a constant-i slice out of a ROMS history, averages or restart file
% [data,z,lon,lat,t] = roms_islice(file,var,time,iindex,grd)
%
% Inputs
%    file = his or avg nc file
%    var = variable name
%    time = time index in nc file
%    iindex = i index of the required slice
%    grd (optional) is the structure of grid coordinates from get_roms_grd 
%
% Outputs
%    
%    data = the 2d slice at requested depth
%    z (2d) matrix of depths
%    lon,lat = horizontal coordinates along the slice
%    t = time in days for the data
%
% John Wilkin

% get the data
data = nc_varget(file,var,[time-1 0 0 iindex-1],[1 -1 -1 1]);
t = nc_varget(file,'ocean_time',time-1,1);

% determine where on the C-grid these values lie 
varcoords = nc_attget(file,var,'coordinates');
if ~isempty(findstr(varcoords,'_u'))
  pos = 'u';
elseif ~isempty(findstr(varcoords,'_v'))
  pos = 'v';
elseif ~isempty(findstr(varcoords,'_rho'))
  pos = 'rho';
else
  error('Unable to parse the coordinates variables to know where the data fall on C-grid')
end

% check the grid information
if nargin<5 | (nargin==5 & isempty(grd))
  % no grd input given so try to get grd_file name from the file
  grd = roms_get_grid(file,file);
else
  if isstr(grd)
    grd = roms_get_grid(grd,file);
  else
    % input was a grd structure but check that it includes the z values    
    if ~isfield(grd,'z_r')
      try 
        grd = roms_get_grid(grd,file,0,1)
      catch
        error('grd does not contain z values');
      end
    end
  end
end

% get section depth coordinates
z_r = grd.z_r;
switch pos
  
  case 'u'    
    % average z_r to Arakawa-C u points
    % this might be redundant if z u,v values are already in structure   
    zM = size(z_r,2);
    zMm = zM-1;
    zL = size(z_r,3);
    zLm = zL-1;
    z = 0.5*(z_r(:,:,1:zLm)+z_r(:,:,2:zL));
    x = grd.lon_u;
    y = grd.lat_u;
    mask = grd.mask_u;
    
  case 'v'
    % average z_r to Arakawa-C v points
    zM = size(z_r,2);
    zMm = zM-1;
    zL = size(z_r,3);
    zLm = zL-1;
    z = 0.5*(z_r(:,1:zMm,:)+z_r(:,2:zM,:));
    x = grd.lon_v;
    y = grd.lat_v;
    mask = grd.mask_v; 
    
  otherwise    
    % for temp, salt, rho, w
    z = z_r;
    x = grd.lon_rho;
    y = grd.lat_rho;
    mask = grd.mask_rho; 
    if size(data,1) ~= size(z,1)
      % trap the var=='omega' case
      % but omega can be N or N+1 depending on whether a rst or his file
      z = grd.z_w;
    end
    
end

% extract the j slices of the coordinates
z = z(:,:,iindex);

% pad surface to z=0
% ******************************************
% NOTE: THIS NEEDS TO BE FIXED FOR THE CASE THAT ZETA IS USED IN THE Z 
% CALCULATION. SHOULD PAD WITH THE Z_W VALUES AND Z=-H
z = [z; zeros([1 size(z,2)])];
data = [squeeze(data); data(size(data,1),:)];

lon = repmat(x(:,iindex)',[size(z,1) 1]);
lat = repmat(y(:,iindex)',[size(z,1) 1]);

% land/sea mask
dry = find(mask==0);
mask(dry) = NaN;
mask = repmat(mask(:,iindex)',[size(z,1) 1]);

% remove singleton dimensions
z = squeeze(z);
data = mask.*squeeze(data);
