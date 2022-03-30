function status = cslice ( cdf )
% CSLICE:  visualization tool for ECOM or SCRUM netcdf files.
%
% USAGE:  status = cslice ( filename )    
%
% PARAMETERS:
%   status:  Whether or not the routine failed or not.
%
%   cdf:  Name of ECOM or SCRUM file to vizualize.
%         Optional.
%


%
% Description of 'cslice_obj' structure fields.
% (You can access this object by typing "global cslice_obj"
% before you invoke cslice.)

% action:
%     command parameter to hslice_command
% add_offset, scale_factor:
%     If present in input file for current variable, the data must
%     be scaled and offset by these amounts.  Defaults to 0 and 1.
% arrows:
%     handle (singular!) for velocity field overlay.  Deleting
%     this deletes all the arrows.
% bathymetry:
%     depth data for the file
% cdf:
%     name of file being interrogated
% colorbar:
%     horizontal slice colorbar handle
% coord:
%     string indicating type of coordinate: 
%       'GEOGRAPHIC' (lat/lon) or 'PROJECTED' (meters, km, etc)
% depth:
%     current depth of the horizontal slice.  This is
%     only meaningful if the variable is 4D
% dimensionality:
%     number of dimensions for the current variable
% first_draw:
%     boolean flag.  Whether or not we are drawing a variable
%     for the first time or not.  The main use of this is that
%     the color limits will be set for best contrast this time
%     only.  All subsequent draws force the user to then change
%     the color limits if wanted.
% hslice_{cmin,cmax}_edit:
%     handles for colormap limit typeins
% hcolormap:
%     colormap for the horizontal slice
% hslice_figure:
%     figure handle for horizontal slice
% hslice_axis:
%     axis handle for horizontal slice
% hslice_{cmax,cmin}_edit :
%     handles for color limit typeins
% hslice_title:
%     handle for horizontal slice label
% hslice_axis_position:
%     normalized axis position for axis.  Don't recall why I need this.
%     Maybe I can get rid of it.
% hx, hy, hw:
%     Data retrieved for horizontal slice.  These are kept in the original
%     format of the file.  Projections are done on the fly.
% hslice_time_edit:
%     handle for timestep typein
% map_projection:  
%     can be either 'none', 'mercator', 'stereographic',
%     or 'lambert conformal conic'
% ncid:
%     file id for netcdf file
% resolution:
%     number of points along vertical slice line at which the
%     data is sampled
% scale
%     only currently used for scrum files.  Scales data down from
%     meters into kilometers.
% shading:
%     current shading, either flat, faceted, or interp
% show_arrows:
%     whether or not to display the velocity field.  I really don't need
%     this, as I could just check the status of the "show arrows" button
%     on the hvfo window.
% timestep:
%     current timestep for current variable
% timestep_min, timestep_max
%     bounds for timestep
% type:
%     what type of netcdf file it is, whether 'SCRUM' or 'ECOM'
% variable:
%     the current variable being displayed
% vcolormap:
%     colormap chosen for vertical slice
% velocity_overlay_figure:
%     handle for velocity overlay command window
% vslice_figure:
%     handle for vertical slice window
% vslice_axis:
%     handle for vertical slice axis
% vslice_axis_position
%     same as hslice_axis_position
% vslice_distance:
%     distance array.  Taken along the slice axis.
% vslice_z:
%     depth array.  Taken in z direction.
% vslice_w:
%     interpolated data for vertical slice.
% vslice_line:
%     handle for line drawn on HORIZONTAL SLICE WINDOW to show where the
%     vertical slice is taken from
% vcolorbar:
%     handle for colorbar axis in qvertical slice window
% xgrid, ygrid:
%     Same as hx and hy, except they are map projected.
% zoom_axis:
%     stack of axis positions.  Store them when using zoom so we can
%     zoom back to what we were.


status = -1;

global cslice_obj cslice_count;


%
% keep track of how many cslice objects are active.
if ( size(cslice_count,1) > 0 )
    cslice_count = cslice_count+1;
else
    cslice_count = 1;
end

N = cslice_count;


if ( nargin == 0 )
    [cdf, pathname] = uigetfile ( '*.*', 'CSLICE INPUT FILE' );
    if ( cdf == 0 )
        help cslice;
        fprintf ( 2, 'Could not open input file.\n' );
        return;
    end
    cslice_obj{N}.cdf = sprintf ( '%s%s', pathname, cdf );

elseif ( isa ( cdf, 'char' ) )
    cslice_obj{N}.cdf = cdf;

else
    fprintf ( 2, 'cslice:  unknown input type ''%s'' ???\n' , char(cdf) );
    co = [];
    return;
end



%
% Figure out what kind of input file it is.
% Currently, ECOM and SCRUM supported.

% Also figure out whether we are dealing with GEOGRAPHIC
% or PROJECTED coordinates

