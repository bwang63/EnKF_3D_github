function hvfo_command ( command )
% HVFO_COMMAND:  Callback handler for velocity overlay gui.
%

%
% $Id: hvfo_command.m,v 1.1 1997/04/16 13:39:21 jevans Exp jevans $
% Currently locked by $Locker: jevans $ (not locked if blank)
% (Time in GMT, EST=GMT-5:00
% $Log: hvfo_command.m,v $
%Revision 1.1  1997/04/16  13:39:21  jevans
%Initial revision
%
%
%


global cslice_obj;

N = cslice_obj_index;



%disp ( sprintf ( 'hvfo_command:  command=%s\n', command ) );
%disp ( sprintf ( 'hvfo_command:  gcbo object type = %s\n', get(gcbo,'style') ) );

hvfo_figure = cslice_obj{N}.velocity_overlay_figure;



switch ( command )

    case 'arrow_color'

        %
        % Make it such that the other radio buttons are turned off,
        % as they should be.
        rb_parent = get(gcbo,'parent');
        all_rbs = findobj ( rb_parent, ...
                    'style', 'radiobutton', ...
                    'callback', 'hvfo_command arrow_color' );
        set ( all_rbs, 'value', 0 );
        set ( gcbo, 'value', 1 );
        hvfo_command draw_arrows;
        
    case 'arrow_edit'

        %
        % If the new value is between the min and max of the slider,
        % reset the slider.
        arrow_slider = findobj(hvfo_figure, 'tag', 'Arrow Slider' );
        min_val = get ( arrow_slider, 'min' );
        max_val = get ( arrow_slider, 'max' );
        edit_val = str2num ( get(gcbo,'string') );

        %
        % if the edit value exceeds the scale max, reset the
        % scale max
        if ( edit_val > max_val )
            set ( arrow_slider, 'max', edit_val );
            set ( arrow_slider, 'value', edit_val );
            set ( gcbo, 'value', edit_val );
        end

        if ( (min_val <= edit_val ) & (edit_val <= max_val ) )
            set ( arrow_slider, 'value', edit_val );
            set ( gcbo, 'value', edit_val );
        else
            set ( gcbo, 'string', num2str ( get(gcbo, 'value') ) );
        end

        hvfo_command draw_arrows;


    case 'arrow_slider'
        %
        % set the arrow text edit widget to match that of the slider.
        arrow_edit = findobj ( hvfo_figure, 'tag', 'Arrow Edit Box' );
        slider_val = get ( gcbo, 'Value' );
        set ( arrow_edit, 'String', num2str(slider_val) );
        set ( arrow_edit, 'Value', slider_val );


        hvfo_command draw_arrows;




    case 'sample_edit'

        %
        % If the new value is between the min and max of the slider,
        % reset the slider.
        sample_slider = findobj(hvfo_figure, 'tag', 'Sampling Slider' );
        min_val = get ( sample_slider, 'min' );
        max_val = get ( sample_slider, 'max' );
        edit_val = round ( str2num ( get(gcbo,'string') ) );

        %
        % if the edit value exceeds the scale max, reset the
        % scale max
        if ( edit_val > max_val )
            set ( sample_slider, 'max', edit_val );
            set ( sample_slider, 'value', edit_val );
            set ( gcbo, 'value', edit_val );
        end

        if ( (min_val <= edit_val ) & (edit_val <= max_val ) )
            set ( sample_slider, 'value', edit_val );
            set ( gcbo, 'value', edit_val );
            set ( gcbo, 'string', num2str(edit_val) );
        else
            set ( gcbo, 'string', num2str ( get(gcbo, 'value') ) );
        end

        hvfo_command draw_arrows;


    case 'sample_slider'
        %
        % set the arrow text edit widget to match that of the slider.
        sample_edit = findobj ( hvfo_figure, 'tag', 'Sampling Edit Box' );
        slider_val = round ( get ( gcbo, 'Value' ) );
        set ( sample_edit, 'String', num2str(slider_val) );
        set ( sample_edit, 'Value', slider_val );
        set ( gcbo, 'Value', slider_val );

        hvfo_command draw_arrows;

    
    case 'set_show_arrows'
        value = get ( gcbo, 'Value' );
        if ( value == 1 )
            cslice_obj{N}.show_arrows = 1;
            hvfo_command draw_arrows;
        else
            cslice_obj{N}.show_arrows = 0;
            hvfo_command undo_it;
        end



    case 'draw_arrows'

        if ( cslice_obj{N}.show_arrows )

            %
            % Undo it first.  This erases any old arrows.
            hvfo_command undo_it;
    
    
            %
            % Retrieve information necessary to construct the arrows.
            sample_slider = findobj(hvfo_figure, 'tag', 'Sampling Slider' );
            sampling_rate = get ( sample_slider, 'value' );
            arrow_slider = findobj(hvfo_figure, 'tag', 'Arrow Slider' );
            arrow_scale = get ( arrow_slider, 'value' );
            color_radiobutton = findobj ( hvfo_figure, ...
                                'style', 'radiobutton', ... 
                                'callback', 'hvfo_command arrow_color', ...
                                'value', 1 ); ...
            arrow_color = get ( color_radiobutton, 'string' );
            if ( ( cslice_obj{N}.dimensionality == 2 ) | ( cslice_obj{N}.dimensionality == 3 ) )
                [velocity,xv,yv] = depaveuv_c ( cslice_obj{N}.cdf, cslice_obj{N}.time_step );
            else
                [velocity,xv,yv] = zsliceuv_c ( cslice_obj{N}.cdf, cslice_obj{N}.time_step, cslice_obj{N}.depth );
            end
	    %velocity = velocity';
    
            axes ( cslice_obj{N}.hslice_axis );
    
	    %
	    % do the map projection
            switch ( cslice_obj{N}.map_projection )
            
                case 'none'
            
            	%
            	% if ECOM, change to kilometers.  
            	% This is pretty stupid.
            	if (strcmp(cslice_obj{N}.coord,'PROJECTED')) 
            
            	    xv = xv/cslice_obj{N}.scale;
            	    yv = yv/cslice_obj{N}.scale;
            	
            	end
            
                case 'lambert conformal conic'
            	    lat_extents = [gmin(yv(:)) gmax(yv(:))];
            	    lon_extents = [gmin(xv(:)) gmax(xv(:))];
            	    m_proj ( 'lambert conformal conic', ...
            		 'lat', lat_extents, ...
            		 'lon', lon_extents );
            	    [xv,yv] = m_ll2xy ( xv, yv );
            
            
                case 'mercator'
            	    m_proj ( 'mercator' );
            	    [xv,yv] = m_ll2xy ( xv, yv );
            
                case 'stereographic'
            	    m_proj ( 'stereographic' );
            	    [xv,yv] = m_ll2xy ( xv, yv );
            
            end

	    %
	    % rotate the arrows into the projection.
	    angle = cslice_angle(xv,yv);
	    [r,c] =size(angle);
	    velocity = velocity .* exp ( sqrt(-1) * angle );
            cslice_obj{N}.arrows = psliceuv ( xv, yv, velocity, sampling_rate, arrow_scale, arrow_color );
        
        end



    case 'undo_it'
        
        %
        % Delete the existing arrows.  Since it is possible that they don't
        % yet exist, use the 'try/catch' capabilities of eval.
        eval ( 'set ( cslice_obj{N}.arrows, ''Visible'', ''Off'' );', '' ); 
        eval ( 'delete(cslice_obj{N}.arrows);\n', '' );



    case 'close_window'
        set ( hvfo_figure, 'Visible', 'off' );

        
end









function angle = cslice_angle(x,y)

% This computes the angle by which we want to rotate the velocity
% field to compensate for the damn projection that we just threw
% up on ourselves.

angle = zeros(size(x));
[r,c] = size(x);
j = [2:c-1];
for i = 2:r-1
    angle(i,j) = atan2(y(i+1,j)-y(i-1,j), x(i+1,j)-x(i-1,j));
end

angle(1,j) = angle(2,j);
angle(r,j) = angle(r-1,j);

angle(1:r,1) = angle(1:r,2);
angle(1:r,c) = angle(1:r,c-1);

return;

