function timeplt_gregax_hour( jd )
%TIMEPLT_GREGAX_HOUR:  Writes gregorian axes tick labels

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
% Fontsize should be the same as the ylabel.
fsize = get ( get(gca,'YLabel'), 'Fontsize' );

%
% Fontsize shouldn't be too large.
%fsize = min ( height / 4, 12 );


%
% Now figure the height of the bottom plot in user coords.
ylim = get ( gca, 'YLim' );
cfactor = diff(ylim) / pos(4);


xt = get ( gca, 'XTick' );
greg = gregorian ( xt(:) );

xlim = get(gca,'xlim');


%
% Make sure that the hour ticks start right on the hour,
% and not in the middle.
% Stop the ticks somewhere around the end of xlim.  Don't really
% care so much about this.
% Also, the first tick starts where the data starts.
jd0 = nanmin(jd); jd1 = xlim(2);
start = gregorian(jd0);
start = [start(1:4) 0 0];
jd0 = julian(start);
stop = gregorian(jd1);


%
% We need to know how many labels to write.
% Assume that we want a maximum of 50 pts between labels.
max_width = 40;
point_width = pos(3);  
dx = diff(xlim);
scale_factor = dx/point_width;  % points per number of days

hour_tic = max_width * scale_factor;

%
% Now round this up to the nearest minute.
hour_tic = ceil ( hour_tic * 24 ) / 24;

%hour_tic = ceil(max(diff(xt(:)))*24)/24;


xt = [jd0:hour_tic:jd1];

ifind = find((xt>xlim(1)) & (xt<xlim(2)));
xt = xt(ifind);
set ( gca, ...
		'XTick', xt, ...
		'XTickLabel', [] );

greg = gregorian(xt);



%
% Now label the xticks in days.
hour_str = sprintf ( '%02i:00', greg(1,4) );
day_str = sprintf ( '%s %2.0f', month_label(greg(1,2),:), greg(1,3) );
year_str = num2str(greg(1,1));
gt_string = { hour_str; day_str; year_str };

ypoint = ylim(1) - 0.5*fsize*cfactor;
xt_label(1) = text ( xt(1), ypoint, 0, gt_string );


%
% Keep track of where to put a label for a new month or year
% by differencing the gregorian dates.  Any entry that is not zero
% means that the entry changed from the previous.
tdiff = diff(greg(:,1:4));

for i = 2:length(xt)

	if ( tdiff(i-1,4)  )
		hour_str = sprintf ( '%02i:00', greg(i,4) );
	else
		hour_str = '';
	end

	if ( tdiff(i-1,3)  )
		day_str = sprintf ( '%s %2.0f', month_label(greg(i,2),:), greg(i,3) );
	else
		day_str = '';
	end

	if ( tdiff(i-1,3) )
		year_str = num2str(greg(i,1));
	else
		year_str = '';
	end

	gt_string = { hour_str; day_str; year_str };

	xt_label(i) = text ( xt(i), ypoint, 0, gt_string );

		
end


set ( xt_label, ...
		'Fontsize', fsize, ...
		'HorizontalAlignment', 'Center', ...
		'VerticalAlignment', 'cap' );





