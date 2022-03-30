function select(m)
%
% SELECT  Part of the DODS data browser (browse.m)
%
% SELECT  controls the graphic (mouse) range selection function.
%
%
%            Deirdre Byrne, The Island Institute, 7 April 1997
%                 dbyrne@islandinstitute.org
%
%

% The preceding empty line is important.
%
% $Id: select.m,v 1.2 2000/11/20 19:04:11 dbyrne Exp $

% $Log: select.m,v $
% Revision 1.2  2000/11/20 19:04:11  dbyrne
%
%
% Changes to remove support for Matlab v4 and add support for Folders.
% -- dbyrne 00/11/20
%
% Revision 1.2  2000/11/20 16:11:17  root
% Changes and addition for Folders Edition.  -- dbyrne 00/11/20
%
% Revision 1.1  2000/05/31 22:57:20  root
% *** empty log message ***
%
% Revision 1.13  2000/03/16 03:28:22  dbyrne
%
%
% Modified windobuttonupfcn to remove stale '1' value.  Removed unused argout.
% dbyrne 00/03/14
%
% Revision 1.12  1999/10/27 21:23:11  dbyrne
%
% Changed minmax to mminmax to avoid conflict with a script in nnet toolbox.
%
% Revision 1.3  1999/10/27 21:14:09  root
% Changed minmax to mminmax to avoid conflict with a script in nnet toolbox.
%
% Revision 1.2  1999/09/02 18:12:23  root
% *** empty log message ***
%
% Revision 1.11  1999/07/20 15:04:05  dbyrne
%
%
% Finished modifications to make dataset selection a modal operation.
% -- dbyrne 99/07/20
%
% Revision 1.10  1999/05/13 03:09:53  dbyrne
%
%
% Added Acknowledge and Data_Use_Policy to archive.m.  Fixed getxxx functions
% to use dodsmsg instead of stdout for errors/info.  Made ChangeLog so that it's
% in Emacs format.  All changes for release 3.0.0 -- dbyrne 99/05/12
%
% Revision 1.1  1998/05/17 14:10:52  dbyrne
% *** empty log message ***
%
% Revision 1.3  1997/12/09 00:40:24  dbyrne
% Changed to permit colored boxes on scroll menus.
%
% Revision 1.2  1997/09/25 19:32:21  tom
% Fixed so that datasets menu does not reset after selecting
% the data range.
%
% Revision 1.1.1.1  1997/09/22 14:13:53  tom
% Imported Matlab GUI sources to CVS
%

% note: global vars must be re-initialized *every* time a function is called
global browse_fig AXES ranges range_boxes gui_buttons num_rang
global master_georange zrange timerange lyr range_day 
global dset

if ~isstr(m)
  if m == 1
    figure(browse_fig)
    set(browse_fig,'windowbuttondownfcn','select(''down'')', ...
	'windowbuttonupfcn','', ...
	'interruptible', 'on')
    return
  else
    set(browse_fig,'windowbuttondownfcn','','windowbuttonupfcn','')
    return
  end
