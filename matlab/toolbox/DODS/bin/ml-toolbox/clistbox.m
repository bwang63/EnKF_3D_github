function argout = clistbox(varargin)

% CLISTBOX  a color-index listbox intended to replace the Matlab
% uicontrol item 'listbox', which does not support colors.
%
%              CLISTBOX([HANDLE], [ARGUMENTS]) or 
%
%            CLISTBOX('handle', [HANDLE], [ARGUMENTS]),
%
% where HANDLE is a valid clistbox handle, is used to get/set
% properties of the existing clistbox indicated by HANDLE.
%
% Clistbox support both single and double-click callbacks.
% The single-click callback is only executed when an item is 
% selected (highlighted), not when it is unselected.  Double-clicking
% on an item will always select it, regardless if it is already
% highlighted.
%
% [HANDLE] = CLISTBOX([ARGUMENTS]) will start a new clistbox in the
% current figure. CLISTBOX('parent', [FIGURE], [ARGUMENTS]) will start
% a new clistbox in the specified figure.
%
% To refresh the clistbox display use: clistbox([HANDLE], 'reset')
%
% To get the value (line number) of the current selections use:
%
%             [VALUES] = CLISTBOX([HANDLE], 'value');
%
% To set the value of clistbox selections, use:
% 
% CLISTBOX('select', [VALUES])
%
% where selecting a value of 0 unselects everything.
%
%
%                CLISTBOX PROPERTIES
%
% For any property, CLISTBOX([HANDLE], [PROPERTY]) *gets* the
% current property value, and CLISTBOX([HANDLE], [PROPERTY], [VALUE])
% *sets* PROPERTY to VALUE.
%
% BACKGROUNDCOLOR: The background color of the clistbox.
%
% DOUBLECLICK:  a string, the double click callback
%
% DRAGFUNCTION: ON/OFF parameter.  This will allow dragging 
% of selections while mouse button is pressed down.
%
% DROPFUNCTION: Only enabled if DRAGFUNCTION is 'on'.  DROPFUNCTION is 
% executed when a line or lines of text have been selected, dragged, 
% and the mouse button is subsequently released.   CLISTBOX will not
% actually rearrange the text, this must be executed by the parent
% program.  To find out where the drop has been requested use:
%
%                clistbox([HANDLE], 'dropposition')
%
% FONTNAME  the list text fontname
%
% FONTSIZE  the list text fontsize
%
% HIGHLIGHTCOLOR: the hightlightcolor for drag boxes and the
% edges of hightlighted selections.
%
% POSITION: The clistbox position in UNITS (see below).
%
% MODE: set the selection mode. 3 modes of list item selection 
% are possible in CLISTBOX:
%
%     MONO       selecting one item unselects all others.
%     OVERRIDE   like mono, but using the middle mouse button or 
%                SHIFT+left mouse button allows multiple selections.
%     MULTI      multiple selections are the default.
%
% The right-click does not select but shows the TOOLTIP.
%
% PARENT: Get/set the clistbox parent.  Parent may only be specified
% as value for NEW clistboxes.
%
% SINGLECLICK: a string, the single click callback.
%
% STRING: A 1- 2- or 3-column *cell array*:
%
%         [{string} {color} {fontweight}]
%
% where the default fontcolor is black and the default fontweight is normal.
%
% TOOLTIP:  Set the tooltip string, which shows on right-click.
%
% UNITS: clistbox units, one of [ inches | centimeters ...
%     | normalized | points | pixels | characters ].

N = nargin;
varargin = varargin(:);
LISTAXIS = [];

% check for a handle argument

if N >= 1
  if ~isstr(varargin{1})
    LISTAXIS = varargin{1};
    varargin = varargin(2:N);
    N = N - 1;
  else
    for i = 1:N
      if isstr(varargin{i})
	if strcmp(lower(varargin{i}),'handle') & N > i
	  % set handle
	  LISTAXIS = varargin{i+1};
	  % remove from list
	  j = 1:N; j = find(~isin(j, [i i+1]));
	  varargin = varargin(j);
	  N = size(varargin,1);
	  break
	end
      end
    end
  end
end

% SET UP DEFAULT VALUES
arg1 = '';
defaultfontweight = 'normal';
defaultforegroundcolor = 'k';
backgroundcolor = [0.702 0.702 0.702];
doublecallback = '';
dragfunction = 'off';
dropfunction = '';
execargs = '';
% changed font 02/01/04 to one that has both plain and it-bold
% in simplest X-installation of RedHat Linux.  Bad idea -- may
% not be a supported font on other systems!  Need a way to check
% ahead of time for a decent font.
fontname = 'Lucida';
fontsize = 12;
highlightcolor = 'k';
listpos = [0 0 0 0];
mode = 'mono';
parent = gcf;
singlecallback = '';
sliderwidth = 15;
units = 'pixels';
userdata = cell({});
tooltip = '';

% PARSE THE INPUT ARGUMENTS
i = 1;
while i <= N
  if isstr(varargin{i})
    if N > i
      arg = lower(varargin{i});
      addtoexec = 0;
      % examine the argument
      switch lower(arg)
	case 'backgroundcolor'
	  backgroundcolor = varargin{i+1};
	  addtoexec = 1;
	  i=i+1;
	case 'tooltip'
	  tooltip = varargin{i+1};
	  addtoexec = 1;
	  i=i+1;
        case 'doubleclick'
	  doublecallback = varargin{i+1};
	  addtoexec = 1;
	  i=i+1;
        case 'dragfunction'
	  dragfunction = varargin{i+1};
	  addtoexec = 1;
	  i=i+1;
        case 'dropfunction'
	  dropfunction = varargin{i+1};
	  addtoexec = 1;
	  i=i+1;
	case 'fontname'
	  fontname = varargin{i+1};
	  addtoexec = 1;
	  i=i+1;
	case 'fontsize'
	  fontsize = varargin{i+1};
	  addtoexec = 1;
	  i=i+1;
	case 'highlightcolor'
	  highlightcolor = varargin{i+1};
	  addtoexec = 1;
	  i=i+1;
	case 'position'
	  listpos = varargin{i+1};
	  addtoexec = 1;
	  i=i+1;
	case 'mode'
	  mode = varargin{i+1};
	  addtoexec = 1;
	  i=i+1;
	case 'parent'
	  parent = varargin{i+1};
	  addtoexec = 0;
	  i=i+1;
	case 'select'
	  arg1 = 'select';
	  arg2 = varargin{i+1};
	  i=i+1;
	  if N > i
	    flag = varargin{i+1};
	    i=i+1;
	  else
	    flag = 'fromelsewhere';
	  end
        case 'singleclick'
	  singlecallback = varargin{i+1};
	  addtoexec = 1;
	  i=i+1;
	case 'units'
	  units = varargin{i+1};
	  addtoexec = 1;
	  i=i+1;
	case 'string'
	  userdata = varargin{i+1};
	  addtoexec = 1;
	  i=i+1;
      end
      
      % save this argument for later use
      if addtoexec
	if isempty(execargs)
	  execargs = arg;
	else
	  execargs = str2mat(execargs,arg);
	end
      end

    else % this is the last argument in the list
      % and is the only argument that will be executed!
      % mostly this is used to request values and handles
      % be returned to the user workspace, or for internal
      % calls.
      arg1 = lower(varargin{i});
    end
  end % varargin{i} is not a string
  i = i+1;
end

% check the fontsize
if fontsize > 24
  error('clistbox: maximum fontsize is 24')
  return
