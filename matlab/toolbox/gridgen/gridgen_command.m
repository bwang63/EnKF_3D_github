function gridgen_command ( command, command_data )
% GRIDGEN_COMMAND:  callback switch for gridgen.  
%
% This routine should not be called fromt the command line.
%


%disp ( sprintf ( 'GRIDGEN_COMMAND:  %s', command ) );

global grid_obj;


switch command

    case 'commit_to_projection'
	gridgen_projection_command commit_to_projection;


    %
    % Enter boundary construction, where no borders have been set yet
    case 'commit_to_boundary_construction'
        gridgen_bcon_command commit_to_boundary_construction;



    %
    % We want to go to the phase where we set the grid
    % resolution.
    case 'commit_to_resolution'
        gridgen_brefine_command commit_to_resolution;



    %
    % We want to go to the phase where we set the grid 
    % cell spacing.
    case 'commit_to_cell_spacing'
	gridgen_cell_spacing_command commit_to_cell_spacing;


    case 'commit_to_masking'
	gridgen_masking_command commit_to_masking;

    case 'commit_to_bathymetry'
	gridgen_bathymetry_command commit_to_bathymetry;

    case 'commit_to_clipping'
	gridgen_clipping_command commit_to_clipping;

    case 'commit_to_coriolis'
	gridgen_coriolis_command commit_to_coriolis;


    case 'commit_to_output'
	gridgen_output_command commit_to_output;


    case 'commit_to_scrum'
	gridgen_scrum_command commit_to_scrum;


    case 'plot_interior'
	gridgen_plot_interior;

    case 'set_instructions'
        text_field = findobj (    grid_obj.control_figure, ...
                                  'Style', 'text', ...
                                  'Tag', 'Instructions Text' );
        set ( text_field, ...
              'FontSize', 12, ...
              'String', command_data );
        drawnow;
        


    case 'exit'
        delete ( grid_obj.control_figure );
	eval ( 'delete (grid_obj.map_figure);', '' );
	clear grid_obj;



    case 'close_map_figure'
	gridgen_command exit;
	closereq;







   %
   % Enter boundary refinement, where all the side control points have
   % been initially set, and we can now allow for the user
   % to set resolution for the border splines.
   case 'setup_boundary_refinement'
       gridgen_brefine_command setup_boundary_refinement;
      


   %
   % Redraw the boundary curves.
   case 'redraw_splines'

      figure ( grid_obj.map_figure );
      gridgen_redraw_splines;



    case 'recompute_splines'
	gridgen_recompute_splines;



    case 'all_done'
	

	%
	% Unset the windowbuttondownfcn callback.
	set ( grid_obj.map_figure, 'WindowButtonDownFcn', '' );

        user_string = [];
        user_string{1} = sprintf ( 'All done.  Use file menu/exit to quit.' );
        
        text_field = findobj (    grid_obj.control_figure, ...
                                  'Style', 'text', ...
                                  'Tag', 'Instructions Text' );
        set ( text_field, ...
              'FontSize', 12, ...
              'String', user_string );
        
        
        
end










function gridgen_redraw_splines()
% GRIDGEN_REDO_SPLINES:  Redraws spline borders for gridgen.
%

%disp ( 'here in gridgen_redraw_splines' )
global grid_obj;


%
% Delete the old control points, old borders.
old_control_points = findobj ( gcf, 'Tag', 'Control Point' );
delete ( old_control_points );
h = findobj ( grid_obj.map_figure, 'Tag', 'Border Spline Line 1' );
delete(h);
h = findobj ( grid_obj.map_figure, 'Tag', 'Border Spline Line 2' );
delete(h);
h = findobj ( grid_obj.map_figure, 'Tag', 'Border Spline Line 3' );
delete(h);
h = findobj ( grid_obj.map_figure, 'Tag', 'Border Spline Line 4' );
delete(h);



%
% Draw the continuous borders for each side.
pts = grid_obj.side1_control_pts;
resolution = 100;
spline_pts = make_spline ( pts(:,1), pts(:,2), resolution );
border_handle =  line ( 'XData', spline_pts(:,1), ...
                        'YData', spline_pts(:,2), ...  
                        'Color', grid_obj.border_spline_color, ...  
                        'Tag', 'Border Spline Line 1' );

pts = grid_obj.side2_control_pts;
resolution = 100;
spline_pts = make_spline ( pts(:,1), pts(:,2), resolution );
border_handle =  line ( 'XData', spline_pts(:,1), ...
                        'YData', spline_pts(:,2), ...  
                        'Color', grid_obj.border_spline_color, ...  
                        'Tag', 'Border Spline Line 2' );

pts = grid_obj.side3_control_pts;
resolution = 100;
spline_pts = make_spline ( pts(:,1), pts(:,2), resolution );
border_handle =  line ( 'XData', spline_pts(:,1), ...
                        'YData', spline_pts(:,2), ...  
                        'Color', grid_obj.border_spline_color, ...  
                        'Tag', 'Border Spline Line 3' );

