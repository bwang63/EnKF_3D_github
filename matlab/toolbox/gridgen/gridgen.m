function gridgen( coastline_file, bathymetry_file )
% GRIDGEN:  generates 2D orthogonal curvilinear coordinates grid.
%
% USAGE:  gridgen ( coastline_file, bathy_file );
%
% PARAMETERS:
%   coastline_file:  Longitude and latitude for coastline.  
%                    Optional.  If not present, prompt for a 
%                    *.mat file.
%   bathy_file:      Longitude, latitude, depth used for gridding.
%                    Optional.  If not present, prompt for a 
%                    *.mat file.
%
% AUTHOR: John Evans (joevans@usgs.gov)
%
% For more information, see http://seiche.er.usgs.gov/gridgen/
%

global grid_obj;

%
% Description of fields of grid_obj
% =================================
% angle:
%   Angle between xi and eta axis of grid points.
% bathymetry_file:
%   pathname of bathymetry file
% border_control_point_color:
%   RGB matlab resource triplet to represent in what color the
%   control points used to determine the grid border are to
%   be drawn in.
% border_spline_color:
%   RGB matlab resource triplet to represent in what color the
%   grid boundary is to be drawn when first constructing the
%   boundary.
% coastline_color:
%   RGB matlab resource triplet to represent in what color the
%   coastline is to be drawn.
% coastline_longitude, coastline_latitude:
%   Locations of coastline coming from coastline file.  May contain
%   NaNs.
% coastline_x_meters, coastline_y_meters:
%   Same as "coastline_longitude" and "coastline_latitude", but
%   converted to meters.
% control_figure:
%   Matlab handle for figure window with instructions and widgets.
% control_point_marker_size:
%   Matlab resource to represent the size of the asterisks used to
%   represent the control points determining the grid borders.
% coriolis:
%   This is the coriolis factor at each rho point.  Right now, it is
%   just the latitude in degrees
% corner_point_color:
%   Same as border_control_color, except at the corners of the grid.
% current_slider_index:
%   Which seta or sxi point we want to move when affecting cell spacing.
% depthmin, depthmax:
%   Defines a clipping plane for scrum files.
% dmde, dndx:
%   Derivatives of the metric coefficients (pm and pn).
% double_res_[xy]:
%   Same as x and y.  Double resolution grid.  It is subsampled before
%   written out.
% grid_bathymetry:
%   Depth in meters at each grid point.
% grid_longitude, grid_latitude:
%   lon and lat of the double resolution grid, not the final
%   grid.
% grid_color:
%   RGB matlab resource triplet to represent in what color the
%   sepeli-computed grid is to be drawn in.
% grid_x_meters, grid_y_meters:
%   Same as "x_rho" and "y_rho" but in meters.
% h:
%   This is bathymetry for the grid to be written out.
% instructions_text:
%   Matlab handle for text area for user instructions.  Underneath
%   control_figure handle heirarchy.
% kb:
%   Not used, I think.  This was related to the possibility of
%   changing what side one used to specify moving control points
%   around to affect cell spacing.  Just sides 1 and 2 now.
% land_indices:
%   indices of "mask_rho" points that represent land
% lat_rho, lon_rho:
%   latitude and longitude at the rho points
% lat_bathy, lon_bathy:
%   latitude and longitude of the bathymetry
% map_figure, map_axis:
%   Matlab handles for the figure window and axis where all the
%   drawing takes place.
% mask_rho, mask_u, mask_v, mask_psi:
%   These matrices are 1 where the respective rho, u, v, and psi points
%   are water, and 0 for land.  Only mask_rho is valid for ECOM.
% min_lon_map, min_lat_map:
%   These two scalars are the longitude and latitude of the southwest
%   corner of the map figure.
% min_resolution, max_resolution:
%   The grid must have at least min_resolution points per side, and no
%   more that max_resolution points per side.
% m[xy]bathy:
%   distance in meters of bathymetry points from min_lon_map and map_lon_map
% neta, nxi:
%   number of seta, sxi points.
% node_type:
%   Another probably useless field.  All sides start out uniform and
%   then become irregular, so it is sort of unnecessary.
% pm, pn:
%   The metric coefficients m and n of the orthogonal curvilinear grid.
% points_per_quadrant:
%   Used to grid the bathymetry.  The user inputs the number of points
%   that must be found in each quadrant around a point to grid.  the
%   points found are weighted according to inverse distance.
% projected_coast_[xy]:
%   Represent the coordinates of the coastline in the map-projected
%   coordinate system.
% projection:
%   Either "mercator", "stereographic", or "lambert_conformal_conic"
% scrum_file:
%   name of scrum file to write.
% search_radius:
%   Used to grid the bathymetry.  The user inputs a search radius
%   in meters.
% seta, sxi:
%   These are points ranging from 0 to 1 that control where the boundary
%   cells are located along the border.  A uniform spacing means that
%   the cells are fairly equidistant.  For a better explanation you will
%   have to consult the documentation for sepeli.f, EXCEPT THAT THERE 
%   ISN'T ANY DOCUMENTATION!!!  HA!!
% seta_marker_inds, sxi_marker_inds:
%   When the border cell spacing is to be adjusted, these keep track of
%   where the "markers" are to be displayed.  These show up as red 
%   asterisks.
% side[1234]_control_pts:
%   These are the coordinates of the control points specified by the 
%   user thru using the mouse that determine the grid border.
% side[1234]_done:
%   Flags to indicate whether or not the user has finished supplying
%   all the points to determine a particular grid border side, whether
%   it is side 1, 2, 3, or 4.  Must be done sequentially, of course.
% side[1234]_spline_pts:
%   These are points computed along the border of the grid.  Not directly
%   used in grid computations, but for display purposes.
% side[1234]_[xy]_ppform:
%   When we are ready to generate the boundary points for the grid, 
%   we create first the pp-form of the splines representing the boundary.
%   This way we can generate [x,y] later depending on the input t 
%   vector we feed into it.  If t is uniform, then the x and y points
%   along a grid boundary will be uniformly separated (relatively, 
%   anyway).  If t is not uniform, then x and y will be unevenly
%   spaced, which we may find desirable.
% sides[13,24]_resolution:
%   The current number of points per side.  Sides 1 and 3 must be the
%   same, sides 2 and 4 must be the same.  Set thru either sliders
%   or edits.
% slider_point_color:
%   RGB matlab resource triplet to represent in what color the
%   control points that determine where the grid cells lie on the
%   grid, after resolution has been determined.
% slide_side:
%   Not used, at least I don't think it is used.  It shouldn't be. 
%   Sides 1 and 2 are the ones that one can move the control points
%   around to affect grid cell spacing.  I originally thought that
%   one might want to be able to change this, but I was probably
%   smoking crack at the time.
% slider_side_curve:
%   This probably doesn't need to be a field that is kept around.
%   Used to figure out what control point was closest to where
%   the user clicked the mouse in order to affect grid cell
%   spacing.
% s1, s2:
%   No idea what these are.  Took them directly from the cgridgen
%   code.
% to_grid_inds:
%   Indices where valid bathymetry will exist.
% xoff, yoff:
%   Distance in meters from the lower left hand corner of the map axis
%   to the southwest corner of the grid.
% x_rho, y_rho, x_u, x_v, y_u, y_v, x_psi, y_psi:
%   Matrices representing the locations of the rho, u, v, and psi points 
%   in meters.
% x, y:
%   Double resolution grid points.  Not written out.
% zbathy:
%   bathymetric depth in meters
% L, M:
%   L = number of rho points along xi axis.
%   M = number of rho points along eta axis.
% LM, MM:
%   One less than L, M
% LP, MP:
%   One more than L, M.





