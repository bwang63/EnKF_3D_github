function argout = dscrolllist(arg1, arg2, arg3, arg4)

% from browse
global browse_fig userlist dset var lonmin lonmax user_num_vars 
global num_rang ranges user_num_sets brs_old_dset datasets 
global variables user_dataprops user_variables oldpos

% shared with listedit
global folder_start folder_end

% local to this program
global DSCROLL DSCROLL_LIST

if nargin < 1
  error('DSCROLLLIST requires at least one input argument')
  return
end

folder_start = '>>'; folder_end = '<<';

switch arg1
  case 'changecolor'
    if isempty(findfig('DODS datasets'))
      return
    end

    foregroundcolor = arg2(1,:);
    backgroundcolor = arg2(2,:);
    for i = 1:length(userlist)
      if isfolder(userlist,i) | isendfolder(userlist, i)
	userlist(i).color = foregroundcolor;
      end
    end
    clistbox(DSCROLL_LIST, 'backgroundcolor', backgroundcolor);
    set(DSCROLL, 'color', backgroundcolor);
    dscrolllist('userdata')
  
  case 'datset'
    if isempty(findfig('DODS datasets'))
      fontsize = 0;
      colors = zeros(1,3);
      figsizes = zeros(1,4);
      % set up the dataset/folder properties editing windows
      dscrolllist('start', fontsize, colors, figsizes)
    end
    type = arg2;
    [dset, datasets] = findvalidsets(type, dset, var, num_rang, ...
	ranges, lonmax, lonmin, user_num_sets, ...
	cat(1,userlist.rangemax), cat(1,userlist.rangemin), ...
	user_dataprops);

    % now, if some dataset is selected, find the folder
    % it's in ....
    level = cat(1,userlist.nestinglevel);
    highlightpos = zeros(length(datasets),1);
  
    if isnan(dset) & isnan(var) & (sum(num_rang) == 0)
      % NOTHING at all has been selected.  Don't do any highlighting
    else
      for i = 1:size(datasets,1)
	if datasets(i) % valid dataset
	  highlightpos(i) = 1;
	  if level(i) > 0
	    % find the parent folders for this dataset
	    thislevel = level(i);
	    thispos = i;
	    while thislevel > 0
	      q = max(find(level(1:thispos-1) == (thislevel - 1)));
	      highlightpos(q) = 1;
	      thispos = q;
	      thislevel = thislevel - 1;
	    end
	  end
	end
      end % end of for loop
    end % end of check for any selections
    
    % reset the fontweight
    [userlist(:).fontweight] = deal('normal');
  
    % update the fontweight -- valid sets are bold
    if any(highlightpos)
      highlightpos = find(highlightpos);
      [userlist(highlightpos).fontweight] = deal('bold');
    end
    
    % reset the visible list
    dscrolllist('userdata')

    if isnan(dset)
      clistbox(DSCROLL_LIST, 'select', 0)
    end

    if strcmp(type,'full')
      x = find(datasets);
      if ~isempty(x)
	if length(x) == 1
	  variables = user_dataprops(x,:)';
	else
	  variables = (sum(user_dataprops(x,:)) > 0)';
	end
      else % no dataset is selected
	variables = ones(user_num_vars,1);
      end
      % reset the variables list
      vscrolllist('userdata')
      
    elseif strcmp(type,'sub')
      % nothing special need be done
    end

  case 'doubleclick' % doubleclick opens/closes folder
    % this is a double click
    pos = dscrolllist('getpos');
    if isfolder(userlist, pos)
      % flip open to closed and vice versa
      userlist(pos).open = ~userlist(pos).open;
      
      % reset list box with new list
      dscrolllist('userdata')
    end

  case 'dreset'
    if isempty(findfig('DODS datasets'))
      fontsize = 0;
      colors = zeros(1,3);
      figsizes = zeros(1,4);
      % set up the dataset/folder properties editing windows
      dscrolllist('start', fontsize, colors, figsizes)
    end

    % unselect dataset
    dset = nan;
    
    % set all to potentially valid
    datasets = zeros(user_num_sets,1);
    clistbox(DSCROLL_LIST, 'select', 0)
    [userlist(:).fontweight] = deal('normal');
    dscrolllist('userdata')
    browse('ylabel')
  
  case 'dselect'
    if isempty(findfig('DODS datasets'))
      fontsize = 0;
      colors = zeros(1,3);
      figsizes = zeros(1,4);
      % set up the dataset/folder properties editing windows
      dscrolllist('start', fontsize, colors, figsizes)
    end
    if nargin == 1
      % select a dataset
      pos = dscrolllist('getpos');
    else
      pos = arg2;
    end

  if nargin == 1
    % WE ARE BEING CALLED BY THE DSCROLLLIST ITSELF
    if pos == 0
      dset = nan;
      datasets = zeros(user_num_sets,1);
      % this calls userdata as well to reset other window
      dscrolllist('datset','full')
      browse('ylabel')
    else
      if ~isfolder(userlist,pos)
	brs_old_dset = dset;
	dset = pos;
	% find out what else is valid
	dscrolllist('datset','sub')
	if isnan(dset)
	  % NEW 00/10/25: FORCE SELECTION OF THIS DATASET
	  dset = pos;
	  dscrolllist('specialselect')
	  num_rang = zeros(8,1);
	  % browse('setdset'), which follows
	  % will take care of setting range boxes etc.
	end
	% if some of the current variables are not in the dataset, 
	% de-select those variables
	if any(~isnan(var))
	  if any(~user_dataprops(dset,var))
	    i = find(user_dataprops(dset,var));
	    if ~isempty(i) 
	      var = var(i);
	    else
	      % NO currently selected variables are valid;
	      var = nan;
	    end
	  end
	end
	% reset other window with possible variables
	variables = user_dataprops(dset,:)';
	vscrolllist('userdata')
	if sum(variables) == 1 & isnan(var)
	  x = find(variables);
	  % this takes care of setting var
	  vscrolllist('vselect', x)
	end
	% reset browser
	browse('setdset')
      else
	% we have just selected a folder
	% unselect the dataset but do nothing else
	brs_old_dset = dset;
	dset = nan;
      end
    end
  else
    % WE ARE BEING CALLED BY THE VSCROLLLIST MENU
    % MEANING DSET WILL NEVER BE NAN AND THE SELECTED
    % POSITION WILL NEVER BE A FOLDER.
    brs_old_dset = dset;
    dset = pos;
    %      [userlist(:).fontweight] = deal('normal');
    dscrolllist('userdata')
      
    % if some of the current variables are not in the dataset, 
    % de-select those variables
    if any(~isnan(var))
      if any(~user_dataprops(dset,var))
	i = find(user_dataprops(dset,var));
	if ~isempty(i) 
	  var = var(i);
	else
	  var = nan;
	end
      end
    end
    % reset other window with possible variables
    variables = user_dataprops(dset,:)';
    vscrolllist('userdata')
    if sum(variables) == 1 & isnan(var)
      x = find(variables);
      % this takes care of setting var
      vscrolllist('vselect', x)
    end
    % reset browser
    % BROWSE ALSO CALLS dscrolllist('datset').
    % ARE ALL THESE CALLS NECESSARY???
    browse('setdset')
  end
    
      
  case 'edit'
    listedit('newlists', userlist, user_variables)

  case 'fontsize'
    if isempty(findfig('DODS datasets'))
      return
    end
    fontsize = arg2;
    clistbox(DSCROLL_LIST, 'fontsize', fontsize)

  case 'getfigpos'
    argout = zeros(1,4);
    if isempty(findfig('DODS datasets'))
      return
    end
    un = get(DSCROLL, 'units');
    set(DSCROLL, 'units', 'pixels');
    figpos = get(DSCROLL, 'pos');
    set(DSCROLL,'units', un);
    argout = figpos;

  case 'getpos'
    % get position on visible list
    pos = clistbox(DSCROLL_LIST, 'value');
    % get the relative position in the userlist
    index = cat(1,userlist(:).show);
    index = find(index);
    if pos > 0
      pos = index(pos);
    end
    argout = pos;

  case 'setfigpos'
    if isempty(findfig('DODS datasets'))
      return
    end

    figpos = arg2;
    if any(figpos(3:4) == 0)
      figpos = browse('figpos', 4);
    end
    if any(figpos(3:4) == 0)
      browse_fig = browse('getfigno');
      un = get(browse_fig,'units');
      set(browse_fig,'units','pixels');
      b_offset = get(browse_fig,'pos');
      set(browse_fig,'units',un)
      fig_size = [370 300];
      fig_offset = [b_offset(1)-30 ...
	    b_offset(2)+b_offset(4)-fig_size(2)-30];
      figpos = [fig_offset fig_size];
    end
    un = get(DSCROLL, 'units');
    set(DSCROLL, 'units', 'pixels', 'pos', figpos);
    set(DSCROLL,'units', un);

  case 'showlist'
    if isempty(findfig('DODS datasets'))
      fontsize = 0;
      colors = zeros(1,3);
      figsizes = zeros(1,4);
      % set up the dataset/folder properties editing windows
      dscrolllist('start', fontsize, colors, figsizes)
    end
    figure(DSCROLL)

  case 'specialselect'
    if isempty(findfig('DODS datasets'))
      fontsize = 0;
      colors = zeros(1,3);
      figsizes = zeros(1,4);
      % set up the dataset/folder properties editing windows
      dscrolllist('start', fontsize, colors, figsizes)
    end
    if ~isnan(dset)
      % extract items that should be shown from the database
      show = cat(1,userlist(:).show);
      % get relative position and highlight it
      sel = sum(show(1:dset));
      clistbox(DSCROLL_LIST,'select', sel)
    end
    
  case 'start'
    % close any existing such window
    closefig('DODS datasets')

    % fontsize
    fontsize = arg2;
    if fontsize == 0
      fontsize = browse('getfontsize');
    end
    
    % colors
    colors = arg3;
    if all(colors == 0)
      colors = browse('getcolors');
      colors = colors(1,:);
    end
    backgroundcolor = colors;

    % figure positions
    figpos = arg4;

    if any(figpos(3:4) == 0)
      figpos = browse('figpos', 4);
    end
    
    if any(figpos(3:4) == 0)
      browse_fig = browse('getfigno');
      un = get(browse_fig,'units');
      set(browse_fig,'units','pixels');
      b_offset = get(browse_fig,'pos');
      set(browse_fig,'units',un)
      fig_size = [370 300];
      fig_offset = [b_offset(1)-30 ...
	    b_offset(2)+b_offset(4)-fig_size(2)-30];
      figpos = [fig_offset fig_size];
    end
    
    DSCROLL = figure('menubar','none','visible','off', ...
	'units', 'pixels', 'pos', figpos, ...
	'numbertitle', 'off','name', 'DODS Browse Bookmarks', ...
	'userdata','DODS datasets', ...
	'resize','on', 'color', backgroundcolor);
    menu = uimenu(DSCROLL,'label','Bookmarks');
    uimenu(menu,'label','Edit Bookmarks', ...
	'callback', 'dscrolllist(''edit'')');
    
    str  = sprintf('%s','Double-click to open/close a folder.');
    DSCROLL_LIST = clistbox('parent',DSCROLL, 'units', 'norm', ...
	'backgroundcolor', backgroundcolor, 'mode','mono', ...
	'fontsize', fontsize, 'tooltip', str, ...
	'doubleclick', 'dscrolllist(''doubleclick'')', ...
	'singleclick', 'dscrolllist(''dselect'')');


    % NEW ON 2001/01/17
    % reset font and italicization of userlist based
    % on restored ranges (or lack thereof).
    dscrolllist('datset','full')
    
    % INSTEAD OF THIS:
    %    % reset the list
    %    dscrolllist('userdata')
    
    %    dscrolllist('specialselect')
    %    if ~isnan(dset)
    %      if ~isfolder(userlist,dset)
    %	% reset other window with possible variables
    %	variables = user_dataprops(dset,:)';
    %      end
    %    else
    %      variables = ones(user_num_vars,1);
    %    end

    % FINALLY, REVEAL THE PRIMARY FIGURE
    set(DSCROLL,'visible','on')
    
    if nargout > 0
      argout = DSCROLL;
    end

  case 'userdata'
    % set the color frames and text in the visible list to
    % respond to changes due to double-clicking

    % first update strings
    userlist = dlist2slist(userlist);
    if ~isempty(userlist)

      % extract items that should be shown from the database
      showlist = char(userlist(:).string);
      colors = cat(1,userlist(:).color);
      fontweight = char(userlist(:).fontweight);
      show = cat(1,userlist(:).show);
      show = find(show);
      showlist = showlist(show,:);
      colors = colors(show,:);
      fontweight = fontweight(show,:);
    
      % first column is the string to be shown
      % second column is the color of the string
      % third column is the highlight/don't highlight boolean
      % We start off with nothing highlighted.
      userdata = cellstr(showlist);
      userdata(:,2) = num2cell(colors,2);
      userdata(:,3) = cellstr(fontweight);
    else
      userdata = cell({});
    end
    % update the userdata in the clistbox
    clistbox(DSCROLL_LIST, 'string', userdata)
  
end
return
