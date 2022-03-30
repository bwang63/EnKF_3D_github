function gridgen_cell_spacing_command ( command )
%
% This function allows the user to set the spacing of the
% boundary cells.


%disp ( sprintf ( 'GRIDGEN_CELL_SPACING:  %s', command ) );



switch command

    case 'commit_to_cell_spacing'
	gridgen_setup_cell_spacing;
	gridgen_redraw_spacing_points;

    case 'go_back_to_grid_resolution'
	gridgen_destroy_spacing_gui;
	gridgen_command commit_to_resolution;



    %
    % Move one of the control points.
    case 'mouse_down'

        %
        % The SelectionType property tells us what kind of mouse
        % event was used.
        %
        % normal: mouse button 1 ==> slide a cell along the border
        switch ( get(gcf,'SelectionType') )
        
           case 'normal'
               gridgen_slide_border;
	       gridgen_recompute_grid;
	       gridgen_command plot_interior;
	       gridgen_redraw_spacing_points;
  
        end


    case 'commit_to_masking'
	gridgen_destroy_spacing_gui;
	gridgen_command commit_to_masking;



end

return;






%
% This updates the control figure for the phase where we
% twiddle the cell spacing.  Set the gui, callbacks, and initialize 
% any necessary global fields.
function gridgen_setup_cell_spacing()

global grid_obj;


%disp ( 'here in gridgen_setup_cell_spacing' );
instructions = { 'GRID CELL SPACING' , 
		 'Click with mouse button 1 to select a point, click again to relocate.', 
		 'Hit ''Go Back'' to return to previous step.',
		 'Hit ''Commit'' when you are happy.' };
%instructions = { 'GRID CELL SPACING' , 
%		 'Click with mouse button 1 to select a point, click again to relocate.', 
%		 'Hit ''Go Back'' to return to previous step.',
%		 'Hit ''Recompute Grid'' to update.',
%		 'Hit ''Commit'' when you are happy.' };

set ( grid_obj.instructions_text, ...
          'String', instructions, ...
          'Fontsize', 12 );
        

a = grid_obj.control_figure;
goback_pushbutton = uicontrol('Parent',grid_obj.control_figure, ...
    'Units','normalized', ...
    'BackgroundColor',[0.701961 0.701961 0.701961], ...
    'Callback','gridgen_cell_spacing_command go_back_to_grid_resolution', ...
    'Position',[0.20 0.25 0.20 0.10], ...
    'String','Go Back', ...
    'Style','pushbutton', ...
    'Tag','Go Back Button', ...
    'Visible', 'on' );

%recompute_pushbutton = uicontrol('Parent',grid_obj.control_figure, ...
%    'Units','normalized', ...
%    'BackgroundColor',[0.701961 0.701961 0.701961], ...
%    'Callback','gridgen_cell_spacing_command recompute_grid', ...
%    'Position',[0.40 0.25 0.20 0.10], ...
%    'String','Recompute Grid', ...
%    'Style','pushbutton', ...
%    'Tag','Recompute Button', ...
%    'Visible', 'on' );

commit_pushbutton = uicontrol('Parent',grid_obj.control_figure, ...
    'Units','normalized', ...
    'BackgroundColor',[0.701961 0.701961 0.701961], ...
    'Callback','gridgen_cell_spacing_command commit_to_masking', ...
    'Position',[0.60 0.25 0.20 0.10], ...
    'String','Commit', ...
    'Style','pushbutton', ...
    'Tag','Go Back Button', ...
    'Visible', 'on' );


set ( grid_obj.map_figure, ...
    'WindowButtonDownFcn', 'gridgen_cell_spacing_command mouse_down' );



return;









%
% This function redraws the control points used to
% affect the spacing of grid cells.
function gridgen_redraw_spacing_points()

%disp ( 'here in gridgen_redraw_spacing_points' );

global grid_obj;

figure ( grid_obj.map_figure );