end

% check the userdata
if ~iscell(userdata)
  error('clistbox: string must be a cell')
  return
end
  
if isempty(LISTAXIS)
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %         CREATE A NEW LISTBOX             %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  % set up the userdata
  if ~isempty(userdata)
    if size(userdata,2) == 1;
      [userdata(:,2)] = deal({foregroundcolor});
    elseif size(userdata,2) == 2;
      [userdata(:,3)] = deal({'normal'});
    else
      % userdata should be the correct size.
    end
  end

  % set up the listbox
  h = uicontextmenu;
  if ~isempty(tooltip)
    for i = size(tooltip,1)
      uimenu(h,'label',deblank(tooltip(i,:)));
    end
  end
  
  % set up the single= and double-click callbacks
  callback = [ 'singleclick:' singlecallback];
  callback = [callback 'doubleclick:' doublecallback];
  
  pixelflag = 0;
  if all(listpos == 0)
    % if no listsize has been set, set one
    pixelflag = 1;
    un = get(parent,'units');
    set(parent,'units','pixels');
    fig_pos = get(parent,'pos');
    set(parent,'units',un);
    fig_size = fig_pos(3:4);
    listpos = [1 sliderwidth fig_size(1)-sliderwidth ...
	  fig_size(2)-sliderwidth];
  else
    % user has set the position and maybe the units
    if strcmp('units','pixels')
      pixelflag = 1;
    end
  end

  if fontsize <= 14
    y_extent = 16.115;
  elseif fontsize <= 24
    y_extent = 26.5;
  end
  
  if pixelflag
    nframes = floor(listpos(4)/y_extent);
    listextent = nframes+1;
    LISTAXIS = axes('parent',parent,'units','pixels', ...
	'pos', listpos, 'visible', 'off', 'xlim', [0 1], ...
	'ylim', [0 listextent], ...
	'color',backgroundcolor, ...
	'nextplot','add', ... 
	'tag', callback, ...
	'xtick',[],'ytick',[], ...
	'xcolor',backgroundcolor, ...
	'ycolor',backgroundcolor, ...
	'userdata', userdata);
  else
    % user has specified a position AND units which are not
    % pixels. set up the requested axis.
    LISTAXIS = axes('parent',parent, 'units', units, ...
	'pos', listpos, 'visible', 'off', 'xlim', [0 1], ...
	'ylim', [0 1], ...
	'color',backgroundcolor, ...
	'nextplot','add', ... 
	'tag', callback, ...
	'xtick',[],'ytick',[], ...
	'xcolor',backgroundcolor, ...
	'ycolor',backgroundcolor, ...
	'userdata', userdata);

    % now do some calculations in pixels
    set(LISTAXIS,'units','pixels');
    p = get(LISTAXIS,'pos');
    % shrink the axis by the width of the sliders
    listpos = [p(1) p(2)+sliderwidth ...
	  p(3)-sliderwidth p(4)-sliderwidth];
    % figure out how many frames can go in it
    nframes = floor(listpos(4)/y_extent);
    listextent = nframes+1;
    set(LISTAXIS,'ylim',[0 listextent])
  end

  % NOW SET UP THE UICONTROL SLIDERS TO GO WITH THE AXIS
  % set up some sliders
  stringlength = size(userdata,1);
  slidermax = max(stringlength-nframes,1);
  sliderstep = 1./(10.^floor(log10(slidermax)));
  sliderstep = [sliderstep/10 sliderstep];

  % the positions are relative to the listpos
  slide1pos = [listpos(1)+listpos(3) listpos(2) sliderwidth ...
	listpos(4)];
  slide2pos = [listpos(1) listpos(2)-sliderwidth ...
	listpos(3)+sliderwidth sliderwidth];

  % the frames provide background color for the sliders
  % in case the sliders are turned off.
  frame(1) = uicontrol(parent,'style','frame', ...
      'units','pixels','vis','off', 'tag', num2str(1), ...
      'pos', slide1pos, ...
      'userdata', LISTAXIS, 'backgroundcolor', backgroundcolor);
  frame(2) = uicontrol(parent,'style','frame', ...
      'units','pixels','vis','off', 'tag', num2str(2), ...
      'pos', slide2pos, ...
      'userdata', LISTAXIS, 'backgroundcolor', backgroundcolor);
  
  str = sprintf('clistbox(''handle'', %.20f, ''vscroll'')',LISTAXIS);
  slide(1) = uicontrol(parent,'style','slider', ...
      'units', 'pixels', 'vis','off', ...
      'pos', slide1pos, 'sliderstep', sliderstep, ...
      'min', 0, 'max', slidermax, 'value', slidermax, ...
      'userdata', LISTAXIS, 'backgroundcolor', backgroundcolor, ...
      'callback', str, 'tag', num2str(1));
  str = sprintf('clistbox(''handle'', %.20f, ''hscroll'')', LISTAXIS);
  slide(2) = uicontrol(parent,'style','slider', ...
      'units', 'pixels', 'vis','off', ...
      'pos', slide2pos, ...
      'sliderstep', [0.1 0.5], 'min', 0, 'max', 1, ...
      'userdata', LISTAXIS, 'backgroundcolor', backgroundcolor, ...
      'value', 0, 'callback', str, 'tag', num2str(2));

  % now reset units to the other thing
  if ~strcmp(units,'pixels')
    set([frame slide LISTAXIS],'units', units)
  end

  % set the resize function
  str = sprintf('clistbox(''handle'', %.20f, ''resize'')',LISTAXIS);
  set(parent,'resizefcn', str)

  % set selected positions
  set(get(LISTAXIS,'ylabel'),'userdata', 0)
  % set [x-scroll y-scroll] history
  set(get(LISTAXIS,'xlabel'),'userdata',[1 1])
  % set mode
  set(get(LISTAXIS,'zlabel'),'userdata', mode)

  for i = 1:nframes
    str = sprintf('clistbox(''handle'', gca, ''select'', %i, ''fromtext'')', i);
    backbox(i) = fill([0 1 1 0 0], [listextent-i listextent-i ...
	  listextent-i+1 listextent-i+1 listextent-i], ...
	highlightcolor, 'buttondownfcn', str, 'uicontextmenu', h, ...
	'vis','off', 'selectionhighlight','off', ...
	'erasemode', 'background', 'userdata', i);
    listbox(i) = text('pos',[0 listextent-i], ...
	'color',highlightcolor,'string','', ...
	'horiz','left','vert','bottom', ...
	'fontname', fontname, 'fontsize', fontsize, ...
	'units', 'data', ...
	'buttondownfcn', str, 'uicontextmenu', h, ...
	'selectionhighlight','off','userdata', i, ...
	'erasemode','normal', 'visible','off', ...
	'clipping','on');
    % Edge lines and edge boxes
    plot([0 1 1 0 0], [listextent-i listextent-i ...
	  listextent-i+1 listextent-i+1 listextent-i], ...
	'color', highlightcolor, ...
	'uicontextmenu', h, ...
	'vis','off', 'selectionhighlight','off', ...
	'erasemode', 'background', 'userdata', i);
    plot([0 1], [listextent-i+1 listextent-i+1], ...
	'color', highlightcolor, ...
	'uicontextmenu', h, ...
	'vis','off', 'selectionhighlight','off', ...
	'erasemode', 'background', 'userdata', i-0.5);
  end
  % the last edge line (at the bottom)
  plot([0 1], [1 1], 'color', ...
      highlightcolor, 'uicontextmenu', h, ...
      'vis','off', 'selectionhighlight','off', ...
      'erasemode', 'background', 'userdata', nframes+0.5);

  % set the drag and drop functions, if requested.
  % only set dropfunction if dragfunction is turned on
  if strcmp(dragfunction,'on')
    str1 = sprintf('clistbox(''''handle'''', %.20f, ''''drag'''')', ...
	LISTAXIS);
    str2 = sprintf('set(gcf,''''pointer'''',''''arrow''''); clistbox(''''handle'''', %.20f ,''''drop'''')', ...
	LISTAXIS);
    str = [ 'set(gcf,''windowbuttonmotionfcn'',' '''' str1, ...
	  ' '');', 'set(gcf,''windowbuttonupfcn'',' '''' str2, ...
	  ' '')'];
    set(parent,'windowbuttondownfcn', str)
    set(parent,'windowbuttonmotionfcn', '')
    set(parent,'windowbuttonupfcn', '')
    set(get(LISTAXIS,'xlabel'),'string', dropfunction)
  end

  % set up initial strings and colors
  endloop = min(nframes, size(userdata,1));
  for i = 1:endloop
    set(listbox(i),'string',userdata{i,1},'color', ...
	userdata{i,2},'fontweight', userdata{i,3})
    set(backbox(i),'facecolor', userdata{i,2})
  end
  
  % make things visible
  set([LISTAXIS listbox frame],'vis','on')
  if stringlength > nframes
    set(slide(1),'vis','on')
  end

  % check if we need a horizontal slider
  clistbox('handle',LISTAXIS, 'hscrollon')

  % the default output argument is the axis handle: set it.
  if nargout > 0
    argout = LISTAXIS;
  end

