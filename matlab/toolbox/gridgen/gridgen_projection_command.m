function gridgen_projection_command ( command )

global grid_obj;

%disp ( sprintf ( 'GRIDGEN_PROJECTION_COMMAND:  %s', command ) );

switch command

    case 'commit_to_projection'
	gridgen_setup_projection_gui;

    case 'lambert_conformal_conic'
	gridgen_set_projection ( command );
        gridgen_destroy_projection_gui;
        gridgen_command commit_to_boundary_construction;

    case 'mercator'
	gridgen_set_projection ( command );
        gridgen_destroy_projection_gui;
        gridgen_command commit_to_boundary_construction;

    case 'stereographic'
	gridgen_set_projection ( command );
        gridgen_destroy_projection_gui;
        gridgen_command commit_to_boundary_construction;

end


return;














function gridgen_setup_projection_gui()

global grid_obj;

%disp ( 'here in gridgen_setup_projection_gui' );

%
% radio buttons for the projection types
a = grid_obj.control_figure;
b = uicontrol ( 'Parent', a, ...
	'Units','normalized', ...
	'BackgroundColor',[0.701961 0.701961 0.701961], ...
	'Callback','gridgen_projection_command stereographic', ...
	'Position',[0.10 0.25 0.20 0.10], ...
	'String','Stereographic', ...
	'Style','radiobutton', ...
	'Tag','stereographic projection radiobutton', ...
	'Value', 0, ...
	'Visible', 'on' );
b = uicontrol ( 'Parent', a, ...
	'Units','normalized', ...
	'BackgroundColor',[0.701961 0.701961 0.701961], ...
	'Callback','gridgen_projection_command mercator', ...
	'Position',[0.40 0.25 0.20 0.10], ...
	'String','Mercator', ...
	'Style','radiobutton', ...
	'Tag','mercator projection radiobutton', ...
	'Value', 0, ...
	'Visible', 'on' );
b = uicontrol ( 'Parent', a, ...
	'Units','normalized', ...
	'BackgroundColor',[0.701961 0.701961 0.701961], ...
	'Callback','gridgen_projection_command lambert_conformal_conic', ...
	'Position',[0.70 0.25 0.20 0.10], ...
	'String','Lambert Conformal Canonic', ...
	'Style','radiobutton', ...
	'Tag','lambert projection radiobutton', ...
	'Value', 0, ...
	'Visible', 'on' );


%
% instructions
user_string{1} = sprintf ( 'Choose a projection type.' );
set ( grid_obj.instructions_text, ...
      'FontSize', 12, ...
      'String', user_string );
return;








function gridgen_destroy_projection_gui()

global grid_obj;

widget = findobj ( grid_obj.control_figure, 'style', 'radiobutton' );
delete(widget);

return;








function gridgen_setup_map_figure ( )

global grid_obj;

a = figure('Color',[0.8 0.8 0.8], ...
        'CloseRequestFcn', '', ...
	'MenuBar','none', ...
	'Name',sprintf ( '%s projection' , grid_obj.projection ),...
	'NumberTitle','off', ...
	'Position',[   10   10   600   400 ], ...     
	'Tag','Gridgen Map Figure');

grid_obj.map_figure = a;
grid_obj.map_axis = gca;

return;






function gridgen_set_projection ( projection )

global grid_obj;

grid_obj.projection = projection;
gridgen_setup_map_figure;

switch projection

    case 'lambert_conformal_conic'
	lat_extents = [min(grid_obj.coastline_latitude) ...
		       max(grid_obj.coastline_latitude)];
	lon_extents = [min(grid_obj.coastline_longitude) ...
		       max(grid_obj.coastline_longitude)];
	m_proj ( 'lambert conformal conic', ...
		 'lat', lat_extents, ...
		 'lon', lon_extents );

    case 'mercator'
	m_proj ( 'mercator' );

    case 'stereographic'
	m_proj ( 'stereographic' );


end

[grid_obj.projected_coast_x, grid_obj.projected_coast_y] = ...
    m_ll2xy(grid_obj.coastline_longitude, grid_obj.coastline_latitude);
%h = line ( grid_obj.projected_coast_x, grid_obj.projected_coast_y );
h = m_line ( grid_obj.coastline_longitude, grid_obj.coastline_latitude );
set ( gca, 'dataaspectratio', [1 1 1] );
set ( h, 'Color', grid_obj.coastline_color );

%
% Load the bathymetry file to get a boundary on the gridding.
load ( grid_obj.bathymetry_file );

[projected_xbathy, projected_ybathy] = m_ll2xy(xbathy,ybathy);
min_xbathy = min(projected_xbathy);
max_xbathy = max(projected_xbathy);
min_ybathy = min(projected_ybathy);
max_ybathy = max(projected_ybathy);

bathy_xboundary = [ min_xbathy; ...
		    max_xbathy; ...
		    max_xbathy; ...
		    min_xbathy; ...
		    min_xbathy; ];
bathy_yboundary = [ min_ybathy; ...
		    min_ybathy; ...
		    max_ybathy; ...
		    max_ybathy; ...
		    min_ybathy; ];

boundary_line = line ( 'XData', bathy_xboundary, ...
		       'YData', bathy_yboundary, ...
		       'Color', 'k', ...
		       'LineWidth', 2 );




hold on;

