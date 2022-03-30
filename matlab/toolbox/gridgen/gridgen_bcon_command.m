% GRIDGEN_BCON_COMMAND
%
% Switchyard routine for boundary construction phase callbacks.
function gridgen_bcon_command( command )

global grid_obj;


%disp ( sprintf ( 'GRIDGEN_BCON_COMMAND:  %s\n', command ) );

switch command

    case 'mouse_down'

        %
        % The SelectionType property tells us which mouse button was used.
        %
        % normal: mouse button 1 ==> add a new control point
        % extend:  mouse button 2 ==> add final control point for this side
        % alt:  mouse button 3 ==> no meaning
        switch ( get(gcf,'SelectionType') )

           case 'normal'
              gridgen_addnew_control_point;
  
           case 'extend'
              gridgen_addfinal_control_point;
  
           case 'alt'
              disp ('set control points: alt chosen, no functionality' );
  
        end


    %
    % This updates the control figure for the boundary
    % construction phase, sets callbacks, initializes any necessary
    % global fields.
    case 'commit_to_boundary_construction'

	gridgen_setup_bcon_gui;

        grid_obj.side1_control_pts = [];
        grid_obj.side1_done = 0;
        grid_obj.side2_control_pts = [];
        grid_obj.side2_done = 0;
        grid_obj.side3_control_pts = [];
        grid_obj.side3_done = 0;
        grid_obj.side4_control_pts = [];
        grid_obj.side4_done = 0;


end

return;






function gridgen_setup_bcon_gui()

global grid_obj;

instructions = { 'Control Point Placement', ...
                 'Use mouse button 1 to mark control point locations on the map.', ...
                 'Use mouse button 2 to mark the end of a side.', ...
		 'Make sure all points lie within the black bathymetry boundary.' };
set ( grid_obj.instructions_text, ...
            'String', instructions, ...
            'Fontsize', 12 );
        
        

%
% Trap any mouse events in the map window to our callback mechanism.
% It will change with each stage that the program is in.
set ( grid_obj.map_figure, ...
   'WindowButtonDownFcn', 'gridgen_bcon_command mouse_down' );



return;









function gridgen_addnew_control_point()
% GRIDGEN_ADDNEW_CONTROL_POINT:  adds new control point in gridgen application.
%

global grid_obj;

hold on

lonlat = get(gca, 'CurrentPoint');
control_point = line ( ...
               'XData', lonlat(1), ...
               'YData', lonlat(3), ...
               'Marker', '*', ...
               'MarkerSize', grid_obj.control_point_marker_size, ...
               'Color', grid_obj.border_control_point_color, ...
               'LineStyle', 'none', ...
               'Tag', 'Control Point' );

if ( ~grid_obj.side1_done )
    grid_obj.side1_control_pts = [grid_obj.side1_control_pts; ...
                                  lonlat(1) lonlat(3)];

elseif ( ~grid_obj.side2_done )
    grid_obj.side2_control_pts = [grid_obj.side2_control_pts; ...
                                  lonlat(1) lonlat(3)];

elseif ( ~grid_obj.side3_done )
    grid_obj.side3_control_pts = [grid_obj.side3_control_pts; ...
                                  lonlat(1) lonlat(3)];
    
elseif ( ~grid_obj.side4_done )
    grid_obj.side4_control_pts = [grid_obj.side4_control_pts; ...
                                  lonlat(1) lonlat(3)];

    
    
end










function gridgen_addfinal_control_point()
% GRIDGEN_ADDFINAL_CONTROL_POINT:  Finishes off a side of control points.
%

global grid_obj;

hold on

lonlat = get(gca, 'CurrentPoint');
control_point = line ( 'XData', lonlat(1), ...
               'YData', lonlat(3), ...
               'Marker', '*', ...
               'MarkerSize', grid_obj.control_point_marker_size, ...
               'Color', grid_obj.corner_point_color, ...
               'LineStyle', 'none', ...
               'Tag', 'Control Point' );

if ( ~grid_obj.side1_done )

   grid_obj.side1_done = 1;

   pts = [grid_obj.side1_control_pts; ...
          lonlat(1) lonlat(3)];

   grid_obj.side1_control_pts = pts;

   h = plot ( pts(:,1), pts(:,2), 'c' );
   set ( h, 'Tag', 'Border Spline Line 1' );

elseif ( ~grid_obj.side2_done )

   grid_obj.side2_done = 1;

   %
   % first point of side 2 is last point of side 1
   [r,c] = size(grid_obj.side1_control_pts);
   n = r;

   pts = [ grid_obj.side1_control_pts(n,1) grid_obj.side1_control_pts(n,2); ...
           grid_obj.side2_control_pts; ...
           lonlat(1) lonlat(3)];

   grid_obj.side2_control_pts = pts;

   h = plot ( pts(:,1), pts(:,2), 'c' );
   set ( h, 'Tag', 'Border Spline Line 2' );


elseif ( ~grid_obj.side3_done )

   grid_obj.side3_done = 1;

   %
   % first point of side 3 is last point of side 2
   [r,c] = size(grid_obj.side2_control_pts);
   n = r;

   pts = [ grid_obj.side2_control_pts(n,1) grid_obj.side2_control_pts(n,2); ...
           grid_obj.side3_control_pts; ...
          [ lonlat(1) lonlat(3)] ];

   grid_obj.side3_control_pts = pts;

   h = plot ( pts(:,1), pts(:,2), 'c' );
   set ( h, 'Tag', 'Border Spline Line 3' );


elseif ( ~grid_obj.side4_done )

   grid_obj.side4_done = 1;

   %
   % first point of side 4 is last point of side 3
   % last point of side 4 is first point of side 1

   [r,c] = size(grid_obj.side3_control_pts);
   n = r;

   pts = ...
      [grid_obj.side3_control_pts(n,1) grid_obj.side3_control_pts(n,2); ...
       grid_obj.side4_control_pts; ...
       [lonlat(1) lonlat(3)]; ...
       grid_obj.side1_control_pts(1,1) grid_obj.side1_control_pts(1,2); ];

   grid_obj.side4_control_pts = pts;

   h = plot ( pts(:,1), pts(:,2), 'c' );
   set ( h, 'Tag', 'Border Spline Line 4' );



   %
   % Get ready for the next phase, boundary refinement.
   gridgen_command setup_boundary_refinement;
   gridgen_command redraw_splines;
   gridgen_command recompute_splines;

end