ncmex ( 'setopts', 0 );
[cslice_obj{N}.type,cslice_obj{N}.coord] = what_type ( cslice_obj{N}.cdf );

if ( strcmp(cslice_obj{N}.type,'unknown') )
   help cslice;
   return;
end

cslice_obj{N}.ncid = ncmex ( 'open', cslice_obj{N}.cdf, 'nowrite' );

% 
% set up default hslice parameters
switch ( cslice_obj{N}.type )
    case 'ECOM'
	cslice_obj{N}.bathymetry = kslice ( cslice_obj{N}.cdf, 'depth' );
	%cslice_obj{N}.bathymetry = cslice_obj{N}.bathymetry';
        cslice_obj{N}.variable = 'depth';
        cslice_obj{N}.dimensionality = 2;

    case 'SCRUM'
	cslice_obj{N}.bathymetry = kslice ( cslice_obj{N}.cdf, 'h' );
	%cslice_obj{N}.bathymetry = cslice_obj{N}.bathymetry';
	cslice_obj{N}.depth_variable = 'h';
	cslice_obj{N}.variable = 'h';
	cslice_obj{N}.dimensionality = 2;

    otherwise
        fprintf ( 2, 'I don''t know what kind of file %s is.\n', cdf );
        return

end

cslice_obj{N}.depth = -1;

%
% Set the max limits.  Currently, the timestep is one-based, like matlab.
cslice_obj{N}.time_step = 1;
cslice_obj{N}.time_step_min = 1;
[time_dimid, rcode] = ncmex('DIMID', cslice_obj{N}.ncid, 'time');
[dud, cslice_obj{N}.time_step_max, status] = ncmex('DIMINQ', cslice_obj{N}.ncid, time_dimid);


cslice_obj{N}.resolution = 40;
cslice_obj{N}.scale = 1000;
cslice_obj{N}.hcolormap = 'jet';
cslice_obj{N}.shading = 'flat';

cslice_obj{N}.first_draw = 1;


%
% To begin with, the map projection will always be 'none'.
cslice_obj{N}.map_projection = 'none';


%
% Activate the horizontal slice.
hslice(N);
hslice_figure_tag = sprintf ( 'hslice figure %d', N );

%
% store the hslice edit widgets
cslice_obj{N}.hslice_figure = findobj ( 0,'tag', hslice_figure_tag );
cslice_obj{N}.hslice_axis = findobj ( cslice_obj{N}.hslice_figure, 'tag', 'hslice axis' );
cslice_obj{N}.hslice_cmax_edit = findobj ( cslice_obj{N}.hslice_figure, 'tag', 'hslice color max edit' );
cslice_obj{N}.hslice_cmin_edit = findobj ( cslice_obj{N}.hslice_figure, 'tag', 'hslice color min edit' );
cslice_obj{N}.hslice_time_edit = findobj ( cslice_obj{N}.hslice_figure, 'tag', 'hslice time edit' );
cslice_obj{N}.hslice_depth_edit = findobj ( cslice_obj{N}.hslice_figure, 'tag', 'hslice depth edit' );
cslice_obj{N}.hslice_title = findobj ( cslice_obj{N}.hslice_figure, 'tag', 'hslice title' );

cslice_obj{N}.hslice_axis_position = get ( cslice_obj{N}.hslice_axis, 'Position' );



%
% Add to the variable menu.  This has to be done dynamically.  Probably
% should not be done thru the hslice function.
hslice_fig = findobj ( 0, 'tag', hslice_figure_tag );
hslice_varmenu ( hslice_fig );

cslice_obj{N}.show_arrows = 0;
hslice_command draw;


%
% Need to keep a list of zoom axes.
% The first row is always the default gca position.
% Don't need to put it on here now because we haven't zoomed yet.
cslice_obj{N}.zoom_axes = [];


%
% Activate the velocity overlay figure.
hvfo(N);
hvfo_figure_tag = sprintf ( 'hvfo figure %d', N );


cslice_obj{N}.velocity_overlay_figure = findobj ( 0, 'tag', hvfo_figure_tag );


%
% Activate the vertical slice figure
vslice(N);
vslice_figure_tag = sprintf ( 'vslice figure %d', N );

cslice_obj{N}.vslice_figure = findobj ( 0, 'tag', vslice_figure_tag );
cslice_obj{N}.vslice_axis = findobj ( cslice_obj{N}.vslice_figure, 'tag', 'vslice axis' );
cslice_obj{N}.vslice_axis_position = get ( cslice_obj{N}.vslice_axis, 'Position' );
cslice_obj{N}.vslice_shading = 'flat';
cslice_obj{N}.vcolorbar = findobj ( cslice_obj{N}.vslice_figure, 'tag', 'vcolorbar' );



%
% If we're here, it must have worked...
status = 1;

return



