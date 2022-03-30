function plotfunction(display_choices, display_data)

% delete stale image handles from browse window
browse('checkplots')

% do some sanity checks
if nargin < 2
  return
end

if any(size(display_choices) == 0) | any(size(display_data) == 0)
  return
end

% to plot, we will need these pieces of information from the browser
georange = browse('getvar','master_georange');
browse_fig = browse('getvar', 'browse_fig');
palette = browse('getvar', 'avhrrpal');
% depthname = % <-- this should be incorporated into DATABASE!

display_choices = display_choices(:);
num_plots = size(display_choices,1);
numnewplots = 0;
fignos = [];

% construct plot arguments
for j = 1:num_plots
  plotstring = '';
  dodserr = 0;
  % choose a plot function based on plot_type
  if strcmp(display_choices(j).plot_type,'plot')
    [figno, dodserr, dodserrmsg] = browseplot1('plot', display_choices(j), ...
	display_data, georange, browse_fig);
  elseif strcmp(display_choices(j).plot_type,'imagesc')
    [figno, dodserr, dodserrmsg] = browseplot2('plot', display_choices(j), ...
	display_data, georange, browse_fig, palette);
  elseif strcmp(display_choices(j).plot_type,'contour') | ...
	strcmp(display_choices(j).plot_type,'contourf')
    [figno, dodserr, dodserrmsg] = browseplot3('plot', display_choices(j), ...
	display_data, georange, browse_fig);
  elseif strcmp(display_choices(j).plot_type, 'pcolor')
    [figno, dodserr, dodserrmsg] = browseplot5('plot', display_choices(j), ...
	display_data, georange, browse_fig, palette);
  elseif strcmp(display_choices(j).plot_type, 'quiver')
    [figno, dodserr, dodserrmsg] = browseplot6('plot', display_choices(j), ...
	display_data, georange, browse_fig);
  elseif strcmp(display_choices(j).plot_type, 'polar')
    [figno, dodserr, dodserrmsg] = browseplot7('plot', display_choices(j), ...
	display_data, georange, browse_fig);
  end

  errquit = 0;
  if dodserr
    str = sprintf('Error in plot number %i:', j);
    str = sprintf('%s\n\n', str, dodserrmsg, ...
	'Quit plotting sequence?');
    quitnow = dodsquestdlg(str, 'DODS ERROR', ...
	'Yes', 'No (resume plotting)', 'Yes', zeros(2,3));
    if strcmp(quitnow(1:2),'Ye')
      errquit = 1;
    else
      errquit = 0;
    end
  else
    if strcmp(display_choices(j).figure, 'browse_fig')
      numnewplots = numnewplots+1;
    end
  end

  % if user wanted to quit due to error, DO SO NOW
  if errquit
    break
  end

  % collect list of new figures
  fignos = [figno, fignos];
end % end of loop through the URLs

% refresh the plot queue
drawnow

% reveal the figure(s)
set(fignos, 'vis', 'on')

if numnewplots > 0
  browse('newboxes'); % this redraws world map and selection
  % ranges; it also makes the first plot in the list visible
  % add new plots to stack
  browse('moreon', numnewplots)
end
