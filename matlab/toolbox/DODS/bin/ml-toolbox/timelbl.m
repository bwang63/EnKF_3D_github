function [thandle, lhandle] = timelbl(tl, timetoggle, thandle, ...
    lhandle, tstring, AXES, dods_colors, fontsize)
%
% TIMELBL    Part of the DODS data browser (browse.m) 
%
% TIMELBL    handles creation and placement of the yearday and year, 
%            (or day month and year), hours and minutes that appear 
%            on the time axis when zoomed in.
%
%
%            Deirdre Byrne, The Island Institute, 7 April 1997
%                 dbyrne@islandinstitute.org
%

% The preceding empty line is important.
%
% $Id: timelbl.m,v 1.2 2000/11/20 19:04:11 dbyrne Exp $

% $Log: timelbl.m,v $
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
% Revision 1.2  1999/09/02 18:12:23  root
% *** empty log message ***
%
% Revision 1.8  1999/05/13 03:09:54  dbyrne
%
%
% Added Acknowledge and Data_Use_Policy to archive.m.  Fixed getxxx functions
% to use dodsmsg instead of stdout for errors/info.  Made ChangeLog so that it's
% in Emacs format.  All changes for release 3.0.0 -- dbyrne 99/05/12
%
% Revision 1.1  1998/05/17 14:10:53  dbyrne
% *** empty log message ***
%
% Revision 1.1.1.1  1997/09/22 14:13:54  tom
% Imported Matlab GUI sources to CVS
%

%global thandle lhandle tstring AXES dods_colors fontsize
xtc = 'xticklabel';
ytc = 'yticklabel';

% clear old labels
if ~isempty(thandle), delete(thandle); thandle = []; end
if ~isempty(lhandle), delete(lhandle); lhandle = []; end
% set up some basic parameters
tl = tl(1:2);
yl = [0 1]; ypos = 0.5;
zoomlyr = 365 + isleap(floor(tl(1)));
dt = diff(tl);
zoomday = floor((tl(1)-floor(tl(1)))*zoomlyr)+1; 	% day of year
hr = floor(tl(1)*zoomlyr*24); 		% that's my start time (in hours);
h0 = round(24*(hr/24 - floor(hr/24))); 	% what hour of the day
daypos = [0:(zoomlyr-1)]./zoomlyr + floor(tl(1));  % day positions
lmo = [31 28+isleap(floor(tl(1))) 31 30 31 30 31 31 30 31 30 31];
mopos = cumsum([0 lmo(1:11)])./zoomlyr + floor(tl(1));
molim = [floor((tl(1)-floor(tl(1)))*zoomlyr) ...
	ceil((tl(2)-floor(tl(2)))*zoomlyr)];
molim = [max(find(cumsum([0 lmo(1:11)]) <= molim(1))) ...
	max(find(cumsum([0 lmo(1:11)]) <= molim(2)))];

