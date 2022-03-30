function [u,x,y]=scrum_zslice(cdf,var,timestep,depth)
%SCRUM_ZSLICE:  Returns horizontal slice from SCRUM Netcdf file.
%
% Returns a matrix containing a horizontal slice at a specified depth
% at a given time step from a SCRUM NetCDF file.  Regions of grid that
% are shallower than requested value are returned as NaNs.
%
% USAGE: [u,x,y]=scrum_zslice(cdf,var,time,depth)
%    cdf:     name of SCRUM/ROMS NetCDF file (or object).
%    var:     name of SCRUM variable.
%    time:    time index, must be zero-based
%    depth:   depth in meters.
%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Load in NetCDF file
if (nargin~=4)
  help scrum_zslice; return
end
if isa(cdf, 'netcdf')
  nc = cdf;
elseif isa(cdf, 'char')
  nc = netcdf(cdf,'nowrite');
end
if(isempty(nc))
  disp(['ERROR:  File ',cdfin,' not found.']);
  return;
end
ncmex('setopts',0);
nc=quick(nc,1);

ncid=ncmex('open',cdf,'nowrite');
if(ncid==-1),
  disp(['file ' cdf ' not found'])
  return
end
depth = -abs(depth); 			% account for depth or z

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Acquire the grid. If "lon_rho" and "lat_rho" are present, grab them,
% otherwise get "x_rho" and "y_rho".
[lon_rho_varid, rcode] = ncmex('VARID', ncid, 'lon_rho');
[lat_rho_varid, rcode] = ncmex('VARID', ncid, 'lat_rho');
if ( (lon_rho_varid >= 0) | (lat_rho_varid >= 0) )
    x=ncmex('varget',ncid,'lon_rho',[0 0],[-1 -1]);
    y=ncmex('varget',ncid,'lat_rho',[0 0],[-1 -1]);
else
    x=ncmex('varget',ncid,'x_rho',[0 0],[-1 -1]);
    y=ncmex('varget',ncid,'y_rho',[0 0],[-1 -1]);
end
x = x';
y = y';
[eta_rho_length, xi_rho_length] = size(x);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% The grid upon which the requested variable is based may not be
% [eta_rho xi_rho].  If the requested variable is, for example, 'u', then
% the grid will be [eta_u xi_u].  If this is the case, then x and y
% need to be altered to reflect this.
[varid, rcode] = ncmex('VARID', ncid, var);
[dud, dud, ndims, vardims, dud, status] = ncmex('varinq', ncid, varid);

y_dimid = vardims(ndims-1);
x_dimid = vardims(ndims);

[y_dim_name, y_length, status] = ncmex('diminq', ncid, y_dimid);
[x_dim_name, x_length, status] = ncmex('diminq', ncid, x_dimid);

[y_length, x_length] = size(x);
if ( strcmp(y_dim_name,'eta_rho') & strcmp(x_dim_name,'xi_rho') )
	;	
elseif ( strcmp(y_dim_name,'eta_u') & strcmp(x_dim_name,'xi_u') )
	x_length = x_length-1;
	eta_u_length = eta_rho_length;
	xi_u_length = xi_rho_length-1;
	x = (x(:,1:xi_rho_length-1) + x(:,2:xi_rho_length))/2;
	y = (y(:,1:xi_rho_length-1) + y(:,2:xi_rho_length))/2;
elseif ( strcmp(y_dim_name,'eta_v') & strcmp(x_dim_name,'xi_v') )
	y_length = y_length-1;
	eta_v_length = eta_rho_length-1;
	xi_v_length = xi_rho_length;
	x = (x(1:eta_rho_length-1,:) + x(2:eta_rho_length,:))/2;
	y = (y(1:eta_rho_length-1,:) + y(2:eta_rho_length,:))/2;
else
	disp(sprintf('what are the dimensions??, %s and %s??', y_dim_name, x_dim_name ) );
	help scrum_zslice;
	return;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Get variables for z eqn [z = zeta * (1 + s) + hc*s + (h - hc)*C(s)]

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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% w is defined at different locations than the others
if ( strcmp(var,'w') )
	[sc, status] = ncmex ( 'varget', ncid, 'sc_w', [0], [-1] );
else
	[sc, status] = ncmex ( 'varget', ncid, 'sc_r', [0], [-1] );
end

[zeta, status] = ncmex ( 'varget', ncid, 'zeta', [timestep 0 0], [1 -1 -1] );
zeta = zeta';

[hc_varid, status] = ncmex ( 'varid', ncid, 'hc' );
if ( status == -1 )
	fprintf ( 2, 'Could not get hc varid from %s.\n', cdf );
	ncmex ( 'close', ncid );
	return;
end
[hc, status] = ncmex ( 'varget1', ncid, hc_varid, [0] );
if ( status == -1 )
	fprintf ( 2, 'Could not get hc from %s.\n', cdf );
	ncmex ( 'close', ncid );
	return;
end

[h, status] = ncmex ( 'varget', ncid, 'h', [0 0], [-1 -1] );
if ( status == -1 )
	fprintf ( 'scrum_zslice:  could not get ''h'' in %s.', cdf );
	return;
end
h = h';

[Cs_r, status] = ncmex ( 'varget', ncid, 'Cs_r', [0], [-1] );
if ( status == -1 )
	fprintf ( 'scrum_zslice:  could not get ''Cs_r'' in %s.', cdf );
	return;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Construct the depth.
