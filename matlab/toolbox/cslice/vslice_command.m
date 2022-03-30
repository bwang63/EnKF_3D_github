function vslice_command ( command )
% VSLICE_COMMAND:  handles callbacks for vertical slicing

global cslice_obj;

N = cslice_obj_index;

%command


vslice_figure_tag = sprintf ( 'vslice figure %d', N );
vslice_figure = findobj ( 0, 'Tag', vslice_figure_tag );
vslice_axis = findobj ( vslice_figure, 'Tag', 'vslice axis' );
vcolorbar = findobj ( vslice_figure, 'Tag', 'vcolorbar' );
vcolor_max_edit = findobj ( vslice_figure, 'tag', 'vslice color max edit' );
vcolor_min_edit = findobj ( vslice_figure, 'tag', 'vslice color min edit' );

set(vslice_figure,'NextPlot','Add' );
set(vslice_axis,'NextPlot','Add' );
axes ( vslice_axis );

switch command
    case 'draw'
        cla;
        draw_was_successful = vslice_draw;
	if ( draw_was_successful == 1 )
           vcolorbar = colorbar(vcolorbar);
	   set ( vcolorbar, 'Tag', 'vcolorbar' );
	end




    % 
    % The next four are all from the File menu.
    case 'save_figure'

        % 
        % Write out the horizontal slice figure to a matlab m file.
        [filename,path] = uiputfile ( '*.m', 'Select Filename For Figure' );
        full_path_name = sprintf ( '%s%s', path, filename );
        eval ( sprintf ( 'print -dmfile -f%i %s;\n', vslice_figure, full_path_name ) );

        
        
    case 'save_data'

        %
        % Write out the horizontal slice data to a matlab mat file.
        [filename,path] = uiputfile ( '*.mat', 'Select Filename For Matlab mat File' );
        full_path_name = sprintf ( '%s%s', path, filename );
        x = cslice_obj{N}.vslice_distance;
        y = cslice_obj{N}.vslice_z;
        w = cslice_obj{N}.vslice_w;
        xx = 'x';
        yy = 'y';
        ww = 'w';
        eval ( sprintf ( 'save(''%s'',''%s'',''%s'',''%s'');\n', full_path_name, xx, yy, ww ) );


    case 'print_postscript'
        [filename,path] = uiputfile ( '*.ps', 'Select Filename For Postscript File' );
        full_path_name = sprintf ( '%s%s', path, filename );
        comm_str = sprintf ( 'print -dpsc2 -noui -f%i %s;\n', vslice_figure, full_path_name );
        eval ( comm_str );


    case 'print_enc_postscript'
        [filename,path] = uiputfile ( '*.eps', 'Select Filename For Encapsulated Postscript File' );
        full_path_name = sprintf ( '%s%s', path, filename );
        comm_str = sprintf ( 'print -dpsc2 -noui -f%i %s;\n', vslice_figure, full_path_name );
        eval ( comm_str );



    case 'hide'
        set ( vslice_figure, 'Visible', 'off' );

        %
        % Doesn't really make sense to have the vertical slice line visible now.
        eval ( 'delete(cslice_obj{N}.vslice_line);', '' );

    
    case 'autoscale_color'
      
	%
	% would like to replace these with nanmin and nanmax
        cmin = gmin(cslice_obj{N}.vslice_w(:));
        cmax = gmax(cslice_obj{N}.vslice_w(:));

        if ( abs((cmin-cmin)) < 1e-10 )
            cmin = cmin - 0.0001;
            cmax = cmax + 0.0001;
        end


        set ( vcolor_max_edit, 'value', cmax );
        set ( vcolor_max_edit, 'string', num2str(cmax) );
        set ( vcolor_min_edit, 'value', cmin );
        set ( vcolor_min_edit, 'string', num2str(cmin) );
        vslice_command draw;

%        eval ( 'delete(cslice_obj{N}.vcolorbar);', '' );
        vcolorbar = colorbar(vcolorbar);
	set ( vcolorbar, 'Tag', 'vcolorbar' );



    case 'new_shading'
        shading_type = get ( gcbo, 'label' );
        cslice_obj{N}.vslice_shading = shading_type;
        shading ( cslice_obj{N}.vslice_shading );

