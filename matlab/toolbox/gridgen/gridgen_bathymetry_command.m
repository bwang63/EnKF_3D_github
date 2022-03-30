function gridgen_bathymetry_command ( command )

%disp ( sprintf ( 'GRIDGEN_BATHYMETRY_COMMAND:  %s', command ) );

global grid_obj;

points_per_quadrant_edit =  ...
    findobj ( grid_obj.control_figure, 'Tag', 'Points Per Quadrant Edit' );
search_radius_edit = ...
    findobj ( grid_obj.control_figure, 'Tag', 'Search Radius Edit' );


switch ( command )

    case 'commit_to_bathymetry'
        %
        % Both of these must be valid in order for the gridding
        % routine to proceed.  Set them to invalid values to begin 
        grid_obj.points_per_quadrant = -1;
        grid_obj.search_radius = -1;
	gridgen_setup_bathymetry_gui;
	
    case 'grid_bathymetry'
        instructions{1} = 'BATHYMETRY'; 
	instructions{2} = 'Hold on, gridding the bathymetry...'; 
	gridgen_command ( 'set_instructions', instructions );
	gridgen_grid_bathymetry;
	gridgen_destroy_bathymetry_gui;
        gridgen_command commit_to_clipping;

    case 'commit_to_clipping'
	
    case 'set_points_per_quadrant'

	% make sure its valid
	points_per_quadrant = get ( points_per_quadrant_edit, 'string' );
	points_per_quadrant = round ( str2num ( points_per_quadrant ) );
	grid_obj.points_per_quadrant = points_per_quadrant;
	if ( points_per_quadrant < 1 )
	    return;
	end

	%
	% if the search radius is also set, then grid the bastard
	if ( grid_obj.search_radius >= 0 )
	    gridgen_bathymetry_command grid_bathymetry;
	end



    case 'set_search_radius'

	% make sure its valid
	search_radius = get ( search_radius_edit, 'string' );
	search_radius = str2num ( search_radius );
% convert from km to M-map's "fraction of earth radius" projected coordinates
	search_radius = search_radius/6370.;  % 6370 km is approx Earch radius
% 
        grid_obj.search_radius = search_radius;
	if ( search_radius < 0 )
	    return;
	end

	%
	% if the search radius is also set, then grid the bastard
	if ( grid_obj.points_per_quadrant >= 1 )
	    gridgen_bathymetry_command grid_bathymetry;
	end

end

return






%
% Setup widgets and callbacks to handle user input.
function gridgen_setup_bathymetry_gui()

%disp ( 'here in gridgen_setup_bathymetry_gui' );

global grid_obj;

%
% bathymetry gridding
instructions{1} = 'BATHYMETRY';
instructions{2} = 'Enter values for the points per quadrant and search radius.';

%
% Figure out approximately how much distance (projected) there is between points.
[proj_bathyx, proj_bathyy] = m_ll2xy ( grid_obj.lon_bathy, grid_obj.lat_bathy ); 
%xmin = min(grid_obj.mxbathy(:));
%xmax = max ( grid_obj.mxbathy(:) );
%ymin = min(grid_obj.mybathy(:));
%ymax = max ( grid_obj.mybathy(:) );
xmin = min(proj_bathyx);
xmax = max ( proj_bathyx );
ymin = min(proj_bathyy);
ymax = max ( proj_bathyy );
area = (ymax-ymin)*(xmax-xmin);
separation = sqrt ( area/length(proj_bathyy) );
%instructions{3} = sprintf ( 'Figure on approximately %f projected units between points.', separation );

gridgen_command ( 'set_instructions', instructions );

points_per_quadrant_label = ...
    uicontrol('Parent', grid_obj.control_figure, ...
              'Units','normalized', ...
              'BackgroundColor',[0.85 0.85 0.85], ...
              'Position',[0.10 0.28 0.35 0.07], ...
              'String','Points Per Quadrant', ...
              'Style','text', ...
              'Tag','Points Per Quadrant Label', ...
              'Visible', 'on' );
points_per_quadrant_edit = ...
    uicontrol('Parent',grid_obj.control_figure, ...
              'Units','normalized', ...
              'BackgroundColor',[1 1 1], ...
              'Callback','gridgen_bathymetry_command set_points_per_quadrant', ...
              'Position',[0.225 0.18 0.10 0.10 ], ...
              'Style','edit', ...
              'Tag','Points Per Quadrant Edit', ...
	      'Value', 0, ...
              'Visible', 'on' );
