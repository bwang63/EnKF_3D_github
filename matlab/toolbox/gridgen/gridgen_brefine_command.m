% GRIDGEN_BREFINE_COMMAND
%
% Switchyard routine for boundary refinement phase callbacks.
function gridgen_brefine_command( command )

%disp ( sprintf ( 'GRIDGEN_BREFINE_COMMAND:  %s\n', command ) );

switch command

    %
    % We are done with boundary refinement, move on to
    % setting the grid cell resolution.
    case 'commit_to_resolution'
        gridgen_resolution_command setup_grid_cell_resolution;


    case 'mouse_down'
        %
        % The SelectionType property tells us what kind of mouse
        % event was used.
        %
        % normal: mouse button 1 ==> move a control point
        % extend:  mouse button 2 ==> insert an extra control point
        % alt:  mouse button 3 ==> delete a control point
        switch ( get(gcf,'SelectionType') )
        
           case 'normal'
              gridgen_move_control_point;
              gridgen_command redraw_splines;
              gridgen_command recompute_splines;
  
           case 'extend'
              gridgen_insert_control_point;
              gridgen_command redraw_splines;
              gridgen_command recompute_splines;
  
           case 'alt'
              gridgen_delete_control_point;
              gridgen_command redraw_splines;
              gridgen_command recompute_splines;
  
        end




    case 'setup_boundary_refinement'
        gridgen_setup_brefinement;




end

return;









%
% This function sets up the widgets, callbacks, and data fields
% for the boundary refinement stage.
function gridgen_setup_brefinement()

global grid_obj;



instructions = { 'Control Point Refinement', ...
    'Use mouse button 1 to select and move a control point.', ...
    'Use mouse button 2 to add a new control point.', ...
    'Use mouse button 3 to delete a control point (except for corners).', ...
    'Hit Commit when you are happy with the boundary.' };

set ( grid_obj.instructions_text, ...
    'String', instructions, ...
    'Fontsize', 12 );




%
% Set the commit callback correctly.
commit_pushbutton = uicontrol('Parent',grid_obj.control_figure, ...
    'Units','normalized', ...
    'BackgroundColor',[0.701961 0.701961 0.701961], ...
    'Callback','gridgen_command commit_to_resolution', ...
    'Position',[0.40 0.25 0.20 0.10], ...
    'String','Commit', ...
    'Style','pushbutton', ...
    'Tag','Commit Button', ...
    'Visible', 'on' );


%
% Set the mouse button down callback correctly for this stage.
set ( grid_obj.map_figure, ...
   'WindowButtonDownFcn', 'gridgen_brefine_command mouse_down' );


return;






%
% GRIDGEN_MOVE_CONTROL_POINT:  moves a control point in gridgen application
function gridgen_move_control_point()

global grid_obj;


%
% Collect the control points.
control_pts = [grid_obj.side1_control_pts; ...
                grid_obj.side2_control_pts; ...
                grid_obj.side3_control_pts; ...
                grid_obj.side4_control_pts];


current_point = get ( gca, 'CurrentPoint' );
x0 = current_point(1); y0 = current_point(3);


[nearest_index, nearest_dist] = gridgen_nearest_pts( control_pts(:,1), ...
                                             control_pts(:,2), ...
                                             x0, y0);


%
% Highlight the point we are moving until the user choosed the
% exact location to move it to.
selected_point = line ( 'XData', control_pts(nearest_index,1), ...
                        'YData', control_pts(nearest_index,2), ...
                        'Color', 'r', ...
                        'Marker', 'o' );


%
% Now get the replacement point.
[xnew, ynew] = ginput(1);
    
    
delete ( selected_point );

for i = 1:length(nearest_index)
    control_pts(nearest_index(i),:) = [xnew ynew];
end


%
% Rewrite back all the control points.
[r1,c] = size(grid_obj.side1_control_pts);
grid_obj.side1_control_pts = control_pts(1:r1,:);

[r2,c] = size(grid_obj.side2_control_pts);
grid_obj.side2_control_pts = control_pts([(r1+1):(r1+r2)],:);

[r3,c] = size(grid_obj.side3_control_pts);
grid_obj.side3_control_pts = control_pts([(r1+r2+1):(r1+r2+r3)],:);

[r4,c] = size(grid_obj.side4_control_pts);
grid_obj.side4_control_pts = control_pts([(r1+r2+r3+1):(r1+r2+r3+r4)],:);

return;






%
% GRIDGEN_INSERT_CONTROL_POINT:  puts new control point into gridgen border.
function gridgen_insert_control_point()


global grid_obj;


%
% Collect the control points.
control_pts = [grid_obj.side1_control_pts; ...
                grid_obj.side2_control_pts; ...
                grid_obj.side3_control_pts; ...
                grid_obj.side4_control_pts];


current_point = get ( gca, 'CurrentPoint' );
xn = current_point(1); yn = current_point(3);


[r,c] = size(control_pts);