else

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % WE ARE MANIPULATING AN EXISTING LISTBOX  %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 

  % the default output argument is the axis handle: set it.
  if nargout > 0
    argout = LISTAXIS;
  end

  % THE FOLLOWING ARGUMENTS ARE EXECUTED ALL BY THEMSELVES
  if ~isempty(arg1)
    switch arg1
      case 'backboxes'
	% return handles to backboxes on this axis
	backboxes = findobj(LISTAXIS,'type','patch');
	numslots = get(backboxes,'userdata');
	numslots = cat(1,numslots{:});
	[k l] = sort(numslots);
	backboxes = backboxes(l);
	backboxes = backboxes(:);
	argout = backboxes;
	
      case 'backgroundcolor'
	argout = get(LISTAXIS,'color');
	
      case 'drag' % drag selected item
	if strcmp(get(get(LISTAXIS, 'ylabel'),'string'),'nodrop')
	  return
	end
	
	pos = get(get(LISTAXIS,'ylabel'),'userdata');
	scrollstuff = get(get(LISTAXIS,'xlabel'),'userdata');
	listboxtop = scrollstuff(1);
	relpos = pos - listboxtop + 1;
	parent = get(LISTAXIS,'parent');
	if pos > 0
	  g = get(LISTAXIS,'currentpoint');
	  g = g(1,2);
	  set(parent,'pointer','circle')
	  edgeline = clistbox('handle',LISTAXIS,'edgelines');
	  nframes = (length(edgeline) - 1)/2;
	  g = round(2*(nframes - g+1.5))/2;
	  y1 = get(edgeline, 'userdata');
	  y1 = cat(1,y1{:});
	  
	  % get canonical string
	  newstring = get(LISTAXIS,'userdata');
	  showlist = char(newstring(:,1));
	  % get max length of shown list
	  [showlength showwidth] = size(showlist);
	  
	  % check to see if text reaches end of listbox
	  if listboxtop+nframes > showlength
	    if g < 1
	      lineon = 1;
	    elseif g > (showlength-listboxtop+1)
	      g = showlength-listboxtop+1.5;
	      lineon = find(abs(y1 - g) == 0);
	    else
	      lineon = find(abs(y1 - g) == 0);
	    end
	  else
	    if g < 1
	      lineon = 1;
	    elseif g > nframes
	      lineon = length(edgeline);
	    else
	      lineon = find(abs(y1 - g) == 0);
	    end
	  end
	  lineoff = 1:length(edgeline);
	  lineoff = lineoff(find(~isin(lineoff,lineon)));
	  set(edgeline(lineoff),'vis','off')
	  set(edgeline(lineon),'vis','on')
	end
	
      case 'drop' % drop selected items
	if strcmp(get(get(LISTAXIS, 'ylabel'),'string'),'nodrop')
	  return
	end
	
	pos = get(get(LISTAXIS,'ylabel'),'userdata');
	edgeline = clistbox('handle',LISTAXIS,'edgelines');
	
	if any(pos > 0)
	  parent = get(LISTAXIS,'parent');
	  set(parent,'windowbuttonmotionfcn','', ...
	      'windowbuttonupfcn','', ...
	      'pointer','arrow')
	  listbox = clistbox('handle',LISTAXIS,'listboxes');
	  
	  
	  nframes = length(listbox);
	  % get current scroll values
	  scrollstuff = get(get(LISTAXIS,'xlabel'),'userdata');
	  listboxtop = scrollstuff(1);
	  
	  % get canonical string
	  newstring = get(LISTAXIS,'userdata');
	  showlist = char(newstring(:,1));
	  % get max length of shown list
	  [showlength showwidth] = size(showlist);
	  
	  g = get(LISTAXIS,'currentpoint');
	  g = g(1,2);
	  g = round(2*(nframes - g+1.5))/2;
	  g = g+listboxtop-1;
	  
	  if g < 1
	    g = 0;
	  elseif g > showlength
	    g = showlength+0.5;
	  end
	  
	  if ~any(g == pos) & ~any(floor(g) == pos) & ...
		~any(ceil(g) == pos)
	    set(get(LISTAXIS,'ylabel'),'string', num2str(g))
	    dropcallback = get(get(LISTAXIS,'xlabel'),'string');
	    eval(dropcallback)
	  end
	end
	set(edgeline,'vis','off')
	
      case 'dragfunction'
	parent = get(LISTAXIS,'parent');
	  str = get(parent','windowbuttondownfcn');
	  argout = 'off';
	if ~isempty(str)
	  if strcmp(str(1:19),'clistbox(''''handle''''') & ...
		~isempty(findstr(str1,'''''drag'''''))
	    argout = 'on';
	  end
	end

      case 'dropfunction'
	argout = get(get(LISTAXIS,'xlabel'), 'string');
	
      case 'doubleclick'
	callback = get(LISTAXIS,'tag');
	if ~isempty(callback)
	  k = findstr(callback,'doubleclick:');
	  if ~isempty(k)
	    doublecallback = callback(k+12:length(callback));
	    singlecallback = callback(13:k-1);
	  else
	    doublecallback = '';
	    singlecallback = callback(13:length(callback));
	  end
	end
	argout = doubleclick;
	
      case 'fontname'
	% return the fontname
	argout = '';
	listbox = clistbox('handle',LISTAXIS,'listboxes');
	if ~isempty(listbox)
	  argout = get(listbox(1),'fontname');
	end
	
      case 'fontsize'
	% return the fontsize
	argout = '';
	listbox = clistbox('handle',LISTAXIS,'listboxes');
	if ~isempty(listbox)
	  argout = get(listbox(1),'fontsize');
	end
	
      case 'edgelines'
	% return handles to backboxes on this axis
	edgelines = findobj(LISTAXIS,'type','line');
	numslots = get(edgelines,'userdata');
	numslots = cat(1,numslots{:});
	[k l] = sort(numslots);
	edgelines = edgelines(l);
	edgelines = edgelines(:);
	argout = edgelines;
	
      case 'frames and sliders'
	% get handles of frames and sliders
	parent = get(LISTAXIS,'parent');
	slide(1) = findobj(parent,'style','slider', ...
	    'userdata', LISTAXIS,'tag',num2str(1));
	slide(2) = findobj(parent,'style','slider', ...
	    'userdata', LISTAXIS,'tag',num2str(2));
	frame(1) = findobj(parent,'style','frame', ...
	    'userdata', LISTAXIS,'tag',num2str(1));
	frame(2) = findobj(parent,'style','frame', ...
	    'userdata', LISTAXIS,'tag',num2str(2));
	frame = frame(:)'; slide = slide(:)';
	argout = [frame slide];
	
      case 'dropposition'
	listbox = clistbox('handle', LISTAXIS,'listboxes');
	droppos = str2num(get(get(LISTAXIS,'ylabel'),'string'));
	argout = droppos;
	
      case 'highlightcolor'
	argout = [];
	edgeline = clistbox('handle',LISTAXIS,'edgelines');
	if ~isempty(edgeline)
	  argout = get(edgeline(1),'color');
	end
	
      case 'hscroll'
	% get the handles to the needed objects
	listbox = clistbox('handle',LISTAXIS,'listboxes');
	nframes = size(listbox,1);
	slide = get(gcf,'currentobject');
	v = get(slide,'value');
	m = get(slide,'max');
	scrollval = round(v)+1;
	
	% get current scroll values
	scrollstuff = get(get(LISTAXIS,'xlabel'),'userdata');
	listboxtop = scrollstuff(1);
	oldscrollval = scrollstuff(2);
	
	% get canonical string
	newstring = get(LISTAXIS,'userdata');
	showlist = char(newstring(:,1));
	% get max length of shown list
	[showlength showwidth] = size(showlist);
	
	% if there are LaTex control characters, don't chop them off!
	
	% check to see if text reaches end of listbox
	if listboxtop+nframes > showlength
	  endloop = showlength - listboxtop + 1;
	  for i = 1:endloop
	    showstring = showlist(i+listboxtop-1,:);
	    if scrollval > 1
	      % find all invisible characters
	      tex_chars = findstr(showstring,'{');
	      tex_chars = [tex_chars findstr(showstring,'}')];
	      for k = 1:showwidth
		if strcmp(showstring(k),'\')
		  l = min([findstr(showstring(k+1:showwidth),' '), ...
		      findstr(showstring(k+1:showwidth),'{')])-1;
		  tex_chars = [tex_chars k:(k+l)];
		end
	      end
	      k = find(tex_chars < scrollval);
	      tex_chars = sort(tex_chars(k));
	      showstring = showstring([tex_chars scrollval:showwidth]);
	    end
	    set(listbox(i), 'string', showstring)
	  end
	else
	  % text fills listbox
	  for i = 1:nframes
	    showstring = showlist(i+listboxtop-1,:);
	    if scrollval > 1
	      % find all invisible characters
	      tex_chars = findstr(showstring,'{');
	      tex_chars = [tex_chars findstr(showstring,'}')];
	      for k = 1:showwidth
		if strcmp(showstring(k),'\')
		  l = min([findstr(showstring(k+1:showwidth),' '), ...
		      findstr(showstring(k+1:showwidth),'{')])-1;
		  tex_chars = [tex_chars k:(k+l)];
		end
	      end
	      k = find(tex_chars < scrollval);
	      tex_chars = sort(tex_chars(k));
	      showstring = showstring([tex_chars scrollval:showwidth]);
	    end
	    set(listbox(i), 'string', showstring)
	  end
	end
	
	% update the scroll history
	set(get(LISTAXIS,'xlabel'),'userdata',[listboxtop scrollval])
	
      case 'hscrollon'
	% check if we need a horizontal scroll for the text
	
	% get handles
	handles = clistbox('handle',LISTAXIS,'frames and sliders');
	listbox = clistbox('handle',LISTAXIS,'listboxes');
	nframes = size(listbox,1);
	slide = handles(3:4);
	
	% get extent of axis in character units
	p1 = get(LISTAXIS,'pos');
	un = get(LISTAXIS,'units');
	set(LISTAXIS,'units','char');
	sz = get(LISTAXIS,'pos');
	nchar = sz(3);
	set(LISTAXIS,'units', un, 'pos', p1);
	
	% get extent of textboxes in same
	p2 = get(listbox,'pos');
	set(listbox,'units','char');
	showwidth = get(listbox,'extent');
	set(listbox,'units','data');
	for i = 1:nframes
	  set(listbox(i),'units','data','pos',p2{i})
	end
	
	% scroll needed?
	showwidth = cat(1,showwidth{:,1});
	showwidth = max(showwidth(:,3));
	if nchar < (showwidth+1)
	  slidermax = (showwidth+1)-nchar;
	  v = get(slide(2),'value');
	  if v > slidermax
	    set(slide(2),'vis','on','max',slidermax,'value', slidermax)
	  else
	    set(slide(2),'vis','on','max', slidermax)
	  end
	else
	  set(slide(2),'vis','off')
	end
	
      case 'listboxes'
	% return handles to listboxes on this axis
	listboxes = findobj(LISTAXIS,'type','text');
	invalid = [get(LISTAXIS,'zlabel'); ...
	  get(LISTAXIS,'ylabel'); ...
	  get(LISTAXIS,'xlabel')];
	listboxes = listboxes(find(~isin(listboxes,invalid)));
	numslots = get(listboxes,'userdata');
	numslots = cat(1,numslots{:});
	[k l] = sort(numslots);
	listboxes = listboxes(l);
	listboxes = listboxes(:);
	argout = listboxes;
	
      case 'position'
	% get handle to sliders etc
	handles = clistbox('handle',LISTAXIS,'frames and sliders');
	frame = handles(1:2);
	slide = handles(3:4);
	
	p = get(LISTAXIS,'position');
	slide1pos = get(slide(1),'pos');
	slide2pos = get(slide(2),'pos');
	% set listpos to WHOLE ORIGINAL POSITION
	listpos = [p(1) slide2pos(1) p(3)+slide1pos(3) ...
	      p(4)+slide2pos(4)];
	argout = listpos;

      case 'mode'
	argout = get(get(LISTAXIS,'zlabel'),'userdata');
	
      case 'parent'
	argout = get(LISTAXIS, 'parent');
	
      case 'reset'
	% set the color frames and text in the visible list to
	% respond to changes due to scrolling, cutting, pasting, etc.
	
	% get handle to slider
	handles = clistbox('handle',LISTAXIS,'frames and sliders');
	frame = handles(1:2);
	slide = handles(3:4);
	
	% get handles to boxes
	listbox = clistbox('handle',LISTAXIS,'listboxes');
	backbox = clistbox('handle',LISTAXIS,'backboxes');
	nframes = size(listbox,1);
	
	% get canonical string list
	newstring = get(LISTAXIS,'userdata');
	backgroundcolor = get(LISTAXIS,'color');
	if isempty(newstring)
	  set(listbox,'string','')
	  set(backbox,'vis','off')
	  set(slide,'vis','off')
	  return
	end
	% get scroll values
	scrollstuff = get(get(LISTAXIS,'xlabel'),'userdata');
	oldlistboxtop = scrollstuff(1);
	scrollval = scrollstuff(2);
	
	% extract items that should be shown from the database
	colors = cat(1,newstring{:,2});
	fontweight = cat(1,newstring(:,3));
	showlist = char(newstring(:,1));
	% get size of shown list
	[showlength showwidth] = size(showlist);
	
	% set vertical slider
	slidermax = max(showlength-nframes,1);
	sliderstep = 1./(10.^floor(log10(slidermax)));
	sliderstep = [sliderstep/10 sliderstep];
	if showlength <= nframes
	  % text does not go to the end of the window.
	  % reset the slider and the listboxtop and save
	  % the values
	  listboxtop = 1;
	  slidermax = 1;
	  val = 1;
	  set(slide(1), 'visible', 'off')
	else
	  set(slide(1), 'visible', 'on')
	  % get/set vert. scrollbar value -- current position
	  v = get(slide(1),'value');
	  m = get(slide(1),'max');
	  listboxtop = round(m-v)+1;
	  
	  if v == m % slider is at the top. keep it there.
	    val = slidermax;
	  else % slider is at bottom or somewhere in the middle
	    if round(m-v) <= slidermax
	      % slider is at an acceptable value
	      val = slidermax-round(m-v);
	    else
	      % slider has to be moved up
	      val = 0;
	    end
	  end
	end
	% set slider to given values
	set(slide(1),'max',slidermax, 'value', val, ...
	    'sliderstep', sliderstep)
	
	% set listboxes and backboxes
	if listboxtop+nframes > showlength
	  % text terminates before listbox
	  endloop = showlength - listboxtop + 1;
	  for i = 1:endloop
	    set(listbox(i), ...
		'string', showlist(i+listboxtop-1,scrollval:showwidth), ...
		'color', colors(i+listboxtop-1,:), ...
		'fontweight', fontweight{i+listboxtop-1})
	    set(backbox(i),'facecolor', colors(i+listboxtop-1,:))
	  end
	  for i = endloop+1:nframes
	    set(listbox(i),'string','')
	    set(backbox(i),'vis','off')
	  end
	else
	  % text fills listbox
	  for i = 1:nframes
	    set(listbox(i), ...
		'string', showlist(i+listboxtop-1,scrollval:showwidth), ...
		'color', colors(i+listboxtop-1,:), ...
		'fontweight', fontweight{i+listboxtop-1})
	    set(backbox(i),'facecolor', colors(i+listboxtop-1,:))
	  end
	end
	
	% find selected object if there is one and unselect it
	obj = findobj(LISTAXIS,'selected','on');
	if ~isempty(obj)
	  % get its position
	  pos = get(obj,'userdata');
	  if iscell(pos)
	    pos = cat(1,pos{:})';
	  end
	  if listboxtop ~= oldlistboxtop
	    set(obj,'selected','off')
	    set(backbox(pos),'vis','off')
	    newpos = pos - (listboxtop - oldlistboxtop);
	    if (newpos <= nframes) & ...
		  (newpos <= showlength+listboxtop-1) & ...
		  (newpos >= 1)
	      set(backbox(newpos),'vis','on')
	      set(listbox(newpos),'selected','on', ...
		  'color', backgroundcolor)
	    end
	  else
	    set(listbox(pos),'color', backgroundcolor)
	  end
	end
	
	% update the scroll history
	set(get(LISTAXIS,'xlabel'),'userdata',[listboxtop ...
	      scrollval])
	
	% now check if we need a horizontal scroll for the text
	clistbox('handle', LISTAXIS, 'hscrollon')
	
      case 'resize'
	resetflag = 0;
	parent = get(LISTAXIS,'parent');
	set(0,'currentfigure',parent)
	units = get(LISTAXIS,'units');
	listbox = clistbox('handle',LISTAXIS,'listboxes');
	t = findobj(LISTAXIS,'type','text');
	if ~isempty(t)
	  fontsize = get(t(1),'fontsize');
	end
	nframes = size(listbox,1);
	% get handles of everything that must have new units
	handles = clistbox('handle',LISTAXIS,'frames and sliders');
	frame = handles(1:2); slide = handles(3:4);
	set([LISTAXIS frame slide],'units','pixels');
	p = get(LISTAXIS,'pos');
	slide1pos = get(slide(1),'pos');
	slide2pos = get(slide(2),'pos');
	% set listpos to WHOLE ORIGINAL POSITION
	% (this is in pixels)
	listpos = [p(1) slide2pos(2) p(3)+slide1pos(3) ...
	      p(4)+slide2pos(4)];
	% now do the usual calculations
	listpos = [listpos(1) listpos(2)+sliderwidth ...
	      listpos(3)-sliderwidth listpos(4)-sliderwidth];
	slide1pos = [listpos(1)+listpos(3) listpos(2) sliderwidth ...
	      listpos(4)];
	slide2pos = [listpos(1) listpos(2)-sliderwidth ...
	      listpos(3)+sliderwidth sliderwidth];
	set(LISTAXIS,'pos', listpos)
	set([slide(1) frame(1)], 'units', 'pixels', 'pos', slide1pos)
	set([slide(2) frame(2)], 'units','pixels', 'pos', slide2pos)
	
	% NOW GO ABOUT RESETTING THE NUMBER OF FRAMES
	% calculate new number of frames
	if fontsize <= 14
	  y_extent = 16.115;
	elseif fontsize <= 24
	  y_extent = 26.5;
	end
	
	% figure out if we need new frames
	newnframes = floor(listpos(4)/y_extent);
	
	% now we can set the units to whatever was requested
	set([LISTAXIS slide frame],'units', units)
	
	if newnframes ~= nframes
	  resetflag = 1;
	  backbox = clistbox(LISTAXIS,'backboxes');
	  edgeline = clistbox(LISTAXIS,'edgelines');
	  delete(edgeline)
	  % get highlightcolor
	  highlightcolor = get(backbox(1),'edgecolor');
	  % reset selections
	  set(get(LISTAXIS,'ylabel'),'userdata', 0)
	  h = get(listbox(1),'uicontextmenu');
	  if newnframes < nframes
	    listextent = newnframes+1;
	    % just delete some frames
	    delete(listbox(newnframes+1:nframes))
	    listbox = listbox(1:newnframes);
	    delete(backbox(newnframes+1:nframes))
	    backbox = backbox(1:newnframes);
	    set(LISTAXIS, 'ylim', [0 listextent]);
	    for i = 1:newnframes
	      set(listbox(i),'pos',[0 listextent-i])
	      set(backbox(i),'ydata', [listextent-i listextent-i ...
		    listextent-i+1 listextent-i+1 listextent-i])
	      % Edge lines and edge boxes
	      plot([0 1 1 0 0], [listextent-i listextent-i ...
		    listextent-i+1 listextent-i+1 listextent-i], ...
		  'color', highlightcolor, ...
		  'uicontextmenu', h, ...
		  'vis','off', 'selectionhighlight','off', ...
		  'erasemode', 'background', 'userdata', i);
	      plot([0 1], [listextent-i+1 listextent-i+1], ...
		  'color', highlightcolor, ...
		  'uicontextmenu', h, ...
		  'vis','off', 'selectionhighlight','off', ...
		  'erasemode', 'background', 'userdata', i-0.5);
	    end
	    % the last edge line (at the bottom)
	    plot([0 1], [1 1], 'color', ...
		highlightcolor, 'uicontextmenu', h, ...
		'vis','off', 'selectionhighlight','off', ...
		'erasemode', 'background', 'userdata', nframes+0.5);
	    nframes = newnframes;
	  else % need some new frames
	    newframes = nframes+1:newnframes;
	    listextent = newnframes+1;	
	    set(LISTAXIS, 'ylim', [0 listextent]);
	    % move old boxes up to top of axis
	    for i = 1:nframes
	      set(listbox(i),'pos',[0 listextent-i], ...
		  'fontsize', fontsize)
	      set(backbox(i),'ydata', [listextent-i listextent-i ...
		    listextent-i+1 listextent-i+1 listextent-i])
	    end
	    % add new boxes at the bottom
	    subplot(LISTAXIS)
	    for i = newframes
	      str = sprintf('clistbox(''handle'',gca,''select'',%i,''fromtext'')',i);
	      backbox(i) = fill([0 1 1 0 0], [listextent-i listextent-i ...
		    listextent-i+1 listextent-i+1 listextent-i], ...
		  highlightcolor, 'buttondownfcn', str, 'uicontextmenu', h, ...
		  'vis','off', 'selectionhighlight','off', ...
		  'erasemode', 'background', 'userdata', i);
	      listbox(i) = text('pos',[0 listextent-i], ...
		  'color',highlightcolor,'string','', ...
		  'horiz','left','vert','bottom', ...
		  'fontname', fontname, 'fontsize', fontsize, ...
		  'units', 'data', ...
		  'buttondownfcn', str, 'uicontextmenu', h, ...
		  'selectionhighlight','off','userdata', i, ...
		  'erasemode','normal', 'visible','on', ...
		  'clipping','on');
	    end
	    set(backbox,'edgecolor',highlightcolor)
	    nframes = newnframes;
	    % MAKE ALL NEW EDGELINES
	    for i = 1:nframes
	      % Edge lines and edge boxes
	      plot([0 1 1 0 0], [listextent-i listextent-i ...
		    listextent-i+1 listextent-i+1 listextent-i], ...
		  'color', highlightcolor, 'uicontextmenu', h, ...
		  'vis','off', 'selectionhighlight','off', ...
		  'erasemode', 'background', 'userdata', i);
	      plot([0 1], [listextent-i+1 listextent-i+1], ...
		  'color', highlightcolor, 'uicontextmenu', h, ...
		  'vis','off', 'selectionhighlight','off', ...
		  'erasemode', 'background', 'userdata', i-0.5);
	    end
	    % the last edge line (at the bottom)
	    plot([0 1], [1 1], 'color', ...
		highlightcolor, 'uicontextmenu', h, ...
		'vis','off', 'selectionhighlight','off', ...
		'erasemode', 'background', 'userdata', nframes+0.5);
	  end
	end
	
	% reset
	if resetflag
	  clistbox('handle', LISTAXIS, 'reset')
	end
	
      case 'select'
	parent = get(LISTAXIS,'parent');
	% DON'T RESPOND TO RIGHT CLICKS!
	if strcmp(get(parent,'selectiontype'), 'alt')
	  return
	end
	
	% set up the possibility of DRAGGING AND DROPPING
	% later this will be unset for certain types of 
	% clicks (for example, when something is being unselected
	% rather than selected, or when the selection is from
	% an outside program.
	set(get(LISTAXIS,'ylabel'),'string', 'drop')
	
	callback = get(LISTAXIS,'tag');
	if ~isempty(callback)
	  k = findstr(callback,'doubleclick:');
	  if ~isempty(k)
	    doublecallback = callback(k+12:length(callback));
	    singlecallback = callback(13:k-1);
	  else
	    doublecallback = '';
	    singlecallback = callback(13:length(callback));
	  end
	end

	% catch doubleclicks
	doubleclick = 0;
	if strcmp(get(parent,'selectiontype'), 'open')
	  doubleclick = 1;
	end
	
	% catch override multiselect
	mode = get(get(LISTAXIS,'zlabel'),'userdata');
	if strcmp(mode, 'override')
	  if strcmp(get(parent,'selectiontype'), 'extend')
	    mode = 'multi';
	  else
	    mode = 'mono';
	  end
	end
	
	% get the position of the selection request
	pos = arg2(:)';
	
	% get handles to boxes
	listbox = clistbox('handle',LISTAXIS,'listboxes');
	backbox = clistbox('handle',LISTAXIS,'backboxes');
	nframes = size(listbox,1);
	backgroundcolor = get(LISTAXIS,'color');
	
	% note that passing in a pos of 0 means unselect ALL
	if pos > 0
	  
	  scrollstuff = get(get(LISTAXIS,'xlabel'),'userdata');
	  listboxtop = scrollstuff(1);
	  
	  if doubleclick
	    if strcmp(mode,'mono')
	      % set the selection and highlighting
	      set(listbox(pos), 'selected', 'on', ...
		  'color', backgroundcolor)
	      set(backbox(pos),'visible','on')
	      set(get(LISTAXIS,'ylabel'), 'userdata', pos+listboxtop-1)
	      set(parent,'windowbuttonmotionfcn','', ...
		  'windowbuttonupfcn','', 'pointer','arrow')
	    elseif strcmp(mode,'multi')
	      % set the selection and highlighting
	      abspos = pos+listboxtop-1;
	      otherpos = get(get(LISTAXIS,'ylabel'),'userdata');
	      otherpos = sort([otherpos abspos]);
	      otherpos = otherpos(findnew(otherpos));
	      otherpos = otherpos(find(otherpos > 0));
	      set(get(LISTAXIS,'ylabel'),'userdata', otherpos);
	      set(listbox(pos), 'selected', 'on', ...
		  'color', backgroundcolor)
	      set(backbox(pos),'visible','on')
	      set(parent,'windowbuttonmotionfcn','', ...
		  'windowbuttonupfcn','', 'pointer','arrow')
	    end
	    
	    if strcmp(flag,'fromtext')
	      % evaluate a doubleclick callback request
	      if ~isempty(doublecallback)
		eval(doublecallback)
	      end
	    end
	    
	    % doubleclicks NEVER mean drag and drop
	    set(get(LISTAXIS,'ylabel'),'string','nodrop')
	    
	  else % this is a SINGLE click -------------------------- %
	    
	    if strcmp(flag,'fromtext')
	      if strcmp(mode,'mono')
		if strcmp(get(listbox(pos),'selected'), 'off')
		  set(get(LISTAXIS,'ylabel'), 'userdata', pos+listboxtop-1)
		  % check if somethings are currently selected
		  % and if so, unselect them
		  h = findobj(LISTAXIS,'selected','on');
		  if ~isempty(h)
		    for i = 1:length(h)
		      oldpos = find(listbox == h(i));
		      colorset = get(backbox(oldpos),'facecolor');
		      set(listbox(oldpos),'selected','off', ...
			  'color', colorset)
		      set(backbox(oldpos),'visible','off')
		    end
		  end
		  % set the selection and highlighting
		  set(listbox(pos), 'selected', 'on', ...
		      'color', backgroundcolor)
		  set(backbox(pos),'visible','on')
		else % this was selected now unselect it
		  abspos = pos+listboxtop-1;
		  otherpos = get(get(LISTAXIS,'ylabel'), 'userdata');
		  if any(otherpos ~= abspos)
		    h = findobj(LISTAXIS,'selected','on');
		    if ~isempty(h)
		      for i = 1:length(h)
			oldpos = find(listbox == h(i));
			colorset = get(backbox(oldpos),'facecolor');
			set(listbox(oldpos),'selected','off', ...
			    'color', colorset)
			set(backbox(oldpos),'visible','off')
		      end
		    end
		    % set the selection and highlighting
		    set(listbox(pos), 'selected', 'on', ...
			'color', backgroundcolor)
		    set(backbox(pos),'visible','on')
		    set(get(LISTAXIS,'ylabel'), 'userdata', abspos)
		  else
		    % unselecting NEVER means drag and drop
		    set(get(LISTAXIS,'ylabel'),'string','nodrop')
		    colorset = get(backbox(pos),'facecolor');
		    set(backbox(pos),'visible','off');
		    set(listbox(pos),'selected', 'off', ...
			'color', colorset)
		    set(get(LISTAXIS,'ylabel'), 'userdata', 0)
		  end
		end
	      elseif strcmp(mode, 'multi')
		if strcmp(get(listbox(pos),'selected'), 'off')
		  abspos = pos+listboxtop-1;
		  otherpos = get(get(LISTAXIS,'ylabel'),'userdata');
		  otherpos = sort([otherpos abspos]);
		  otherpos = otherpos(findnew(otherpos));
		  otherpos = otherpos(find(otherpos > 0));
		  set(get(LISTAXIS,'ylabel'),'userdata', otherpos);
		  % set the selection and highlighting
		  set(listbox(pos), 'selected', 'on', ...
		      'color', backgroundcolor)
		  set(backbox(pos),'visible','on')
		else
		  % unselecting NEVER means drag and drop
		  set(get(LISTAXIS,'ylabel'),'string','nodrop')
		  abspos = pos+listboxtop-1;
		  otherpos = get(get(LISTAXIS,'ylabel'),'userdata');
		  otherpos = otherpos(find(~isin(otherpos, abspos)));
		  if isempty(otherpos)
		    otherpos = 0;
		  end
		  set(get(LISTAXIS,'ylabel'),'userdata', otherpos);
		  colorset = get(backbox(pos),'facecolor');
		  set(backbox(pos),'visible','off');
		  set(listbox(pos),'selected', 'off', ...
		      'color', colorset)
		end
	      end
	      
	      if ~isempty(singlecallback)
		eval(singlecallback)
	      end
	      
	    else % selection is from elsewhere than clicking on text.
	      
	      % selecting from elsewhere NEVER means drag and drop
	      set(get(LISTAXIS,'ylabel'),'string','nodrop')
	      
	      % selection is RELATIVE TO USERDATA, not visible list.
	      % NOTE: there is no 'unselect' from outside requests
	      % just select 0, then reselect desired.
	      relpos = pos-listboxtop+1;
	      if strcmp(mode, 'mono')
		set(get(LISTAXIS,'ylabel'),'userdata', pos);
		% check if something is currently selected
		% and if so, unselect it
		h = findobj(LISTAXIS,'selected','on');
		if ~isempty(h)
		  for i = 1:length(h)
		    oldpos = find(listbox == h(i));
		    colorset = get(backbox(oldpos),'facecolor');
		    set(listbox(oldpos),'selected','off', ...
			'color', colorset)
		    set(backbox(oldpos),'visible','off')
		  end
		end
		for i = 1:length(relpos)
		  if relpos(i) <= nframes & relpos(i) >= 1
		    % set the selection and highlighting
		    set(listbox(relpos(i)), 'selected', 'on', ...
			'color', backgroundcolor)
		    set(backbox(relpos(i)),'visible','on')
		  end
		end
		
	      elseif strcmp(mode, 'multi')
		set(get(LISTAXIS,'ylabel'),'userdata', pos);
		for i = 1:length(relpos)
		  if relpos(i) <= nframes & relpos(i) >= 1
		    % set the selection and highlighting
		    set(listbox(relpos(i)), 'selected', 'on', ...
			'color', backgroundcolor)
		    set(backbox(relpos(i)),'visible','on')
		  end		  
		end % end of loop
	      end % end of multi
	    end % end of check for fromtext
	    
	  end % end of check for doubleclick/singleclick
	  
	else % pos == 0
	  % a request has come in to UNSELECT ALL
	  % check if something is currently selected
	  h = findobj(LISTAXIS,'selected','on');
	  if ~isempty(h)
	    for i = 1:length(h)
	      oldpos = find(listbox == h(i));
	      set(listbox(oldpos),'color', ...
		  get(backbox(oldpos),'facecolor'))
	    end
	  end
	  edgeline = clistbox('handle',LISTAXIS,'edgelines');
	  set(listbox, 'selected', 'off')
	  set([backbox(:); edgeline(:)], 'visible', 'off')
	  set(get(LISTAXIS,'ylabel'),'userdata', 0);
	end

      case 'singleclick'
	callback = get(LISTAXIS,'tag');
	if ~isempty(callback)
	  k = findstr(callback,'doubleclick:');
	  if ~isempty(k)
	    doublecallback = callback(k+12:length(callback));
	    singlecallback = callback(13:k-1);
	  else
	    doublecallback = '';
	    singlecallback = callback(13:length(callback));
	  end
	end
	argout = singleclick;
	
      case 'string'
	argout = get(LISTAXIS,'userdata');
	
      case 'tooltip'
	% get the "tooltips"
	str = '';
	listbox = clistbox('handle', LISTAXIS,'listboxes');
	if ~isempty(listbox)
	  h = get(listbox(1),'uicontextmenu');
	  k = get(h,'children');
	  for i = length(k)
	    str = str2mat(str, get(k(i),'label'));
	  end
	  str = str(2:size(str,1),:);
	end
	argout = str;
	
      case 'value'
	pos = get(get(LISTAXIS,'ylabel'),'userdata');
	argout = pos;
	
      case 'vscroll'
	% get scrollbar position
	slide = get(gcf,'currentobject');
	v = get(slide,'value');
	m = get(slide,'max');
	
	% get oldlistboxtop
	scrollstuff = get(get(LISTAXIS,'xlabel'),'userdata');
	oldlistboxtop = scrollstuff(1);
	scrollval = scrollstuff(2);
	
	% get handles to boxes
	listbox = clistbox('handle',LISTAXIS,'listboxes');
	backbox = clistbox('handle',LISTAXIS,'backboxes');
	nframes = size(listbox,1);
	
	% set the new top of the list
	listboxtop = round(m-v)+1;
	% if no actual scrolling has occured, exit without doing anything
	if listboxtop == oldlistboxtop
	  return
	end
	
	% at this point, we are sure real scrolling has occured
	% update the list box
	
	% get canonical string list
	newstring = get(LISTAXIS,'userdata');
	backgroundcolor = get(LISTAXIS,'color');
	colors = cat(1,newstring(:,2));
	colors = cat(1,colors{:});
	showlist = char(newstring(:,1));
	fontweight = cat(1,newstring(:,3));
	% get size of shown list
	[showlength showwidth] = size(showlist);
	
	% update the colors and text in response to scrolling
	if listboxtop+nframes > showlength
	  endloop = showlength - listboxtop + 1;
	  for i = 1:endloop
	    set(listbox(i), ...
		'string', showlist(i+listboxtop-1,scrollval:showwidth), ...
		'color', colors(i+listboxtop-1,:), ...
		'fontweight', fontweight{i+listboxtop-1})
	    set(backbox(i),'facecolor', colors(i+listboxtop-1,:), ...
		'vis','off')
	    
	  end
	  for i = endloop+1:nframes
	    set(listbox(i),'string','')
	    set(backbox(i),'vis','off')
	  end
	else
	  % text fills listbox
	  for i = 1:nframes
	    set(listbox(i), ...
		'string', showlist(i+listboxtop-1,scrollval:showwidth), ...
		'color', colors(i+listboxtop-1,:), ...
		'fontweight',fontweight{i+listboxtop-1})
	    set(backbox(i),'facecolor', colors(i+listboxtop-1,:), ...
		'vis','off')
	  end
	end
	
	% reset scroll history
	set(get(LISTAXIS,'xlabel'),'userdata',[listboxtop scrollval])
	
	% now that we have scrolled and colors are correct
	% reset the selected object highlighting
	pos = get(get(LISTAXIS,'ylabel'),'userdata');
	
	clistbox('handle', LISTAXIS, 'select', 0)
	
	if any(pos > 0)
	  clistbox('handle', LISTAXIS, 'select', pos, 'fromslide')
	end
	
    end
    
    % now return to user workspace
    return
  end
  
  % ARGUMENTS TO EXECUTE IN CONCERT ON AN *EXISTING* LISTBOX
  % set up flags to see if we need to reset the display afterward
  resetflag = 0;
  resizeflag = 0;
  handles = [];

  listbox = clistbox('handle', LISTAXIS, 'listboxes');
  backbox = clistbox('handle', LISTAXIS, 'backboxes');
  nframes = size(listbox,1);
  for i = 1:size(execargs,1)
    arg = deblank(execargs(i,:));
    switch arg
      case 'backgroundcolor'
	if isempty(handles)
	  handles = clistbox('handle',LISTAXIS,'frames and sliders');
	  frame = handles(1:2); slide = handles(3:4);
	end
	set([slide frame],'backgroundcolor', ...
	    backgroundcolor)
	set(LISTAXIS,'color',backgroundcolor, ...
	    'xcolor', backgroundcolor, 'ycolor', ...
	    backgroundcolor)
      
      case 'doubleclick'
	tag = get(LISTAXIS,'tag');
	k = findstr(tag,'doubleclick:');
	if isempty(k)
	  tag = [tag 'doubleclick:' doublecallback];
	else
	  tag = [ tag(1:k-1) 'doubleclick:' doublecallback];
	end
	set(LISTAXIS,'tag', tag)
	
      case 'dragfunction'
	parent = get(LISTAXIS,'parent');
	if strcmp(dragfunction,'on')
	  str1 = sprintf('clistbox(''''handle'''', %.20f, ''''drag'''')', ...
	      LISTAXIS);
	  str2 = sprintf('set(gcf,''''pointer'''',''''arrow''''); clistbox(''''handle'''', %.20f ,''''drop'''')', ...
	      LISTAXIS);
	  str = [ 'set(gcf,''windowbuttonmotionfcn'',' '''' str1, ...
		' '');', 'set(gcf,''windowbuttonupfcn'',' '''' str2, ...
		' '')'];
	  set(parent,'windowbuttondownfcn', str)
	  set(parent,'windowbuttonmotionfcn', '')
	  set(parent,'windowbuttonupfcn', '')
	else
	  set(parent,'windowbuttondownfcn','')
	  set(parent,'windowbuttonmotionfcn','')
	  set(parent,'windowbuttonupfcn','')
	end
      
      case 'dropfunction'
	set(get(LISTAXIS,'xlabel'), 'string', dropfunction)
      
      case 'fontname'
	set(listbox,'fontname',fontname)
	
      case 'fontsize'
	% get old fontsize and compare
	t = findobj(LISTAXIS,'type','text');
	if ~isempty(t)
	  oldfontsize = get(t(1),'fontsize');
	  if fontsize ~= oldfontsize
	    set(listbox,'fontsize', fontsize)
	    resizeflag = 1;
	  end
	end
      
      case 'highlightcolor'
	edgeline = clistbox('handle',LISTAXIS,'edgelines');
	set(edgeline,'color',highlightcolor)
	set(backbox,'edgecolor', highlightcolor)
      
      case 'mode'
	set(get(LISTAXIS,'zlabel'),'userdata', mode)
	
      case 'position'
	% get more handles
	handles = clistbox('handle',LISTAXIS,'frames and sliders');
	frame = handles(1:2); slide = handles(3:4);
	p = get(LISTAXIS,'pos');
	q = get(slide(1),'pos');
	sw = q(3); % slider width in units-of-the-moment
	% add in sliders for OVERALL size
	oldlistpos = [p(1) p(2)-sw ...
	      p(3)+sw p(4)+sw];
      
	if any(listpos ~= oldlistpos)
	  if any(listpos(3:4) ~= oldlistpos(3:4))
	    resizeflag = 1;
	  end
	  % SET NEW SIZE
	  % Convert from overall size to axis and slider sizes.
	  units = get(LISTAXIS,'units');
	  if ~strcmp(units,'pixels')
	    set(LISTAXIS, 'pos', listpos)
	    set([LISTAXIS frame slide],'units','pixels')
	    % this is new listpos in PIXELS
	    listpos = get(LISTAXIS,'pos');
	  end
	  % here we are using canonical sliderwith in PIXELS
	  listpos = [listpos(1) listpos(2)+sliderwidth ...
		listpos(3)-sliderwidth listpos(4)-sliderwidth];
	  slide1pos = [listpos(1)+listpos(3) listpos(2) sliderwidth ...
		listpos(4)];
	  slide2pos = [listpos(1) listpos(2)-sliderwidth ...
		listpos(3)+sliderwidth sliderwidth];
	  set([slide(1) frame(1)], 'pos', slide1pos)
	  set([slide(2) frame(2)], 'pos', slide2pos)
	  set(LISTAXIS,'pos', listpos)
	  % Finally, reset the units if necc.
	  if ~strcmp(units,'pixels')
	    set([LISTAXIS frame slide],'units',units)
	  end
	end
      
      case 'singleclick'
	tag = get(LISTAXIS,'tag');
	k = findstr(tag,'doubleclick:');
	if ~isempty(k)
	  tag = [ 'singleclick:' singlecallback tag];
	else
	  tag = [ 'singleclick:' singlecallback];
	end
	set(LISTAXIS,'tag', tag)
      
      case 'string'
	% set up the userdata
	if ~isempty(userdata)
	  if size(userdata,2) == 1;
	    [userdata(:,2)] = deal({foregroundcolor});
	  elseif size(userdata,2) == 2;
	    [userdata(:,3)] = deal({'normal'});
	  else
	    % userdata should be the correct size.
	  end
	end
	set(LISTAXIS,'userdata', userdata);
	resetflag = 1;
      
      case 'tooltip'
	% set up the "tooltips"
	if ~isempty(listbox)
	  h = get(listbox(1),'uicontextmenu');
	  k = get(h,'children');
	  delete(k)
	  for i = size(tooltip,1)
	    uimenu(h,'label',deblank(tooltip(i,:)));
	  end
	end
	
      case 'units'
	% get handles of everything that must have new units
	handles = clistbox('handle',LISTAXIS,'frames and sliders');
	frame = handles(1:2); slide = handles(3:4);
	% change over the units
	set([LISTAXIS slide frame],'units', units);
    
    end % end of switch
  end % end of for loop through execargs
  
  if resizeflag
    clistbox('handle', LISTAXIS, 'resize')
  end
  if resetflag
    clistbox('handle', LISTAXIS, 'reset')
  end
  
end
return