search_radius_label = ...
    uicontrol('Parent', grid_obj.control_figure, ...
              'Units','normalized', ...
              'BackgroundColor',[0.85 0.85 0.85], ...
              'Position',[0.55 0.28 0.35 0.07], ...
              'String','Search Radius (km)', ...
              'Style','text', ...
              'Tag','Search Radius Label', ...
              'Visible', 'on' );
search_radius_edit = ...
    uicontrol('Parent',grid_obj.control_figure, ...
              'Units','normalized', ...
              'BackgroundColor',[1 1 1], ...
              'Callback','gridgen_bathymetry_command set_search_radius', ...
              'Position',[0.675 0.18 0.10 0.10 ], ...
              'Style','edit', ...
              'Tag','Search Radius Edit', ...
	      'Value', 0, ...
              'Visible', 'on' );
return;







%
% remove the current gui before going on to the next step
function gridgen_destroy_bathymetry_gui()

global grid_obj;

widget = findobj ( grid_obj.control_figure, ...
		   'Tag', 'Points Per Quadrant Label' ); 
delete(widget);
widget = findobj ( grid_obj.control_figure, ...
		   'Tag', 'Points Per Quadrant Edit' ); 
delete(widget);
widget = findobj ( grid_obj.control_figure, ...
		   'Tag', 'Search Radius Label' ); 
delete(widget);
widget = findobj ( grid_obj.control_figure, ...
		   'Tag', 'Search Radius Edit' ); 
delete(widget);

return;






function gridgen_grid_bathymetry()

%disp ( 'here in gridgen_grid_bathymetry' );

global grid_obj;

L = grid_obj.L;
M = grid_obj.M;
LM = grid_obj.LM;
MM = grid_obj.MM;
LP = grid_obj.LP;
MP = grid_obj.MP;


%min_lon_map = grid_obj.min_lon_map;
%min_lat_map = grid_obj.min_lat_map;
[x_rho,y_rho] = m_ll2xy(grid_obj.lon_rho, grid_obj.lat_rho);


grid_bathymetry = zeros(LP,MP);

j = [1:MP];
grid_bathymetry(1,j) = Inf * ones(size(grid_bathymetry(1,j)));
grid_bathymetry(LP,j) = Inf * ones(size(grid_bathymetry(LP,j)));

i = [2:L];
grid_bathymetry(i,1) = Inf * ones(size(grid_bathymetry(i,1)));
grid_bathymetry(i,MP) = Inf * ones(size(grid_bathymetry(i,MP)));

grid_bathymetry(grid_obj.land_indices) = Inf * ones(size(grid_obj.land_indices));




%
% get the bathymetry , convert to projected units
[xbathy,ybathy] = m_ll2xy ( grid_obj.lon_bathy, grid_obj.lat_bathy ); 
zbathy = grid_obj.zbathy;

%
% do the gridding
to_grid_inds = find(isfinite(grid_bathymetry));
grid_obj.to_grid_inds = to_grid_inds;



grid_bathymetry(to_grid_inds) = ...
    gridgen_griddata ( xbathy, ybathy, zbathy, ...
		       x_rho(to_grid_inds), y_rho(to_grid_inds) );

%
% set INF elements of h equal to -99999.00
inds = find(isinf(grid_bathymetry));
grid_bathymetry(inds) = -99999 * ones(size(grid_bathymetry(inds)));

grid_obj.grid_bathymetry = grid_bathymetry;



return;








function gridgen_destroy_gridgen_gui ()

%disp ( 'here in gridgen_destroy_bathymetry_gui' );

global grid_obj;

return;




%
% actually grids the bathymetry
%
% x, y, z:  represents bathymetry data we have
% xi, yi, zi:  what we want to grid
function zi = gridgen_griddata ( x, y, z, xi, yi )

global grid_obj;

%n = length(xi(:));
%zi = zeros(size(xi));
%for i = 1:n
%    bathy_ind = gridgen_nearest_pts ( x, y, xi(i), yi(i) );
%    zi(i) = z(bathy_ind);
%end

search_radius = grid_obj.search_radius;
points_per_quadrant = grid_obj.points_per_quadrant;


n = length(xi(:));

instructions{1} = 'BATHYMETRY';

