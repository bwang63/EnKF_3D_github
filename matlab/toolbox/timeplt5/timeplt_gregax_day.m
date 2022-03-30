function timeplt_gregax_day( jd )
%TIMEPLT_GREGAX_DAY:  Writes gregorian axes tick labels

%disp ( 'present in timeplt_gregax_day' );

month_label = [    'Jan'; ...
                'Feb';...
                'Mar';...
                'Apr';...
                'May';...
                'Jun';...
                'Jul';...
                'Aug';...
                'Sep';...
                'Oct';...
                'Nov';...
                'Dec'];

%
% First figure out the height of the bottom plot in points.
% Then allow for 3 lines to fit here.
old_units = get ( gca, 'Units' );
set ( gca, 'Units', 'Points' );
pos = get(gca, 'Position' );
set ( gca, 'Units', old_units )
height = pos(2);

%
% Fontsize should be the same as the ylabel.
fsize = get ( get(gca,'YLabel'), 'Fontsize' );


%
% Now figure the height of the bottom plot in user coords.
ylim = get ( gca, 'YLim' );
cfactor = diff(ylim) / pos(4);


xt = get ( gca, 'XTick' );
greg = gregorian ( xt(:) );

xlim = get(gca,'xlim');


%
% Make sure that the minute ticks start right on the day,
% and not in the middle.
% Stop the ticks somewhere around the end of xlim.  Don't really
% care so much about this.
jd0 = nanmin(jd); jd1 = xlim(2);
start = gregorian(jd0);
start = [start(1:3) 0 0 0];
jd0 = julian(start);
stop = gregorian(jd1);


%
% We need to know how many labels to write.
% Assume that we want a maximum of 50 pts between labels.
max_width = 40;
point_width = pos(3);  
dx = diff(xlim);
scale_factor = dx/point_width;  % number of days per point

day_tic = max ( max_width*scale_factor, 1 );

%
% round this up to the nearest day.
day_tic = ceil(day_tic);

%
% do some more refinement to get good day splits
if ( (day_tic >= 4) & (day_tic <6) )
    day_tic = 5;
elseif ( (day_tic >= 6) & (day_tic <8.5) )
    day_tic = 7;
elseif ( (day_tic >= 8.5) & (day_tic <12) )
    day_tic = 10;
elseif ( (day_tic >= 12) & (day_tic <16) )
    day_tic = 14;
end

xt = [jd0:day_tic:jd1];

ifind = find((xt>=xlim(1)) & (xt<=xlim(2)));
xt = xt(ifind);
set ( gca, ...
        'XTick', xt, ...
        'XTickLabel', [] );

greg = gregorian(xt);





%
% Now label the xticks in days.
gt_string = {     num2str(greg(1,3)); ...
                month_label(greg(1,2),:); ...
                num2str(greg(1,1)) };

ypoint = ylim(1) - 0.5*fsize*cfactor;
xt_label(1) = text ( xt(1), ypoint, 0, gt_string );


%
% Keep track of where to put a label for a new month or year
% by differencing the gregorian dates.  Any entry that is not zero
% means that the entry changed from the previous.
tdiff = diff(greg(:,1:3));

for i = 2:length(xt)

    if ( tdiff(i-1,1)  )
        year_str = num2str(greg(i,1));
    else
        year_str = '';
    end

    if ( tdiff(i-1,2)  )
        month_str = month_label(greg(i,2),:);
    else
        month_str = '';
    end

    if ( tdiff(i-1,3) )
        day_str = num2str(greg(i,3));
    else
        day_str = '';
    end

    gt_string = { day_str; month_str; year_str };

    xt_label(i) = text ( xt(i), ypoint, 0, gt_string );

        
end


set ( xt_label, ...
        'Fontsize', fsize, ...
        'HorizontalAlignment', 'Center', ...
        'VerticalAlignment', 'cap' );





