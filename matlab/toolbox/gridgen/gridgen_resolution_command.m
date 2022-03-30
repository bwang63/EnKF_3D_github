function gridgen_resolution_command ( command )

global grid_obj;


%disp ( sprintf ( 'GRIDGEN_RESOLUTION_COMMAND:  %s\n', command ) );


switch command

    case 'commit_to_cell_spacing'
	gridgen_destroy_resolution_gui;
	gridgen_command commit_to_cell_spacing;

    case 'go_back_to_boundary_refinement'
	gridgen_destroy_resolution_gui;
	grid_lines = findobj ( grid_obj.map_figure, 'Tag', 'grid lines' );
	delete (grid_lines);
	gridgen_brefine_command setup_boundary_refinement;
	gridgen_command redraw_splines;
	gridgen_command recompute_splines;




    case 'setup_grid_cell_resolution'
        gridgen_setup_resolution;
	gridgen_resolution_command replot;


    case 'replot'
        gridgen_ives_zacharias; 
        [grid_obj.x grid_obj.y] = gridgen_get_interior; 
        grid_obj.old_seta = grid_obj.seta;
        grid_obj.old_sxi = grid_obj.sxi;
        gridgen_reset_splines;
        gridgen_command plot_interior;


   %
   % got a value from the slider.
   % Make the edit reflect that, then redo the splines.
   case 'sides_13_slider'
      
      slider_13 = findobj ( grid_obj.control_figure, ...
                        'Tag', 'Side 1,3 Resolution Slider' );
      edit_13 = findobj ( grid_obj.control_figure, ...
                        'Tag', 'Sides 1,3 Resolution Edit' );

      slider_val = round ( get ( slider_13, 'Value' ) );

      set ( slider_13, 'Value', slider_val );
      set ( edit_13, 'String', num2str(slider_val) );

      grid_obj.sides13_resolution = slider_val;

      gridgen_command recompute_splines;
      gridgen_resolution_command replot;




   %
   % got a value from the edit.
   % Make the slider reflect that, then redo the splines.
   case 'sides_13_resolution_edit'

      slider_13 = findobj ( grid_obj.control_figure, ...
                        'Tag', 'Side 1,3 Resolution Slider' );
      edit_13 = findobj ( grid_obj.control_figure, ...
                        'Tag', 'Sides 1,3 Resolution Edit' );

      edit_value = round(str2num(get(edit_13,'String')));

      set ( slider_13, 'Value', edit_value );
      set ( edit_13, 'string', num2str(edit_value) );

      grid_obj.sides13_resolution = edit_value;
      
      gridgen_command recompute_splines;

      gridgen_resolution_command replot;





   %
   % got a value from the slider.
   % Make the edit reflect that, then redo the splines.
   case 'sides_24_slider'
      
      slider_24 = findobj ( grid_obj.control_figure, ...
                        'Tag', 'Side 2,4 Resolution Slider' );
      edit_24 = findobj ( grid_obj.control_figure, ...
                        'Tag', 'Sides 2,4 Resolution Edit' );

      slider_val = round ( get ( slider_24, 'Value' ) );

      set ( slider_24, 'Value', slider_val );
      set ( edit_24, 'String', num2str(slider_val) );

      grid_obj.sides24_resolution = slider_val;

      gridgen_command recompute_splines;
      gridgen_resolution_command replot;




   %
   % got a value from the edit.
   % Make the slider reflect that, then redo the splines.
   case 'sides_24_resolution_edit'

      slider_24 = findobj ( grid_obj.control_figure, ...
                        'Tag', 'Side 2,4 Resolution Slider' );
      edit_24 = findobj ( grid_obj.control_figure, ...
                        'Tag', 'Sides 2,4 Resolution Edit' );

      edit_value = round(str2num(get(edit_24,'String')));

      grid_obj.sides24_resolution = edit_value;

      set ( slider_24, 'Value', edit_value );
      set ( edit_24, 'String', num2str(edit_value) );

      gridgen_command recompute_splines;
      gridgen_resolution_command replot;



end

