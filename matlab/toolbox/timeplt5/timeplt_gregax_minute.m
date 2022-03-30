function timeplt_gregax_minute( jd )
%TIMEPLT_GREGAX_MINUTE:  Writes gregorian axes tick labels

month_label = [	'Jan'; ...
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
% Fontsize shouldn't be too large.
fsize = get ( get(gca,'YLabel'), 'Fontsize' );
%fsize = min ( height / 4, 12 );


%
% Now figure the height of the bottom plot in user coords.
ylim = get ( gca, 'YLim' );
cfactor = diff(ylim) / pos(4);


xt = get ( gca, 'XTick' );
greg = gregorian ( xt(:) );

xlim = get(gca,'xlim');


%
% Make sure that the minute ticks start right on the minute,
% and not in the middle.
% Stop the ticks somewhere around the end of xlim.  Don't really
% care so much about this.
jd0 = nanmin(jd); jd1 = xlim(2);
start = gregorian(jd0);
start = [start(1:5) 0];
jd0 = julian(start);
stop = gregorian(jd1);


%
% We need to know how many labels to write.
% Assume that we want a maximum of 50 pts between labels.
max_width = 40;
point_width = pos(3);  
dx = diff(xlim);
scale_factor = dx/point_width;  % points per number of days

min_tic = max_width * scale_factor;

%
% Now round this up to the nearest minute.
min_tic = ceil ( min_tic * 24 * 60 ) / 24 / 60;

%min_tic = ceil(max(diff(xt(:)))*24*60)/(24*60);




xt = [jd0:min_tic:jd1];

ifind = find((xt>=xlim(1)) & (xt<=xlim(2)));
xt = xt(ifind);
set ( gca, ...
		'XTick', xt, ...
		'XTickLabel', [] );

greg = gregorian(xt);



%
% Now label the xticks in days.
year_str = num2str(greg(1,1));
day_str = sprintf ( '%s %2.0i', month_label(greg(1,2),:), greg(1,3) ); 
min_str = sprintf ( '%.0f:%02i', greg(1,4), greg(1,5) );
gt_string = { min_str; day_str; year_str };

ypoint = ylim(1) - 0.5*fsize*cfactor;
xt_label(1) = text ( xt(1), ypoint, 0, gt_string );


%
% Keep track of where to put a label for a new month or year
% by differencing the gregorian dates.  Any entry that is not zero
% means that the entry changed from the previous.
tdiff = diff(greg(:,1:5));

for i = 2:length(xt)

	if ( tdiff(i-1,1)  )
		year_str = num2str(greg(i,1));
	else
		year_str = '';
	end

	if ( tdiff(i-1,3)  )
		day_str = sprintf ( '%s %2.0i', month_label(greg(i,2),:), greg(i,3) ); 
	else
		day_str = '';
	end

	if ( tdiff(i-1,5) )
		min_str = sprintf ( '%.0f:%02i', greg(i,4), greg(i,5) );
	else
		min_str = '';
	end

	gt_string = { min_str; day_str; year_str };

	xt_label(i) = text ( xt(i), ypoint, 0, gt_string );

		
end


set ( xt_label, ...
		'Fontsize', round(fsize), ...
		'HorizontalAlignment', 'Center', ...
		'VerticalAlignment', 'cap', ...
		'Tag', 'xtick labels' );





