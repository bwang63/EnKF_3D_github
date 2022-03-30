function [argout1] = dodspropedit(arg1, arg2, arg3, arg4)

% determined externally
global folder_start folder_end

% used locally
global PROP_FIGURE propeditboxes propeditcolor archivebutton
global editboxcontents propbuffer

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%         BASIC CONTROL OF FIGURES AND LOADING NEW LISTS             %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
switch arg1
  case 'changecolor'
    if ~isempty(findfig('DODS propedit'))
      foregroundcolor = arg2(1,:);
      backgroundcolor = arg2(2,:);
      editcolor = arg2(3,:);
      datacolor = get(propeditcolor,'backgroundcolor');
      
      % set things in the PROP_FIGURE window
      k = findobj(PROP_FIGURE,'type','uicontrol');
      set(k,'foregroundcolor', foregroundcolor, ...
	  'backgroundcolor', backgroundcolor)
      set(propeditboxes, 'foregroundcolor', foregroundcolor, ...
	  'backgroundcolor', editcolor)
      set(propeditcolor,'backgroundcolor', datacolor)
      set(PROP_FIGURE, 'color', backgroundcolor)
    end
    
  case 'close'
    if isempty(findfig('DODS propedit'))
      return
    end
    % cancel edit session
    set(PROP_FIGURE,'visible','off');
  
  case 'doeval'
    % first check if changes made that are not applied.
    newname = deblank(get(propeditboxes(1),'string'));
    newarchive = deblank(get(propeditboxes(2),'string'));
    newcolor = deblank(get(propeditboxes(3),'string'));
    newcolor = sscanf(newcolor,'%g');
    newcolor = newcolor(:)';
    
    if ~strcmp(newname,editboxcontents{1}) | ...
	  ~strcmp(newarchive, editboxcontents{2}) | ...
	  ~all(newcolor == editboxcontents{3})
      str = 'Please ''Apply'' your changes first.';
      dodsmsg(str)
      return
    end
    listedit('doeval')
    
  case 'eframe'
    newcolor = deblank(get(propeditboxes(3),'string'));
    newcolor = sscanf(newcolor,'%g');
    newcolor = newcolor(:)';
    if all(size(newcolor) == [1 3])
      if all(newcolor >= 0) & all(newcolor <= 1)
	set(propeditcolor,'backgroundcolor',newcolor)
      else
	% send error message
      end
    else
      % send error message
    end
    
  case 'eprops'
    if isempty(findfig('DODS propedit'))
      return
    end
    % update properties in the edit window
    pos = 1;
    propbuffer = arg2;
    backgroundcolor = get(PROP_FIGURE,'color');
    if (size(propbuffer,1) == 1)
      psize = size(folder_start,2);
      showstring = deblank(propbuffer(pos).name);
      if isfolder(propbuffer, pos)
	showstring = deblank(showstring(psize+1:length(showstring)));
	set(propeditboxes(1),'string',showstring)
	set(propeditboxes(2),'string','N/A')
	set(propeditcolor,'backgroundcolor', backgroundcolor)
	set(propeditboxes(3),'string','N/A')
	set(propeditboxes(4),'string','N/A')
	set(archivebutton,'vis','off')
      else
	% this is a dataset
	showstring = deblank(showstring);
	archive = deblank(propbuffer(pos).archive);
	dataname = deblank(propbuffer(pos).dataname);
	color = sprintf('%g %g %g',propbuffer(pos).color);
	set(propeditboxes(1),'string',showstring)
	set(propeditboxes(2),'string',archive)
	set(propeditcolor,'backgroundcolor',propbuffer(pos).color)
	set(propeditboxes(3),'string',color)
	set(propeditboxes(4),'string', dataname)
	set(archivebutton,'vis','on')
	editboxcontents = cell(1,3);
	% save this information in the editboxcontents
	editboxcontents{1} = showstring;
	editboxcontents{2} = archive;
	editboxcontents{3} = propbuffer(pos).color;
      end
    else % multiple selections or no selection!
      set(propeditboxes(1),'string','')
      set(propeditboxes(2),'string','')
      set(propeditcolor,'backgroundcolor', backgroundcolor)
      set(propeditboxes(3),'string','')
      set(propeditboxes(4),'string','')
      set(archivebutton,'vis','off')
    end
    
  case 'finished'
    % set properties
    dodspropedit('setprops')
    
    % close the figure
    set(PROP_FIGURE,'visible','off');
    
  case 'fontsize'
    if ~isempty(findfig('DODS propedit'))
      fontsize = arg2;
      set(propeditboxes, 'fontsize', fontsize)
    end
    
  case 'getfigpos'
    argout1 = zeros(1,4);
    if isempty(findfig('DODS propedit'))
      return
    end
    % properties figure
    un = get(PROP_FIGURE, 'units');
    set(PROP_FIGURE, 'units', 'pixels');
    figpos = get(PROP_FIGURE, 'pos');
    set(PROP_FIGURE,'units', un);
    argout1 = figpos;

  case 'setfigpos'
    if isempty(findfig('DODS propedit'))
      return
    end
  
    figpos = arg2;
    if any(figpos(3:4) == 0)
      figpos = browse('figpos', 7);
    end
    if any(figpos(3:4) == 0)
      browse_fig = browse('getfigno');
      un = get(browse_fig,'units');
      set(browse_fig,'units','pixels');
      b_offset = get(browse_fig,'pos');
      set(browse_fig,'units',un)
      fig_size = [415 300];
      fig_offset = [b_offset(1)+b_offset(3) - fig_size(1) - 55 ...
	    b_offset(2)+b_offset(4)-fig_size(2)+5];
      figpos = [fig_offset fig_size];
    end
    % properties figure
    un = get(PROP_FIGURE, 'units');
    set(PROP_FIGURE, 'units', 'pixels', 'pos', figpos);
    set(PROP_FIGURE,'units', un);
    
  case 'setprops'
    % set editable properties of the selected dataset/folder
    pos = 1;
    if isfolder(propbuffer, pos)
      newname = deblank(get(propeditboxes(1),'string'));
      newarchive = '';
      propbuffer(pos).name = [folder_start newname];
    else
      newname = deblank(get(propeditboxes(1),'string'));
      propbuffer(pos).name = newname;
      newarchive = deblank(get(propeditboxes(2),'string'));
      propbuffer(pos).archive = newarchive;
      newcolor = deblank(get(propeditboxes(3),'string'));
      newcolor = sscanf(newcolor,'%g');
      newcolor = newcolor(:)';
      if all(size(newcolor) == [1 3])
	if all(newcolor >= 0) & all(newcolor <= 1)
	  propbuffer(pos).color = newcolor;
	end
      end
    end
    % save this information in the editboxcontents
    editboxcontents{1} = newname;
    editboxcontents{2} = newarchive;
    editboxcontents{3} = propbuffer(pos).color;

    % propagate changes to listedit
    listedit('setprops', propbuffer)
    
  case 'showprops'
    if isempty(findfig('DODS propedit'))
      fontsize = 0;
      colors = zeros(3,3);
      figsize = zeros(1,4);
      dodspropedit('start', fontsize, colors, figsize)
      newdata = listedit('eprops');
      dodspropedit('eprops', newdata);
    end
    figure(PROP_FIGURE)
    
  case 'start'
    % close any existing figure
    closefig('DODS propedit')
    
    % set fontsize
    fontsize = arg2;
    if fontsize == 0
      fontsize = browse('getfontsize');
    end
    
    % set colors
    colors = arg3;
    if all(colors == 0)
      colors = browse('getcolors');
      colors = colors([6 1 5],:);
    end
    foregroundcolor = colors(1,:);
    backgroundcolor = colors(2,:);
    editcolor = colors(3,:);
    
    % Set up The DATASET/FOLDER PROPERTIES EDITING WINDOW
    % set figure positions
    figpos = arg4;
    if any(figpos(3:4) == 0)
      figpos = browse('figpos', 7);
    end
    if any(figpos(3:4) == 0)
      browse_fig = browse('getfigno');
      un = get(browse_fig,'units');
      set(browse_fig,'units','pixels');
      b_offset = get(browse_fig,'pos');
      set(browse_fig,'units',un)
      fig_size = [415 300];
      fig_offset = [b_offset(1)+b_offset(3) - fig_size(1) - 55 ...
	    b_offset(2)+b_offset(4)-fig_size(2)+5];
      figpos = [fig_offset fig_size];
    end
    
    PROP_FIGURE = figure('menubar','none','visible','off', ...
	'units','pixels','pos', figpos, ...
	'color', backgroundcolor, ...
	'numbertitle','off','name', 'DODS Bookmark Properties', ...
	'resize','off', 'userdata','DODS propedit');
    uicontrol(PROP_FIGURE,'style','frame','units','norm', ...
	'pos',[0 0.6 1 0.4],'backgroundcolor', backgroundcolor);
    uicontrol(PROP_FIGURE,'style','frame','units','norm', ...
	'pos',[0 0 1 0.6],'backgroundcolor', backgroundcolor);
    uicontrol(PROP_FIGURE,'style','text', 'units','norm', ...
	'pos',[0.1 0.8 0.15 0.08], ...
	'backgroundcolor', backgroundcolor, ...
	'foregroundcolor', foregroundcolor, ...
	'fontsize',fontsize, ...
	'horizontalalign','right', ...
	'string', 'Dataname:');
    uicontrol(PROP_FIGURE,'style','text', 'units','norm', ...
	'pos',[0.1 0.42 0.15 0.08], ...
	'backgroundcolor',backgroundcolor, ...
	'foregroundcolor',foregroundcolor, ...
	'fontsize',fontsize, ...
	'horizontalalign','right', ...
	'string', 'Name:');
    uicontrol(PROP_FIGURE,'style','text', 'units','norm', ...
	'pos',[0.1 0.32 0.15 0.08], ...
	'backgroundcolor',backgroundcolor, ...
	'foregroundcolor',foregroundcolor, ...
	'fontsize',fontsize, ...
	'horizontalalign','right', ...
	'string', 'Archive:');
    uicontrol(PROP_FIGURE,'style','text', 'units','norm', ...
	'pos',[0.1 0.22 0.15 0.08], ...
	'backgroundcolor',backgroundcolor, ...
	'foregroundcolor',foregroundcolor, ...
	'fontsize',fontsize, ...
	'horizontalalign','right', ...
	'string', 'Color:');
    propeditcolor = uicontrol(PROP_FIGURE,'style','frame', ...
	'units','norm', ...
	'pos',[0.25 0.22 0.06 0.08], ...
	'backgroundcolor', backgroundcolor);
    
    propeditboxes(1) = uicontrol(PROP_FIGURE,'style','edit', ...
	'units','norm', ...
	'fontsize',fontsize, ...
	'pos',[0.25 0.42 0.65 0.08],'backgroundcolor',editcolor, ...
	'foregroundcolor', foregroundcolor, ...
	'horizontalalign','left');
    propeditboxes(2) = uicontrol(PROP_FIGURE,'style','edit', ...
	'units','norm', ...
	'fontsize',fontsize, ...
	'pos',[0.25 0.32 0.65 0.08],'backgroundcolor', editcolor, ...
	'foregroundcolor',foregroundcolor, ...
	'horizontalalign','left', ...
	'tooltip','Archive is an m-file with information about the dataset');
    propeditboxes(3) = uicontrol(PROP_FIGURE,'style','edit', ...
	'units','norm', ...
	'fontsize',fontsize, ...
	'pos',[0.33 0.22 0.57 0.08],'backgroundcolor', editcolor, ...
	'foregroundcolor', foregroundcolor, ...
	'horizontalalign','left', ...
	'tooltip','Color is a R-G-B vector with values from 0 - 1', ...
	'callback','dodspropedit(''eframe'')');
    propeditboxes(4) = uicontrol(PROP_FIGURE,'style','text', ...
	'units','norm', ...
	'fontsize',fontsize, ...
	'pos',[0.25 0.8 0.65 0.08],'backgroundcolor',[0.6 0.6 0.6], ...
	'foregroundcolor', foregroundcolor, ...
	'horizontalalign','center', ...
	'tooltip','Dataname in the archive file');
    editboxcontents = cell(1,3);

    % ok, cancel and apply
    uicontrol(PROP_FIGURE,'style','push','units','norm', ...
	'pos',[0.1 0.05 0.15 0.1],'string','Ok', ...
	'foregroundcolor', foregroundcolor, ...
	'backgroundcolor', backgroundcolor, ...
	'fontsize',fontsize, ...
	'callback','dodspropedit(''finished'')');
    uicontrol(PROP_FIGURE,'style','push','units','norm', ...
	'pos',[0.425 0.05 0.15 0.1],'string','Cancel', ...
	'foregroundcolor', foregroundcolor, ...
	'backgroundcolor', backgroundcolor, ...
	'fontsize', fontsize, ...
	'callback','dodspropedit(''close'')');
    uicontrol(PROP_FIGURE,'style','push','units','norm', ...
	'pos',[0.75 0.05 0.15 0.1],'string','Apply', ...
	'foregroundcolor', foregroundcolor, ...
	'backgroundcolor', backgroundcolor, ...
	'fontsize', fontsize, ...
	'callback','dodspropedit(''setprops'')');
    % reload the archive and clear the cached metadata
    uicontrol(PROP_FIGURE, 'style', 'text', ...
	'units', 'norm', ...
	'pos',[0.3 0.64 0.6 0.1], ...
	'string', [ 'Press to reload archive and clear cached ',...
	  'metadata.  This action cannot be undone.'], ...
	'horiz','left', ...
	'foregroundcolor', foregroundcolor, ...
	'backgroundcolor', backgroundcolor, ...
	'fontsize',fontsize)
    archivebutton = uicontrol(PROP_FIGURE, 'style', 'push', ...
	'units', 'norm', ...
	'pos',[0.1 0.64 0.2 0.1], ...
	'string', 'Reload/Clear', ...
	'foregroundcolor', foregroundcolor, ...
	'backgroundcolor', backgroundcolor, ...
	'fontsize',fontsize, ...
	'callback','dodspropedit(''doeval'')');
end

return