return;






%
% This function sets up the widgets, callbacks, and data fields
% for the boundary refinement stage.
function gridgen_setup_resolution()

%disp ('here in gridgen_setup_resolution' );

global grid_obj;


instructions = { 'GRID RESOLUTION', ...
    'Use the sliders and edits to change the grid resolution.', ...
    'Hit ''Go Back'' to change the grid boundaries.', ...
    'Hit ''Commit'' when you are happy with the resolution.' };

set ( grid_obj.instructions_text, ...
    'String', instructions, ...
    'Fontsize', 12 );


a = grid_obj.control_figure;
b = uicontrol('Parent',a, ...
    'Units','normalized', ...
    'Position',[0.025 0.03125 0.95 0.45], ...
    'Style','frame', ...
    'Tag','Slider Frame', ...
    'Visible', 'on' );
b = uicontrol('Parent',a, ...
    'Units','normalized', ...
    'Callback','gridgen_resolution_command sides_13_slider', ...
    'Enable','on', ...
    'Position',[0.035 0.28 0.45 0.10], ...
    'SliderStep', [0.002 0.10], ...
    'Style','slider', ...
    'Tag','Side 1,3 Resolution Slider', ...
    'Visible', 'on' );
b = uicontrol('Parent',a, ...
    'Units','normalized', ...
    'Callback','gridgen_resolution_command sides_24_slider', ...
    'Enable', 'on', ...
    'Position',[0.515 0.28 0.45 0.10], ...
    'SliderStep', [0.002 0.10], ...
    'Style','slider', ...
    'Tag','Side 2,4 Resolution Slider', ...
    'Visible', 'on' );
b = uicontrol('Parent',a, ...
    'Units','normalized', ...
    'BackgroundColor',[0.85 0.85 0.85], ...
    'Position',[0.12 0.40 0.26 0.07], ...
    'String','Sides 1,3 Resolution (eta)', ...
    'Style','text', ...
    'Tag','Sides 1,3 Resolution Label', ...
    'Visible', 'on' );
b = uicontrol('Parent',a, ...
    'Units','normalized', ...
    'BackgroundColor',[0.85 0.85 0.85], ...
    'Position',[0.62 0.40 0.26 0.07], ...
    'String','Sides 2,4 Resolution (xi)', ...
    'Style','text', ...
    'Tag','Sides 2,4 Resolution Label', ...
    'Visible', 'on' );
b = uicontrol('Parent',a, ...
    'Units','normalized', ...
    'BackgroundColor',[1 1 1], ...
    'Callback','gridgen_resolution_command sides_13_resolution_edit', ...
    'Position',[0.18 0.18 0.15 0.10 ], ...
    'Style','edit', ...
    'Tag','Sides 1,3 Resolution Edit', ...
    'Visible', 'on' );
b = uicontrol('Parent',a, ...
    'Units','normalized', ...
    'BackgroundColor',[1 1 1], ...
    'Callback','gridgen_resolution_command sides_24_resolution_edit', ...
    'Enable', 'on', ...
    'Position',[0.67 0.18 0.15 0.10], ...
    'Style','edit', ...
    'Tag','Sides 2,4 Resolution Edit', ...
    'Visible', 'on' );

%
% Set the 'Go Back' pushbutton
goback_pushbutton = uicontrol('Parent',grid_obj.control_figure, ...
    'Units','normalized', ...
    'BackgroundColor',[0.701961 0.701961 0.701961], ...
    'Callback','gridgen_resolution_command go_back_to_boundary_refinement', ...
    'Position',[0.16 0.045 0.20 0.10], ...
    'String','Go Back', ...
    'Style','pushbutton', ...
    'Tag','Go Back Button', ...
    'Visible', 'on' );

commit_pushbutton = findobj ( grid_obj.control_figure, 'Tag', 'Commit Button' );
delete(commit_pushbutton);
commit_pushbutton = uicontrol('Parent',grid_obj.control_figure, ...
    'Units','normalized', ...
    'BackgroundColor',[0.701961 0.701961 0.701961], ...
    'Callback','gridgen_resolution_command commit_to_cell_spacing', ...
    'Position',[0.64 0.045 0.20 0.10], ...
    'String','Commit', ...
    'Style','pushbutton', ...
    'Tag','Go Back Button', ...
    'Visible', 'on' );


