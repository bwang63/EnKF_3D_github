%GREGAXIS Convert numeric XTickLabels to date strings.
%	GREGAXIS gets the x-axis tick values from the current axis
%	and converts them to date strings of the form "Jan 1 ",
%	"Feb 27", ...  The value 1 maps to "Jan 1 ", and the
%	value 365 maps to "Dec 31".  Labels for values outside
%	this range are blank.
%
%	Limitations:  GREGAXIS doesn't know about leap year.
%	GREGAXIS only knows how to label days with respect to the
%	first day of the year; it can't label days with respect
%	to some absolute date.
%
%	Example:
%	  plot(1:10:365, 1:10:365)
%	  gregor



months = [1 cumsum([31 28 31 30 31 30 31 31 30 31 30 31])+1]';
monthsTable = [months (1:13)'];
monthStr = ['Jan'
    'Feb'
    'Mar'
    'Apr'
    'May'
    'Jun'
    'Jul'
    'Aug'
    'Sep'
    'Oct'
    'Nov'
    'Dec'];

ticks = get(gca, 'XTick');
ticks=rem(ticks,365);
newTickLabels = zeros(length(ticks), 6);
for k = 1:length(ticks)
  if ((ticks(k) > 0) & (ticks(k) < 366))
    month = floor(table1(monthsTable, ticks(k)));
    day = ticks(k) - months(month) + 1;
    newTickLabels(k,:) = sprintf('%s %-2d', monthStr(month,:), day);
  else
    newTickLables(k,:) = '      ';
  end
end
set(gca, 'XTickLabels', newTickLabels);
