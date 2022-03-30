function hslice_draw()
% HSLICE_DRAW:  Redraws the hslice figure.
%

global cslice_obj;

N = cslice_obj_index;

%
% delete the colorbar if it exists.
eval ( 'delete(cslice_obj{N}.colorbar);','' );

axes ( cslice_obj{N}.hslice_axis );
cla;

set(gcf,'NextPlot','Add' );
set(gca,'NextPlot','Add' );

get_hslice_data;


%
% Do the map projection.
x = cslice_obj{N}.hx;
y = cslice_obj{N}.hy;
w = cslice_obj{N}.hw;
switch ( cslice_obj{N}.map_projection )

    case 'none'


    case 'lambert conformal conic'
	lat_extents = [gmin(y(:)) gmax(y(:))];
	lon_extents = [gmin(x(:)) gmax(x(:))];
	m_proj ( 'lambert conformal conic', ...
		 'lat', lat_extents, ...
		 'lon', lon_extents );
	[x,y] = m_ll2xy ( x, y );


    case 'mercator'
	m_proj ( 'mercator' );
	[x,y] = m_ll2xy ( x, y );

    case 'stereographic'
	m_proj ( 'stereographic' );
	[x,y] = m_ll2xy ( x, y );

end


pslice2 ( x, y, w );
xlabel('km'),ylabel('km');
set ( cslice_obj{N}.hslice_axis, 'Position', cslice_obj{N}.hslice_axis_position );
set(gca,'tickdir','out')

%
% if this is the first time for the draw (maybe for
% the whole program, or maybe just for this variable),
% then set the color limit widgets accordingly
% Then make sure that all draws for this particular variable
% don't readjust the color limits.  Let the user do that.
if ( cslice_obj{N}.first_draw )

    clims = get ( cslice_obj{N}.hslice_axis, 'CLim' );
    cmin = clims(1);
    cmax = clims(2);

    set ( cslice_obj{N}.hslice_cmin_edit, 'value', cmin );
    set ( cslice_obj{N}.hslice_cmin_edit, 'string', num2str(cmin) );
    set ( cslice_obj{N}.hslice_cmax_edit, 'value', cmax );
    set ( cslice_obj{N}.hslice_cmax_edit, 'string', num2str(cmax) );
    cslice_obj{N}.first_draw = 0;
else
    cmin = get ( cslice_obj{N}.hslice_cmin_edit, 'value' );
    cmax = get ( cslice_obj{N}.hslice_cmax_edit, 'value' );
    set ( cslice_obj{N}.hslice_axis, 'clim', [cmin cmax] );
end


set ( cslice_obj{N}.hslice_axis, 'DataAspectRatio', [1 1 1] );
shading ( cslice_obj{N}.shading );
comm_str = sprintf ( 'colormap(%s);', cslice_obj{N}.hcolormap );
eval ( comm_str );

cslice_obj{N}.colorbar = colorbar;

%
% put in the description string
time_step = get ( cslice_obj{N}.hslice_time_edit, 'value' );
switch ( cslice_obj{N}.type )
  case 'ECOM'
    jd = ecomtime ( cslice_obj{N}.cdf );
    date_string = jd2str ( jd(time_step) );
    
  case 'SCRUM'
    date_string = sprintf ( 'timestep %i', time_step );
    
end


file_string = cslice_obj{N}.cdf;
file_string(1:max(findstr(file_string,'/')))=[];
title_string{1} = sprintf ( 'Slice of %s, %s, file: %s', cslice_obj{N}.variable, date_string, file_string );
if ~strcmp(cslice_obj{N}.map_projection,'none')
    title_string{2} = sprintf ( '%s map projection', cslice_obj{N}.map_projection );
end

set ( cslice_obj{N}.hslice_title, 'string', title_string );



% wilkin to get mercator-like aspect ratio
%if cslice_obj{N}.coord == 'GEOGRAPHIC' 
%  set(gca,'DataAspectRatio',[1 cos(mean(get(gca,'ylim'))*pi/180) 1]);
%end