pts = grid_obj.side4_control_pts;
resolution = 100;
spline_pts = make_spline ( pts(:,1), pts(:,2), resolution );
border_handle =  line ( 'XData', spline_pts(:,1), ...
                        'YData', spline_pts(:,2), ...  
                        'Color', grid_obj.border_spline_color, ...  
                        'Tag', 'Border Spline Line 4' );



%
% Draw the corner control point.
corner_pts = [ grid_obj.side1_control_pts(1,:); ...
               grid_obj.side2_control_pts(1,:); ...
               grid_obj.side3_control_pts(1,:); ...
               grid_obj.side4_control_pts(1,:) ];

corner_pts_handle = line ( 'XData', corner_pts(:,1), ...
                            'YData', corner_pts(:,2), ...
                            'LineStyle', 'None', ...  
                            'Marker', '*', ...  
                            'MarkerSize', grid_obj.control_point_marker_size, ...  
                            'Color', grid_obj.corner_point_color, ...  
                            'Tag', 'Control Point' );



%
% Now draw the interior control points.
[r1,c1] = size ( grid_obj.side1_control_pts );
[r2,c2] = size ( grid_obj.side2_control_pts );
[r3,c3] = size ( grid_obj.side3_control_pts );
[r4,c4] = size ( grid_obj.side4_control_pts );
interior_points = [  grid_obj.side1_control_pts(2:r1-1,:); ...
                     grid_obj.side2_control_pts(2:r2-1,:); ...
                     grid_obj.side3_control_pts(2:r3-1,:); ...
                     grid_obj.side4_control_pts(2:r4-1,:) ] ;



control_pts_handle = line ( 'XData', interior_points(:,1), ...
                            'YData', interior_points(:,2), ...
                            'LineStyle', 'None', ...  
                            'Marker', '*', ...  
                            'MarkerSize', grid_obj.control_point_marker_size, ...  
                            'Color', grid_obj.border_control_point_color, ...  
                            'Tag', 'Control Point' );


return;






%
% Recompute the border splines based upon the slider values.
function gridgen_recompute_splines()

global grid_obj;


%
% Lastly, set up the border points determined by the resolution sliders.
% Remember, these are NOT the same as the control points!  The control
% points specify the spline, while the border points are just points
% along the spline, the number should be 7??

%
% If the sliders have been defined and have values, then that is the
% value to use.  Otherwise use the minimum resolution.
resolution_slider = findobj ( grid_obj.control_figure, ...
                                    'Tag', 'Side 1,3 Resolution Slider' );
if ( isempty(resolution_slider) )
    resolution = grid_obj.min_resolution;
else
    resolution = get ( resolution_slider, 'value' );
end

pts = grid_obj.side1_control_pts;
spline_pts = make_spline ( pts(:,1), pts(:,2), resolution );
grid_obj.side1_spline_pts = spline_pts;

pts = grid_obj.side3_control_pts;
spline_pts = make_spline ( pts(:,1), pts(:,2), resolution );
grid_obj.side3_spline_pts = spline_pts;




resolution_slider = findobj ( grid_obj.control_figure, ...
                                    'Tag', 'Side 2,4 Resolution Slider' );
if ( isempty(resolution_slider) )
    resolution = grid_obj.min_resolution;
else
    resolution = get ( resolution_slider, 'value' );
end
pts = grid_obj.side2_control_pts;
spline_pts = make_spline ( pts(:,1), pts(:,2), resolution );
grid_obj.side2_spline_pts = spline_pts;

pts = grid_obj.side4_control_pts;
spline_pts = make_spline ( pts(:,1), pts(:,2), resolution );
grid_obj.side4_spline_pts = spline_pts;

return;







%
% make_spline
function pts =make_spline ( x, y, spline_resolution )

n = length(x);
t = linspace(0.0, 1.0, n);
ti = linspace(0.0, 1.0, spline_resolution );
xi = spline( t, x, ti );
yi = spline( t, y, ti );
pts = [xi(:) yi(:)];

return;





function gridgen_plot_interior()
% GRIDGEN_PLOT_INTERIOR:  plots orthogonal curvilinear grid

%disp ( 'here in gridgen_plot_interior' );

global grid_obj;

figure(grid_obj.map_figure);

%
% plot the grid.
% I don't use pcolor here because it is difficult to control the
% grid color this way.
h = findobj ( grid_obj.map_figure, 'Tag', 'grid lines' );
if ( ~isempty(h) )
    delete(h);
end

[r,c] = size ( grid_obj.x );
for i = 1:r
    h = line ( 'XData', grid_obj.x(i,:), ...
	       'YData', grid_obj.y(i,:), ...
	       'Color', grid_obj.grid_color, ...
	       'Tag', 'grid lines' );
end
for i = 1:c
    h = line ( 'XData', grid_obj.x(:,i), ...
	       'YData', grid_obj.y(:,i), ...
	       'Color', grid_obj.grid_color, ...
	       'Tag', 'grid lines' );
end

return;




