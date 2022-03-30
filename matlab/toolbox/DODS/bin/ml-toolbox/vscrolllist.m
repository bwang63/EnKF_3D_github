function argout = vscrolllist(arg1, arg2, arg3, arg4)

% shared with other functions
global browse_fig user_variables dset var variables user_num_vars
global brs_old_var num_rang

% used only locally
global VSCROLL VSCROLL_LIST

if nargin < 1
  error('VSCROLLLIST requires at least one input argument')
  return
end

switch arg1
  case 'changecolor'
    if isempty(findfig('DODS variables'))
      return
    end
    foregroundcolor = arg2(1,:);
    backgroundcolor = arg2(2,:);
    set(VSCROLL,'color', backgroundcolor)
    clistbox(VSCROLL_LIST, 'backgroundcolor', backgroundcolor)
    userdata = clistbox(VSCROLL_LIST,'string');
    userdata(:,2) = deal({foregroundcolor});
    clistbox(VSCROLL_LIST, 'string', userdata);
    
  case 'fontsize'
    if isempty(findfig('DODS variables'))
      return
    end
    fontsize = arg2;
    clistbox(VSCROLL_LIST, 'fontsize', fontsize)
    
  case 'getpos'
    % get position on visible list
    pos = clistbox(VSCROLL_LIST, 'value');
    % get the relative position in the userlist
    index = find(variables);
    if pos > 0
      pos = index(pos);
    end
    argout = pos;
    
  case 'getfigpos'
    argout = zeros(1,4);
    if isempty(findfig('DODS variables'))
      return
    end
    % edit figure
    un = get(VSCROLL, 'units');
    set(VSCROLL, 'units', 'pixels');
    figpos = get(VSCROLL, 'pos');
    set(VSCROLL,'units', un);
    argout = figpos;

  case 'setfigpos'
    if isempty(findfig('DODS variables'))
      return
    end

    figpos = arg2;
    if any(figpos(3:4) == 0)
      figpos = browse('figpos', 8);
    end
    if any(figpos(3:4) == 0)
      browse_fig = browse('getfigno');
      un = get(browse_fig,'units');
      set(browse_fig,'units','pixels');
      b_offset = get(browse_fig,'pos');
      set(browse_fig,'units',un)
      fig_size = [150 420];
      fig_offset = [b_offset(1)-60 ...
	    b_offset(2)+b_offset(4)-fig_size(2)-60];
      figpos = [fig_offset fig_size];
    end
    un = get(VSCROLL, 'units');
    set(VSCROLL, 'units', 'pixels', 'pos', figpos);
    set(VSCROLL,'units', un);
    
  case 'showlist'
    if isempty(findfig('DODS variables'))
      fontsize = 0;
      colors = zeros(2,3);
      figsizes = zeros(1,4);
      % set up the dataset/folder properties editing windows
      vscrolllist('start', fontsize, colors, figsizes)
    end
    figure(VSCROLL)

  case 'start'
    closefig('DODS variables')
    
    fontsize = arg2;
    if fontsize == 0
      fontsize = browse('getfontsize');
    end

    colors = arg3;
    if all(colors == 0)
      colors = browse('getcolors');
      colors = colors([6 1],:);
    end
    foregroundcolor = colors(1,:);
    backgroundcolor = colors(2,:);
    
    figpos = arg4;
    if any(figpos(3:4) == 0)
      browse_fig = browse('getfigno');
      un = get(browse_fig,'units');
      set(browse_fig,'units','pixels');
      b_offset = get(browse_fig,'pos');
      set(browse_fig,'units',un)
      fig_size = [150 420];
      fig_offset = [b_offset(1)-60 ...
	    b_offset(2)+b_offset(4)-fig_size(2)-60];
      figpos = [fig_offset fig_size];
    end
    
    VSCROLL = figure('menubar','none','visible','off', ...
	'units', 'pixels', 'pos', figpos, ...
	'numbertitle', 'off','name', 'DODS Variables', ...
	'userdata','DODS variables', ...
	'resize', 'on', ...
	'color', backgroundcolor);
    
    % by not setting a doubleclick callback we ensure that
    % doubleclicks are simply treated as singleclicks.
    VSCROLL_LIST = clistbox('parent', VSCROLL, ...
	'backgroundcolor', backgroundcolor, ...
	'singleclick', 'vscrolllist(''vselect'')', ...
	'mode','multi', 'units', 'normalized', ...
	'fontsize', fontsize);

    % Set up the variables list window
    if ~isnan(dset)
      dscrolllist('datset','sub')
    end
    vscrolllist('userdata')
    
    % reveal the figure
    set(VSCROLL,'visible','on')
    
    if nargout > 0
      argout = VSCROLL;
    end
    
  case 'userdata'
    if isempty(findfig('DODS variables'))
      fontsize = 0;
      colors = zeros(2,3);
      figsizes = zeros(1,4);
      % set up the dataset/folder properties editing windows
      vscrolllist('start', fontsize, colors, figsizes)
    end
    
    % extract variables that should be shown
    i = find(variables);
    if ~isempty(i)
      nvars = length(i);
      showlist = user_variables(i,:);
      % find all underscores and replace with spaces
      % since Latex is the interpreter ...
      k = find(abs(showlist) == 95);
      showlist(k) = char(32);
      color = browse('getcolors');
      foregroundcolor = color(6,:);
      colors = cell(nvars,1);
      [colors(:)] = deal({[foregroundcolor]});
      userdata = cellstr(showlist);
      userdata(:,2) = colors;
    else
      userdata = cell({});
    end
    
    % remove all currently selected variables
    clistbox(VSCROLL_LIST,'select',0)
    % update the userdata in the clistbox
    clistbox(VSCROLL_LIST,'string',userdata)
    if any(~isnan(var))
      k = find(isin(i,var));
      clistbox(VSCROLL_LIST,'select', k)
    end
    
  case 'vreset'
    if isempty(findfig('DODS variables'))
      fontsize = 0;
      colors = zeros(2,3);
      figsizes = zeros(1,4);
      % set up the dataset/folder properties editing windows
      vscrolllist('start', fontsize, colors, figsizes)
    end
    % unselect variable
    var = nan;
    % set all variables to valid
    variables = ones(user_num_vars,1);
    clistbox(VSCROLL_LIST, 'select', 0)
    vscrolllist('userdata')
    
  case 'vselect'
    if isempty(findfig('DODS variables'))
      fontsize = 0;
      colors = zeros(2,3);
      figsizes = zeros(1,4);
      % set up the dataset/folder properties editing windows
      vscrolllist('start', fontsize, colors, figsizes)
    end
    brs_old_var = var;
    if nargin == 1
      newvar = vscrolllist('getpos');
    else
      newvar = arg2;
    end
    
    if nargin == 1
      % we are being called BY THE VSCROLLLIST ITSELF
      if any(newvar > 0)
	var = newvar;
	variables(var) = 1;
        if ~isnan(dset)
	  dscrolllist('datset','sub')
	else
	  dscrolllist('datset','full')
	end
	% reset browser
	browse('choose_var')
      else
	var = nan;
	variables = ones(user_num_vars,1);
	if ~isnan(dset)
	  % yes, this is absolutely necessary!
	  dscrolllist('dselect',dset)
	else
	  dscrolllist('datset','full')
	end
      end
    else
      % we are being called by the dscrolllist menu
      % because there is only one variable in the
      % selected dataset.  SELECT IT.
      var = newvar;
      variables = zeros(user_num_vars,1);
      variables(var) = 1;
      % calling dscrolllist also resets the vscrolllist
      if ~isnan(dset)
	dscrolllist('datset','sub')
      end
      vscrolllist('userdata')
      % reset browser
      browse('choose_var')
    end
    
end

return