% If there are no input arguments, force the user to give the
% name of a file to use for lat and lon.
if ( nargin == 0 );

    %
    % Get the name for the coastline file.
    [fname, pathname] = uigetfile ( '*.mat', 'Coastline File' );
    coastline_file = sprintf ( '%s%s', pathname, fname );

    %
    % Get the name for the bathymetry file.
    [fname, pathname] = uigetfile ( '*.mat', 'Bathymetry File' );
    bathymetry_file = sprintf ( '%s%s', pathname, fname );


elseif ( nargin ~= 2 )
    help gridgen;
    return;
end

%
% Load the coastline data.
load ( coastline_file );
if ( ~exist('lon') | ~exist('lat') )
    fprintf ( 2, 'Mat-file must have ''lon'' and ''lat'' variables.' );
    help gridgen;
    return;
end
grid_obj.coastline_longitude = lon;
grid_obj.coastline_latitude = lat;

grid_obj.bathymetry_file = bathymetry_file;
load ( bathymetry_file );
if ( ~exist('xbathy') | ~exist('ybathy') | ~exist('zbathy') )
    fprintf ( 2, 'Bathymetry mat-file must have ''xbathy'', ''ybathy'', and ''zbathy'' variables.' );
    help gridgen;
    return;
end



gridgen_setup_controls;
grid_obj.control_figure = findobj ( 0, 'Tag','Gridgen Control Figure');
grid_obj.instructions_text = findobj ( grid_obj.control_figure, 'Tag', 'Instructions Text' );