%
% Put up the grid cell slider points.
% First delete them if they already exist.
h = findobj ( grid_obj.map_figure, 'Tag', 'slider points' );
if ( ~isempty(h) )
    delete(h);
end

seta = grid_obj.seta;
sxi = grid_obj.sxi;

%
% determine the indices of the slider points.  Since the points on the
% screen correspond to every other index in seta and sxi, the indices
% MUST be odd.
if ( isempty ( grid_obj.seta_marker_inds ) )
    seta_inds = linspace ( 1, length(seta), grid_obj.num_slider_points+2 );
    seta_inds = round(seta_inds);
    for i = 1:length(seta_inds)
        if ( mod(seta_inds(i),2) == 0 )
            seta_inds(i) = seta_inds(i) + 1;
        end
    end
else
    seta_inds = grid_obj.seta_marker_inds;
end


if ( grid_obj.kb(1) == 1 )
    x = ppval( grid_obj.side1_x_ppform, seta(seta_inds) );
    y = ppval( grid_obj.side1_y_ppform, seta(seta_inds) );
else
    x = ppval( grid_obj.side3_x_ppform, seta(seta_inds) );
    y = ppval( grid_obj.side3_y_ppform, seta(seta_inds) );
end
h = line ( 'XData', x, ...
	   'YData', y, ...  
	   'Marker', '*', ...  
	   'MarkerSize', grid_obj.control_point_marker_size, ...
	   'LineStyle', 'none', ...  
	   'Color', grid_obj.slider_point_color, ...  
	   'Tag', 'slider points' );

grid_obj.seta_marker_inds = seta_inds;


if ( isempty ( grid_obj.sxi_marker_inds ) )
    sxi_inds = linspace ( 1, length(sxi), grid_obj.num_slider_points+2 );
    sxi_inds = round(sxi_inds);
    for i = 1:length(sxi_inds)
        if ( mod(sxi_inds(i),2) == 0 )
	    sxi_inds(i) = sxi_inds(i) + 1;
        end
    end
else
    sxi_inds = grid_obj.sxi_marker_inds;
end



if ( grid_obj.kb(2) == 2 )
    x = ppval( grid_obj.side2_x_ppform, sxi(sxi_inds) );
    y = ppval( grid_obj.side2_y_ppform, sxi(sxi_inds) );
else
    x = ppval( grid_obj.side4_x_ppform, sxi(sxi_inds) );
    y = ppval( grid_obj.side4_y_ppform, sxi(sxi_inds) );
end
h = line ( 'XData', x, ...
	   'YData', y, ...  
	   'Marker', '*', ...  
	   'MarkerSize', grid_obj.control_point_marker_size, ...
	   'LineStyle', 'none', ...  
	   'Color', grid_obj.slider_point_color, ...  
	   'Tag', 'slider points' );


grid_obj.sxi_marker_inds = sxi_inds;

return;






%
% GRIDGEN_SLIDE_BORDER:  Refine grid by moving a border cell.
function gridgen_slide_border()

%disp ( 'here in gridgen_slide_border' );

global grid_obj;


%
% Temporarily unset the buttondownfcn property.  We do this because
% we need to use ginput to get the 2nd point.  Replace it when we are
% done.
buttondownfcn = get ( grid_obj.map_figure, 'WindowButtonDownFcn' );
set ( grid_obj.map_figure, 'WindowButtonDownFcn', '' );

seta = grid_obj.seta;
sxi = grid_obj.sxi;

cp = get ( gca, 'CurrentPoint' );
x0 = cp(1); 
y0 = cp(3);


if ( grid_obj.kb(1) == 1 )
    x1 = ppval ( grid_obj.side1_x_ppform, seta(grid_obj.seta_marker_inds) );
    x1 = x1(:);
    y1 = ppval ( grid_obj.side1_y_ppform, seta(grid_obj.seta_marker_inds) );
    y1 = y1(:);
