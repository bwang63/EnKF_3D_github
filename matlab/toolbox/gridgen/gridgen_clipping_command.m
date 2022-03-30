function gridgen_clipping_command ( command )

global grid_obj;

%disp ( sprintf ( 'GRIDGEN_CLIPPING_COMMAND:  %s', command ) );


switch command

    case 'commit_to_clipping'
	gridgen_setup_clipping_gui;


    case 'set_clipping_planes'

        bathymetry = grid_obj.grid_bathymetry;
        naninds = find(bathymetry==-99999);
        bathymetry(naninds) = NaN * ones(size(naninds));
            
	planes_string = get(gcbo,'string');

	if ( isempty(planes_string) )

            grid_obj.depthmin = round(min(bathymetry(:)));
            grid_obj.depthmax = round(max(bathymetry(:)));

	else

            [t,r] = strtok(planes_string,' ');
	    grid_obj.depthmin = round(str2num ( t ));
            [t,r] = strtok(r,' ');
	    grid_obj.depthmax = round(str2num ( t ));
	    if ( grid_obj.depthmin >= grid_obj.depthmax )
		set ( gcbo, 'String', '' );
		return;
	    end

	end

	lesser_inds =  find ( bathymetry<grid_obj.depthmin );
        grid_obj.grid_bathymetry(lesser_inds) = grid_obj.depthmin*ones(size(lesser_inds));
	greater_inds =  find ( bathymetry>grid_obj.depthmax );
        grid_obj.grid_bathymetry(greater_inds) = grid_obj.depthmax*ones(size(greater_inds));

        gridgen_destroy_clipping_gui;
	gridgen_command commit_to_output;



end

return









function gridgen_setup_clipping_gui()

global grid_obj;

bathymetry = grid_obj.grid_bathymetry;
naninds = find(bathymetry==-99999);
bathymetry(naninds) = NaN * ones(size(naninds));

min_bathymetry = min(bathymetry(:));
max_bathymetry = max(bathymetry(:));


bathy_range_string = ...
    sprintf ( 'Bathymetry range is [%f %f].', min_bathymetry, max_bathymetry );
instructions = { 'BATHYMETRY CLIPPING PLANES', ...
    bathy_range_string, ...
    'Enter a valid subrange of this, separated by a space.', ...
    'Don''t include any brackets or braces.', ...
    'If you just hit return, the current range is maintained.' };

set ( grid_obj.instructions_text, ...
    'String', instructions, ...
    'Fontsize', 12 );

clipping_text = uicontrol('Parent', grid_obj.control_figure, ...
    'Callback', 'gridgen_clipping_command set_clipping_planes', ...
    'Units','normalized', ...
    'BackgroundColor',[1 1 1], ...
    'Enable', 'on', ...
    'Position',[0.40 0.18 0.20 0.10 ], ...
    'Style','edit', ...
    'Tag','Bathymetry Clipping Plane Edit', ...
    'Visible', 'on' );




return;









function gridgen_destroy_clipping_gui()

global grid_obj;

set ( grid_obj.instructions_text, ...
    'String', '', ...
    'Fontsize', 12 );

widget = findobj ( grid_obj.control_figure, 'Tag', 'Bathymetry Clipping Plane Edit' );
delete(widget);
return;

