function [outarg] = choosecolor(arg1, arg2, arg3, arg4);

global color_fig colorshow coloredit whichdodscolor

switch arg1
  case 'applycolor'
    choosecolor('setcolor')
    newcolor = get(colorshow,'backgroundcolor');
    browse('setcolor', whichdodscolor, newcolor);
    figure(color_fig)

  case 'changecolor'
    if isempty(findfig('DODS colors'))
      return
    end
    oldcolor = get(colorshow,'backgroundcolor');
    dods_colors = arg2;
    if all(dods_colors == 0)
      dods_colors = browse('getcolors');
    end
    k = findobj(color_fig,'type','uicontrol');
    set(k,'foregroundcolor',dods_colors(6,:));
    set(color_fig,'color', dods_colors(1,:));
    set(k,'backgroundcolor',dods_colors(1,:));
    set(coloredit,'backgroundcolor', dods_colors(5,:));
    set(colorshow,'backgroundcolor',oldcolor);
  
  case 'choosecolor'
    if isempty(findfig('DODS colors'))
      fontsize = 0;
      figsize = zeros(1,4);
      colors = zeros(3,3);
      % set up the dataset/folder properties editing windows
      choosecolor('start', fontsize, figsize, colors)
    end
    whichdodscolor = arg2;
    dods_colors = browse('getcolors');
    currentcolor = dods_colors(whichdodscolor,:);
    set(colorshow,'backgroundcolor', currentcolor)
    str = sprintf('%g ', currentcolor);
    set(coloredit,'string', str);
    figure(color_fig)
    
  case 'close'
    if isempty(findfig('DODS colors'))
      return
    end
    set(color_fig,'vis','off');
    
  case 'getcolorpos'
    c = get(gca,'currentpoint'); c = round(c(1,1:2));
    cmap = get(gca,'userdata');
    cmapindex = (c(2)-1)*3+c(1);
    set(colorshow,'backgroundcolor', cmap(cmapindex,:));
    str = sprintf('%g ', cmap(cmapindex,:));
    set(coloredit,'string', str);

  case 'getfigpos'
    outarg = zeros(1,4);
    if isempty(findfig('DODS colors'))
      return
    end

    % edit figure
    un = get(color_fig, 'units');
    set(color_fig, 'units', 'pixels');
    figpos = get(color_fig, 'pos');
    set(color_fig,'units', un);
    outarg = figpos;
    
  case 'setcolor'
    newcolor = deblank(get(coloredit, 'string'));
    newcolor = sscanf(newcolor,'%g');
    newcolor = newcolor(:)';
    if all(size(newcolor) == [1 3])
      if all(newcolor >= 0) & all(newcolor <= 1)
	set(colorshow,'backgroundcolor',newcolor)
      else
	oldcolor = get(colorshow,'backgroundcolor');
	str = sprintf('%g ',oldcolor);
	set(coloredit,'string', str)
      end
    else
      oldcolor = get(colorshow,'backgroundcolor');
      str = sprintf('%g ',oldcolor);
      set(coloredit,'string', str)
    end

  case 'setfigpos'
    if isempty(findfig('DODS colors'))
      return
    end
    
    figsize = arg2;
    if any(figsize(3:4) == 0)
      % set up default figure size
      k = get(0,'units');
      set(0,'units','pixels')
      scr_size = get(0,'ScreenSize'); scr_offset = scr_size(1:2); 
      scr_size = scr_size(3:4);
      set(0,'units',k)
      fig_size = [300 300];
      fig_offset = scr_size - fig_size + [40 -55];
      figsize = [fig_offset fig_size];
    end
    un = get(color_fig,'units');
    set(color_fig, 'units','pixels','pos', figsize)
    set(color_fig,'units',un);
      
  case 'start'
    fontsize = arg2;
    if fontsize == 0
      fontsize = browse('getfontsize');
    end
    
    colorfigpos = arg3;
    if any(colorfigpos(3:4) == 0)
      colorfigpos = browse('figpos',2);
    end
    if any(colorfigpos(3:4) == 0)
      % set default browser figure size:
      scr_size = get(0,'ScreenSize'); scr_offset = scr_size(1:2); 
      scr_size = scr_size(3:4);
      fig_size = [300 300];
      fig_offset = scr_size - fig_size + [40 -55];
      colorfigpos = [fig_offset fig_size];
    end

    colors = arg4;
    if all(colors == 0)
      colors = browse('getcolors');
      colors = colors([6 1 5],:);
    end
    foregroundcolor = colors(1,:);
    backgroundcolor = colors(2,:);
    editcolor = colors(3,:);
    % create the figure
    cmap = [0 0 0; 0.5 0.5 0.5; 1 1 1; 1 0 0; 0 1 0; ...
      0 0 1; 1 1 0; 1 0 1; 0 1 1];

    color_fig = figure('NumberTitle','off', ...
	'Name', 'DODS Color Chooser', ...
	'units','pixels' ,...
	'Position', colorfigpos, ...
	'interruptible','on', ...
	'resize','off', ...
	'color', backgroundcolor, ...
	'visible','off', ...
	'userdata','DODS colors', ...
	'menubar','none', 'colormap', cmap);
    uicontrol(color_fig,'style','frame','units','norm', ...
	'pos',[0 0 1 0.25],'backgroundcolor', backgroundcolor);
    str = sprintf('%s\n%s\n%s', 'Choose a color by clicking', ...
	'on the squares at left','or type in a value below.');
    uicontrol(color_fig,'style','edit','units','norm', ...
	'max', 3, ...
	'pos', [0.45 0.6 0.45 0.16], 'string', str, ...
	'foregroundcolor', foregroundcolor, ...
	'backgroundcolor', backgroundcolor);
    uicontrol(color_fig,'style','push','units','norm', ...
	'pos',[0.1 0.05 0.15 0.1],'string','Ok', ...
	'foregroundcolor', foregroundcolor, ...
	'backgroundcolor', backgroundcolor, ...
	'callback', ...
	'choosecolor(''applycolor''); choosecolor(''close'')', ...
	'fontsize',fontsize)
    uicontrol(color_fig,'style','push','units','norm', ...
	'pos',[0.42 0.05 0.155 0.1],'string','Cancel', ...
	'foregroundcolor', foregroundcolor, ...
	'backgroundcolor', backgroundcolor, ...
	'callback', 'choosecolor(''close'')', ...
	'fontsize', fontsize);
    uicontrol(color_fig,'style','push','units','norm', ...
	'pos',[0.75 0.05 0.15 0.1],'string','Apply', ...
	'foregroundcolor', foregroundcolor, ...
	'backgroundcolor', backgroundcolor, ...
	'callback', ...
	'choosecolor(''applycolor'')', ...
	'fontsize', fontsize);
    colorshow = uicontrol(color_fig,'style','frame', ...
	'units','norm', ...
	'pos',[0.1 0.44 0.08 0.08], ...
	'backgroundcolor', backgroundcolor);
    coloredit = uicontrol(color_fig,'style','edit', ...
	'units','norm', ...
	'fontsize',fontsize, ...
	'pos',[0.2 0.44 0.57 0.08],'backgroundcolor', editcolor, ...
	'foregroundcolor', foregroundcolor, ...
	'horizontalalign','left', ...
	'tooltip','Color is a R-G-B vector with values from 0 - 1', ...
	'callback','choosecolor(''setcolor'')');

    axes('units','norm','pos', [0.1 0.6 0.3 0.3], ...
	'xlim',[0.5 3.5],'ylim',[0.5 3.5],'nextplot','add', ...
	'PlotBoxAspectRatio',[1 1 1], 'xtick',[],'ytick',[], ...
	'userdata', cmap)
    z = [1 1, 2 2, 3 3; 4 4, 5 5, 6 6; 7 7, 8 8, 9 9];
    image([0.75 3.25], [1 3], z,  ...
	'buttondownfcn', 'choosecolor(''getcolorpos'')');
    x = [0.5 0.5]; y = [0.5 3.5];
    for i = 0:3
      plot(x+i,y,'k','linew',2); 
    end
    x = [0.5 3.5]; y = [0.5 0.5];
    for i = 0:3
      plot(x,y+i,'k','linew',2); 
    end
    
end

return