else
    x1 = ppval ( grid_obj.side3_x_ppform, seta(grid_obj.seta_marker_inds) );
    x1 = x1(:);
    y1 = ppval ( grid_obj.side3_y_ppform, seta(grid_obj.seta_marker_inds) );
    y1 = y1(:);
end
if ( grid_obj.kb(2) == 2 )
    x2 = ppval ( grid_obj.side2_x_ppform, sxi(grid_obj.sxi_marker_inds) );
    x2 = x2(:);
    y2 = ppval ( grid_obj.side2_y_ppform, sxi(grid_obj.sxi_marker_inds) );
    y2 = y2(:);
else
    x2 = ppval ( grid_obj.side4_x_ppform, sxi(grid_obj.sxi_marker_inds) );
    x2 = x2(:);
    y2 = ppval ( grid_obj.side4_y_ppform, sxi(grid_obj.sxi_marker_inds) );
    y2 = y2(:);
end

x = [x1; x2];
y = [y1; y2];


ind = gridgen_nearest_pts ( x, y, x0, y0 );

if ( ind <= length(x1) )
    if ( grid_obj.kb(1) == 1 )
	grid_obj.slide_side = 1;
    else
	grid_obj.slide_side = 3;
    end
else
    if ( grid_obj.kb(2) == 2 )
	grid_obj.slide_side = 2;
    else
	grid_obj.slide_side = 4;
    end
end



switch ( grid_obj.slide_side )
    case 1
	current_slider_index = grid_obj.seta_marker_inds(ind);
    case 2
	current_slider_index = grid_obj.sxi_marker_inds(ind-length(x1));
    case 3
	current_slider_index = grid_obj.seta_marker_inds(ind);
    case 4
	current_slider_index = grid_obj.seta_marker_inds(ind-length(x1));
end
grid_obj.current_slider_index = current_slider_index;


%
% Make sure that the chosen point is not the first or the
% last on a side.  Illegal to move a corner.
switch ( grid_obj.slide_side )

    case 1
	if ( (current_slider_index == 1) | (current_slider_index == length(seta) ) )
	    return;
	end
    case 2
	if ( (current_slider_index == 1) | (current_slider_index == length(sxi) ) )
	    return;
	end
    case 3
	if ( (current_slider_index == 1) | (current_slider_index == length(seta) ) )
	    return;
	end
    case 4
	if ( (ind == 1) | (ind == length(sxi) ) )
	    return;
	end

end


switch ( grid_obj.slide_side )
    case 1
	h = plot ( ppval ( grid_obj.side1_x_ppform, seta(current_slider_index) ), ...
		   ppval ( grid_obj.side1_y_ppform, seta(current_slider_index ) ) );
	set ( h, ...
	      'Marker', '*', ...
	      'LineStyle', 'none', ...
	      'Color', 'blue' );
	     
	fine_t = linspace ( seta(1), seta(length(seta)), 500 );
	x = ppval ( grid_obj.side1_x_ppform, fine_t );
	y = ppval ( grid_obj.side1_y_ppform, fine_t );
	grid_obj.slider_side_curve = [x(:) y(:)];
    case 2
	h = plot( ppval ( grid_obj.side2_x_ppform, sxi(current_slider_index) ), ...
		  ppval ( grid_obj.side2_y_ppform, sxi(current_slider_index ) ) );
	set ( h, ...
	      'Marker', '*', ...
	      'LineStyle', 'none', ...
	      'Color', 'blue' );
	fine_t = linspace ( sxi(1), sxi(length(sxi)), 500 );
	x = ppval ( grid_obj.side2_x_ppform, fine_t );
	y = ppval ( grid_obj.side2_y_ppform, fine_t );
	grid_obj.slider_side_curve = [x(:) y(:)];
    case 3
	h = plot ( ppval ( grid_obj.side3_x_ppform, seta(current_slider_index ) ), ...
		   ppval ( grid_obj.side3_y_ppform, seta(current_slider_index ) ) );
	set ( h, ...
	      'Marker', '*', ...
	      'LineStyle', 'none', ...
	      'Color', 'blue' );
	fine_t = linspace ( seta(1), seta(length(seta)), 500 );
	x = ppval ( grid_obj.side3_x_ppform, fine_t );
	y = ppval ( grid_obj.side3_y_ppform, fine_t );
	grid_obj.slider_side_curve = [x(:) y(:)];
    case 4
	h = plot ( ppval ( grid_obj.side4_x_ppform, sxi(current_slider_index ) ), ...
		   ppval ( grid_obj.side4_y_ppform, sxi(current_slider_index ) ) );
	set ( h, ...
	      'Marker', '*', ...
	      'LineStyle', 'none', ...
	      'Color', 'blue' );
	fine_t = linspace ( sxi(1), sxi(length(sxi)), 500 );
	x = ppval ( grid_obj.side4_x_ppform, fine_t );
	y = ppval ( grid_obj.side4_y_ppform, fine_t );
	grid_obj.slider_side_curve = [x(:) y(:)];