%
% Give the sliders and edits the initial values.
slider_13 = findobj ( grid_obj.control_figure, ...
                  'Tag', 'Side 1,3 Resolution Slider' );
   
slider_24 = findobj ( grid_obj.control_figure, ...
                  'Tag', 'Side 2,4 Resolution Slider' );



set ( slider_13, 'Min', grid_obj.min_resolution );
set ( slider_13, 'Max', grid_obj.max_resolution ); 
set ( slider_13, 'Value', grid_obj.sides13_resolution );

set ( slider_24, 'Min', grid_obj.min_resolution );
set ( slider_24, 'Max', grid_obj.max_resolution ); 
set ( slider_24, 'Value', grid_obj.sides24_resolution );

edit_13 = findobj ( grid_obj.control_figure, ...
                  'Tag', 'Sides 1,3 Resolution Edit' );
set ( edit_13, 'String', num2str ( grid_obj.sides13_resolution ) );

edit_24 = findobj ( grid_obj.control_figure, ...
                  'Tag', 'Sides 2,4 Resolution Edit' );
set ( edit_24, 'String', num2str ( grid_obj.sides24_resolution ) );


%
% delete the control point markers and spline lines, as they are no
% longer needed
h = findobj (grid_obj.map_axis, 'Tag', 'Border Spline Line 1' );
delete(h);
h = findobj (grid_obj.map_axis, 'Tag', 'Border Spline Line 2' );
delete(h);
h = findobj (grid_obj.map_axis, 'Tag', 'Border Spline Line 3' );
delete(h);
h = findobj (grid_obj.map_axis, 'Tag', 'Border Spline Line 4' );
delete(h);
h = findobj (grid_obj.map_axis, 'Tag', 'Control Point' );
delete(h);




grid_obj.seta_marker_inds = [];
grid_obj.sxi_marker_inds = [];




return;








%
% This function computes the rectified boundary using IZ.
function gridgen_ives_zacharias()

%disp ( 'here in gridgen_ives_zacharias' );

global grid_obj;
global cgridgen_obj;


%
% This field controls how the border cells are 
% determined in the grid refinement stage.  Possible values
% are 'uniform', or 'nonuniform'.
%
% When we first enter grid refinement, always make it uniform.
grid_obj.node_type = { 'uniform', 'uniform' };


%
% This field controls which sides the grid refinement is focused
% on.  It is either side 1 or 3, and 2 or 4.  Initially, it is
% 1 and 2.
grid_obj.kb = [1 2];

%
% This field controls how many slider points are used to change
% seta and sxi.
grid_obj.num_slider_points = 5;



%
% Generate the pp-form of the splines.  Then find the equidistant
% spacing.
n = length(grid_obj.side1_spline_pts(:,1));
t = linspace ( 0.0, 1.0, n );
grid_obj.side1_x_ppform = spline ( t, grid_obj.side1_spline_pts(:,1) );
grid_obj.side1_y_ppform = spline ( t, grid_obj.side1_spline_pts(:,2) );
grid_obj.side1_t = equidist_spline ( grid_obj.side1_x_ppform, ...
                     grid_obj.side1_y_ppform,  ...
                     linspace(0.0,1.0,grid_obj.sides13_resolution) );
%                     t );

n = length(grid_obj.side2_spline_pts(:,1));
t = linspace ( 0.0, 1.0, n );
grid_obj.side2_x_ppform = spline ( t, grid_obj.side2_spline_pts(:,1) );
grid_obj.side2_y_ppform = spline ( t, grid_obj.side2_spline_pts(:,2) );
grid_obj.side2_t = equidist_spline ( grid_obj.side2_x_ppform, ...
                     grid_obj.side2_y_ppform,  ...
                     linspace(0.0,1.0,grid_obj.sides24_resolution) );
