function hslice_command ( action )
% HSLICE_COMMAND:  Implements callbacks for hslice window.
%
% USAGE:  Not to be called from command line.


%action

status = 1;
global cslice_obj;

N = cslice_obj_index;

cslice_obj{N}.action = action;

hslice_figure_tag = sprintf ( 'hslice figure %d', N );

hslice_fig = findobj ( 0, 'tag', hslice_figure_tag );
hcolor_min_edit = findobj ( cslice_obj{N}.hslice_figure, 'tag', 'hslice color min edit' );
hcolor_max_edit = findobj ( cslice_obj{N}.hslice_figure, 'tag', 'hslice color max edit' );
    

switch ( action )
        
    case 'advedit'
        advedit_command = get ( gcbo, 'label' );
        switch ( advedit_command )

            case 'contour'

                axes ( cslice_obj{N}.hslice_axis );
                xlim = get(gca,'xlim');
                ylim = get(gca,'ylim');
                cla;
                set(gcf,'NextPlot','Add' );
                set(gca,'NextPlot','Add' );
                newplot;

                %
                % get the contour vector from the colorbar
                cv = get ( cslice_obj{N}.colorbar, 'Ytick' );

                [cs,h] = contourf ( cslice_obj{N}.hx, cslice_obj{N}.hy, cslice_obj{N}.hw, cv );
                %clabel ( cs, h );

                %
                % delete the old colorbar, put a contour-specific one
                % in its place
                position = get ( cslice_obj{N}.colorbar, 'Position' );
                delete ( cslice_obj{N}.colorbar );
                cslice_obj{N}.colorbar = contourbar ( cslice_obj{N}.hslice_axis, position );

                %
                % The colors always seem off unless I do the following.
                % This is a kludge, but it seems to work.  Shrug.
                set ( cslice_obj{N}.colorbar, 'clim', get(cslice_obj{N}.hslice_axis, 'clim') );

                set ( cslice_obj{N}.hslice_axis, 'position', cslice_obj{N}.hslice_axis_position );
                set ( cslice_obj{N}.hslice_axis, 'xlim', xlim );
                set ( cslice_obj{N}.hslice_axis, 'ylim', ylim );

            case 'velocity overlay'

                set ( cslice_obj{N}.velocity_overlay_figure, 'Visible', 'on' );



            case 'vslice'
                eval ( 'delete(cslice_obj{N}.vslice_line);', '' );
                [x,y] = cslice_getline ( cslice_obj{N}.hslice_axis );
                cslice_obj{N}.vslice_line = line ( x, y, 'color', 'k' );
                cslice_obj{N}.vslice_line_x = x;
                cslice_obj{N}.vslice_line_y = y;



                set ( cslice_obj{N}.vslice_figure, 'Visible', 'on' );
                cslice_obj{N}.vslice_first_draw = 1;
                vslice_command draw;


            otherwise
                fprintf ( 2, 'hslice_command/advedit:  %s not yet supported\n', advedit_command );
        end
                

    case 'autoscale_color'
        cmin = gmin(cslice_obj{N}.hw(:));
        cmax = gmax(cslice_obj{N}.hw(:));

        if ( abs((cmin-cmin)) < 1e-10 )
            cmin = cmin - 0.0001;
            cmax = cmax + 0.0001;
        end

        set ( hcolor_max_edit, 'value', cmax );
        set ( hcolor_max_edit, 'string', num2str(cmax) );
        set ( hcolor_min_edit, 'value', cmin );
        set ( hcolor_min_edit, 'string', num2str(cmin) );
        hslice_command draw;


    case 'colormap'
        cmap = get ( gcbo, 'label' );
        cslice_obj{N}.hcolormap = cmap;
        comm_str = sprintf ( 'colormap(%s);', cmap );
        eval ( comm_str );


    case 'exit'
        delete ( cslice_obj{N}.hslice_figure );
        delete ( cslice_obj{N}.velocity_overlay_figure );
        delete ( cslice_obj{N}.vslice_figure );
        ncmex ( 'close', cslice_obj{N}.ncid );
	cslice_obj{N} = [];


    case 'draw'
        hslice_draw;
        if ( cslice_obj{N}.show_arrows )
            hvfo_command draw_arrows;
        end


    case 'new_shading'
        shading_type = get ( gcbo, 'label' );
        cslice_obj{N}.shading = shading_type;
        shading ( cslice_obj{N}.shading );
        

    case 'new_variable'
        cslice_obj{N}.variable = get ( gcbo, 'label' );

        %
        % If there is a add_offset and scale_factor, get it.
        [dud,dud,status] = ncmex ( 'attinq', cslice_obj{N}.ncid, cslice_obj{N}.variable, 'add_offset' );
        if ( status == -1 )
            cslice_obj{N}.add_offset = 0;
        else  
            [cslice_obj{N}.add_offset, status] = ncmex ( 'attget', cslice_obj{N}.ncid, cslice_obj{N}.variable, 'add_offset' );
        end

        [dud,dud,status] = ncmex ( 'attinq', cslice_obj{N}.ncid, cslice_obj{N}.variable, 'scale_factor' );
        if ( status == -1 )
            cslice_obj{N}.scale_factor = 1;
        else  
            [cslice_obj{N}.scale_factor, status] = ncmex ( 'attget', cslice_obj{N}.ncid, cslice_obj{N}.variable, 'scale_factor' );
        end


        get_hslice_data;
        cslice_obj{N}.first_draw = 1;
        hslice_command draw;
        if ( strcmp(get(cslice_obj{N}.vslice_figure,'Visible'),'on') )
            cslice_obj{N}.vslice_line = line ( cslice_obj{N}.vslice_line_x, cslice_obj{N}.vslice_line_y, 'color', 'k' );
            cslice_obj{N}.vslice_first_draw = 1;
            vslice_command draw;
        end


    case 'print_enc_postscript'
        [filename,path] = ...
            uiputfile ( '*.eps', 'Select Filename For Encapsulated Postscript File' );
        full_path_name = sprintf ( '%s%s', path, filename );
        comm_str = sprintf ( 'print -dpsc2 -noui -f%i %s;\n', ...
                              cslice_obj{N}.hslice_figure, ...
                              full_path_name );
        eval ( comm_str );


    %
    % Barbara Robson's changes
    case 'print_pcx'
	[filename,path] = ...
	    uiputfile ( '*.pcx', 'Select Filename For PCX File' );
        full_path_name = sprintf ( '%s%s', path, filename );
	comm_str = sprintf ( 'print -dpcx256 -f%i %s;\n', ...
			      cslice_obj{N}.hslice_figure, ...
			      full_path_name );
	eval ( comm_str );


    case 'print_to_printer'
	answer = inputdlg({'Print style','Printer Name', 'Other Options'},...
			   'Print Options',1,{'psc2','', '-noui'});
	if (size(answer,1)>0)
	    printstyle = char(answer(1));
	    printername = char(answer(2));
	    others = char(answer(3));
	    comm_str = sprintf( 'print -d%s -P%s %s -f%i ;\n',...
				printstyle, printername, others, ...
				cslice_obj{N}.hslice_figure);
	    eval (comm_str );
	end




    case 'print_postscript'
        [filename,path] = ...
            uiputfile ( '*.ps', 'Select Filename For Postscript File' );
        full_path_name = sprintf ( '%s%s', path, filename );
        comm_str = sprintf ( 'print -dpsc2 -noui -f%i %s;\n', ...
                              cslice_obj{N}.hslice_figure, ...
                              full_path_name );
        eval ( comm_str );


    %
    % Handle the projections here.
    case 'projection_lambert'
	cslice_obj{N}.map_projection = 'lambert conformal conic';
	hslice_draw;
	return;

    case 'projection_mercator'
	cslice_obj{N}.map_projection = 'mercator';
	hslice_draw;
	return;

    case 'projection_none'
	cslice_obj{N}.map_projection = 'none';
	hslice_draw;
	return;

    case 'projection_stereographic'
	cslice_obj{N}.map_projection = 'stereographic';
	hslice_draw;
	return;



    case 'save_data'

        %
        % Write out the horizontal slice data to a matlab mat file.
        [filename,path] = uiputfile ( '*.mat', 'Select Filename For Matlab mat File' );
        full_path_name = sprintf ( '%s%s', path, filename );
        x = cslice_obj{N}.hx;
        y = cslice_obj{N}.hy;
        w = cslice_obj{N}.hw;
        xx = 'x';
        yy = 'y';
        ww = 'w';
        eval ( sprintf ( 'save(''%s'',''%s'',''%s'',''%s'');\n', ...
                          full_path_name, xx, yy, ww ) );


    % 
    % The next four are all from the File menu.
    case 'save_figure'

        % 
        % Write out the horizontal slice figure to a matlab m file.
        [filename,path] = uiputfile ( '*.m', 'Select Filename For Figure' );
        full_path_name = sprintf ( '%s%s', path, filename );
        eval ( sprintf ( 'print -dmfile %s;\n', full_path_name ) );

        

    case 'set_color_min'
        cmin = str2num ( get(gcbo,'string') );
	cmax = str2num ( get(hcolor_max_edit,'string') );
	if ( (abs(cmax-cmin) <= 1e-4) | (cmin > cmax) )
	    cmin = cmax - 1e-4;
	end
	set ( gcbo, 'string', num2str(cmin) );
        set ( gcbo, 'value', cmin );
        hslice_command draw;

    case 'set_color_max'
	cmin = str2num ( get(hcolor_min_edit,'string') );
        cmax = str2num ( get(gcbo,'string') );
	if ( (abs(cmax-cmin) <= 1e-4) | (cmin > cmax) )
	    cmax = cmin + 1e-4;
	end
	set ( gcbo, 'string', num2str(cmax) );
        set ( gcbo, 'value', cmax );
        hslice_command draw;
    
    case 'set_depth'
        cslice_obj{N}.depth = str2num ( get(gcbo,'string') );
        set ( gcbo, 'value', cslice_obj{N}.depth );
        hslice_command draw;

    case 'set_time'
	hslice_time_edit = findobj ( hslice_fig, 'tag', 'hslice time edit' );
	time_step = str2num ( get(hslice_time_edit,'string') );

	%
	% Check to see if within bounds
	if ( time_step < cslice_obj{N}.time_step_min )
	    time_step = 1;
	end
	if ( time_step > cslice_obj{N}.time_step_max )
	    time_step = cslice_obj{N}.time_step_max;
	end

        cslice_obj{N}.time_step = time_step;
        set ( hslice_time_edit, ...
	    'value', cslice_obj{N}.time_step, ...
	    'string', num2str(time_step) );
        hslice_command draw;

        %
        % If the vslice window is up, then we want to redraw
        % the vslice line. 
        if ( strcmp ( get(cslice_obj{N}.vslice_figure,'Visible'), 'on' ) ) 
            cslice_obj{N}.vslice_line = line ( cslice_obj{N}.vslice_line_x, ...
                                    cslice_obj{N}.vslice_line_y, ...
                                    'color', 'k' );
            vslice_command draw;
        end


    case 'step_forwards_one'
	hslice_time_edit = findobj ( hslice_fig, 'tag', 'hslice time edit' );
	time_step = get ( hslice_time_edit, 'String' );
	value = str2num(time_step);
	set ( hslice_time_edit, 'String', num2str(value+1) );
	hslice_command set_time;

    case 'step_backwards_one'
	hslice_time_edit = findobj ( hslice_fig, 'tag', 'hslice time edit' );
	time_step = get ( hslice_time_edit, 'String' );
	value = str2num(time_step);
	set ( hslice_time_edit, 'String', num2str(value-1) );
	hslice_command set_time;

    case 'zoom_in'
        axes ( cslice_obj{N}.hslice_axis );
        old_gca_axis = axis;
        cslice_obj{N}.zoom_axes = [cslice_obj{N}.zoom_axes; old_gca_axis];

        [zoomx zoomy] = ginput(2);        
        new_gca_axis = [min(zoomx) max(zoomx) min(zoomy) max(zoomy)];
        axis ( new_gca_axis );


    case 'zoom_out'
        %
        % Pick off the last axis on the zoom axis list.
        [r,c] = size(cslice_obj{N}.zoom_axes);
        if ( r ~= 0 )
            old_gca_axis = cslice_obj{N}.zoom_axes(r,:);
            cslice_obj{N}.zoom_axes = cslice_obj{N}.zoom_axes((1:(r-1)),:);
            axes ( cslice_obj{N}.hslice_axis );
            axis ( old_gca_axis );
        end


    otherwise
        fprintf ( 2, 'hslice_command:  %s??  Unknown command encountered.\n', action );

end



return;

