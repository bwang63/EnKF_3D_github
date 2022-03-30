function status = vslice_draw()
% VSLICE_DRAW:  Redraws the vertical slice figure, of course.
%
% PARAMETERS:
%   status:  whether or not the operation was successful or not.
%            Possible reasons for an unsuccessful operation might
%            be that an attempt was made to take a vertical slice
%            out of a variable that has no depth dimension.

global cslice_obj;

N = cslice_obj_index;

status = 1;


vslice_figure_tag = sprintf ( 'vslice figure %d', N );
vslice_figure = findobj ( 0, 'tag', vslice_figure_tag );

vslice_axis = findobj ( vslice_figure, 'tag', 'vslice axis' );


if ( cslice_obj{N}.dimensionality < 4 )
    fprintf ( 2, 'Can''t make a vertical slice out of %s.\n', cslice_obj{N}.variable );
    set ( vslice_figure, 'Visible', 'Off' );
    delete ( cslice_obj{N}.vslice_line );
    status = 0;
    return;
end


% 
% first, redo the string
title_text = findobj ( vslice_figure, 'tag', 'vslice title' );
time_step = get ( cslice_obj{N}.hslice_time_edit, 'value' );
switch ( cslice_obj{N}.type )
    case 'ECOM'
        jd = ecomtime ( cslice_obj{N}.cdf );
        date_string = jd2str ( jd(time_step) );

    case 'SCRUM'
        date_string = sprintf ( 'timestep %i', time_step );

end
set ( title_text, ...
        'string', sprintf ( 'Vertical Slice of %s, %s', cslice_obj{N}.variable, date_string ) );


%
% 
%if ( cslice_obj{N}.vslice_first_draw

%
% 
res_edit = findobj ( vslice_figure, 'tag', 'vslice resolution edit' );
resolution = get ( res_edit, 'value' );
x = get ( cslice_obj{N}.vslice_line, 'XData' );
y = get ( cslice_obj{N}.vslice_line, 'YData' );


cdf_pt1 = [x(1) y(1)];
cdf_pt2 = [x(2) y(2)];
[cslice_obj{N}.vslice_w, cslice_obj{N}.vslice_distance, xx, yy, cslice_obj{N}.vslice_z] ...
    = get_cross_slice(    cdf_pt1, cdf_pt2  );

%
% Put the horizontal distance into kilometers.
%cslice_obj{N}.vslice_distance = cslice_obj{N}.vslice_distance / cslice_obj{N}.scale;


vslice_axis = findobj ( vslice_figure, 'tag', 'vslice axis' );
axes ( vslice_axis );
pslice2 ( cslice_obj{N}.vslice_distance, cslice_obj{N}.vslice_z, cslice_obj{N}.vslice_w );
set ( vslice_axis, 'DataAspectRatioMode', 'auto' );
ylabel ( 'meters' );
xlabel ( 'kilometers' );
%set ( gca, 'XTick', [] );
shading ( cslice_obj{N}.vslice_shading );


%
% If this is a first draw for the vertical slice, get the color
% limits from the horizontal slice.
hcolor_max_edit = findobj ( cslice_obj{N}.hslice_figure, 'tag', 'hslice color max edit' );
hcolor_min_edit = findobj ( cslice_obj{N}.hslice_figure, 'tag', 'hslice color min edit' );
vcolor_max_edit = findobj ( cslice_obj{N}.vslice_figure, 'tag', 'vslice color max edit' );
vcolor_min_edit = findobj ( cslice_obj{N}.vslice_figure, 'tag', 'vslice color min edit' );
if ( cslice_obj{N}.vslice_first_draw )
    set ( vcolor_max_edit, 'String', get(hcolor_max_edit,'String') );
    set ( vcolor_max_edit, 'Value', get(hcolor_max_edit,'Value') );
    set ( vcolor_min_edit, 'String', get(hcolor_min_edit,'String') );
    set ( vcolor_min_edit, 'Value', get(hcolor_min_edit,'Value') );
    cslice_obj{N}.vslice_first_draw = 0;
    cslice_obj{N}.vcolormap = cslice_obj{N}.hcolormap;
end

comm_str = sprintf ( 'colormap ( %s );', cslice_obj{N}.vcolormap );
eval ( comm_str );

climits = [get(vcolor_min_edit,'Value') get(vcolor_max_edit,'Value')];
set ( vslice_axis, 'clim', climits );