%                     t );

n = length(grid_obj.side3_spline_pts(:,1));
t = linspace ( 0.0, 1.0, n );
grid_obj.side3_x_ppform = spline ( t, grid_obj.side3_spline_pts(:,1) );
grid_obj.side3_y_ppform = spline ( t, grid_obj.side3_spline_pts(:,2) );
grid_obj.side3_t = equidist_spline ( grid_obj.side3_x_ppform, ...
                     grid_obj.side3_y_ppform,  ...
                     linspace(0.0,1.0,grid_obj.sides13_resolution) );
%                     t );

n = length(grid_obj.side4_spline_pts(:,1));
t = linspace ( 0.0, 1.0, n );
grid_obj.side4_x_ppform = spline ( t, grid_obj.side4_spline_pts(:,1) );
grid_obj.side4_y_ppform = spline ( t, grid_obj.side4_spline_pts(:,2) );
grid_obj.side4_t = equidist_spline ( grid_obj.side4_x_ppform, ...
                     grid_obj.side4_y_ppform,  ...
                     linspace(0.0,1.0,grid_obj.sides24_resolution) );
%                     t );

    
grid_obj.dig = gridgen_get_dig;


%
% Initialize certain parameters.  
% Same as specified in cgridgen.inc.
cgridgen_obj.nx = 400;
cgridgen_obj.ny = 400;
cgridgen_obj.imax = 1000;
cgridgen_obj.mcst = 40000;
cgridgen_obj.nbdmax = 100000;
cgridgen_obj.nmax = cgridgen_obj.nx + cgridgen_obj.ny;
cgridgen_obj.nx2 = cgridgen_obj.nx * 2;
cgridgen_obj.ny2 = cgridgen_obj.ny * 2;
cgridgen_obj.kep = 9;
cgridgen_obj.nwrk = 2*(cgridgen_obj.kep-2)*(2^(cgridgen_obj.kep+1))+cgridgen_obj.kep+10*cgridgen_obj.nx+12*cgridgen_obj.ny+27;
cgridgen_obj.big = 1e35;
cgridgen_obj.eps = 1e-16;


%
% Initialize certain global variables.
cgridgen_obj.ewrk = zeros(cgridgen_obj.nwrk,1);



%
% Initialize vector z (complex) with contour of physical boundary

jindex = 0;
imax = 1000;
xb = grid_obj.dig(:,1); 
yb = grid_obj.dig(:,2); 
cgridgen_obj.xb = xb;
cgridgen_obj.yb = yb;
icorner = grid_obj.dig(:,3);

cgridgen_obj.z = cgridgen_obj.xb + i*cgridgen_obj.yb;
cgridgen_obj.n = zeros(4,1);
corner_find = find(icorner==1);
if ( length(corner_find) > 4 )
    disp('input error:  there must be only 4 corners');
    return;
end
cgridgen_obj.n = corner_find;


np = length(cgridgen_obj.xb);
if ( length(cgridgen_obj.n) ~= 4 )
    disp('input error:  there must be only 4 corners');
    return;
end

if ( np ~= cgridgen_obj.n(4) )
    disp ('input error:  last point digitized must be a corner');
    return;
end


%
% map physical boundary to a rectangle
itmax = 80;
errmax = 1e-5;
error_within_bounds = 0;
n = cgridgen_obj.n;
z = cgridgen_obj.z;
for k = 1:itmax
    
    z = mexrect ( z, np, n(1), n(2), n(3), n(4) );


    %
    % calculate departure of contour from rectangle
    error = 0.0;
    error = error + sum ( abs ( real (z(1:n(1)) - z(1)) ) );
    error = error + sum ( abs ( imag (z(n(1)+1:n(2)) - z(n(1)+1)) ) );
    error = error + sum ( abs ( real (z(n(2)+1:n(3)) - z(n(2)+1)) ) );
    error = error + sum ( abs ( imag (z(n(3)+1:n(4)) - z(n(3)+1)) ) );

    error = error / (imag(z(n(4))) * 2 + 2 );

    %disp ( sprintf ( 'regularity error in mapped contour at iteration %4.0f is %f', k, error ) );

    if ( abs(error) < errmax )
        error_within_bounds = 1;
        break;
    end