end
old_point = h;



set ( grid_obj.map_figure, 'WindowButtonDownFcn', buttondownfcn );




h = findobj ( grid_obj.map_figure, 'Tag', 'sliding point' );
if ( ~isempty(h) )
    delete(h);
end

x = grid_obj.slider_side_curve(:,1);
y = grid_obj.slider_side_curve(:,2);

[x0, y0] = ginput(1);

delete ( old_point );

nearest_ind = gridgen_nearest_pts ( x, y, x0, y0 );
new_t = fine_t(nearest_ind);

switch ( grid_obj.slide_side )
    case 1
	seta(current_slider_index) = new_t;
    case 2
	sxi(current_slider_index) = new_t;
    case 3
	seta(current_slider_index) = new_t;
    case 4
	sxi(current_slider_index) = new_t;
end

grid_obj.seta = seta;
grid_obj.sxi = sxi;



return;






%
% destroy the current gui before going on to another step
function gridgen_destroy_spacing_gui()

global grid_obj;

%disp ( 'here in gridgen_destroy_spacing_gui' );

h = findobj ( grid_obj.control_figure, 'style', 'pushbutton' );
delete (h );

%
% First the slider points if they exist.
h = findobj ( grid_obj.map_figure, 'Tag', 'slider points' );
if ( ~isempty(h) )
    delete(h);
end
return;








function gridgen_recompute_grid()
% GRIDGEN_RECOMPUTE_GRID:  Makes seta and sxi consistent.

global grid_obj;

seta = grid_obj.seta;
seta = seta(:);
sxi = grid_obj.sxi;
sxi = sxi(:);

old_seta = grid_obj.old_seta;
old_seta = old_seta(:);
old_sxi = grid_obj.old_sxi;
old_sxi = old_sxi(:);

seta_inds = grid_obj.seta_marker_inds;
sxi_inds = grid_obj.sxi_marker_inds;

    
if ( max(diff(old_seta - seta)) ~= 0 )

    ppt = spline ( seta_inds, seta(seta_inds) );
    seta = ppval ( ppt, [1:1:length(seta)] );
    seta = seta(:);
    if ( find(diff(seta)<=0) )
	fprintf ( 2, 'seta not monotonic increasing, gridgen_recompute_grid\n' );
    end
end

if ( max(diff(old_sxi - sxi)) ~= 0 )

    ppt = spline ( sxi_inds, sxi(sxi_inds) );
    sxi = ppval ( ppt, [1:1:length(sxi)] );
    sxi = sxi(:);
    if ( find(diff(sxi)<=0) )
	fprintf ( 2, 'sxi not monotonic increasing, gridgen_recompute_grid\n' );
    end
end

grid_obj.seta = seta;
grid_obj.sxi = sxi;
grid_obj.old_seta = old_seta;
grid_obj.old_sxi = sxi;
[grid_obj.x grid_obj.y] = gridgen_get_interior;
%gridgen_reset_splines;

return;









