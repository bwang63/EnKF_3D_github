function gridgen_masking_command ( command )
% This function handles the masking and bathymetry.
%

%disp ( sprintf ( 'GRIDGEN_MASKING_COMMAND:  %s', command ) );
 
global grid_obj;

switch command

    case 'commit_to_masking'
	gridgen_setup_masking_gui;
        gridgen_setup_masking;
	gridgen_projection2meters;
	gridgen_construct_grid_variables;
        gridgen_mask;
	gridgen_command commit_to_bathymetry;

end

return;




%
% Not much at present for the user to do, just read instructions.
function gridgen_setup_masking_gui()

%disp ( 'here in gridgen_setup_masking_gui' );

global grid_obj;

instructions{1} = sprintf ( 'GRID CELL MASKING' ); 
gridgen_command ( 'set_instructions', instructions );


return;







function gridgen_setup_masking()

%disp ( 'here in gridgen_setup_masking' );

global grid_obj;



%
% The following constants are used by many routines following, 
% including masking.
M2 = grid_obj.neta - 1;
L2 = grid_obj.nxi - 1;
L = L2 / 2 + 1;
M = M2 / 2 + 1;
LM = L - 1;
MM = M - 1;
LP = L + 1;
MP = M + 1;

grid_obj.M2 = M2;
grid_obj.L2 = L2;
grid_obj.L = L;
grid_obj.M = M;
grid_obj.LM = LM;
grid_obj.MM = MM;
grid_obj.LP = LP;
grid_obj.MP = MP;

return;







%
% The grid must be computed in meters.  Do this here.
function gridgen_projection2meters()

%disp ( 'here in gridgen_projection2meters' );

global grid_obj;


[grid_longitude, grid_latitude] = ...
    m_xy2ll ( grid_obj.double_res_x, grid_obj.double_res_y);
grid_obj.grid_longitude = grid_longitude;
grid_obj.grid_latitude = grid_latitude;

%instructions{1} = sprintf ( 'GRID CELL MASKING' ); 
%instructions{2} = sprintf ( 'Projecting the grid into meters, hold on...');
%gridgen_command ( 'set_instructions', instructions );






%%
%% find the most southwest node of the grid
%min_lon_grid = min(grid_longitude(:));
%min_lat_grid = min(grid_latitude(:));
%
%
%%
%% find the most southwest part of the current map
%xlim = get(grid_obj.map_axis,'xlim');
%min_projected_x = min ( xlim(:) );
%ylim = get(grid_obj.map_axis,'ylim');
%min_projected_y = min ( ylim(:) );
%[min_lon_map, min_lat_map] = m_xy2ll ( min_projected_x, min_projected_y );
%grid_obj.min_lon_map = min_lon_map;
%grid_obj.min_lat_map = min_lat_map;
%
%
%grid_offset_x = geodist2 (min_lat_map, min_lon_map, min_lat_map, min_lon_grid );
%grid_offset_y = geodist2 ( min_lat_map, min_lon_map, min_lat_grid, min_lon_map );
%grid_obj.xoff = grid_offset_x;
%grid_obj.yoff = grid_offset_y;





%
% don't have to put grid into meters

%%
%% make the grid in terms of meters
%grid_x_meters = zeros(size(grid_longitude));
%grid_y_meters = zeros(size(grid_latitude));
%
%lat_matrix = min_lat_map * ones(size(grid_longitude));
%grid_x_meters = geodist2 ( min_lat_map, min_lon_map, lat_matrix, grid_longitude );
%
%lon_matrix = min_lon_map * ones(size(grid_latitude));
%grid_y_meters = geodist2 ( min_lat_map, min_lon_map, grid_latitude, lon_matrix );
%
%grid_obj.grid_x_meters = grid_x_meters;
%grid_obj.grid_y_meters = grid_y_meters;





%
% don't have to do the following step, I don't think

%%
%% put the coastline in terms of meters
%instructions{1} = sprintf ( 'GRID CELL MASKING' ); 
%instructions{2} = sprintf ( 'Projecting the coastline into meters, hold on...');
%gridgen_command ( 'set_instructions', instructions );
%
%coast_lon = grid_obj.coastline_longitude;
%coast_lat = grid_obj.coastline_latitude;
%coastline_x_meters = zeros(size(coast_lon));
%coastline_y_meters = zeros(size(coast_lat));
%len_coast = length(coast_lon);
%
%lat_matrix = min_lat_map * ones(size(coast_lat));
%coastline_x_meters = geodist2 ( min_lat_map, min_lon_map, lat_matrix, coast_lon );
%
%lon_matrix = min_lon_map * ones(size(coast_lon));
%coastline_y_meters = geodist2 ( min_lat_map, min_lon_map, coast_lat, lon_matrix );
%
%grid_obj.coastline_x_meters = coastline_x_meters;
%grid_obj.coastline_y_meters = coastline_y_meters;