%
% Need to find the proper place to insert the new control point.
% For each pair "P" [P2 - P1] of points, find the projection point, "Pr", 
% of the new control point "Pn" on the line defined by "P".  
% The correct pair in which to do the insertion will be the pair 
% for whom the distance from Pn to Pr is a minimum.  Hope that is
% valid.
%
% The projection is done by noting that the dot product defined by
% the vector [Pn-Pr] and P is 0, as is the cross product of P and
% a vector composed of [Pr - P1].  This gives two equations in two
% unknowns that allow us to solve for Pr.
for i = 1:r-1
    
    x2 = control_pts(i+1,1);
    y2 = control_pts(i+1,2);
    x1 = control_pts(i,1);
    y1 = control_pts(i,2);

    A = [(x2-x1) (y2-y1); (y2-y1) -(x2-x1)];
    b = [(xn*(x2-x1) + yn*(y2-y1)); (x1*(y2-y1) -y1*(x2-x1))];

    if ( isinf(cond(A)) )
        dist(i) = NaN;
    else
        Pr = A\b;

        %
        % Now check that the projected point actually lies in the middle.
        % Do this by noting that for some alpha, 0 <= alpha <= 1.0, 
        % (1-alpha)*P1 + (alpha)*P2 = Pr.
        %
        % If the projected point's alpha value is outside this range,
        % then Pr actually lies on one side or the other.
        if ( (x2 - x1) ~= 0.0 )
            alpha = (Pr(1) - x1)/(x2-x1);
        else
            alpha = (Pr(2) - y1)/(y2-y1);
        end

        if ( (0<= alpha) & (alpha <= 1.0) )
            dist(i) = sqrt( (Pr(1)-xn)*(Pr(1)-xn) + (Pr(2)-yn)*(Pr(2)-yn) );
        else
            dist(i) = NaN;
        end

    end

end

min_index = find(min(dist) == dist);

[r1,c] = size ( grid_obj.side1_control_pts );
[r2,c] = size ( grid_obj.side2_control_pts );
[r3,c] = size ( grid_obj.side3_control_pts );
[r4,c] = size ( grid_obj.side4_control_pts );


if ( min_index < r1 )

    pts = grid_obj.side1_control_pts;

    pts = [ pts(1:min_index,:); ...
            [xn yn]; ...
            pts((min_index+1):r1,:) ];
    grid_obj.side1_control_pts = pts;

    
elseif ( min_index < (r1+r2) )

    pts = grid_obj.side2_control_pts;

    pts = [ pts(1:(min_index-r1),:); ...
            [xn yn]; ...
            pts((min_index-r1+1):r2,:) ];
    grid_obj.side2_control_pts = pts;

elseif ( min_index < (r1+r2+r3) )

    pts = grid_obj.side3_control_pts;

    pts = [ pts(1:(min_index-r1-r2),:); ...
            [xn yn]; ...
            pts((min_index-r1-r2+1):r3,:) ];
    grid_obj.side3_control_pts = pts;

elseif ( min_index < (r1+r2+r3+r4) )

    pts = grid_obj.side4_control_pts;

    pts = [ pts(1:(min_index-r1-r2-r3),:); ...
            [xn yn]; ...
            pts((min_index-r1-r2-r3+1):r4,:) ];
    grid_obj.side4_control_pts = pts;

else
    
    disp('gridgen_insert_control_point:  min_index out of whack' );

end


return;






%
% GRIDGEN_DELETE_CONTROL_POINT:  deletes a control point in gridgen application
function gridgen_delete_control_point()

global grid_obj;



%
% Collect the control points.
control_pts = [grid_obj.side1_control_pts; ...
            grid_obj.side2_control_pts; ...
            grid_obj.side3_control_pts; ...
            grid_obj.side4_control_pts];


current_point = get ( gca, 'CurrentPoint' );
x0 = current_point(1); y0 = current_point(3);


[nearest_index, nearest_dist] = gridgen_nearest_pts( control_pts(:,1), ...
                                        control_pts(:,2), ...
                                        x0, y0);


%
% If there are more than one point selected, it will be assumed that
% a corner point has been chosen.  Since this is illegal, we bail out.
if ( length(nearest_index) > 1 )
   return;
end


   

[r1,c] = size(grid_obj.side1_control_pts);
[r2,c] = size(grid_obj.side2_control_pts);
[r3,c] = size(grid_obj.side3_control_pts);
[r4,c] = size(grid_obj.side4_control_pts);

if ( nearest_index < r1 )

   pts = grid_obj.side1_control_pts;
   keepers = [[1:(nearest_index-1)]'; ...
            [(nearest_index+1):r1]' ];
   grid_obj.side1_control_pts = pts(keepers,:);

elseif ( nearest_index < (r1+r2) )

   pts = grid_obj.side2_control_pts;
   keepers = [[1:(nearest_index-r1-1)]'; ...
            [(nearest_index-r1+1):r2]' ];
   grid_obj.side2_control_pts = pts(keepers,:);

elseif ( nearest_index < (r1+r2+r3) )

   pts = grid_obj.side3_control_pts;
   keepers = [[1:(nearest_index-r1-r2-1)]'; ...
            [(nearest_index-r1-r2+1):r3]' ];
   grid_obj.side3_control_pts = pts(keepers,:);

elseif ( nearest_index < (r1+r2+r3+r4) )

   pts = grid_obj.side4_control_pts;
   keepers = [[1:(nearest_index-r1-r2-r3-1)]'; ...
            [(nearest_index-r1-r2-r3+1):r4]' ];
   grid_obj.side4_control_pts = pts(keepers,:);

else
   
   disp ('gridgen_delete_control_point:  nearest index out of whack');

end




return;