n = length(sc);
z = zeta * (1+sc(1)) + hc*sc(1) + (h - hc)*Cs_r(1);
for i = 2:n
  zi = zeta * (1+sc(i)) + hc*sc(i) + (h - hc)*Cs_r(i);
  z = cat ( 3, z, zi );
end
z = permute ( z, [3 1 2] );

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% reshape the depth such that each vertical profile is a column.
if ( strcmp(y_dim_name,'eta_rho') & strcmp(x_dim_name,'xi_rho') )
	;
elseif ( strcmp(y_dim_name,'eta_u') & strcmp(x_dim_name,'xi_u') )
	z = (z(:,:,1:xi_rho_length-1) + z(:,:,2:xi_rho_length))/2;
	zeta = (zeta(:,1:xi_rho_length-1) + zeta(:,2:xi_rho_length))/2;
	h = (h(:,1:xi_rho_length-1) + h(:,2:xi_rho_length))/2;
elseif ( strcmp(y_dim_name,'eta_v') & strcmp(x_dim_name,'xi_v') )
	z = (z(:,1:eta_rho_length-1,:) + z(:,2:eta_rho_length,:))/2;
	zeta = (zeta(1:eta_rho_length-1,:) + zeta(2:eta_rho_length,:))/2;
	h = (h(1:eta_rho_length-1,:) + h(2:eta_rho_length,:))/2;
else
	disp(sprintf('what are the dimensions??, %s and %s??', y_dim_name, x_dim_name ) );
	help scrum_zslice;
	return;
end
z = reshape ( z, [s_rho_length y_length*x_length] );

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Retrieve the requested variable at the given timestep.
[data,status]=ncmex('varget',ncid,var,[(timestep-1) 0 0 0],[1 -1 -1 -1] );
if ( status == -1 )
	fprintf ( 'scrum_zslice:  could not get ''%s'' in %s.', var, cdf );
	return;
end
data = permute ( data, [3 2 1] );
data = reshape(data,[s_rho_length y_length*x_length]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% define z and data at zeta (elevation)
z = [z; reshape(zeta, [1 y_length*x_length] ) ];
data = [data; data(s_rho_length,:)];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% define z at values greater than zeta to be Inf
% define data to be NaN
z = [z; Inf*ones(1,y_length*x_length)];
data = [data; NaN * ones(1,y_length*x_length)];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% define data at bathymetry values to be same as data at lowest 
% existing values.
z = [ -1*reshape(h,[1 y_length*x_length]); z];
data = [ data(1,:); data ];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% define z at depth greater than bathymetry to be -Inf
% define data at depth greater than bathymetry to be NaN
z = [ -Inf*ones(1,y_length*x_length); z ];
data = [ NaN * ones(1,y_length*x_length); data ];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Find the indices of data values that have just greater depth than
% depth.
zgreater = ( z < depth );
zg_ind = diff(zgreater);
zg_ind = find(zg_ind~=0);
zg_ind = zg_ind + [0:1:length(zg_ind)-1]';
data_greater_z = data(zg_ind);
depth_greater_z = z(zg_ind);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Find the indices of the data values that have just lesser depth
% than depth.
zlesser = ( z > depth );
zl_ind = diff(zlesser);
zl_ind = find(zl_ind~=0);
zl_ind = zl_ind + [1:1:length(zg_ind)]';
data_lesser_z = data(zl_ind);
depth_lesser_z = z(zl_ind);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Interpolate between the data values.
alpha = (depth - depth_greater_z) ./ ( depth_lesser_z - depth_greater_z );

data_at_depth = (data_lesser_z .* alpha) + (data_greater_z .* (1-alpha));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Now reshape the data into a square grid.
u = reshape ( data_at_depth, [y_length x_length] );

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% If there is a suitable mask variable, we will want to mask out certain cells.
% For now, mask out the land cells.
if ( strcmp(y_dim_name,'eta_rho') & strcmp(x_dim_name,'xi_rho') )
  %Get the mask_rho variable
  [mask_rho_varid, status] = ncmex ( 'varid', ncid, 'mask_rho' );
  if ( status ~= -1 )
    [mask_rho, status] = ncmex ( 'varget', ncid, 'mask_rho', [0 0], [-1 -1] );
    mask_rho = mask_rho';
    mask_inds = find(mask_rho==0);
    u(mask_inds) = NaN * ones(size(mask_inds));
  end
elseif ( strcmp(y_dim_name,'eta_u') & strcmp(x_dim_name,'xi_u') )
  %
  %Get the mask_u variable
  [mask_u_varid, status] = ncmex ( 'varid', ncid, 'mask_u' );
  if ( status ~= -1 )
    [mask_u, status] = ncmex ( 'varget', ncid, 'mask_u', [0 0], [-1 -1] );
    mask_u = mask_u';
    mask_inds = find(mask_u==0);
    u(mask_inds) = NaN * ones(size(mask_inds));
  end
elseif ( strcmp(y_dim_name,'eta_v') & strcmp(x_dim_name,'xi_v') )
  %Get the mask_u variable
  [mask_v_varid, status] = ncmex ( 'varid', ncid, 'mask_u' );
  if ( status ~= -1 )
    [mask_v, status] = ncmex ( 'varget', ncid, 'mask_v', [0 0], [-1 -1] );
    mask_v = mask_v';
    mask_inds = find(mask_v==0);
    u(mask_inds) = NaN * ones(size(mask_inds));
  end
else
  disp(sprintf('what are the dimensions??, %s and %s??', y_dim_name, x_dim_name ) );
  help scrum_zslice;
  return;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% all done with netcdf file operations
ncmex ( 'close', ncid );

u = u'; x = x'; y = y';