%
% get the bathymetry again and convert the lon/lat pairs to meters
%instructions{1} = sprintf ( 'GRID CELL MASKING' ); 
%instructions{2} = sprintf ( 'Projecting the provided bathymetry into meters, hold on...');
%gridgen_command ( 'set_instructions', instructions );

load ( grid_obj.bathymetry_file );
lon_bathy = xbathy; lat_bathy = ybathy;
grid_obj.lon_bathy = xbathy; grid_obj.lat_bathy = ybathy;
bathy_len = length(lat_bathy);

%lon_matrix = min_lon_map * ones(size(xbathy));
%mybathy = geodist2 ( min_lat_map, min_lon_map, lat_bathy, lon_matrix );
%lat_matrix = min_lat_map * ones(size(ybathy));
%mxbathy = geodist2 ( min_lat_map, min_lon_map, lat_matrix, lon_bathy );

%grid_obj.mxbathy = mxbathy;
%grid_obj.mybathy = mybathy;
grid_obj.zbathy = zbathy;


return;









function gridgen_construct_grid_variables()

%disp ( 'here in gridgen_projection2meters' );

global grid_obj;

instructions{1} = sprintf ( 'GRID CELL MASKING' ); 
instructions{2} = sprintf ( 'Constructing grid variables...');
gridgen_command ( 'set_instructions', instructions );

L = grid_obj.L;
M = grid_obj.M;
LM = grid_obj.LM;
MM = grid_obj.MM;
LP = grid_obj.LP;
MP = grid_obj.MP;

smin1 = Inf;
smin2 = Inf;
smax1 = -Inf;
smax2 = -Inf;

%x = grid_obj.grid_x_meters;
%y = grid_obj.grid_y_meters;
x = grid_obj.double_res_x;
y = grid_obj.double_res_y;
grid_longitude = grid_obj.grid_longitude;
grid_latitude = grid_obj.grid_latitude;

ang = zeros(LP,MP);
s1 = zeros(LP,MP);
s2 = zeros(LP,MP);

%
% NEW STUFF
%
% The s1 and s2 (h1 and h2 in ecom?) factors used to be computed
% by using ye olde distance formula on the grid in meters.  Instead,
% we want to use "dist.m" to compute the factors based on the 
% lat/lon grid.  Don't ask.  Ask and I will hunt you down and kill
% you like a dog.  Anyway, "dist.m" computes distances between
% successive points, so we need to interleave the points just
% right.  That is what the "odds", "evens", "first_half", and
% "second_half" business is all about.
j = [2:M];
veclen = 2*(M-1);
odds = [1:2:veclen];
evens = [2:2:veclen];
first_half = [1:veclen/2];
second_half = [(veclen/2+1):veclen];
for i = 2:L
%    s1(i,j) = sqrt( ( x(2*i-1,2*j-2)-x(2*i-3,2*j-2) ).^2 
%          + ( y(2*i-1,2*j-2)-y(2*i-3,2*j-2) ).^2 );
    lons = [grid_longitude(2*i-1,2*j-2) grid_longitude(2*i-3,2*j-2)];
    lats = [grid_latitude(2*i-1,2*j-2) grid_latitude(2*i-3,2*j-2)];
    lonv(odds) = lons(first_half);
    latv(odds) = lats(first_half);
    lonv(evens) = lons(second_half);
    latv(evens) = lats(second_half);
    dists = dist(latv,lonv);
    s1(i,j) = dists(odds);
    smin1 = min ( smin1, min(s1(i,j)) );
    smax1 = max ( smax1, max(s1(i,j)) );

    lons = [grid_longitude(2*i-2,2*j-1) grid_longitude(2*i-2,2*j-3)];
    lats = [grid_latitude(2*i-2,2*j-1) grid_latitude(2*i-2,2*j-3)];
    lonv(odds) = lons(first_half);
    latv(odds) = lats(first_half);
    lonv(evens) = lons(second_half);
    latv(evens) = lats(second_half);
    dists = dist(latv,lonv);
    s2(i,j) = dists(odds);
