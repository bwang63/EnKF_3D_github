function timeplt_gregax_year( jd )
%TIMEPLT_GREGAX_DAY:  Writes gregorian axes tick labels


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
start = [start(1) 1  1 0 0 0];
jd0 = julian(start);
stop = gregorian(jd1);


%
% We need to know how many labels to write.
% Assume that we want a maximum of 50 pts between labels.
max_width = 40;
point_width = pos(3);  
dx = diff(xlim);
scale_factor = dx/point_width;  % points per number of days

year_tic = ceil ( max_width * scale_factor / 365.24 );

%year_tic = ceil(max(diff(xt(:)/365.24)));


gyears = start;
last_gyear = start; 
last_jyear = julian(start);
while ( last_jyear <= jd1 )
	last_gyear(1) = last_gyear(1) + year_tic;
	last_jyear = julian(last_gyear);
	gyears = [gyears; last_gyear];
end

xt = julian(gyears);

ifind = find((xt>=xlim(1)) & (xt<=xlim(2)));
xt = xt(ifind);
set ( gca, ...
		'XTick', xt, ...
		'XTickLabel', [] );

greg = gregorian(xt);

year_labels = num2str(greg(:,1));
set ( gca, 'XTickLabel', year_labels );


