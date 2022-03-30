function h = timeplt ( arg1, arg2, arg3, arg4 )
% TIMEPLT  time series stack plots with Gregorian Time labels on x axes
%   
% USAGE:  
%   h = timeplt ( 'demo' ) 
%       
%     where
%        h = handles of plot axes
%
%   h = timeplt ( jd, u, [istack], [ylims] );
%
%      where
%         jd = Julian Day time vector  (e.g produced by JULIAN.M)
%         u = column vector or matrix of column vectors containing time
%             series data.  If the column is complex, it will be plotted
%             as a stick plot.  
%         istack = vector of indices indicating which panel you want
%             to plot the time series data.  istack=[1 2] would make
%             two panels one on top of the other and plot the first 
%             column of u in the lower panel and the second column of
%             u in the upper panel.  If any column in u is complex,  
%             istack must be specified.  If istack is not specified, all the 
%             columns will be plotted in the first panel.
%         ylims  = [npanels x 2] matrix containing the ylimits of 
%              the panel plots.  If you are plotting two panels and 
%              you want the limits of both plots to be from -10 to 15,
%              then set ylims=[-10 15; -10 15].  Autoscales if ylims
%              is not set
%

%
% directory of data structure fields
%
% [year|month|day|hour|minute]_cut
%    Set the cutoff for different types of Gregorian axis types
%    You can adjust these to suit your preferences.  For example, 
%    if your plot got labeled with days, but you want hours, 
%    run timeplt again with hour_cut specified.
%
% [year|month|day|hour|minute]_cut_flag
%    If any of these are true, then the plot follows that convention.
%
% figure:
%    handle for the time plot figure window
% jd:
%    julian time vector for the given plots
% data:
%    stuff to be plotted vs time
% plot_axes:
%    vector of axes handles.  They correspond to what's in "istack".
%    If istack was not specified, then there is just one axes.  Same
%    as output h above.
% istack:
%    Same as above.
% ylims:
%    Same as above.
%    
  

global timeplt_obj timeplt_count;

%
% keep track of how many timeplt objects are active.
if ( size(timeplt_count,1) > 0 )
    timeplt_count = timeplt_count + 1;
else
    timeplt_count = 1;
end

N = timeplt_count;


%
% Store default values.
timeplt_obj{N}.year_cut=250;
timeplt_obj{N}.month_cut=20;
timeplt_obj{N}.day_cut=.2;
timeplt_obj{N}.hour_cut=.02;
timeplt_obj{N}.minute_cut=0.005;

timeplt_obj{N}.year_cut_specified = 0;
timeplt_obj{N}.month_cut_specified = 0;
timeplt_obj{N}.day_cut_specified = 0;
timeplt_obj{N}.hour_cut_specified = 0;
timeplt_obj{N}.minute_cut_specified = 0;

timeplt_obj{N}.plot_axes = [];
timeplt_obj{N}.ylims = [];


%
% Store a reference to the figure window.
% If there are any open figures, use it.
timeplt_obj{N}.figure = timeplt_figure(gcf, N);


%
% Catch resize events in the figure, and don't clip the data!
set ( timeplt_obj{N}.figure, ...
        'ResizeFcn', 'timeplt_draw', ...
        'DefaultLineClipping', 'off' );



%
% Parse the command line args.
if ( nargin == 0 )
    
    disp ( 'No arguments specified.' );
    help timeplt;
    delete ( timeplt_obj{N}.figure );
    return;

end

if ( nargin == 1 ) 

    if ( strcmp(arg1, 'demo') )

        start=[1990 11 1 0 0 0];    %Gregorian start [yyyy mm dd hh mi sc]
        stop=[1991 2 1 0 0 0];
        jd=julian(start):julian(stop); 
        u=sin(.1*jd(:)).^2-.5;
        v=cos(.1*jd(:));
    
        %
        %w is vector, so must have it's own axes
        w=u+i*v;
    
        timeplt_obj{N}.jd = jd;
        timeplt_obj{N}.data = [u v abs(w) w];
        timeplt_obj{N}.istack = [1 1 2 3];

        timeplt_draw;

        h = timeplt_obj{N}.plot_axes;
    
        axes ( h(3) );
        title('Demo of Timeplt')
        stacklbl( h(1), 'East + North velocity','m/s');
        stacklbl( h(2), 'Speed','m/s');
        stacklbl( h(3), 'Velocity Sticks','m/s');

        set ( h, 'Box', 'on' );

        return;

    else
        disp ( sprintf ( 'Huh?  I don''t recognize %s.', arg1 ) );
        help timeplt;
        return;
    end
    

%
% Not a demo, must process the command line arguments.
else
    
    
    
    %
    % process the first two arguments.
    timeplt_obj{N}.jd = arg1(:);
    data = arg2;
    
    %
    % make sure the data is columar
    [r,c] = size(data);
    if ( r < c )
        data = data';
    end
    timeplt_obj{N}.data = data;
    
    
    
    
    
    if ( nargin == 2 )
    
        timeplt_obj{N}.istack = ones(size(timeplt_obj{N}.data,2),1);
        timeplt_obj{N}.ylims = [];
    
    elseif ( nargin == 3 )
    
        timeplt_obj{N}.ylims = [];
        timeplt_obj{N}.istack = arg3;
    
    
    elseif ( nargin == 4 )
    
        timeplt_obj{N}.istack = arg3;
        timeplt_obj{N}.ylims = arg4;
    
    end

end


timeplt_draw; 

h = timeplt_obj{N}.plot_axes; 

set ( h, 'Box', 'on' );


%
% Store the ylims so that any plot window resizes
% keep the same ylims.
ylims = [];
for i = 1:length(h)
    ylims = [ylims; get(h(i),'YLim')];
end
timeplt_obj{N}.ylims = ylims;

return;

    