gridgen_command commit_to_projection;



%
% Set up some resources that are used often enough
% that they really needed to be defined.


%
% medium green coastline
grid_obj.coastline_color = [0 0.5 0];

%
% Cyan border spline lines.
grid_obj.border_spline_color = [0 1 1];

%
% Blue control points, except for red corners.
grid_obj.border_control_point_color = [0 0 1];
grid_obj.corner_point_color = [1 0 0];

%
% Black grid.
grid_obj.grid_color = [0 0 0];


%
% Red slider point colors
grid_obj.slider_point_color = [1 0 0];


%
% Other resources.

%
% Maximum number of spline points.
grid_obj.min_resolution = 7;
grid_obj.max_resolution = 300;

grid_obj.sides13_resolution = grid_obj.min_resolution;
grid_obj.sides24_resolution = grid_obj.min_resolution;

grid_obj.control_point_marker_size = 10;


return;





gridgen_command setup_boundary_construction;




%
% Check to see if the gcf has any data.
child_axes = findobj ( grid_obj.map_figure, 'type', 'axes' );
if ( isempty ( child_axes ) )
   fprintf ( 2, 'There is no currently defined axis.\n' );
   return;
end

line_data = findobj ( grid_obj.map_axis, 'type', 'line' );

%
% if more than one line, turn it all into a single, nan delimited line
number_of_lines = size(line_data,1);
if ( number_of_lines > 1 )
    all_xd = [];
    all_yd = [];
    for i = 1:number_of_lines
	xd = get(line_data(i),'XData');
	all_xd = [all_xd; xd(:); nan];
	yd = get(line_data(i),'YData');
	all_yd = [all_yd; yd(:); nan];
    end
    all_xd(number_of_lines) = [];
    all_yd(number_of_lines) = [];
    delete ( line_data );
    line_data = line ( 'XData', all_xd, 'YData', all_yd );
end



return;













%
% GRIDGEN_SETUP_CONTROLS
%
% Set up the control figure.
% This much stays constant thru all phases.
function gridgen_setup_controls()
ssize=get(0,'ScreenSize');
a = figure('Color',[0.8 0.8 0.8], ...
	'MenuBar','none', ...
	'Name','Gridgen Control', ...
	'NumberTitle','off', ...
	'Position',[10 ssize(4)-220 500 180], ...
	'Tag','Gridgen Control Figure');
b = uimenu ( 'Parent', a, ...
	'Label', 'File', ...
	'Tag', 'Gridgen File Menu' );
c = uimenu ( 'Parent', b, ...
	'Callback', 'gridgen_command exit', ...
	'Label', 'Exit', ...
	'Tag', 'Gridgen Exit Menu Item' );
b = uicontrol('Parent',a, ...
	'Units','normalized', ...
	'BackgroundColor',[0.701961 0.701961 0.701961], ...
	'Position',[0.025 0.525 0.95 0.45], ...
	'Style','frame', ...
	'Tag','Text Frame');
b = uicontrol('Parent',a, ...
	'Units','normalized', ...
	'BackgroundColor',[0.95 0.95 0.95], ...
	'HorizontalAlignment', 'left', ...
	'Position',[0.05 0.55 0.9 0.4], ...
	'Style','text', ...
	'Tag','Instructions Text');
return;