%        eval ( 'delete(cslice_obj{N}.vcolorbar);', '' );
        vcolorbar = colorbar(vcolorbar);
	set ( vcolorbar, 'Tag', 'vcolorbar' );


        
    case 'colormap'
        cmap = get ( gcbo, 'label' );
        comm_str = sprintf ( 'colormap ( %s );', cmap );
        eval ( comm_str );

%        eval ( 'delete(vcolorbar);', '' );
        vcolorbar = colorbar(vcolorbar);
	set ( vcolorbar, 'Tag', 'vcolorbar' );



        
    case 'advedit'
        advedit_command = get ( gcbo, 'label' );
        switch ( advedit_command )

            case 'contour'

                xlim = get(gca,'xlim');
                ylim = get(gca,'ylim');
                cla;
                set(gcf,'NextPlot','Add' );
                set(gca,'NextPlot','Add' );
                newplot;

                %
                % get the contour vector from the colorbar
                cv = get ( vcolorbar, 'Ytick' );

                [cs,h] = contourf ( cslice_obj{N}.vslice_distance, cslice_obj{N}.vslice_z, cslice_obj{N}.vslice_w, cv );
%                clabel ( cs, h );


                %
                % delete the old colorbar, put a contour-specific one
                % in its place
                position = get ( vcolorbar, 'Position' );
                delete ( vcolorbar );
                vcolorbar = contourbar ( vslice_axis, position );
	        set ( vcolorbar, 'Tag', 'vcolorbar' );

                %
                % The colors always seem off unless I do the following.
                % This is a kludge, but it seems to work.  Shrug.
                set ( vcolorbar, 'clim', get(vslice_axis, 'clim') );


                set ( vslice_axis, 'xlim', xlim );
                set ( vslice_axis, 'ylim', ylim );




            otherwise
                fprintf ( 2, 'vslice_command/advedit:  %s not yet supported\n', advedit_command );

        end


    case 'resolution'
        resolution_edit = findobj ( vslice_figure, 'tag', 'vslice resolution edit' );
        new_resolution = str2num ( get(resolution_edit,'String') );
        set ( resolution_edit, 'value', new_resolution );
        cslice_obj{N}.resolution = new_resolution;
        vslice_command draw;

%        eval ( 'delete(vcolorbar);', '' );
        vcolorbar = colorbar(vcolorbar);
	set ( vcolorbar, 'Tag', 'vcolorbar' );


    case 'cmin'
        cmin = str2num ( get(gcbo,'string') );
	cmax = str2num ( get(vcolor_max_edit,'string') );
	if ( (abs(cmax-cmin) <= 1e-4) | (cmin > cmax) )
	    cmin = cmax - 1e-4;
	end
	set ( gcbo, 'string', num2str(cmin) );
        set ( gcbo, 'value', cmin );
        climits = [get(vcolor_min_edit,'Value') get(vcolor_max_edit,'Value')];
        set ( vslice_axis, 'clim', climits );

        vcolorbar = colorbar(vcolorbar);
	set ( vcolorbar, 'Tag', 'vcolorbar' );
	%vslice_command draw;

    case 'cmax'
        cmin = str2num ( get(vcolor_max_edit,'string') );
        cmax = str2num ( get(gcbo,'string') );
	if ( (abs(cmax-cmin) <= 1e-4) | (cmin > cmax) )
	    cmax = cmin + 1e-4;
	end
	set ( gcbo, 'string', num2str(cmax) );
        set ( gcbo, 'value', cmax );
        climits = [get(vcolor_min_edit,'Value') get(vcolor_max_edit,'Value')];
        set ( cslice_obj{N}.vslice_axis, 'clim', climits );

        vcolorbar = colorbar(vcolorbar);
	set ( vcolorbar, 'Tag', 'vcolorbar' );

    otherwise
        fprintf ( 2, 'vslice_command:  Don''t understand what ''%s'' means.\n', command );

end

set ( vslice_axis, 'position', cslice_obj{N}.vslice_axis_position );


