function [w,x,y]=scrum_zsliceuv(cdf,timestep,zdepth)
%  SCRUM_ZSLICE  Returns a matrix containing a horizontal slice of velocity
%          at a specified depth at a given time step from a SCRUM NetCDF 
%          file.  Regions of grid that are shallower than requested value 
%          are returned as NaNs.
%
%       USAGE: [w,x,y]=scrum_zsliceuv(cdf,var,zdepth)
%
%   where zuser is a depth in meters (e.g -10.)
%

% John Evans (joevans@usgs.gov)

if (nargin<2 | nargin>4),
  help scrum_zslice; return
end

ncmex('setopts',0);
ncid=ncmex('open',cdf,'nowrite');
if(ncid==-1),
  disp(['file ' cdf ' not found'])
  return
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Acquire the grid.
% If "lon_rho" and "lat_rho" are present, grab them.
% Otherwise, get "x_rho" and "y_rho".
[lon_rho_varid, rcode] = ncmex('VARID', ncid, 'lon_rho');
[lat_rho_varid, rcode] = ncmex('VARID', ncid, 'lat_rho');
if ( (lon_rho_varid >= 0) | (lat_rho_varid >= 0) )
    x=ncmex('varget',ncid,'lon_rho',[0 0],[-1 -1]);
    y=ncmex('varget',ncid,'lat_rho',[0 0],[-1 -1]);
else
    x=ncmex('varget',ncid,'x_rho',[0 0],[-1 -1]);
    y=ncmex('varget',ncid,'y_rho',[0 0],[-1 -1]);
end

x_rho = x';
y_rho = y';

[eta_rho_length, xi_rho_length] = size(x_rho);
eta_u_length = eta_rho_length;
eta_v_length = eta_rho_length-1;
xi_u_length = xi_rho_length-1;
xi_v_length = xi_rho_length;
eta_psi_length = eta_rho_length-1;
xi_psi_length = xi_rho_length-1;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% construct the grids at the psi points.
xtemp = (x_rho(:,1:(xi_rho_length-1)) + x_rho(:,2:xi_rho_length))/2;
x = (xtemp(1:(eta_rho_length-1),:)  + xtemp(2:eta_rho_length,:))/2;
ytemp = (y_rho(:,1:(xi_rho_length-1)) + y_rho(:,2:xi_rho_length))/2;
y = (ytemp(1:(eta_rho_length-1),:)  + ytemp(2:eta_rho_length,:))/2;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Get all the variables needed to compute 
%    z = zeta * (1 + s) + hc*s + (h - hc)*C(s)

[s_rho_dimid, status] = ncmex ( 'dimid', ncid, 's_rho' );
if ( status == -1 )
  fprintf ( 2, 'Could not get s_rho dimid from %s.\n', cdf );
  ncmex ( 'close', ncid );
  return;
end
[dimname, s_rho_length, status] = ncmex ( 'diminq', ncid, s_rho_dimid );
if ( status == -1 )
  fprintf ( 2, 'Could not get s_rho length from %s.\n', cdf );
  ncmex ( 'close', ncid );
  return;
end

[sc_r, status] = ncmex ( 'varget', ncid, 'sc_r', [0], [-1] );
if ( status == -1 )
  fprintf ( 2, 'Could not get ''sc_r'' variable from %s.\n', cdf );
  ncmex ( 'close', ncid );
  return;
end

[zeta, status] = ncmex ( 'varget', ncid, 'zeta', [timestep 0 0], [1 -1 -1] );
zeta = zeta';

[hc_varid, status] = ncmex ( 'varid', ncid, 'hc' );
if ( status == -1 )
  fprintf ( 2, 'Could not get hc variable from %s.\n', cdf );
  ncmex ( 'close', ncid );
  return;
end
[hc, status] = ncmex ( 'varget1', ncid, hc_varid, [0] );
if ( status == -1 )
  fprintf ( 2, 'Could not get hc variable from %s.\n', cdf );
  ncmex ( 'close', ncid );
  return;
end

[h, status] = ncmex ( 'varget', ncid, 'h', [0 0], [-1 -1] );
if ( status == -1 )
  fprintf ( 'scrum_zsliceuv:  could not get ''h'' in %s.', cdf );
  return;
end
h = h';

[Cs_r, status] = ncmex ( 'varget', ncid, 'Cs_r', [0], [-1] );
if ( status == -1 )
  fprintf ( 'scrum_zsliceuv:  could not get ''Cs_r'' in %s.', cdf );
  return;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Construct the depth.
n = length(sc_r);
z = zeta * (1+sc_r(1)) + hc*sc_r(1) + (h - hc)*Cs_r(1);
for i = 2:n
  zi = zeta * (1+sc_r(i)) + hc*sc_r(i) + (h - hc)*Cs_r(i);
  z = cat ( 3, z, zi );