end

if ( error_within_bounds )
    ;
else
    disp ( sprintf ( 'warning:  failed to converge in %4.0f iterations\n', itmax ) ) ;
end

cgridgen_obj.z = z;


%
% n should actually be a 5-vector.  In the fortran code it is zero based.
% Need to be careful of that.
n = [0; cgridgen_obj.n(:)];



n = cgridgen_obj.n;


%
% The quantity (n(1) - ind) will have a zero entry, so in order
% to keep the indices 1-based, we have to add one.
ind = 1:n(1);
k = n(1) - ind + 1;
xint(k,1) = xb(ind);
yint(k,1) = yb(ind);
s(k,1) = imag(z(ind));

ind = n(1):n(2);
k = ind - n(1) + 1;
xint(k,2) = xb(ind);
yint(k,2) = yb(ind);
s(k,2) = real(z(ind));

ind = n(2):n(3);
k = ind - n(2) + 1;
xint(k,3) = xb(ind);
yint(k,3) = yb(ind);
s(k,3) = imag(z(ind));

ind = n(3):n(4);
k = n(4) - ind + 1;
xint(k,4) = xb(ind);
yint(k,4) = yb(ind);
s(k,4) = real(z(ind));

xint(n(1)+1,1) = xint(1,4);
yint(n(1)+1,1) = yint(1,4);
s(n(1)+1,1) = imag(z(n(4)));

cgridgen_obj.xint = xint;
cgridgen_obj.yint = yint;
cgridgen_obj.s = s;
cgridgen_obj.n = [0; n];

















%
% GRIDGEN_RESET_SPLINES:  Side splines now match seta and sxi.
function gridgen_reset_splines()

%disp ( 'here in gridgen_reset_splines' );

% The pp-forms of the splines that define the borders of the
% grid must be reset to use the values in seta and sxi.
%
% seta defines the border on sides 1 and 3, while sxi defines
% the points on sides 2 and 4.

global grid_obj;

seta = grid_obj.seta;
sxi = grid_obj.sxi;

seta_ind = [1:2:length(seta)];
seta = seta(seta_ind);
sxi_ind = [1:2:length(sxi)];
sxi = sxi(sxi_ind);


%
% seta runs clockwise on side 1
t = grid_obj.side1_t;
x = ppval ( grid_obj.side1_x_ppform, t );
x = flipud(x(:));
y = ppval ( grid_obj.side1_y_ppform, t );
y = flipud(y(:));

%grid_obj.side1_x_ppform = csape ( seta, x );
%grid_obj.side1_y_ppform = csape ( seta, y );
grid_obj.side1_x_ppform = spline ( seta, x );
grid_obj.side1_y_ppform = spline ( seta, y );
grid_obj.side1_t = seta;

t = grid_obj.side2_t;
x = ppval ( grid_obj.side2_x_ppform, t );
y = ppval ( grid_obj.side2_y_ppform, t );

%grid_obj.side2_x_ppform = csape ( sxi, x );
%grid_obj.side2_y_ppform = csape ( sxi, y );
grid_obj.side2_x_ppform = spline ( sxi, x );
grid_obj.side2_y_ppform = spline ( sxi, y );
grid_obj.side2_t = sxi;

%
% seta runs clockwise on side 3
t = grid_obj.side3_t;
x = ppval ( grid_obj.side3_x_ppform, t );
x = flipud(x(:));
y = ppval ( grid_obj.side3_y_ppform, t );
y = flipud(y(:));

%grid_obj.side3_x_ppform = csape ( flipud(seta(:)), x );
%grid_obj.side3_y_ppform = csape ( flipud(seta(:)), y );
grid_obj.side3_x_ppform = spline ( flipud(seta(:)), x );
grid_obj.side3_y_ppform = spline ( flipud(seta(:)), y );
grid_obj.side3_t = seta;