%    s2(i,j) = sqrt( ( x(2*i-2,2*j-1) - x(2*i-2,2*j-3) ).^2 
%          + ( y(2*i-2,2*j-1) - y(2*i-2,2*j-3) ).^2 );
    smin2 = min ( smin2, min(s2(i,j)) );
    smax2 = max ( smax2, max(s2(i,j)) );
    ang(i,j) = atan2 ( y(2*i-1,2*j-2)-y(2*i-3,2*j-2), ...
               x(2*i-1,2*j-2)-x(2*i-3,2*j-2) ) * 57.296;
    pm(i,j) = 1 ./ s1(i,j);
    pn(i,j) = 1 ./ s2(i,j);
end

%disp ( sprintf ( 'minimum grid cell sizes = %f, %f\n', smin1, smin2 ) );
%disp ( sprintf ( 'maximum grid cell sizes = %f, %f\n', smax1, smax2 ) );



%
% M, N factors outside the boundaries
pm(1,j) = pm(2,j);
pn(1,j) = pn(2,j);
s1(1,j) = s1(2,j);
s2(1,j) = s2(2,j);
pm(LP,j) = pm(L,j);
pn(LP,j) = pn(L,j);
s1(LP,j) = s1(L,j);
s2(LP,j) = s2(L,j);

i = [1:LP];
pm(i,1) = pm(i,2);
pn(i,1) = pn(i,2);
s1(i,1) = s1(i,2);
s2(i,1) = s2(i,2);
pm(i,MP) = pm(i,M);
pn(i,MP) = pn(i,M);
s1(i,MP) = s1(i,M);
s2(i,MP) = s2(i,M);

%
% Compute dndx, dmde
dndx = zeros(LP,MP);
dmde = zeros(LP,MP);
j = [2:M];
for i = 2:L
    dndx(i,j) = (1./pn(i+1,j) - 1./(pn(i-1,j)))/2;
    dmde(i,j) = (1./pm(i,j+1) - 1./(pm(i,j-1)))/2;
end

j = 2:M;
dndx(1,j) = zeros(size(dndx(1,j)));
dmde(1,j) = zeros(size(dmde(1,j)));
dndx(LP,j) = zeros(size(dndx(LP,j)));
dmde(LP,j) = zeros(size(dmde(LP,j)));


i = 1:LP;
dndx(i,1) = zeros(size(dndx(i,1)));
dmde(i,1) = zeros(size(dmde(i,1)));
dndx(i,MP) = zeros(size(dndx(i,MP)));
dmde(i,MP) = zeros(size(dmde(i,MP)));



%
% Split up grid solution into separate arrays for the coordinates
% of the four locations on the Arakawa C grid corresponding to rho,
% psi, u and v points.
%                              ------------------
%                             |                  |
%                             |                  |
%                             |                  |
%    i,jth grid cell =>    u(i,j)   rho(i,j)     |
%                             |                  |
%                             |                  |
%                             |                  |
%                        psi(i,j)---- v(i,j)-----
%


%
% psi points
j = [1:M];
lon_psi = zeros(L,M);
lat_psi = zeros(L,M);
for i = 1:L
    xpsi(i,j) = x(2*i-1,2*j-1);
    ypsi(i,j) = y(2*i-1,2*j-1);
    lon_psi(i,j) = grid_longitude(2*i-1,2*j-1);
    lat_psi(i,j) = grid_latitude(2*i-1,2*j-1);
end

%
% u points
j = [2:M];
longitude_u = zeros(L,MP);
latitude_u = zeros(L,MP);
for i = 1:L
    xu(i,j) = x(2*i-1,2*j-2);
    yu(i,j) = y(2*i-1,2*j-2);
    longitude_u(i,j) = grid_longitude(2*i-1,2*j-2);
    latitude_u(i,j) = grid_latitude(2*i-1,2*j-2);
end

i = [1:L];
xu(i,1) = 2 * xpsi(i,1) - xu(i,2);
xu(i,MP) = 2 * xpsi(i,M) - xu(i,M);
yu(i,1) = 2 * ypsi(i,1) - yu(i,2);
yu(i,MP) = 2 * ypsi(i,M) - yu(i,M);
longitude_u(i,1) = 2 * lon_psi(i,1) - longitude_u(i,2);
longitude_u(i,MP) = 2 * lon_psi(i,M) - longitude_u(i,M);
latitude_u(i,1) = 2 * lat_psi(i,1) - latitude_u(i,2);
latitude_u(i,MP) = 2 * lat_psi(i,M) - latitude_u(i,M);


%
% v points
j = [1:M];
longitude_v = zeros(LP,M);
latitude_v = zeros(LP,M);
for i = 2:L
    xv(i,j) = x(2*i-2,2*j-1);
    yv(i,j) = y(2*i-2,2*j-1);
    longitude_v(i,j) = grid_longitude(2*i-2,2*j-1);
    latitude_v(i,j) = grid_latitude(2*i-2,2*j-1);