end
z = permute ( z, [3 1 2] );

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Now average z, h, and zeta across the grid cell centers.
z = (z(:,1:eta_rho_length-1,:)+z(:,2:eta_rho_length,:))/2;
z = (z(:,:,1:xi_rho_length-1)+z(:,:,2:xi_rho_length))/2;
h = (h(1:eta_rho_length-1,:)+h(2:eta_rho_length,:))/2;
h = (h(:,1:xi_rho_length-1)+h(:,2:xi_rho_length))/2;
zeta = (zeta(1:eta_rho_length-1,:)+zeta(2:eta_rho_length,:))/2;
zeta = (zeta(:,1:xi_rho_length-1)+zeta(:,2:xi_rho_length))/2;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% reshape the depth such that each vertical profile is a column.
z = reshape ( z, [s_rho_length eta_psi_length*xi_psi_length] );

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Retrieve u at the given timestep.
[data_u, status] = ncmex ( 'varget', ncid, 'u', [timestep 0 0 0], [1 -1 -1 -1] );
if ( status == -1 )
	fprintf ( 'scrum_zsliceuv:  could not get ''u'' in %s.', cdf );
	return;
end
data_u = permute ( data_u, [3 2 1] );
data_u = (data_u(:,1:eta_u_length-1,:) + data_u(:,2:eta_u_length,:))/2;
data_u = reshape(data_u,[s_rho_length eta_psi_length*xi_psi_length]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Retrieve v at the given timestep.
if ( status == -1 )
	fprintf ( 'scrum_zsliceuv:  could not get ''u'' in %s.', cdf );
	return;
end
[data_v, status] = ncmex ( 'varget', ncid, 'v', [timestep 0 0 0], [1 -1 -1 -1] );
data_v = permute ( data_v, [3 2 1] );
data_v = (data_v(:,:,1:xi_v_length-1) + data_v(:,:,2:xi_v_length))/2;
data_v = reshape(data_v,[s_rho_length eta_psi_length*xi_psi_length]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% If there is a mask_rho, we will want to use it later.
[mask_rho_varid, status] = ncmex ( 'varid', ncid, 'mask_rho' );
if ( status ~= -1 )
  [mask_rho, status] = ncmex ( 'varget', ncid, 'mask_rho', [0 0], [-1 -1] );
  if ( status == -1 )
    fprintf ( 'scrum_zsliceuv:  could not get ''mask_rho'' in %s.', cdf );
    return;
  end
end
ncmex ( 'close', ncid );

velocity = data_u + sqrt(-1)*data_v;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% define z and velocity at zeta (elevation)
z = [z; reshape(zeta, [1 eta_psi_length*xi_psi_length] ) ];
velocity = [velocity; velocity(s_rho_length,:)];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% define z at values greater than zeta to be Inf
% define velocity to be NaN
z = [z; Inf*ones(1,eta_psi_length*xi_psi_length)];
velocity = [velocity; NaN * ones(1,eta_psi_length*xi_psi_length)];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% define z at bathymetry values to be those bathymetry values
% define velocity at bathymetry values to be same as data at lowest 
% existing values.
z = [ -1*reshape(h,[1 eta_psi_length*xi_psi_length]); z];
velocity = [ velocity(1,:); velocity ];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% define z at depth greater than bathymetry to be -Inf
% define velocity at depth greater than bathymetry to be NaN
z = [ -Inf*ones(1,eta_psi_length*xi_psi_length); z ];
velocity = [ NaN * ones(1,eta_psi_length*xi_psi_length); velocity ];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Find the indices of data values that have just greater depth than
% zdepth.
zgreater = ( z < zdepth );
zg_ind = diff(zgreater);
zg_ind = find(zg_ind~=0);
zg_ind = zg_ind + [0:1:length(zg_ind)-1]';
velocity_greater_z = velocity(zg_ind);
depth_greater_z = z(zg_ind);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Find the indices of the data values that have just lesser depth
% than zdepth.
zlesser = ( z > zdepth );
zl_ind = diff(zlesser);
zl_ind = find(zl_ind~=0);
zl_ind = zl_ind + [1:1:length(zg_ind)]';
velocity_lesser_z = velocity(zl_ind);
depth_lesser_z = z(zl_ind);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Interpolate between the data values.
alpha = (zdepth - depth_greater_z) ./ ( depth_lesser_z - depth_greater_z );

velocity_at_depth = (velocity_lesser_z .* alpha) + (velocity_greater_z .* (1-alpha));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Now reshape the data into a square grid.
w = reshape ( velocity_at_depth, [eta_psi_length xi_psi_length] );

w = w.'; x = x.'; y = y.';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% apply the rotation
%
% Since the "angle" variable is not always present, we
% need to construct it.  In the scrum files, it is apparently
% always in degrees.  Don't bother with degrees here.
angle = zeros(size(x));

[r,c] = size(x);
j = [2:c-1];
for i = 2:r-1
  angle(i,j) = atan2(y(i+1,j)-y(i-1,j), x(i+1,j)-x(i-1,j));
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% rotate into east and north components
w=w.*exp(sqrt(-1)*angle);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Mask out the land.
% Since we average the u and v across cells, the appropriate mask
% dimension is that of "mask_psi".  I don't want to take the chance
% that it may not be present in the file, so I compute it from 
% mask_rho.

[mask_rho_varid, status] = ncmex ( 'varid', ncid, 'mask_rho' );
if ( status ~= -1 )
  [umask,vmask,pmask]=uvp_masks ( mask_rho );
  mask_inds = find ( pmask == 0 );
  w(mask_inds) = NaN * ones(size(mask_inds));
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Convert to cm/s

%w=w.*100;