for k = 1:n

    if ( mod(k,100) == 0 )
        instructions{2} = sprintf ( '%.1f%% done...', k/n*100 ); 
        gridgen_command ( 'set_instructions', instructions );
    end

    near_inds = find ( (abs(x-xi(k)) <= search_radius) & (abs(y-yi(k)) <= search_radius) );
    nearx = x(near_inds)-xi(k); 
    neary = y(near_inds)-yi(k);
    nearz = z(near_inds);

    quad1_inds = find ( (nearx>=0) & (neary>=0) );
    quad1x = nearx(quad1_inds); 
    quad1y = neary(quad1_inds);
    quad1z = nearz(quad1_inds);

    quad2_inds = find ( (nearx<0) & (neary>=0) );
    quad2x = nearx(quad2_inds); 
    quad2y = neary(quad2_inds);
    quad2z = nearz(quad2_inds);

    quad3_inds = find ( (nearx<0) & (neary<0) );
    quad3x = nearx(quad3_inds); 
    quad3y = neary(quad3_inds);
    quad3z = nearz(quad3_inds);

    quad4_inds = find ( (nearx>=0) & (neary<0) );
    quad4x = nearx(quad4_inds); 
    quad4y = neary(quad4_inds);
    quad4z = nearz(quad4_inds);

    if ( ~isempty(quad1_inds) )
	ranges_quad1 =  sqrt(quad1x.^2 + quad1y.^2);
	[sorted_range_quad1, range_inds] = sort(ranges_quad1);
	closest_quad1_inds = range_inds([1:1:min(length(range_inds),points_per_quadrant)]);
    else
	ranges_quad1 = [];
	closest_quad1_inds = [];
    end
    if ( ~isempty(quad2_inds) )
	ranges_quad2 =  sqrt(quad2x.^2 + quad2y.^2);
	[sorted_range_quad2, range_inds] = sort(ranges_quad2);
	closest_quad2_inds = range_inds([1:1:min(length(range_inds),points_per_quadrant)]);
    else
	ranges_quad2 = [];
	closest_quad2_inds = [];
    end
    if ( ~isempty(quad3_inds) )
	ranges_quad3 =  sqrt(quad3x.^2 + quad3y.^2);
	[sorted_range_quad3, range_inds] = sort(ranges_quad3);
	closest_quad3_inds = range_inds([1:1:min(length(range_inds),points_per_quadrant)]);
    else
	ranges_quad3 = [];
	closest_quad3_inds = [];
    end
    if ( ~isempty(quad4_inds) )
	ranges_quad4 =  sqrt(quad4x.^2 + quad4y.^2);
	[sorted_range_quad4, range_inds] = sort(ranges_quad4);
	closest_quad4_inds = range_inds([1:1:min(length(range_inds),points_per_quadrant)]);
    else
	ranges_quad4 = [];
	closest_quad4_inds = [];
    end

    closest_ranges = [ranges_quad1(closest_quad1_inds); ...
		 ranges_quad2(closest_quad2_inds); ...
		 ranges_quad3(closest_quad3_inds); ...
		 ranges_quad4(closest_quad4_inds); ];
    closest_z = [quad1z(closest_quad1_inds); ...
		 quad2z(closest_quad2_inds); ...
		 quad3z(closest_quad3_inds); ...
		 quad4z(closest_quad4_inds); ];


    %
    % If no points are close enough, then "closest_ranges"
    % will be empty.  In that case, set the bathymetry to -99999.
    % Otherwise weight it according to who is closest.
    if ( isempty(closest_ranges) )
	zi(k) = -99999;
    else
        inv_ranges = 1 ./ closest_ranges;
        zi(k) = dot ( ( inv_ranges ./ sum(inv_ranges) ), closest_z );
    end
	

end




return;








function xnew=min(x)
% just like min, except that it skips over bad points
[imax,jmax]=size(x);

for j=1:jmax
       good=find(finite(x(:,j)));
       if length(good)>0
          xnew(j)=min(x(good,j));
       else
          xnew(j)=NaN;
       end
end



function xnew=max(x)
% just like max, except that it skips over bad points
[imax,jmax]=size(x);

for j=1:jmax
       good=find(finite(x(:,j)));
       if length(good)>0
          xnew(j)=max(x(good,j));
       else
          xnew(j)=NaN;
       end
end