end

xv(1,j) = 2 * xpsi(1,j) - xv(2,j);
xv(LP,j) = 2 * xpsi(L,j) - xv(L,j);
yv(1,j) = 2 * ypsi(1,j) - yv(2,j);
yv(LP,j) = 2 * ypsi(L,j) - yv(L,j);
longitude_v(1,j) = 2 * lon_psi(1,j) - longitude_v(2,j);
longitude_v(LP,j) = 2 * lon_psi(L,j) - longitude_v(L,j);
latitude_v(1,j) = 2 * lat_psi(1,j) - latitude_v(2,j);
latitude_v(LP,j) = 2 * lat_psi(L,j) - latitude_v(L,j);


%
% rho points
xr = ones(LP,MP);
yr = ones(LP,MP);
lat_rho = zeros(LP,MP);
lon_rho = zeros(LP,MP);
j = [2:M];
for i = 2:L
    xr(i,j) = x( 2*i-2, 2*j-2 );
    yr(i,j) = y( 2*i-2, 2*j-2 );
    lon_rho(i,j) = grid_longitude( 2*i-2, 2*j-2 );
    lat_rho(i,j) = grid_latitude(  2*i-2, 2*j-2 );
end


j = 2:M;
xr(LP,j) = 2 * xu(L,j) - xr(L,j);
xr(1,j) = 2 * xu(1,j) - xr(2,j);
yr(LP,j) = 2 * yu(L,j) - yr(L,j);
yr(1,j) = 2 * yu(1,j) - yr(2,j);
lon_rho(LP,j) = 2 * longitude_u(L,j) - lon_rho(L,j);
lon_rho(1,j) = 2 * longitude_u(1,j) - lon_rho(2,j);
lat_rho(LP,j) = 2 * latitude_u(L,j) - lat_rho(L,j);
lat_rho(1,j) = 2 * latitude_u(1,j) - lat_rho(2,j);

i = [1:LP];
xr(i,MP) = 2 * xv(i,M) - xr(i,M);
yr(i,MP) = 2 * yv(i,M) - yr(i,M);
xr(i,1) = 2 * xv(i,1) - xr(i,2);
yr(i,1) = 2 * yv(i,1) - yr(i,2);
lon_rho(i,MP) = 2 * longitude_v(i,M) - lon_rho(i,M);
lat_rho(i,MP) = 2 * latitude_v(i,M) - lat_rho(i,M);
lon_rho(i,1) = 2 * longitude_v(i,1) - lon_rho(i,2);
lat_rho(i,1) = 2 * latitude_v(i,1) - lat_rho(i,2);




%
% Diagnostics:
% Compute the area of domain from m,n factors.
area = 1 ./ pm.*pn;
area = sum(area(:));
%disp ( sprintf ( 'area = %f\n', area ) );



%
% Check orthogonality by evaluating 
%   dx       dx           dy        dy
%   --   *   --      +    --   *    --
%  d(xi)   d(eta)        d(xi)    d(eta)
%
j = [1:MM];
errplt = zeros(LM,MM);
for i = 1:LM
    errplt(i,j) =  (     ( x(2*i+1,2*j) - x(2*i-1,2*j) ) ...
              .* ( x(2*i,2*j+1) - x(2*i,2*j-1) ) ...
             +   ( y(2*i+1,2*j) - y(2*i-1,2*j) ) ...
              .* ( y(2*i,2*j+1) - y(2*i,2*j-1) ) );
end
err_x = x(2:L,2:M);
err_y = y(2:L,2:M);
errplt_figure = figure ( 'Name', 'Orthogonality Check' );
pslice(err_x,err_y,errplt);



%
% Compute the coriolis factors.
coriolis = lat_rho;

%
% Boundary conditions.
j = [1:MP];
coriolis(1,j) = zeros(size(coriolis(1,j)));
coriolis(LP,j) = zeros(size(coriolis(LP,j)));

i = [2:L];
coriolis(i,1) = zeros(size(coriolis(i,1)));
coriolis(i,MP) = zeros(size(coriolis(i,MP)));



grid_obj.s1 = s1;
grid_obj.s2 = s2;
grid_obj.angle = ang;
grid_obj.x_rho = xr;
grid_obj.y_rho = yr;
grid_obj.lon_rho = lon_rho;
grid_obj.lat_rho = lat_rho;
grid_obj.pm = pm;
grid_obj.pn = pn;
grid_obj.dndx = dndx;
grid_obj.dmde = dmde;
grid_obj.x_psi = xpsi;
grid_obj.y_psi = ypsi;
grid_obj.lon_psi = lon_psi;
grid_obj.lat_psi = lat_psi;
grid_obj.x_u = xu;
grid_obj.x_v = xv;
grid_obj.y_u = yu;
grid_obj.y_v = yv;
grid_obj.lon_u = longitude_u;
grid_obj.lon_v = longitude_v;
grid_obj.lat_u = latitude_u;
grid_obj.lat_v = latitude_v;

