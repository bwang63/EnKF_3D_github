function timeplt_draw()
% TIMEPLT_DRAW:  Takes care of drawing routines.
%

%disp ( sprintf ( 'here in timeplt_draw' ) );

global timeplt_obj;


N = timeplt_obj_index;


eval ( 'delete ( timeplt_obj{N}.plot_axes );', '' );


%
% Redo all the axes.
num_axes = max(timeplt_obj{N}.istack(:) );

for i = 1:num_axes
    h(i) = subplot(num_axes,1,i);

    if ( ~isempty(timeplt_obj{N}.ylims) )
        set ( h, 'YLim', timeplt_obj{N}.ylims(i,:) );
    end

end

set ( h,     'NextPlot', 'Add' );

            
h = flipud(h(:));





jd = timeplt_obj{N}.jd;
data = timeplt_obj{N}.data;
istack = timeplt_obj{N}.istack;


%
% colordef white color scheme line colors
defaultcmap = get ( 0, 'defaultaxescolororder' );
if ( size(istack,1) > size(defaultcmap,1) )
    cmap = jet(size(istack,1));
else
    cmap = defaultcmap;
end
axis_color_index = zeros(length(istack),1);


	


jd0 = nanmin(jd);
jd1 = nanmax(jd);

%
% Make the time axis always extend 5 percent past the
% data.
timediff = jd1 - jd0;
xlim = [(jd0 - timediff*0.05) (jd1 + timediff*0.05)];
set ( h, 'XLim', xlim );


%
% plot the data
for i = 1:length(istack)
    axes ( h(istack(i)) );

	%
	% set the index into the colormap correctly
	% each pane is to be the same as the order for regular matlab plots.
	% While I'm at it, I think I will cure world hunger. 
	axis_color_index(istack(i)) = axis_color_index(istack(i)) + 1;
	
    if ( isreal ( data(:,i) ) )
        graph = plot ( jd, data(:,i) );
        if ( ~isempty(timeplt_obj{N}.ylims) )
            set ( gca, 'YLim', timeplt_obj{N}.ylims(istack(i),:) );
        end
    else

        %
        % Retrieve the ylims.  If ylims were specified
        % in the timplt call, then it has already been
        % set in the gca.  Otherwise construct it from the
        % data.
        if ( isempty(timeplt_obj{N}.ylims) )
            y0 = min ( nanmin(imag(data(:,i))), 0);
            y1 = max ( nanmax(imag(data(:,i))), 0);
            ylim = [y0 y1];
            set ( gca, 'YLim', ylim );
        else
            ylim = get ( gca, 'ylim' );
        end

        %
        % Construct the scaling factor to accurately do
        % stick plots.
        old_units = get ( gca, 'Units' );
        set ( gca, 'Units', 'Pixels' );
        pos = get ( gca, 'Position' );
        set ( gca, 'Units', old_units );

        scale_factor = (diff(xlim)/diff(ylim)) * (pos(4)/pos(3));

        u_data = scale_factor * real(data(:,i));
        v_data = imag(data(:,i));

        x=jd;
        xp=x;
        yp=zeros(size(xp));
        xplot=ones(length(xp),2);
        yplot=xplot;
        xplot(:,1)=x(:);
        xplot(:,2)=xp(:)+u_data(:);
        xplot(:,3)=x(:);
        yplot(:,1)=yp(:);
        yplot(:,2)=yp(:)+v_data(:);
        yplot(:,3)=yp(:)*nan;
        xplot=xplot';
        yplot=yplot';
        if(~isempty(find(finite(u_data(:)))))
            graph(1) = plot( [jd0 jd1],[0 0] );
            graph(2) = plot ( xplot(:), yplot(:) );...
        end
            
        
    end

%	index = mod(i-1, length(cmap))+1;
%    set ( graph, 'color', cmap(index,:) );
	set ( graph, 'color', cmap(axis_color_index(istack(i)),:) );

end



%
% We want to do our own labels, thank you very much.
set ( h, 'XTickLabel', [] );

%
% What's the separation of the ticks?
xt = get(gca,'XTick' );
xt_sep = max(diff(xt(:)));


axes ( h(1) );
if (timeplt_obj{N}.year_cut_specified)
    timeplt_gregax_year ( timeplt_obj{N}.jd );
elseif (timeplt_obj{N}.month_cut_specified)
    timeplt_gregax_month ( timeplt_obj{N}.jd );
elseif (timeplt_obj{N}.day_cut_specified)
    timeplt_gregax_day ( timeplt_obj{N}.jd );
elseif (timeplt_obj{N}.hour_cut_specified)
    timeplt_gregax_hour( timeplt_obj{N}.jd );
elseif (timeplt_obj{N}.minute_cut_specified)
    timeplt_gregax_minute( timeplt_obj{N}.jd );
elseif ( xt_sep > timeplt_obj{N}.year_cut )
    timeplt_gregax_year ( timeplt_obj{N}.jd );
    timeplt_obj{N}.year_cut_specified = 1;
elseif (xt_sep > timeplt_obj{N}.month_cut) 
    timeplt_gregax_month ( timeplt_obj{N}.jd );
    timeplt_obj{N}.month_cut_specified = 1;
elseif (xt_sep > timeplt_obj{N}.day_cut)
    timeplt_gregax_day ( timeplt_obj{N}.jd );
    timeplt_obj{N}.day_cut_specified = 1;
elseif (xt_sep > timeplt_obj{N}.hour_cut)
    timeplt_gregax_hour( timeplt_obj{N}.jd );
    timeplt_obj{N}.hour_cut_specified = 1;
else
    timeplt_gregax_minute ( timeplt_obj{N}.jd );
    timeplt_obj{N}.minute_cut_specified = 1;
end


%
% Now make sure that all axes have the same tick marks as the first.
set ( h, 'XTick', get(h(1), 'XTick' ) );

    


    
timeplt_obj{N}.plot_axes = h;


%
% The last thing we do is to calculate the printing properties.
% We want the paperposition to come out as close as possible to
% what's on screen.
old_units = get( timeplt_obj{N}.figure, 'Units' );
set ( timeplt_obj{N}.figure, 'Units', 'Points' );
old_paper_units = get ( timeplt_obj{N}.figure, 'PaperUnits' );
set ( timeplt_obj{N}.figure, 'PaperUnits', 'Points' );
set ( timeplt_obj{N}.figure, 'PaperType', 'usletter' );


onscreen_position = get ( timeplt_obj{N}.figure, 'Position' );
onpaper_position = get ( timeplt_obj{N}.figure, 'PaperPosition' );

%
% The maximum width that the plot can be is 612 points.  Anything
% larger must be scaled down.
% The maximum height is 792 points.
if ( onscreen_position(3) > 612 )
    hreduction_factor = 612 / onscreen_position(3);
else
    hreduction_factor = 1;
end

onpaper_position(3) = onscreen_position(3) * hreduction_factor;
onpaper_position(4) = onscreen_position(4) * hreduction_factor;

if ( onscreen_position(4) > 792 )
    vreduction_factor = 792 / onscreen_position(4);
else
    vreduction_factor = 1;
end

onpaper_position(3) = onpaper_position(3) * vreduction_factor;
onpaper_position(4) = onpaper_position(4) * vreduction_factor;

onpaper_position(1) = (612 - onpaper_position(3))/2;
onpaper_position(2) = (792 - onpaper_position(3))/2;

set ( timeplt_obj{N}.figure, 'PaperPosition', onpaper_position );
set ( timeplt_obj{N}.figure, 'Units', old_units );
set ( timeplt_obj{N}.figure, 'PaperUnits', old_paper_units );


