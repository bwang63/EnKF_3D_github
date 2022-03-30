function [argout1] = mastershow(arg1, arg2, arg3, arg4)

% determined by browse
global dodsdir

% buffer is shared with listedit
global buffer

% local
global MASTER_FIGURE MASTER_LIST masterlist master_variables

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%        FUNCTIONS FOR THE MASTER LIST                               %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
switch arg1
  case 'changecolor'
    if ~isempty(findfig('DODS masterlist'))
      foregroundcolor = arg2(1,:);
      backgroundcolor = arg2(2,:);
      % now set things on the masterlist and listedit
      % clistboxes.  listedit will not need foregroundcolor
      set(MASTER_FIGURE, 'color', backgroundcolor)
      clistbox(MASTER_LIST, 'backgroundcolor', backgroundcolor)
      userdata = clistbox(MASTER_LIST,'string');
      userdata(:,2) = deal({foregroundcolor});
      clistbox(MASTER_LIST, 'string', userdata);
    end

  case 'fontsize'
    if ~isempty(findfig('DODS masterlist'))
      fontsize = arg2;
      clistbox(MASTER_LIST, 'fontsize', fontsize)
    end
    
  case 'getfigpos'
    if ~isempty(findfig('DODS masterlist'))
      un = get(MASTER_FIGURE, 'units');
      set(MASTER_FIGURE, 'units', 'pixels');
      figpos = get(MASTER_FIGURE, 'pos');
      set(MASTER_FIGURE,'units', un);
      argout1 = figpos;
    else
      argout1 = [0 0 0 0];
    end
  
  case 'mclose'
    if ~isempty(findfig('DODS masterlist'))
      set(MASTER_FIGURE,'visible','off')
    end

  case 'mcopy'
    % get position on visible list
    pos = clistbox(MASTER_LIST, 'value');
    if pos > 0
      buffer{1} = masterlist(pos);
      buffer{2} = 'master';
      buffer{3} = master_variables;
    end

  case 'mopen'
    if isempty(findfig('DODS masterlist'))
      fontsize = 0;
      colors = zeros(2,3);
      figsize = zeros(1,4);
      % set up the dataset/folder properties editing windows
      mastershow('start', fontsize, colors, figsize)
    end
    figure(MASTER_FIGURE)

  case 'mselall'
    % get position on visible list
    pos = 1:length(masterlist);
    clistbox(MASTER_LIST, 'select', pos)
    buffer{1} = masterlist(pos);
    buffer{2} = 'master';
    buffer{3} = master_variables;

  case 'newmaster'
    % get foregroundcolor
    if ~isempty(findfig('DODS masterlist'))
      userdata = clistbox(MASTER_LIST,'userdata');
      foregroundcolor = userdata{1,2};

      % get info from the new masterlist
      userdata = char(masterlist(:).string);
      userdata = cellstr(userdata);
      userdata(:,2) = deal({foregroundcolor});
      clistbox(MASTER_LIST, 'string', userdata);
    end
  
  case 'setfigpos'
    if ~isempty(findfig('DODS masterlist'))
      if any(figpos(3:4) == 0)
	browse_fig = browse('getfigno');
	un = get(browse_fig,'units');
	set(browse_fig,'units','pixels');
	b_offset = get(browse_fig,'pos');
	set(browse_fig,'units',un)
	fig_size = [370 300];
	fig_offset = [b_offset(1)+b_offset(3) - fig_size(1) ...
	      b_offset(2)+b_offset(4)-fig_size(2)+5];
	figpos = [fig_offset fig_size];
      end

      % set size
      un = get(MASTER_FIGURE, 'units');
      set(MASTER_FIGURE, 'units', 'pixels','pos', figpos);
      set(MASTER_FIGURE,'units', un);
    end

  case 'start'
    
    closefig('DODS masterlist')
    
    % set fontsize
    fontsize = arg2;
    if fontsize == 0
      fontsize = browse('getfontsize');
    end

    % set colors
    colors = arg3;
    if all(colors == 0)
      colors = browse('getcolors');
      colors = colors([6 1],:);
    end
    foregroundcolor = colors(1,:);
    backgroundcolor = colors(2,:);
    
    % set figure positions
    figpos = arg4;
    if any(figpos(3:4) == 0)
      figpos = browse('figpos', 6);
    end
    if any(figpos(3:4) == 0)
      browse_fig = browse('getfigno');
      un = get(browse_fig,'units');
      set(browse_fig,'units','pixels');
      b_offset = get(browse_fig,'pos');
      set(browse_fig,'units',un)
      fig_size = [370 300];
      fig_offset = [b_offset(1)+b_offset(3) - fig_size(1) ...
	    b_offset(2)+b_offset(4)-fig_size(2)+5];
      figpos = [fig_offset fig_size];
    end

    % set up the MASTER LIST WINDOW
    MASTER_FIGURE = figure('menubar','none','visible','off', ...
	'units','pixels','pos', figpos, ...
	'numbertitle','off','name', 'DODS Master Bookmarks List', ...
	'color', backgroundcolor, ...
	'resize','on', 'userdata','DODS masterlist');
  
    % set up editing menu options
    filemenu = uimenu(MASTER_FIGURE,'label','File');
    uimenu(filemenu,'label','Close', 'callback', ...
	'mastershow(''mclose'')');
    editmenu = uimenu(MASTER_FIGURE,'label','Edit');
    uimenu(editmenu,'label','Copy', ...
	'callback','mastershow(''mcopy'')','accelerator','C');
    uimenu(editmenu,'label','Select All', ...
	'callback','mastershow(''mselall'')','accelerator','A');

    % load the master data
    if isempty(masterlist)
      fname = [dodsdir 'brsdat2'];
      eval(['load ' fname])
    end

    % set up the clistbox
    userdata = char(masterlist(:).string);
    userdata = cellstr(userdata);
    userdata(:,2) = deal({foregroundcolor});
    userdata(:,3) = deal({['normal']});
    MASTER_LIST = clistbox('parent',MASTER_FIGURE, ...
	'backgroundcolor', backgroundcolor, ...
	'mode', 'override', 'fontsize', fontsize, ...
	'units','normalized', ...
	'string', userdata);
end