if timetoggle
  molabs = (['JFMAMJJASOND';'AEAPAUUUECOE';'NBRRYNLGPTVC']');
  daylabs = '';
  for i = 1:12
    x = sprintf('%2i',1:lmo(i)); x = (reshape(x,2,lmo(i)))';
    daylabs = [daylabs; x];
  end
  % write date to blue label
  xlab = [daylabs(zoomday,:) ' ' molabs(molim(1),:) sprintf(' %4i',floor(tl(1)))];
else
  molabs = sprintf('%3i',cumsum([1 lmo(1:11)])); 
  molabs = (reshape(molabs,3,12))';
  daylabs = sprintf('%3i',[1:zoomlyr]); daylabs = (reshape(daylabs,3,zoomlyr))';
  % write date to blue label
  xlab = [daylabs(zoomday,:) ' ' sprintf(' %4i',floor(tl(1)))];
end
molabs = [molabs; molabs]; mopos = [mopos mopos+1];

% categories of time axis interval
if dt <= 0.00055 			% less than 35 mins to 6h, show m & h
  if (dt < 0.00007)
    mint = 5;
  elseif (0.00007 < dt) & (dt <= 0.00055)
    mint = 10;
  end
  % blue day lines 
  if zoomday > 360
    daypos = [daypos daypos(1:2)+1]; daylabs = [daylabs; daylabs(1:2,:)];
  end
  daypos = daypos(zoomday:zoomday+2); daylabs = daylabs(zoomday:zoomday+2,:);
  l = length(daypos); x = [];
  if timetoggle
    for i = 1:l,
      j = max(find(round(daypos(i)*zoomlyr*24) >= round(mopos(molim)*zoomlyr*24)));
      x = [x; ' ' molabs(molim(j),:) sprintf(' %4i',floor(daypos(i)))];
    end
  else
    for i = 1:l,
      x = [x; sprintf(' %4i',floor(daypos(i)))];
    end
  end
  daylabs = [daylabs, x];
  x = daypos(:)*ones(1,2); y = ones(l,1)*[ypos yl(2)];
  lhandle = line(x',y','color',dods_colors(8,:),'erasemode','none', 'clipping','on');
  for i = 1:l,
    thandle(i) = text(daypos(i), ...
	yl(1), daylabs(i,:),'units','data', ...
	'color',dods_colors(8,:), ...
	'horiz','center','vert','bottom', ...
	'fontsize', fontsize, ...
	'clipping','on');
  end
  % now do hrs
  hrs = [h0:23 0:h0]; ll = length(hrs);
  hrpos = [hr:(hr+ll-1)]./(zoomlyr*24);
  hrlabs = sprintf('%2i', hrs); ll = length(hrlabs)/2;
  hrlabs = (reshape(hrlabs,2,ll))';
  j = l+1;
  for i = 1:ll,
    if (hrpos(i) > tl(1)) & (hrpos(i) < tl(2))
      thandle(j) = text(hrpos(i), ...
	  yl(1)-0.1, hrlabs(i,:),'units','data', ...
	  'color',dods_colors(8,:), ...
	  'horiz','center','vert','top', ...
	  'fontsize', fontsize, ...
	  'clipping','off');
      j = j+1;
    end
  end
       
  % add in minutes
  l = length(hrpos);
  minpos = []; minlabs = '';
  x = sprintf('%2i',0:mint:59);
  x = (reshape(x,2,floor(60/mint)))';
  x(1,:) = '  ';
  for i = 1:l,
    minpos = [minpos (0:mint:59)/(zoomlyr*24*60)+hrpos(i)];
    minlabs = [minlabs; x]; 
  end
  % chop to avoid bug in v5
  i = min(find(daypos >= tl(1))); l = length(daypos);
  daypos = daypos(i:l); daylabs = daylabs(i:l,:);
  i = min(find(hrpos >= tl(1))); l = length(hrpos);
  hrpos = hrpos(i:l); hrlabs = hrlabs(i:l,:);
  i = min(find(minpos >= tl(1))); l = length(minpos);
  minpos = minpos(i:l); minlabs = minlabs(i:l,:);
  % plot
  set(AXES(3),'xtick',minpos,xtc,minlabs)
  set(tstring(1),'string','Time in Minutes','color',dods_colors(3,:))
  set(tstring(2),'string',xlab,'color',dods_colors(8,:))
elseif (0.00055 < dt) & (dt <= 0.003) 	% 6h to 35h, show h & d
  hrs = [h0:23 0:23 0:23]; l = length(hrs);
  hrpos = [hr:(hr+l-1)]./(zoomlyr*24);
  % wraparound
  if zoomday > 360
    daypos = [daypos daypos(1:2)+1]; daylabs = [daylabs; daylabs(1:2,:)];
  end
  daypos = daypos(zoomday:zoomday+2); daylabs = daylabs(zoomday:zoomday+2,:);
  hrlabs = sprintf('%2i', h0:23); l = length(hrlabs)/2;
  hrlabs = (reshape(hrlabs,2,l))';
  x = sprintf('%2i',0:23); x = (reshape(x,2,24))';
  x(1,:) = '  ';
  hrlabs = [hrlabs; x; x];
  
  % month lines
  mopos = mopos(1:13); molabs = molabs(1:13,:);
  m = length(mopos); x = [];
  for i = 1:m, x = [x, sprintf(' %4i',floor(mopos(i)))]; end
  x = reshape(x,5,m)';
  molabs = [molabs, x];
  x = mopos(:)*ones(1,2); y = ones(m,1)*[ypos yl(2)];
  lhandle = line(x',y','color',dods_colors(8,:),'erasemode','none', 'clipping','on');
  for i = 1:m,
    thandle(i) = text(mopos(i),yl(1),molabs(i,:),'units','data', ...
	'color',dods_colors(8,:),'horiz','center','vert','bottom', ...
	'fontsize', fontsize, ...
	'clipping','on');
  end
  j = m+1;
  l = length(daypos);
  for i = 1:l,
    if (daypos(i) > tl(1)) & (daypos(i) < tl(2))
      thandle(j) = text(daypos(i), ...
	  yl(1)-0.1, daylabs(i,:),'units','data', ...
	  'color',dods_colors(8,:),'horiz','center','vert','top', ...
	  'fontsize', fontsize, ...
	  'clipping','off');
      j = j+1;
    end
  end
  % chop to avoid bug in v5
  i = min(find(daypos >= tl(1))); l = length(daypos);
  daypos = daypos(i:l); daylabs = daylabs(i:l,:);
  i = min(find(hrpos >= tl(1))); l = length(hrpos);
  hrpos = hrpos(i:l); hrlabs = hrlabs(i:l,:);
  % plot
  set(AXES(3),'xtick',hrpos,xtc,hrlabs)
  set(tstring(1),'string','Time in Hours','color',dods_colors(3,:))
  set(tstring(2),'string',xlab,'color',dods_colors(8,:))
elseif (0.003 < dt) &  (dt < 0.01) 	% 35h to 4d, show d and h
  % wraparound
  if zoomday > 360
    daypos = [daypos daypos(1:5)+1]; daylabs = [daylabs; daylabs(1:5,:)];
  end
  daypos = daypos(zoomday:zoomday+5); daylabs = daylabs(zoomday:zoomday+5,:);
  l = length(daypos);
  m = length(mopos); x = [];
  for i = 1:m, x = [x, sprintf(' %4i',floor(mopos(i)))]; end
  x = reshape(x,5,m)';
  molabs = [molabs, x];
  
  % month lines
  x = mopos(:)*ones(1,2); y = ones(m,1)*[ypos yl(2)];
  lhandle = line(x',y','color',dods_colors(8,:),'erasemode','none', 'clipping','on');
  for i = 1:m,
    thandle(i) = text(mopos(i),yl(1),molabs(i,:),'units','data', ...
	'color',dods_colors(8,:),'horiz','center','vert','bottom', ...
	'fontsize', fontsize, ...
	'clipping','on');
  end
    
  % add in hours
  hrpos = []; hrlabs = '';
  hint = 4; 				% hour interval
  x = sprintf('%2i',0:hint:23); x = (reshape(x,2,24/hint))';
  x(1,:) = '  ';
  j = m+1;
  for i = 1:l,
    hrpos = [hrpos (0:hint:23)/(zoomlyr*24)+daypos(i)];
    hrlabs = [hrlabs; x]; 
    if (daypos(i) > tl(1)) & (daypos(i) < tl(2))
      thandle(j) = text(daypos(i), ...
	  yl(1)-0.1, daylabs(i,:),'units','data', ...
	  'color',dods_colors(8,:), ...
	  'horiz','center','vert','top', ...
	  'fontsize', fontsize, ...
	  'clipping','off');
      j = j+1;
    end
  end
  % chop to avoid bug in v5
  i = min(find(daypos >= tl(1))); l = length(daypos);
  daypos = daypos(i:l); daylabs = daylabs(i:l,:);
  i = min(find(hrpos >= tl(1))); l = length(hrpos);
  hrpos = hrpos(i:l); hrlabs = hrlabs(i:l,:);
  % plot
  set(AXES(3),'xtick',hrpos,xtc,hrlabs)
  set(tstring(1),'string','Time in Hours','color',dods_colors(3,:))
  set(tstring(2),'string',xlab,'color',dods_colors(8,:))
elseif (0.01 < dt) &  (dt < 0.06) 	% 35h to 17.5d, show days
  daypos = [daypos daypos(1:35)+1]; daylabs = [daylabs; daylabs(1:35,:)];
  l = length(daypos);
  daypos = daypos(zoomday:l); daylabs = daylabs(zoomday:l,:);
  % chop to avoid bug in v5
  i = min(find(daypos >= tl(1))); l = length(daypos);
  daypos = daypos(i:l); daylabs = daylabs(i:l,:);
  mopos = mopos(1:14); molabs = molabs(1:14,:);
  m = length(mopos); x = [];
  for i = 1:m, x = [x, sprintf(' %4i',floor(mopos(i)))]; end
  x = reshape(x,5,m)';
  molabs = [molabs, x];
  x = mopos(:)*ones(1,2); y = ones(m,1)*[ypos yl(2)];
  lhandle = line(x',y','color',dods_colors(8,:),'erasemode','none', 'clipping','on');
  for i = 1:m,
    thandle(i) = text(mopos(i),yl(1),molabs(i,:),'units','data', ...
	'color',dods_colors(8,:),'horiz','center','vert','bottom', ...
	'fontsize', fontsize, ...
	'clipping','on');
  end
  set(AXES(3),'xtick',daypos,xtc,daylabs)
  set(tstring(1),'string','Time in Days','color',dods_colors(3,:))
  set(tstring(2),'string',xlab,'color',dods_colors(8,:))
elseif (0.06 < dt) & (dt <= 35/zoomlyr) 	% 17.5d to ~35d, show alt days
  ii = [1:2:zoomlyr]';
  daypos = daypos(ii); daylabs = daylabs(ii,:);
  daypos = [daypos daypos(1:18)+1]; daylabs = [daylabs; daylabs(1:18,:)];
  % chop to avoid bug in v5
  i = min(find(daypos >= tl(1))); l = length(daypos);
  daypos = daypos(i:l); daylabs = daylabs(i:l,:);
  m = length(mopos); x = [];
  for i = 1:m, x = [x, sprintf(' %4i',floor(mopos(i)))]; end
  x = reshape(x,5,m)';
  molabs = [molabs, x];
  x = mopos(:)*ones(1,2); y = ones(m,1)*[ypos yl(2)];
  lhandle = line(x',y','color',dods_colors(8,:),'erasemode','none', 'clipping','on');
  for i = 1:m,
    thandle(i) = text(mopos(i),yl(1)-0.1,molabs(i,:),'units','data', ...
	'color',dods_colors(8,:),'horiz','center','vert','bottom', ...
	'fontsize', fontsize, ...
	'clipping','on');
  end
  set(AXES(3),'xtick',daypos,xtc,daylabs)
  set(tstring(1),'string','Time in Days','color',dods_colors(3,:))
  set(tstring(2),'string',xlab)
elseif (35/zoomlyr <= dt) & (dt < 0.5) 	% 35 days to 1/2 year, show days 1/ 7-10
  % wraparound following year
  daypos = [daypos daypos(1:185)+1]; daylabs = [daylabs; daylabs(1:185,:)];
  mopos = mopos(1:18); molabs = molabs(1:18,:);
  % decimate to make it legible
  if timetoggle
    ii =[1:7:zoomlyr];
  else
    ii = [1:10:zoomlyr];
  end
  daypos = daypos(ii); daypos = [daypos daypos+1];
  daylabs = daylabs(ii,:); daylabs = [daylabs; daylabs];
  % chop to avoid bug in v5
  i = min(find(daypos >= tl(1))); l = length(daypos);
  daypos = daypos(i:l); daylabs = daylabs(i:l,:);
  m = length(mopos); x = [];
  for i = 1:m, x = [x, sprintf(' %4i',floor(mopos(i)))]; end
  x = reshape(x,5,m)';
  molabs = [molabs, x];
  x = mopos(:)*ones(1,2); y = ones(m,1)*[ypos yl(2)];
  lhandle = line(x',y','color',dods_colors(8,:),'erasemode','none', 'clipping','on');
  for i = 1:m,
    thandle(i) = text(mopos(i),yl(1),molabs(i,:),'units','data', ...
	'color',dods_colors(8,:),'horiz','center','vert','bottom', ...
	'fontsize', fontsize, ...
	'clipping','on');
  end
  set(AXES(3),'xtick',daypos,xtc,daylabs)
  set(tstring(1),'string','Time in Days','color',dods_colors(3,:))
  set(tstring(2),'string',xlab)
elseif (0.5 <= dt) & (dt < 1) 		% 1/2 yr to 1 year, show months
  % Note: Matlab 5 very badly behaved wrt Axis Tick Labels!!!!
  % First label always writes to first xtick position that falls
  % within axis limits!  Even if it should be 3rd or 4th label, etc.!
  i = min(find(mopos >= tl(1)));
  molabs([1 13],:) = [blanks(3); blanks(3)]; 
  mopos = mopos(i:24); molabs = molabs(i:24,:);
  m = length(mopos);
  x = mopos(:)*ones(1,2); y = ones(m,1)*[ypos yl(2)];
  lhandle = line(x',y','color',dods_colors(8,:),'erasemode','none', 'clipping','on');
  yr = floor(tl);
  yrlabs = []; yrpos = [];
  j = 1;
  for i = 1:length(yr(1):yr(2))
    yrpos = yr(1)+i-1;
    yrlab = sprintf('%4i',yrpos);
    if (yrpos > tl(1)) & (yrpos < tl(2))
      thandle(j) = text(yrpos,yl(1)-0.1,yrlab,'units','data', ...
	  'color',dods_colors(8,:),'horiz','center','vert','top', ...
	  'fontsize', fontsize, ...
	  'clipping','off');
      j = j+1;
    end
  end
  set(AXES(3),'xtick',mopos,xtc,molabs)
  if timetoggle
    set(tstring(1),'string','Time in Months','color',dods_colors(3,:))
  else
    set(tstring(1),'string','Time in Days','color',dods_colors(3,:))
  end
  set(tstring(2),'string',xlab,'color',dods_colors(8,:))
elseif (1 < dt) & (dt < 2)
  mopos = [mopos mopos(1:12)+2]; 
  molabs = [molabs; molabs(1:12,:)]; 
  if timetoggle 
    molabs = molabs(:,1);
  else
    l = length(mopos);
    mopos = mopos(1:2:l);
    molabs = molabs(1:2:l,:);
  end
  m = length(mopos);
  x = mopos(:)*ones(1,2); y = ones(m,1)*[ypos yl(2)];
  lhandle = line(x', y', 'color', dods_colors(8,:), ...
      'erasemode', 'none', 'clipping', 'on');
  for i =1:m
    thandle(i) = text(mopos(i), yl(1),molabs(i,:), 'units', 'data', ...
	'color', dods_colors(8,:), 'horiz', 'center', 'vert', 'bottom', ...
	'fontsize', fontsize, ...
	'clipping','on');
  end
  set(AXES(3),'xtickmode','auto','xticklabelmode','auto')
  set(tstring(1),'string','Time in Years','color',dods_colors(3,:))
  set(tstring(2),'string',xlab)
else 					% 1 < dt  use autolabels
  set(AXES(3),'xtickmode','auto','xticklabelmode','auto')
  set(tstring(1),'string','Time in Years','color',dods_colors(3,:))
  set(tstring(2),'string',xlab)
end