t = grid_obj.side4_t;
x = ppval ( grid_obj.side4_x_ppform, t );
y = ppval ( grid_obj.side4_y_ppform, t );

%grid_obj.side4_x_ppform = csape ( flipud(sxi(:)), x );
%grid_obj.side4_y_ppform = csape ( flipud(sxi(:)), y );
grid_obj.side4_x_ppform = spline ( flipud(sxi(:)), x );
grid_obj.side4_y_ppform = spline ( flipud(sxi(:)), y );
grid_obj.side4_t = sxi;









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









%
%
function gridgen_destroy_resolution_gui()

global grid_obj;

%disp ( 'here in gridgen_destroy_resolution_gui' );

widget = findobj ( grid_obj.control_figure, 'Tag', 'Sides 1,3 Resolution Label' );
delete ( widget );
widget = findobj ( grid_obj.control_figure, 'Tag', 'Sides 2,4 Resolution Label' );
delete ( widget );

widget = findobj ( grid_obj.control_figure, 'style', 'slider' );
delete ( widget );

widget = findobj ( grid_obj.control_figure, 'style', 'edit' );
delete ( widget );

widget = findobj ( grid_obj.control_figure, 'style', 'pushbutton' );
delete ( widget );

widget = findobj ( grid_obj.control_figure, 'Tag', 'Slider Frame' );
delete ( widget );



return















%
% GRIDGEN_GET_DIG:  generate the digital boundary that the fortran expected.
%
% If this is not called with any input arguments, then all four boundaries
% are computed with a uniform mesh.  If the 'side' is specified, then
% that side is computed with the given mesh, while the others are still uniform.
function dig = gridgen_get_dig( side, input_t )

global grid_obj;



% 
% compute for sides 1 thru 4
n = length(grid_obj.side1_spline_pts(:,1));

if ( (nargin ~= 0 ) & ( strcmp(side, 'side1') ) )
	t = input_t;
	grid_obj.side1_t = input_t;
else
	t = grid_obj.side1_t;
end

t(1) = [];
x = ppval ( grid_obj.side1_x_ppform, t );
x = x(:);
y = ppval ( grid_obj.side1_y_ppform, t );
y = y(:);
dig1 = [x y zeros(size(x))];
[r,c] = size(dig1);
dig1(r,3) = 1.0;



n = length(grid_obj.side2_spline_pts(:,1));
if ( (nargin ~= 0 ) & ( strcmp(side, 'side2') ) )
	t = input_t;
	grid_obj.side2_t = input_t;
else
	t = grid_obj.side2_t;
end

t(1) = [];
x = ppval ( grid_obj.side2_x_ppform, t );
x = x(:);
y = ppval ( grid_obj.side2_y_ppform, t );
y = y(:);
dig2 = [x y zeros(size(x))];
[r,c] = size(dig2);
dig2(r,3) = 1.0;



n = length(grid_obj.side3_spline_pts(:,1));

if ( (nargin ~= 0 ) & ( strcmp(side, 'side3') ) )
	t = input_t;
	grid_obj.side3_t = input_t;
else
	t = grid_obj.side3_t;
end

t(1) = [];
x = ppval ( grid_obj.side3_x_ppform, t );
x = x(:);
y = ppval ( grid_obj.side3_y_ppform, t );
y = y(:);
dig3 = [x y zeros(size(x))];
[r,c] = size(dig3);
dig3(r,3) = 1.0;


n = length(grid_obj.side4_spline_pts(:,1));

if ( (nargin ~= 0 ) & ( strcmp(side, 'side4') ) )
	t = input_t;
	grid_obj.side4_t = input_t;
else
	t = grid_obj.side4_t;
end

t(1) = [];
x = ppval ( grid_obj.side4_x_ppform, t );
x = x(:);
y = ppval ( grid_obj.side4_y_ppform, t );
y = y(:);
dig4 = [x y zeros(size(x))];
[r,c] = size(dig4);
dig4(r,3) = 1.0;


dig = [dig1; dig2; dig3; dig4];


return;