grid_obj.coriolis = coriolis;

return;














%
% Here we perform the actual masking.
function gridgen_mask()

%disp ( 'here in gridgen_mask' );

global grid_obj;



L = grid_obj.L;
M = grid_obj.M;
LM = grid_obj.LM;
MM = grid_obj.MM;
LP = grid_obj.LP;
MP = grid_obj.MP;


%coastline_x_meters = grid_obj.coastline_x_meters;
%coastline_y_meters = grid_obj.coastline_y_meters;
%x_rho = grid_obj.x_rho;
%y_rho = grid_obj.y_rho;
coastline_x = grid_obj.projected_coast_x;
coastline_y = grid_obj.projected_coast_y;
[x_rho,y_rho] = m_ll2xy ( grid_obj.lon_rho, grid_obj.lat_rho );



%
% h is the bathymetry matrix.
% land_points will be 1 everywhere is is actually land, NaN
% where it is water.
mask_rho = ones(LP,MP);
land_points = zeros(LP,MP);


%
% This allows the upcoming for loop to run without special cases.  So
% I guess you could say I set up a special case here, huh?
nan_inds = find(isnan(coastline_x));
if ( isempty(nan_inds) )
    nan_inds = [0; length(coastline_x)+1];
else
    nan_inds = [0; nan_inds(:)];
end

instructions{1} = sprintf ( 'GRID CELL MASKING' ); 
instructions{2} = sprintf ( 'ok, ok, we''re really masking now...');
gridgen_command ( 'set_instructions', instructions );


for i = 1:length(nan_inds)-1

    land_inds = [nan_inds(i)+1:nan_inds(i+1)-1];
    inds = mexinside ( x_rho, y_rho, ...
		       coastline_x(land_inds), coastline_y(land_inds) );
    inside_inds = find(inds==1);
    land_points(inside_inds) = ones(size(inside_inds));


    %
    % tell the user by how much we done.
    instructions{3} = sprintf ( '%.1f%% done.', nan_inds(i+1)/length(coastline_x)*100 );
    gridgen_command ( 'set_instructions', instructions );

end
    
instructions{3} = sprintf ( '100.0%% done.' );
gridgen_command ( 'set_instructions', instructions );



%
% Here we determine mask_rho.  This is the opposite of land_points
land_indices = find(land_points==1);
grid_obj.land_indices = land_indices;
mask_rho(land_indices) = zeros(size(land_indices));



%
% Construct the other masks.
[mask_u, mask_v, mask_psi] = uvp_masks ( mask_rho' );
mask_u = mask_u';
mask_v = mask_v';
mask_psi = mask_psi';

grid_obj.mask_rho = mask_rho;
grid_obj.mask_u = mask_u;
grid_obj.mask_v = mask_v;
grid_obj.mask_psi = mask_psi;


return;















function [umask,vmask,pmask]=uvp_masks(rmask);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Copyright (c) 1996 Rutgers University                                    %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                           %
%  function [umask,vmask,pmask]=uvp_masks(rmask)                            %
%                                                                           %
%  This function computes the Land/Sea masks on U-, V-, and PSI-points      %
%  from the mask on RHO-points.                                             %
%                                                                           %
%  On Input:                                                                %
%                                                                           %
%    rmask        Land/Sea mask on RHO-points (real matrix).                %
%                                                                           %
%  On Output:                                                               %
%                                                                           %
%    umask        Land/Sea mask on U-points (real matrix).                  %
%    vmask        Land/Sea mask on V-points (real matrix).                  %
%    pmask        Land/Sea mask on PSI-points (real matrix).                %
%                                                                           %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[Mp Lp]=size(rmask);

%  Land/Sea mask on U-points.

for i=2:Lp,
  for j=1:Mp,
    umask(j,i-1)=rmask(j,i)*rmask(j,i-1);
  end,
end,

%  Land/Sea mask on V-points.

for i=1:Lp,
  for j=2:Mp,
    vmask(j-1,i)=rmask(j,i)*rmask(j-1,i);
  end,
end,

%  Land/Sea mask on PSI-points.

for i=2:Lp,
  for j=2:Mp,
    pmask(j-1,i-1)=rmask(j,i)*rmask(j,i-1)*rmask(j-1,i)*rmask(j-1,i-1);
  end,
end,

return