else  % we are choosing stations  
  m = lower(m);
  if strcmp(m,'down'),
    axs = get(gcf,'Children'); % look for figure axes
    valid = 0;
    for i=1:length(axs),
      if strcmp(get(axs(i),'Type'),'axes'),
	pt1 = get(axs(i),'CurrentPoint');
	xlim = get(axs(i),'XLim');
	ylim = get(axs(i),'YLim');
	if (xlim(1) <= pt1(1,1) & pt1(1,1) <= xlim(2) & ...
	      ylim(1) <= pt1(1,2) & pt1(1,2) <= ylim(2))
	  valid = 1;
	  % cleverly change to axis in which pointer is found,
	  % allowing Select for multiple plots on one fig
	  set(gcf,'CurrentAxes',axs(i)); 
	  break
	end
      end
    end
    
    if ~valid; return; end
    pt1 = get(gca,'currentpoint');
    pt2 = pt1;
    c = computer;
    if strcmp(c(1:2),'MA') % allow for Macintosh-type mouse events
      rb0 = get(gcf,'currentpoint');
      rbbox([rb0 0 0],get(gcf,'currentpoint'))
      w = 1;
      while w
        w = waitforbuttonpress;
        rbbox([rb0 0 0],get(gcf,'currentpoint'))
      end
    else
      % this is the key little line:
      rbbox([get(gcf,'currentpoint') 0 0],get(gcf,'currentpoint'))
    end
    pt2 = get(gca,'currentpoint');
    pt1 = pt1(1,1:2);
    pt2 = pt2(1,1:2);
    xmin = min([pt1(1,1) pt2(1,1)]); ymin = min([pt1(1,2) pt2(1,2)]);
    xmax = max([pt1(1,1) pt2(1,1)]); ymax = max([pt1(1,2) pt2(1,2)]);
    if gca == AXES(1), 
      xmin = max(master_georange(1),xmin);
      xmax = min(master_georange(2),xmax);
      ymin = max(master_georange(3),ymin);
      ymax = min(master_georange(4),ymax);
      ranges(2,:) = [ymin ymax];
      if master_georange(1) == 0
	if all([xmin xmax] >= 0) & all([xmin xmax] <= 180);
	  ranges(1,:) = [xmin xmax];
	elseif all([xmin xmax] >= 180)
	  ranges(1,:) = [xmin xmax] - 360;
	elseif all(mminmax([xmin xmax]) == [0 360])
	  ranges(1,:) = [-180 180];
	elseif (xmax > 180) & (xmin <= 180)
	  ranges(1,:) = [xmin xmax-360];
	else
	  ranges(1,:) = [xmax xmin-360];
	end
      else
	ranges(1,:) = [xmin xmax];
      end
      set(range_boxes(1),'xdata',[xmin xmax xmax xmax xmax xmin xmin xmin], ...
	  'ydata', [ranges(2,1) ranges(2,1), ranges(2,1), ranges(2,2) ...
	      ranges(2,2) ranges(2,2), ranges(2,2), ranges(2,1)], ...
	  'visible','on')
      num_rang(1:4) = [1 1 1 1]';
      set(gui_buttons(8),'String',sprintf('%.3f',xmin))
      set(gui_buttons(9),'String',sprintf('%.3f',xmax))
      set(gui_buttons(10),'String',sprintf('%.3f',ranges(2,1)))
      set(gui_buttons(11),'String',sprintf('%.3f',ranges(2,2)))
      % reset other window
      if isnan(dset)
        dscrolllist('datset','full')
      else
        dscrolllist('datset','sub')
      end
      browse('gsetrange');
      return
    elseif gca == AXES(2)
      ymin = max(zrange(1),ymin);
      ymax = min(zrange(2),ymax);
      ranges(3,:) = [ymin ymax];
      num_rang(5:6) = [1 1]';
      xl = [0.01 0.99];
      set(range_boxes(2),'xdata',[xl(1:2) xl(2) xl(2) xl(2) xl(1) xl(1) xl(1)], ...
	  'ydata', [ranges(3,1) ranges(3,1) ranges(3,1) ranges(3,2) ...
	      ranges(3,2) ranges(3,2) ranges(3,2) ranges(3,1)], ...
	  'visible','on')
      set(gui_buttons(12),'String',sprintf('%.2f',ranges(3,2)))
      set(gui_buttons(13),'String',sprintf('%.2f',ranges(3,1)))
      % reset other window
      if isnan(dset)
	dscrolllist('datset','full')
      else
	dscrolllist('datset','sub')
      end
      browse('gsetrange');
      return
    elseif gca == AXES(3)
      xmin = max(timerange(1),xmin);
      xmax = min(timerange(2),xmax);
      ranges(4,:) = [xmin xmax];
      num_rang(7:8) = [1 1]';

      set(gui_buttons(14),'String',sprintf('%.5f',ranges(4,1)))
      lmo = [31 28 31 30 31 30 31 31 30 31 30 31];
      if rem(floor(ranges(4,1)),4) == 0
	if floor(ranges(4,1)) == 1900 	% 1900 was apparently not a leap year!
	  lyr = 365;
	else
	  lyr = 366;
	  lmo(2) = 29;
	end
      else
	lyr = 365;
      end
      range_day = floor((ranges(4,1)-floor(ranges(4,1)))*lyr(1))+1; % day of year

      t = min(find(range_day < cumsum(lmo)));
      if isempty(t)
	t = 12;
      end
      % day
      t(2) = range_day(1) - sum(lmo(1:t(1)-1));
      % hr
      t(3) = floor((((ranges(4,1)-floor(ranges(4,1)))*lyr(1)+1)-range_day(1))*24);
      % min
      t(4) = floor(((((ranges(4,1)-floor(ranges(4,1)))*lyr(1)+1)*24 - ...
	  range_day(1)*24)-t(3))*60);
      % sec
      t(5) = floor(((((ranges(4,1)-floor(ranges(4,1)))*lyr(1)+1)*24*60 - ...
	  range_day(1)*24*60)-t(3)*60)*60-t(4)*60);
      for i = 1:5;
	set(gui_buttons(39+i),'string',sprintf('%i',t(i)))
      end
      
      set(gui_buttons(15),'String',sprintf('%.5f',ranges(4,2)))
      lmo = [31 28 31 30 31 30 31 31 30 31 30 31];
      if rem(floor(ranges(4,2)),4) == 0
	if floor(ranges(4,2)) == 1900 	% 1900 was apparently not a leap year!
	  lyr(2) = 365;
	else
	  lyr(2) = 366;
	  lmo(2) = 29;
	end
      else
	lyr(2) = 365;
      end
      range_day(2) = floor((ranges(4,2)-floor(ranges(4,2)))*lyr(2))+1; % day of year
      t = min(find(range_day(2) < cumsum(lmo)));
      if isempty(t)
	t = 12;
      end
      % day
      t(2) = range_day(2) - sum(lmo(1:t(1)-1));
      % hr
      t(3) = floor((((ranges(4,2)-floor(ranges(4,2)))*lyr(2)+1)-range_day(2))*24);
      % min
      t(4) = floor(((((ranges(4,2)-floor(ranges(4,2)))*lyr(2)+1)*24 - ...
	  range_day(2)*24)-t(3))*60);
      % sec
      t(5) = floor(((((ranges(4,2)-floor(ranges(4,2)))*lyr(2)+1)*24*60 - ...
	  range_day(2)*24*60)-t(3)*60)*60-t(4)*60);
      for i = 1:5;
	set(gui_buttons(44+i),'string',sprintf('%i',t(i)))
      end
      
      yl = [0.01 0.99];
      set(range_boxes(3),'xdata', [ranges(4,1:2) ranges(4,2) ranges(4,2) ...
	      ranges(4,2) ranges(4,1) ranges(4,1) ranges(4,1)], ...
	  'ydata', [yl(1) yl(1) yl(1) yl(2) yl(2) yl(2) yl(2) yl(1)], ...
	  'visible','on')
      % reset other window
      if isnan(dset)
	dscrolllist('datset','full')
      else
	dscrolllist('datset','sub')
      end
      browse('gsetrange');
      return
    end
  end
end
