function [out1, out2] = dispmenu(argin1, argin2, argin3, argin4, argin5)
%
% DISPMENU      Part of the DODS data browser.
%
%            Deirdre Byrne, U Maine, 2000/01/07
%                 dbyrne@umeoce.maine.edu

% local variables
global display_menu display_data get_variables display_count
global display_choices display_fig display_metadata

if isstr(argin1)
  switch argin1
    case 'addplot'
      % reset display choices for each plot
      sz = size(display_choices,1);
      plotno = sz+1;
      display_choices = [display_choices(:); struct('acqno', 1, ...
	    'x', 1, 'x_slice', '', 'x_slicesize', '', ...
	    'y', 1, 'y_slice', '', 'y_slicesize', '', ...
	    'z', 1, 'z_slice', '', 'z_slicesize', '', ...
	    'zz', 1, 'zz_slice', '', 'zz_slicesize', '', ...
	    'figure', 'browse_fig', 'plot_type', 'imagesc', ...
	    'clim', [], ...
	    'cval', [], ...
	    'linestyle', '-', ...
	    'color', '', 'marker', 'none', 'shading', ...
	    'flat')]; 
      
      % find lat and lon and use as default x- and y- arguments
      if all(size(display_data) > 0)
	displayonbrowse = [0 0];
	acqno = display_choices(plotno).acqno;
	for j = 1:size(display_data(acqno).name,1)
	  % set lon and lat as default x- and y- variables
	  if ~isempty(instr('Longitude', display_data(acqno).name(j,:)))
	    whichvar = j;
	    display_choices(plotno).x = whichvar;
	    varname = deblank(display_data(acqno).name(whichvar,:));
            display_choices(plotno).x_slice = varname;
	    displayonbrowse(1) = 1;
	  end
	  if ~isempty(instr('Latitude', display_data(acqno).name(j,:)))
	    whichvar = j;
	    display_choices(plotno).y = whichvar;
	    varname = deblank(display_data(acqno).name(whichvar,:));
            display_choices(plotno).y_slice = varname;
	    displayonbrowse(2) = 1;
	  end

	  % set the default z- and zz- variables to the first
	  % selected variable
	  for k = 1:size(get_variables, 1)
	    if ~isempty(instr(deblank(get_variables(k,:)), ...
		  display_data(acqno).name(j,:)))
	      whichvar = j;
	      display_choices(plotno).z = whichvar;
	      display_choices(plotno).zz = whichvar;
	      varname = deblank(display_data(acqno).name(whichvar,:));
	      display_choices(plotno).z_slice = varname;
	      display_choices(plotno).zz_slice = varname;
	      break
	    end
	  end
	end % end of loop through names

	% if either lon or lat missing, suppress display on browser
	if ~all(displayonbrowse == 1)
	  display_choices(i).figure = 'figure';  
	end
	
	for varnum = 5:8
	  callbackstring = sprintf('%s%i%s%i%s%i%s%i%s', ...
	      '[browse_var, browse_slice] =  dispmenu(''getslice'',', ...
	      varnum, ...
	      [ '); if ~isempty(browse_slice), ', ...
		  'if exist(browse_var) == 1, browse_dims = nan; ', ...
		  'eval(browse_slice, ''% put error message here'');', ...
		  'dispmenu(''setslicesize'',' ], ...
	      varnum, ...
	      [ ', browse_dims), else, dispmenu(''setslicesize'',' ], ...
	      varnum, ...
	      [ ', 0); end; else, dispmenu(''setslicesize'',' ], ...
	      varnum, ...
	      [ ', 0); end; clear browse_slice browse_var browse_dims']);
	  evalin('base',callbackstring)
	end
      
%	fulldims = display_data(acqno).size{whichvar};
%	slicedims = fulldims;
%      
%	for varnum = 5:8
%	  dimstr = 'Slice size: ';
%	  fullstr = 'Full Downloaded size: ';
%	  for i = 1:length(fulldims)
%	    fullstr = [fullstr, sprintf('%i ', fulldims(i))];
%	  end
%	  set(display_menu{varnum}(3),'string', fullstr);
%	  
%	  for i = 1:length(slicedims)
%	    dimstr = [dimstr, sprintf('%i ', slicedims(i))];
%	  end
%	  set(display_menu{varnum}(4),'string', dimstr);
%	end
      end
      
      % refresh string for first listbox
      str = get(display_menu{1},'string');
      str = strvcat(str, sprintf('plot%i', plotno));
      set(display_menu{1}, 'string', str, 'value', plotno);
      
      set(cat(2, display_menu{[1:16]}), 'enable', 'on')
      set(display_menu{9}(4), 'enable', 'off')
      % calling case 1 will set all the buttons to a reasonable value
      dispmenu(1)

    case 'applytoall'
      % set everything except Rxx_ value
      whichplot = get(display_menu{1},'value');
      numplots = size(display_choices,1);

      % catch plot type change first
      if isstr(argin2)
	% do some things
	fig = display_choices(whichplot).figure;
	plot_type = display_choices(whichplot).plot_type;
	color = display_choices(whichplot).color;
	linestyle = display_choices(whichplot).linestyle;
	marker = display_choices(whichplot).marker;
	shading = display_choices(whichplot).shading;
	clim = display_choices(whichplot).clim;
	cval = display_choices(whichplot).cval;
	% reset all plot type options to these
	[display_choices(:).figure] = deal(fig);
	[display_choices(:).plot_type] = deal(plot_type);
	[display_choices(:).color] = deal(color);
	[display_choices(:).linestyle] = deal(linestyle);
	[display_choices(:).marker] = deal(marker);
	[display_choices(:).shading] = deal(shading);
	[display_choices(:).clim] = deal(clim);
	[display_choices(:).cval] = deal(cval);
	return
      end
      
      varnum = argin2;
      switch varnum
	case 5
	  whichvar = display_choices(whichplot).x;
	  slice = display_choices(whichplot).x_slice;
	  slicesize = display_choices(whichplot).x_slicesize;
	case 6
	  whichvar = display_choices(whichplot).y;
	  slice = display_choices(whichplot).y_slice;
	  slicesize = display_choices(whichplot).y_slicesize;
	case 7
	  whichvar = display_choices(whichplot).z;
	  slice = display_choices(whichplot).z_slice;
	  slicesize = display_choices(whichplot).z_slicesize;
	case 8
	  whichvar = display_choices(whichplot).zz;
	  slice = display_choices(whichplot).zz_slice;
	  slicesize = display_choices(whichplot).zz_slicesize;
      end
      
      acqno = display_choices(whichplot).acqno;
      varname = deblank(display_data(acqno).name(whichvar,:));
      if instr(varname, slice)
	prefix = sprintf('R%i_', acqno);
	l = size(prefix,2);
	rootname = varname(l+1:length(varname));
	if strcmp(varname, slice)
	  sliceprefix = '';	slicesuffix = '';
	else
	  k = instr(varname, slice);
	  l = size(varname, 2);
	  sliceprefix = slice(1:k-1);
	  slicesuffix = slice(k+l:length(slice));
	end

	cantapply = [];
	for i = 1:numplots
	  ac = display_choices(i).acqno;
	  name = deblank(display_data(ac).name(whichvar,:));
	  if instr(rootname, name)
	    % first check the same position on the variable list
	    switch varnum
	      case 5
		display_choices(i).x = whichvar;
		display_choices(i).x_slice = [sliceprefix name ...
		      slicesuffix];
	      case 6
		display_choices(i).y = whichvar;
		display_choices(i).y_slice = [sliceprefix name ...
		      slicesuffix];
	      case 7
		display_choices(i).z = whichvar;
		display_choices(i).z_slice = [sliceprefix name ...
		      slicesuffix];
	      case 8
		display_choices(i).zz = whichvar;
		display_choices(i).zz_slice = [sliceprefix name ...
		      slicesuffix];
	    end
	    
	    % get new slicesize
	    callbackstring = sprintf('%s%i%s%i%s%i%s%i%s', ...
		'[browse_var, browse_slice] =  dispmenu(''getslice'',', ...
		varnum, ...
		[ '); if ~isempty(browse_slice), ', ...
		    'if exist(browse_var) == 1, browse_dims = nan; ', ...
		    'eval(browse_slice, ''% put error message here'');', ...
		    'dispmenu(''setslicesize'',' ], ...
		  varnum, ...
		[ ', browse_dims), else, dispmenu(''setslicesize'',' ], ...
		  varnum, ...
	        [ ', 0); end; else, dispmenu(''setslicesize'',' ], ...
		  varnum, ...
	        [ ', 0); end; clear browse_slice browse_var browse_dims']);
	    evalin('base',callbackstring)
	    
	  else
	    % if no match there, check all variables
	    for j = 1:size(display_data(ac).name,1)
	      wv = 0;
	      if instr(rootname, name)
		wv = i;
		break
	      end
	    end
	    if wv > 0
	      display_choices(i).x = wv;
	      display_choices(i).x_slice = [sliceprefix name ...
		    slicesuffix];

	      % set new sizes of full and slice
	      dims = display_data(acqno).size{whichvar};
	      fullstr = 'Full Downloaded size: ';
	      for i = 1:length(dims)
		fullstr = [fullstr, sprintf('%i ', dims(i))];
	      end
	      set(display_menu{varnum}(3),'string', fullstr);

	      callbackstring = sprintf('%s%i%s%i%s%i%s%i%s', ...
		  '[browse_var, browse_slice] =  dispmenu(''getslice'',', ...
		    varnum, ...
		  [ '); if ~isempty(browse_slice), ', ...
		      'if exist(browse_var) == 1, browse_dims = nan; ', ...
		      'eval(browse_slice, ''% put error message here'');', ...
		      'dispmenu(''setslicesize'',' ], ...
		    varnum, ...
		  [ ', browse_dims), else, dispmenu(''setslicesize'',' ], ...
		    varnum, ...
		  [ ', 0); end; else, dispmenu(''setslicesize'',' ], ...
		    varnum, ...
		  [ ', 0); end; clear browse_slice browse_var browse_dims']);
	      evalin('base',callbackstring)
	    else
	      cantapply = [cantapply i];
	    end
	  end
	end % end of loop through plots
	
	if ~isempty(cantapply)
	  str = sprintf('plot%i ', cantapply);
	  str = sprintf('Change cannot be applied to plot(s) %s', str);
	  dodsmsg(str)
	end
	      
      else % variable name does not appear in slice
	% this is not allowed
      end
      
    case 'changecolor'
      if isempty(findfig('DODS display'))
	return
      end
      colors = argin2;
      k = findobj(display_fig,'type','uicontrol');
      set(k,'foregroundcolor',colors(1,:), ...
	  'backgroundcolor',colors(2,:))
      % all of the edit box handles
      h = cat(1,display_menu{5:8});
      h = h(:,5);
      h = h(:)';
      h = [h display_menu{4}];
      h = [h display_menu{15}(1)]; 
      set(h,'backgroundcolor', colors(3,:))
      return
      
    case 'delall'
      display_choices = display_choices([]);
      set(display_menu{1},'string', '')
      set(cat(2, display_menu{1:16}), 'enable', 'off')
      set(display_menu{9}(1), 'enable', 'on')
    
    case 'delplot'
      whichplot = get(display_menu{1},'value');
      if all(size(display_choices) > 0)
	sz = size(display_choices,1);
	if whichplot == 1;
	  display_choices = display_choices(2:sz);
	elseif whichplot < sz
	  display_choices = ...
	      display_choices([1:whichplot-1 whichplot+1:sz]);
	else
	  display_choices = display_choices([1:sz-1]);
	end
	% refresh string and display for first listbox
	sz = sz - 1;
	whichplot = whichplot - 1;
	if whichplot < 1, whichplot = 1; end
	str = '';
	for i = 1:sz
	  str = strvcat(str, sprintf('plot%i', i));
	end
	if sz > 0
	  set(display_menu{1}, 'string', str, 'value', whichplot);
	  % calling case 1 will set all the buttons to a reasonable value
	  dispmenu(1)
	else
	  display_choices = display_choices([]);
	  set(display_menu{1},'string', '')
	  set(cat(2, display_menu{1:16}), 'enable', 'off')
	  set(display_menu{9}(1), 'enable', 'on')
	end
      end
    
    case 'display'
      % this is called from unpack.m
      % start a new display figure if needed!
      if isempty(findfig('DODS display'))
	fontsize = 0;
	figsize = [0 0 0 0];
	colors = zeros(3,3);
	dispmenu('start', fontsize, figsize, colors)
      end

      if nargin == 5
	display_data = argin2;
	display_data = display_data(:);
	get_variables = argin3;
	display_count = argin4;
	display_metadata = argin5;
      end

      if nargin == 5
	% first, strip out 'Acknowledge' and 'URL' from variable names
	for i = 1:size(display_data,1)
	  sz = size(display_data(i).name,1);
	  keepvar = zeros(sz,1);
	  for j = 1:sz
	    if isempty(instr('_Acknowledge', ...
		  display_data(i).name(j,:))) & ...
		  isempty(instr('_URL', display_data(i).name(j,:)))
	      keepvar(j) = 1;
	    end
	  end
	  display_data(i).name = display_data(i).name(find(keepvar),:);
	  display_data(i).size = display_data(i).size(find(keepvar));
	  % next, add in 'none' variable at top of list.
	  display_data(i).name = strvcat('none', display_data(i).name);
	  display_data(i).size = [{0}; display_data(i).size];
	end
      end
      
      if isempty(char(display_data(:).name))
	set(cat(2, display_menu{1:16}), 'enable', 'off')
	display_acq_urls = 0;
      elseif all(strcmp('none',cellstr(char(display_data(:).name))))
	set(cat(2, display_menu{1:16}), 'enable', 'off')
	display_acq_urls = 0;
      else
	set(cat(2, display_menu{1:16}), 'enable', 'on')
	set(display_menu{9}(3), 'label','Set Z-data')
	set(display_menu{9}(4), 'enable', 'off')
	display_data = display_data(:);
	display_acq_urls = size(display_data, 1);
      end
      
      if display_acq_urls > 0
	% set/reset display choices for each plot
	[display_choices(1:display_acq_urls)] = ...
	    deal(struct('acqno', 1, ...
	    'x', 1, 'x_slice', '', 'x_slicesize', '', ...
	    'y', 1, 'y_slice', '', 'y_slicesize', '', ...
	    'z', 1, 'z_slice', '', 'z_slicesize', '', ...
	    'zz', 1, 'zz_slice', '', 'zz_slicesize', '', ...
	    'figure', 'browse_fig', ...
	    'plot_type', 'imagesc', 'clim', [], ...
	    'cval', [], ...
	    'linestyle', '-', 'color', '', ...
	    'marker', 'none', 'shading', ...
	    'flat')); 
	display_choices = display_choices(:);
	% make sure to chop to number of existing urls;
	% otherwise old, user-added "ghost" plots may
	% persist.
	display_choices = display_choices(1:display_acq_urls);
      else
	display_choices = display_choices([]);
      end

      % find lat and lon and use as default x- and y- arguments
      slice = '';
      for i = 1:display_acq_urls
	display_choices(i).acqno = i;
	displayonbrowse = [0 0];
	for j = 1:size(display_data(i).name,1)
	  
	  % set lon and lat as default x- and y- variables
	  if ~isempty(instr('Longitude', display_data(i).name(j,:)))
	    display_choices(i).x = j;
	    display_choices(i).x_slice = deblank(display_data(i).name(j,:));
	    display_choices(i).x_slicesize = display_data(i).size{j};
	    displayonbrowse(1) = 1;
	  end
	  if ~isempty(instr('Latitude', display_data(i).name(j,:)))
	    display_choices(i).y = j;
	    display_choices(i).y_slice = deblank(display_data(i).name(j,:));
	    display_choices(i).y_slicesize = display_data(i).size{j};
	    displayonbrowse(2) = 1;
	  end
	end
	
	% if either lon or lat missing, suppress display on browser
	if ~all(displayonbrowse == 1)
	  display_choices(i).figure = 'figure';  
	end
    
	for j = 1:size(display_data(i).name,1)
	  % set the default z- and zz- variables to the first selected variable
	  % and select a reasonable slice from it
	  for k = 1:size(get_variables, 1)
	    if ~isempty(instr(deblank(get_variables(k,:)), ...
		  display_data(i).name(j,:)))
	      break
	    end
	  end
	  if ~isempty(instr(deblank(get_variables(k,:)), ...
		display_data(i).name(j,:)))
	    break
	  end
	end
	      
	display_choices(i).z = j;
	display_choices(i).z_slice = deblank(display_data(i).name(j,:));
	display_choices(i).z_slicesize = display_data(i).size{j};

	display_choices(i).zz = j;
	display_choices(i).zz_slice = deblank(display_data(i).name(j,:));
	display_choices(i).zz_slicesize = display_data(i).size{j};
	% -------------------- NOW SELECT A SLICE -----------------
	% check that lat and lon have both been identified
	if all(displayonbrowse == 1)
	  % check that metadata exists
	  if isfield(display_metadata,'geopos')
	    geopos = display_metadata.geopos;
	    % check that metatdata is not empty or incorrectly sized
	    if all(size(geopos) == [1 4])
	      % check that lat and lon maps are identified in metadata
	      if (geopos(1) > 0) & (geopos(2) > 0)
	      
		% IF WE GOT THIS FAR, IT'S OK TO DEFINE A SLICE
		
		% get the number of dimensions
		ND = size(display_metadata.axes,1);
		% now go ahead and create a slice
		slice = [display_choices(i).z_slice];
                % NEW 2002/01/08 for loaddods 3.2.7 and java-loaddods
                reorder = [1:ND];
		if ND > 2
		  reorder = [reorder(ND-1:ND) fliplr(reorder(1:ND-2))];
		  k = find(geopos > 0);
		  geopos(k) = geopos(k(reorder));
		  % now go ahead and create a slice
		  slice = [slice '(' ];
		  for l = 1:ND
		    if l == geopos(1) | l == geopos(2)
		      slice = [slice ':'];
		    else
		      slice = [slice '1'];
		    end
		    if l < ND
		      slice = [slice ','];
		    end
		  end
		  slice = [ 'squeeze(' slice '))'];
		  % we should now have only TWO dimensions
		  % if Y comes first, we're done.
		  % if x comes first, transpose the matrix.
		end
		if geopos(1) < geopos(2)
		  slice = [ slice ''''];
		end
		% The slice definition is complete.  Apply the slice
		display_choices(i).z_slice = slice;
		display_choices(i).zz_slice = slice;
		% --------------- END OF SLICE SELECTION ----------------
	      end % end of geopos value check
	    end % end of geopos size check
	  end % end of check for geopos metadata field
	end % end of check for display on browse
      end % end of loop through num acq urls

      % set up strings for first and second listboxes
      str = '';
      for i = 1:display_acq_urls
	str = strvcat(str, sprintf('plot%i', i));
      end
      set(display_menu{1}, 'string', str, 'value', 1);
	
      str = '';
      for i = display_count:display_count+display_acq_urls-1
	str = strvcat(str, sprintf('R%i_', i));
      end
      set(display_menu{2}, 'string', str, 'value', 1)

      if display_acq_urls > 0
	% calling case 1 will set all the buttons to reasonable
	% values.  Must loop through all plots to set slice
	% sizes for all of them.  Got backwards to end up at
	% plot number 1.
	for i = display_acq_urls:-1:1
	  set(display_menu{1}, 'value', i);
	  dispmenu(1)
	  % now we have to set the slice size
	  if ~isempty(slice)
	    % we made a slice: evaluate and display its size
	    for varnum = 7:8
	      callbackstring = sprintf('%s%i%s%i%s%i%s%i%s', ...
		  '[browse_var, browse_slice] =  dispmenu(''getslice'',', ...
		    varnum, ...
		  [ '); if ~isempty(browse_slice), ', ...
		      'if exist(browse_var) == 1, browse_dims = nan; ', ...
		      'eval(browse_slice, ''% put error message here'');', ...
		      'dispmenu(''setslicesize'',' ], ...
		    varnum, ...
		  [ ', browse_dims), else, dispmenu(''setslicesize'',' ], ...
		    varnum, ...
		  [ ', 0); end; else, dispmenu(''setslicesize'',' ], ...
		    varnum, ...
		  [ ', 0); end; clear browse_slice browse_var browse_dims']);
	      evalin('base',callbackstring)
	    end
	  end
	end
      else
	% clear strings
	set(cat(2, display_menu{5:8}),'string','')
	v = cat(1, display_menu{5:8});
	set(v(:,2),'value',1);
	set(v(:,3),'string','Full Downloaded size');
	set(display_menu{10}, 'value', 1)
	browse('enableclear')
	if nargin == 4
	  return
	end
      end

      % reveal the figure
      set(display_fig,'visible','on')
      % bring it into focus
      figure(display_fig)
	
    case 'fontsize'
      if isempty(findfig('DODS display'))
	return
      end
      fontsize = argin2;
      set(cat(2, display_menu{[1:8 10:19]}), 'fontsize', fontsize)
      return
      
    case 'getfigpos'
      out1 = zeros(1,4);
      if isempty(findfig('DODS display'))
	return
      end

      un = get(display_fig, 'units');
      set(display_fig, 'units', 'pixels');
      out1 = get(display_fig, 'pos');
      set(display_fig, 'units', un)
      return
    
    case 'getslice'
      whichplot = get(display_menu{1},'value');
      varnum = argin2;
      acqno = display_choices(whichplot).acqno;

      % get the variable
      if varnum == 5
	whichvar = display_choices(whichplot).x;
      elseif varnum == 6
	whichvar = display_choices(whichplot).y;
      elseif varnum == 7
	whichvar = display_choices(whichplot).z;
      elseif varnum == 8
	whichvar = display_choices(whichplot).zz;
      end
      varname = deblank(display_data(acqno).name(whichvar,:));
      
      % set the slice
      if strcmp(varname,'none')
	out1 = '';
	slice = '';
      else
	slice = get(display_menu{varnum}(5),'string');
	if varnum == 5
	  display_choices(whichplot).x_slice = slice;
	elseif varnum == 6
	  display_choices(whichplot).y_slice = slice;
	elseif varnum == 7
	  display_choices(whichplot).z_slice = slice;
	elseif varnum == 8
	  display_choices(whichplot).zz_slice = slice;
	end
      
	if isempty(instr(varname, slice))
	  str =[ 'Error: the selected variable is not included in ', ...
		'the slice!' ];
	  dodsmsg(str)
	  out1 = '';
	  slice = '';
	  set(display_menu{varnum}(5),'string','')
	  if varnum == 5
	    display_choices(whichplot).x_slice = '';
	  elseif varnum == 6
	    display_choices(whichplot).y_slice = '';
	  elseif varnum == 7
	    display_choices(whichplot).z_slice = '';
	  elseif varnum == 8
	    display_choices(whichplot).zz_slice = '';
	  end

	  % *FORCE* SLICES TO CONTAIN THE VARIABLE NAME
	  % ------
	  %acqno = display_choices(whichplot).acqno;
	  %varname = deblank(display_data(acqno).name(whichvar,:));
	  %if varnum == 5
	  %  display_choices(whichplot).x_slice = varname;
	  %elseif varnum == 6
	  %  display_choices(whichplot).y_slice = varname;
	  %elseif varnum == 7
	  %  display_choices(whichplot).z_slice = varname;
	  %elseif varnum == 8
	  %  display_choices(whichplot).zz_slice = varname;
	  %end
	  %set(display_menu{varnum}(5),'string', varname);
	  % ------
	else
	  out1 = varname;
	  slice = [ 'browse_dims = size(' slice ');'];
	end
      end
      out2 = slice;
      
    case 'menu11'
      whichplot = get(display_menu{1},'value');
      % set color menu
      str = get(display_menu{11}(1),'string');
      val = 1;
      for i = 1:size(str,1);
	if strcmp(deblank(lower(str(i,:))), ...
	      display_choices(whichplot).color)
	  val = i;
	  break
	end
      end
      set(display_menu{11}(1), 'vis', 'on', 'value', val)
      set(display_menu{11}(2), 'vis', 'on')

    case 'menu12'
      whichplot = get(display_menu{1},'value');
      % set linestyle menu
      str = get(display_menu{12}(1),'string');
      val = 5;
      for i = 1:size(str,1);
	if strcmp(deblank(lower(str(i,:))), ...
	      display_choices(whichplot).linestyle)
	  val = i;
	  break
	end
      end
      set(display_menu{12}(1), 'vis', 'on', 'value', val)
      set(display_menu{12}(2), 'vis', 'on')
	
    case 'menu13'
      whichplot = get(display_menu{1},'value');
      % set marker menu
      str = get(display_menu{13}(1),'string');
      val = 1;
      for i = 1:size(str,1);
	if strcmp(deblank(lower(str(i,:))), ...
	      display_choices(whichplot).marker)
	  val = i;
	  break
	end
      end
      set(display_menu{13}(1), 'vis', 'on', 'value', val)
      set(display_menu{13}(2),'vis','on')
      
    case 'menu14'
      whichplot = get(display_menu{1},'value');
      % set shading menu
      str = get(display_menu{14}(1),'string');
      for i = 1:size(str,1);
	if strcmp(deblank(lower(str(i,:))), ...
	      display_choices(whichplot).shading)
	  break
	end
      end
      set(display_menu{14}(1), 'vis', 'on', 'value', i)
      set(display_menu{14}(2),'vis','on')
      
    case 'menu15'
      whichplot = get(display_menu{1},'value');
      % set color limits
      clim = display_choices(whichplot).clim;
      set(display_menu{15}(1),'vis', 'on', 'string', num2str(clim));
      set(display_menu{15}(2),'vis','on')
      
    case 'menu16'
      whichplot = get(display_menu{1},'value');
      % set color limits
      cval = display_choices(whichplot).cval;
      set(display_menu{16}(1),'vis', 'on', 'string', num2str(cval));
      set(display_menu{16}(2),'vis','on')
      
    case 'setfigpos'
      if isempty(findfig('DODS display'))
	return
      end

      % get figsize
      figsize = argin2;
      if any(figsize(3:4) == 0)
	% set up default figure size
	k = get(0,'units');
	set(0,'units','pixels')
	scr_size = get(0,'ScreenSize'); scr_offset = scr_size(1:2); 
	scr_size = scr_size(3:4);
	set(0,'units',k)
	fig_size = [460 540];
	fig_offset(1) = 100;
	fig_offset(2) = scr_size(2)*0.5;
	if fig_offset(2)+fig_size(2)+20 > scr_size(2),
	  fig_offset(2) = scr_size(2)-fig_size(2)-40; 
	end
	figsize = [fig_offset fig_size];
      end
      un = get(display_fig,'units');
      set(display_fig, 'units','pixels','pos', figsize)
      set(display_fig,'units',un);
      return
      
    case 'setslicesize'
      whichplot = get(display_menu{1},'value');
      varnum = argin2;
      dims = argin3;

      if varnum == 5
	display_choices(whichplot).x_slicesize = dims;
      elseif varnum == 6
	display_choices(whichplot).y_slicesize = dims;
      elseif varnum == 7
	display_choices(whichplot).z_slicesize = dims;
      elseif varnum == 8
	display_choices(whichplot).zz_slicesize = dims;
      end
      
      dimstr = 'Slice size: ';
      if all(~isnan(dims))
	set(cat(1,display_menu{[17 19]}),'enable','on')
	for i = 1:length(dims)
	  dimstr = [dimstr, sprintf('%i ', dims(i))];
	end
	c = get(display_menu{varnum}(4),'userdata');
	set(display_menu{varnum}(4), 'string', dimstr, ...
	    'foregroundcolor', c, 'fontweight','normal')
      else
	dimstr = '            NOT A VALID SLICE';
	set(cat(1,display_menu{[17 19]}),'enable','off')
	set(display_menu{varnum}(4), 'string', dimstr, ...
	    'foregroundcolor','r','fontweight','bold')
      end
      
    case 'setnewvar'
      % this is when var is set clicking on a new variable
      whichplot = get(display_menu{1},'value');
      varnum = argin2;
      whichvar = get(display_menu{varnum}(2),'value');
      acqno = display_choices(whichplot).acqno;
      varname = deblank(display_data(acqno).name(whichvar,:));
      if strcmp(varname,'none')
	slice = '';
	set(display_menu{varnum}(5),'enable','off')
      else
	slice = varname;
	set(display_menu{varnum}(5),'enable','on')
      end
      dims = display_data(acqno).size{whichvar};
      if varnum == 5
	display_choices(whichplot).x = whichvar;
      elseif varnum == 6
	display_choices(whichplot).y = whichvar;
      elseif varnum == 7
	display_choices(whichplot).z = whichvar;
      elseif varnum == 8
	display_choices(whichplot).zz = whichvar;
      end
      set(display_menu{varnum}(5),'string', slice);
      
      fullstr = 'Full Downloaded size: ';
      for i = 1:length(dims)
	fullstr = [fullstr, sprintf('%i ', dims(i))];
      end
      set(display_menu{varnum}(3),'string', fullstr);

      callbackstring = sprintf('%s%i%s%i%s%i%s%i%s', ...
	  '[browse_var, browse_slice] =  dispmenu(''getslice'',', ...
	    varnum, ...
	  [ '); if ~isempty(browse_slice), ', ...
	      'if exist(browse_var) == 1, browse_dims = nan; ', ...
	      'eval(browse_slice, ''% put error message here'');', ...
	      'dispmenu(''setslicesize'',' ], ...
	    varnum, ...
	  [ ', browse_dims), else, dispmenu(''setslicesize'',' ], ...
	    varnum, ...
	  [ ', 0); end; else, dispmenu(''setslicesize'',' ], ...
	    varnum, ...
	  [ ', 0); end; clear browse_slice browse_var browse_dims']);
      evalin('base',callbackstring)
      
    case 'setvar'
      % this is when var is set by changing the plot number
      whichplot = get(display_menu{1},'value');
      varnum = argin2;
      whichvar = get(display_menu{varnum}(2),'value');
      acqno = display_choices(whichplot).acqno;
      varname = deblank(display_data(acqno).name(whichvar,:));
      if strcmp(varname,'none')
	set(display_menu{varnum}(5),'enable','off')
      else
	set(display_menu{varnum}(5),'enable','on')
      end
      
      if varnum == 5
	slice = display_choices(whichplot).x_slice;
	slicesize = display_choices(whichplot).x_slicesize;
      elseif varnum == 6
	slice = display_choices(whichplot).y_slice;
	slicesize = display_choices(whichplot).y_slicesize;
      elseif varnum == 7
	slice = display_choices(whichplot).z_slice;
	slicesize = display_choices(whichplot).z_slicesize;
      elseif varnum == 8
	slice = display_choices(whichplot).zz_slice;
	slicesize = display_choices(whichplot).zz_slicesize;
      end
      set(display_menu{varnum}(5),'string', slice);
      fulldims = display_data(acqno).size{whichvar};
      if isempty(slice)
	slicedims = fulldims;
      else
	slicedims = slicesize;
      end
      
      dimstr = 'Slice size: ';
      fullstr = 'Full Downloaded size: ';
      for i = 1:length(fulldims)
	fullstr = [fullstr, sprintf('%i ', fulldims(i))];
      end
      set(display_menu{varnum}(3),'string', fullstr);
      
      for i = 1:length(slicedims)
	dimstr = [dimstr, sprintf('%i ', slicedims(i))];
      end
      set(display_menu{varnum}(4),'string', dimstr);
      
    case 'start'
      % prevent multiple startups
      closefig('DODS display')
      
      % initialize variables
      display_choices = struct('acqno', 1, ...
	  'x', 1, 'x_slice', '', 'x_slicesize', '', ...
	  'y', 1, 'y_slice', '', 'y_slicesize', '', ...
	  'z', 1, 'z_slice', '', 'z_slicesize', '', ...
	  'zz', 1, 'zz_slice', '', 'zz_slicesize', '', ...
	  'figure', 'browse_fig', ...
	  'plot_type', 'imagesc', 'clim', [], ...
	  'cval', [], ...
	  'linestyle', '-', 'color', '', ...
	  'marker', 'none', 'shading', ...
	  'flat');
      display_choices = display_choices([]);
      display_data = struct('name','','size',[]);
      display_data = display_data([]);

      % get fontsize
      fontsize = argin2;
      if fontsize == 0
	fontsize = browse('getfontsize');
      end
      
      % get figsize
      figpos = argin3;
      % THE EDIT FIGURE
      if any(figpos(3:4) == 0)
	figpos = browse('figpos',3);
      end

      if any(figpos(3:4) == 0)
	% set up default figure size
	un = get(0,'units');
	set(0,'units','pixels')
	scr_size = get(0,'ScreenSize'); 
	scr_size = scr_size(3:4);
	set(0,'units', un)
	fig_size = [460 540];
	fig_offset(1) = 100;
	fig_offset(2) = scr_size(2)*0.5;
	if fig_offset(2)+fig_size(2)+20 > scr_size(2),
	  fig_offset(2) = scr_size(2)-fig_size(2)-40; 
	end
	figpos = [fig_offset fig_size];
      end

      % get colors
      colors = argin4;
      if all(colors == 0) | ~all(size(colors == [3 3]))
	colors = browse('getcolors');
	colors = colors([6 1 5],:);
      end
      
      % initialize some values for figures
      display_menu = cell(10,1);

      buttonpos = [0.01 0.95 0.5 0.05];
      indent = 0.05;
      buttonsep = 0.05;
      
      % initialize some values for working
      display_acq_urls = 0;
      
      % set up the figure
      display_fig = figure('numbertitle','off', ...
	  'Name','Display acquired data', ...
	  'visible','off', ...
	  'interruptible','off', ...
	  'units','pixels', ...
	  'resize','off',...
	  'userdata','DODS display', ...
	  'color', colors(1,:), ...
	  'menubar', 'none', ...
	  'position', figpos);
      
      % set up the uimenu
      display_menu{9}(1) = uimenu(display_fig,'label','Edit');
      display_menu{9}(2) = uimenu(display_fig, 'label', ...
	  'Apply to All', 'enable', 'on');
      uimenu(display_menu{9}(1),'label','Add New Plot','callback', ...
	  'dispmenu(''addplot'')');
      uimenu(display_menu{9}(1),'label','Delete Plot', 'callback', ...
	  'dispmenu(''delplot'')');
      uimenu(display_menu{9}(1),'label','Delete All Plots', 'callback', ...
	  'dispmenu(''delall'')');
      uimenu(display_menu{9}(2),'label','Set Plot Type', ...
	  'callback', 'dispmenu(''applytoall'',''plot'')', 'enable', 'on');
      uimenu(display_menu{9}(2),'label','Set X-data', ...
	  'callback', 'dispmenu(''applytoall'', 5)', 'enable', 'on');
      uimenu(display_menu{9}(2),'label','Set Y-data', ...
	  'callback', 'dispmenu(''applytoall'',6)', 'enable', 'on');
      display_menu{9}(3) = uimenu(display_menu{9}(2),'label','Set Z-data', ...
	  'callback', 'dispmenu(''applytoall'', 7)', 'enable', 'on');
      display_menu{9}(4) = uimenu(display_menu{9}(2),'label','Set V-data', ...
	  'callback', 'dispmenu(''applytoall'', 8)', 'enable', 'on');
      
      % set up basic button dimensions
      buttonheight = 0.06;
      buttonwidth = 0.1;
      buttonsep = 0.02;
      
      %%%%%%%%%%%%%%%%%%  FRAME 1 %%%%%%%%%%%%%%%%%%%%%%%%%
      frame1pos = [0 0.7 0.17 0.3];
      uicontrol('Units','norm', ...
	  'Style','frame', ...
	  'backgroundcolor', colors(2,:), ...
	  'Position', frame1pos)
      
      % Inside frame 1: plot number list
      list1title = [frame1pos(1)+0.02 ...
	    frame1pos(2)+frame1pos(4)-0.02-buttonheight ...
	    1.2*buttonwidth buttonheight];
      list1pos = [frame1pos(1)+0.02 frame1pos(2)+0.02 ...
	    frame1pos(3)-0.04 frame1pos(4)-0.04-buttonheight-buttonsep];
      str = sprintf('%s\n%s','Plot','Number');
      uicontrol('units','norm','style','text', ...
	  'foregroundcolor', colors(1,:), ...
	  'backgroundcolor', colors(2,:), ...
	  'position', list1title, ...
	  'horiz','center', ...
	  'max', 2, ...
	  'tooltip', 'Select which plot to modify', ...
	  'string', str)
      display_menu{1} = uicontrol('Units','norm', ...
	  'Position', list1pos, ...
	  'foregroundcolor', colors(1,:), ...
	  'backgroundcolor', colors(2,:), ...
	  'String',' ', ...
	  'callback','dispmenu(1)', ...
	  'Style','listbox');
      %%%%%%%%%%%%%%%%%%  END FRAME 1 %%%%%%%%%%%%%%%%%%%%%%%%%
      
      %%%%%%%%%%%%%%%%%%  FRAME 2 %%%%%%%%%%%%%%%%%%%%%%%%%
      % top row: acq #, plot type, plot options, window
      frame2pos = [0.17 0.7 0.83 0.3];
      uicontrol('Units','norm', ...
	  'Style','frame', ...
	  'backgroundcolor', colors(2,:), ...
	  'Position', frame2pos)
      
      % inside frame 2: list of acquisitions 
      list2title = [frame2pos(1)+0.02 ...
	    frame2pos(2)+frame2pos(4)-0.02-buttonheight ...
	    1.3*buttonwidth buttonheight];
      list2pos = [frame2pos(1)+0.02 frame2pos(2)+0.02 ...
	    0.11 frame2pos(4)-0.04-buttonheight-buttonsep];
      str = sprintf('%s\n%s','Acquisition','Number');
      uicontrol('units','norm','style','text', ...
	  'foregroundcolor', colors(1,:), ...
	  'backgroundcolor', colors(2,:), ...
	  'position', list2title, ...
	  'horiz','center', ...
	  'max', 2, ...
	  'tooltip', 'Select which data download to plot', ...
	  'string', str)
      display_menu{2} = uicontrol('Units','norm', ...
	  'Position', list2pos, ...
	  'foregroundcolor', colors(1,:), ...
	  'backgroundcolor', colors(2,:), ...
	  'String',' ', ...
	  'callback','dispmenu(2)', ...
	  'Style','listbox');
      
      % inside frame 2: plot type menu 
      list3title = [0.32 frame2pos(2)+frame2pos(4)-0.02-buttonheight ...
	    1.2*buttonwidth buttonheight];
      list3pos = [0.32 frame2pos(2)+0.02 ...
	    0.16 frame2pos(4)-0.04-buttonheight-buttonsep];
      str = sprintf('%s\n%s','Plot','Type');
      uicontrol('Units','norm', ...
	  'foregroundcolor', colors(1,:), ...
	  'backgroundcolor', colors(2,:), ...
	  'Position', list3title, ...
	  'max', 2, ...
	  'String', str, ...
	  'tooltip', 'Select the Matlab plot command to use', ...
	  'horiz','center', ...
	  'Style','text');
      display_menu{10} = uicontrol('Units','norm', ...
	  'foregroundcolor', colors(1,:), ...
	  'backgroundcolor', colors(2,:), ...
	  'Position', list3pos, ...
	  'value', 2, ... 
	  'callback','dispmenu(10)', ...
	  'String', 'Plot|Imagesc|Contour|Contourf|Pcolor|Quiver|Polar', ...
	  'Style','listbox');
      
      % inside frame 2: special plot characteristic menus
      stretch = 1.5;
      menu1 = str2mat('default', 'y', 'm', 'c', 'r', 'g', 'b', 'w', ...
	  'k');
      menu1pos = [0.52 1-1.5*buttonheight-0.02 ...
	    stretch*buttonwidth buttonheight];
      menu1title = [0.52 1-buttonheight/2-0.02 ...
	    stretch*buttonwidth buttonheight/2];
  
      menu2 = str2mat('-','--',':','-.','none');
      menu2pos = [1-0.02-stretch*buttonwidth ...
	    1-1.5*buttonheight-0.02 ...
	    stretch*buttonwidth buttonheight];
      menu2title = [1-0.02-stretch*buttonwidth ...
	    1-buttonheight/2-0.02 ...
	    stretch*buttonwidth buttonheight/2];
      
      menu3 = str2mat('none', '+', 'o', 'x', '*', 's', 'd', 'v', ...
	  '^', '<', '>', 'p', 'h', '.');
      menu3pos = [0.52 frame2pos(2)+frame2pos(4)/3-buttonheight/2 ...
	    stretch*buttonwidth buttonheight];
      menu3title = [0.52 frame2pos(2)+frame2pos(4)/3+buttonheight/2 ...
	    stretch*buttonwidth buttonheight/2];

      menu4 = str2mat('flat','faceted','interp');
      menu4pos = [1-0.02-stretch*buttonwidth ...
	     frame2pos(2)+frame2pos(4)/3-buttonheight/2 ...
	     stretch*buttonwidth buttonheight];
      menu4title = [1-0.02-stretch*buttonwidth ...
	    frame2pos(2)+frame2pos(4)/3+buttonheight/2 ...
	    stretch*buttonwidth buttonheight/2];
      
      menu5pos = [0.6 frame2pos(2)+frame2pos(4)/3-buttonheight/2 ...
	    stretch*buttonwidth buttonheight];
      menu5title = [0.52 frame2pos(2)+frame2pos(4)/3+buttonheight/2 ...
	    2*stretch*buttonwidth buttonheight/2];

      display_menu{11}(1) = uicontrol('Units','norm', ...
	  'position', menu1pos, ...
	  'String',menu1, ...
	  'visible','off', ...
	  'foregroundcolor', colors(1,:), ...
	  'backgroundcolor', colors(2,:), ...
	  'callback', 'dispmenu(11)', ...
	  'Style','popupmenu', ...
	  'Value',1);
      display_menu{11}(2) = uicontrol('Units','norm', ...
	  'position', menu1title, ...
	  'String','Color', ...
	  'tooltip', 'line and symbol color', ...
	  'foregroundcolor', colors(1,:), ...
	  'backgroundcolor', colors(2,:), ...
	  'visible','off', ...
	  'horiz','left', ...
	  'Style','text');
      display_menu{12}(1) = uicontrol('Units','norm', ...
	  'position', menu2pos, ...
	  'String',menu2, ...
	  'foregroundcolor', colors(1,:), ...
	  'backgroundcolor', colors(2,:), ...
	  'visible','off', ...
	  'callback', 'dispmenu(12)', ...
	  'Style','popupmenu', ...
	  'Value',1);
      display_menu{12}(2) = uicontrol('Units','norm', ...
	  'position', menu2title, ...
	  'String','Linestyle', ...
	  'tooltip', '', ...
	  'foregroundcolor', colors(1,:), ...
	  'backgroundcolor', colors(2,:), ...
	  'visible','off', ...
	  'horiz','left', ...
	  'Style','text');
      display_menu{13}(1) = uicontrol('Units','norm', ...
	  'position', menu3pos, ...
	  'String',menu3, ...
	  'foregroundcolor', colors(1,:), ...
	  'backgroundcolor', colors(2,:), ...
	  'visible','off', ...
	  'callback', 'dispmenu(13)', ...
	  'Style','popupmenu', ...
	  'Value',1);
      display_menu{13}(2) = uicontrol('Units','norm', ...
	  'position', menu3title, ...
	  'String','Marker', ...
	  'tooltip', 'select the plot symbol', ...
	  'foregroundcolor', colors(1,:), ...
	  'backgroundcolor', colors(2,:), ...
	  'visible','off', ...
	  'horiz','left', ...
	  'Style','text');
      display_menu{14}(1) = uicontrol('Units','norm', ...
	  'position', menu4pos, ...
	  'String', menu4, ...
	  'visible','off', ...
	  'foregroundcolor', colors(1,:), ...
	  'backgroundcolor', colors(2,:), ...
	  'callback', 'dispmenu(14)', ...
	  'Style','popupmenu', ...
	  'Value',1);
      display_menu{14}(2) = uicontrol('Units','norm', ...
	  'position', menu4title, ...
	  'String','Shading', ...
	  'foregroundcolor', colors(1,:), ...
	  'backgroundcolor', colors(2,:), ...
	  'visible','off', ...
	  'horiz','left', ...
	  'Style','text');
      display_menu{15}(1) = uicontrol('Units','norm', ...
	  'position', menu5pos, ...
	  'String', '', ...
	  'foregroundcolor', colors(1,:), ...
	  'backgroundcolor', colors(3,:), ...
	  'visible','on', ...
	  'horiz', 'left', ...
	  'callback', 'dispmenu(15)', ...
	  'Style','edit');
      display_menu{15}(2) = uicontrol('Units','norm', ...
	  'position', menu5title, ...
	  'String','Color limits (in data units)', ...
	  'foregroundcolor', colors(1,:), ...
	  'backgroundcolor', colors(2,:), ...
	  'visible','on', ...
	  'tooltip', 'default limits: entire data range', ...
	  'horiz','left', ...
	  'Style','text');
      display_menu{16}(1) = uicontrol('Units','norm', ...
	  'position', menu5pos, ...
	  'String', '', ...
	  'foregroundcolor', colors(1,:), ...
	  'backgroundcolor', colors(3,:), ...
	  'visible','off', ...
	  'horiz', 'left', ...
	  'callback', 'dispmenu(16)', ...
	  'Style','edit');
      display_menu{16}(2) = uicontrol('Units','norm', ...
	  'position', menu5title, ...
	  'String','Contour number or levels', ...
	  'foregroundcolor', colors(1,:), ...
	  'backgroundcolor', colors(2,:), ...
	  'visible','off', ...
	  'tooltip', 'default autoselects number of contours and their levels ', ...
	  'horiz','left', ...
	  'Style','text');
      
      % inside frame 2: control choice of display window 
      popup1pos = [0.52 frame2pos(2)+0.01 ...
	    0.5-buttonwidth-buttonsep-0.04 buttonheight];
      edit1pos = [popup1pos(1)+popup1pos(3)+0.02 popup1pos(2) ...
	    buttonwidth buttonheight];
      str = str2mat('Display on browse window', ...
	  'Display on new window', 'Display on window:');
      display_menu{3} = uicontrol('Units','norm', ...
	  'Position', popup1pos, ...
	  'String', str, ...
	  'value', 1, ...
	  'tooltip', 'Select the destination figure', ...
	  'callback', 'dispmenu(3)', ...
	  'Style','popup');
      display_menu{4} =  uicontrol('Units','norm', ...
	  'Position', edit1pos, ...
	  'foregroundcolor', colors(1,:), ...
	  'backgroundcolor', colors(3,:), ...
	  'callback', 'dispmenu(4)', ...
	  'Style','edit', 'visible', 'off');
      %%%%%%%%%%%%%%%%%% END FRAME 2 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      
      %%%%%%%%%%%%%%%%%% FRAME 3 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      % bottom row: selected variables and slices
      frame3pos = [0 0.1 1 0.6];
      uicontrol('Style','frame', ...
	  'units','norm', ...
	  'backgroundcolor', colors(2,:), ...
	  'Position', frame3pos)

      % variables lists inside frame 3
      top = frame3pos(2)+frame3pos(4);
      lw = 0.5-buttonwidth-buttonsep-0.02;
      lx1 = frame3pos(1)+0.02;
      lx2 = lx1+buttonwidth+buttonsep;
      lx3 = lx2+lw+buttonsep;
      lh = frame3pos(4)/4;
      
      label5pos = [lx1 top-lh/2 buttonwidth buttonheight/2];
      list5pos = [lx2 top-lh+0.0125 lw lh-0.025];
      slice5dimpos = [lx3 top-0.0125-buttonheight/2 1-lx3-0.02 buttonheight/2];
      slice5pos = [lx3 label5pos(2)-0.025 1-lx3-0.02 buttonheight];
      dim5pos = [lx3 list5pos(2) 1-lx3-0.02 buttonheight/2];

      label6pos = [lx1 top-1.5*lh buttonwidth buttonheight/2];
      list6pos = [lx2 top-2*lh+0.0125 lw lh-0.025];
      slice6dimpos = [lx3 top-lh-0.0125-buttonheight/2 1-lx3-0.02 buttonheight/2];
      slice6pos = [lx3 label6pos(2)-0.025 1-lx3-0.02 buttonheight];
      dim6pos = [lx3 list6pos(2) 1-lx3-0.02 buttonheight/2];

      label7pos = [lx1 top-2.5*lh buttonwidth buttonheight/2];
      list7pos = [lx2 top-3*lh+0.0125 lw lh-0.025];
      slice7dimpos = [lx3 top-2*lh-0.0125-buttonheight/2 1-lx3-0.02 buttonheight/2];
      slice7pos = [lx3 label7pos(2)-0.025 1-lx3-0.02 buttonheight];
      dim7pos = [lx3 list7pos(2) 1-lx3-0.02 buttonheight/2];

      label8pos = [lx1 top-3.5*lh buttonwidth buttonheight/2];
      list8pos = [lx2 top-4*lh+0.0125 lw lh-0.025];
      slice8dimpos = [lx3 top-3*lh-0.0125-buttonheight/2 1-lx3-0.02 buttonheight/2];
      slice8pos = [lx3 label8pos(2)-0.025 1-lx3-0.02 buttonheight];
      dim8pos = [lx3 list8pos(2) 1-lx3-0.02 buttonheight/2];
      
      % All of the variable selection controls
      display_menu{5}(1) = uicontrol('Units','norm', ...
	  'Position', label5pos, ...
	  'String','X-data', ...
	  'tooltip', 'Select data for the x-axis', ...
	  'foregroundcolor', colors(1,:), ...
	  'backgroundcolor', colors(2,:), ...
	  'Style','text');
      display_menu{5}(2) = uicontrol('Units','norm', ...
	  'Position', list5pos, ...
	  'String','', ...
	  'callback', 'dispmenu(5)', ...
	  'foregroundcolor', colors(1,:), ...
	  'backgroundcolor', colors(2,:), ...
	  'value', 1, ...
	  'Style','listbox');
      display_menu{5}(3) = uicontrol('Units','norm', ...
	  'Position', dim5pos, ...
	  'String','Full Downloaded Size:', ...
	  'foregroundcolor', colors(1,:), ...
	  'backgroundcolor', colors(2,:), ...
	  'horiz','left', ...
	  'Style','text');
      display_menu{5}(4) = uicontrol('Units','norm', ...
	  'Position', slice5dimpos, ...
	  'String','Slice size:', ...
	  'foregroundcolor', colors(1,:), ...
	  'backgroundcolor', colors(2,:), ...
	  'userdata',  colors(1,:), ...
	  'horiz','left', ...
	  'Style','text');
      varnum = 5;
      callbackstring = sprintf('%s%i%s%i%s%i%s%i%s', ...
	  '[browse_var, browse_slice] =  dispmenu(''getslice'',', ...
	    varnum, ...
	  [ '); if ~isempty(browse_slice), ', ...
	      'if exist(browse_var) == 1, browse_dims = nan; ', ...
	      'eval(browse_slice, ''% put error message here'');', ...
	      'dispmenu(''setslicesize'',' ], ...
	    varnum, ...
	  [ ', browse_dims), else, dispmenu(''setslicesize'',' ], ...
	    varnum, ...
	  [ ', 0); end; else, dispmenu(''setslicesize'',' ], ...
	    varnum, ...
	  [ ', 0); end; clear browse_slice browse_var browse_dims']);
      display_menu{5}(5) = uicontrol('Units','norm', ...
	  'Position', slice5pos, ...
	  'String','', ...
	  'foregroundcolor', colors(1,:), ...
	  'backgroundcolor', colors(3,:), ...
	  'horiz','left', ...
	  'callback', callbackstring, ...
	  'Style','edit');
      display_menu{6}(1) = uicontrol('Units','norm', ...
	  'Position', label6pos, ...
	  'tooltip', 'Select data for the y-axis', ...
	  'String','Y-data', ...
	  'foregroundcolor', colors(1,:), ...
	  'backgroundcolor', colors(2,:), ...
	  'Style','text');
      display_menu{6}(2) = uicontrol('Units','norm', ...
	  'Position', list6pos, ...
	  'String','', ...
	  'callback', 'dispmenu(6)', ...
	  'foregroundcolor', colors(1,:), ...
	  'backgroundcolor', colors(2,:), ...
	  'value', 1, ...
	  'Style','listbox');
      display_menu{6}(3) = uicontrol('Units','norm', ...
	  'Position', dim6pos, ...
	  'String','Full Downloaded Size:', ...
	  'foregroundcolor', colors(1,:), ...
	  'backgroundcolor', colors(2,:), ...
	  'horiz','left', ...
	  'Style','text');
      display_menu{6}(4) = uicontrol('Units','norm', ...
	  'Position', slice6dimpos, ...
	  'String','Slice size:', ...
	  'foregroundcolor', colors(1,:), ...
	  'backgroundcolor', colors(2,:), ...
	  'userdata',  colors(1,:), ...
	  'horiz','left', ...
	  'Style','text');
      varnum = 6;
      callbackstring = sprintf('%s%i%s%i%s%i%s%i%s', ...
	  '[browse_var, browse_slice] =  dispmenu(''getslice'',', ...
	    varnum, ...
	  [ '); if ~isempty(browse_slice), ', ...
	      'if exist(browse_var) == 1, browse_dims = nan; ', ...
	      'eval(browse_slice, ''% put error message here'');', ...
	      'dispmenu(''setslicesize'',' ], ...
	    varnum, ...
	  [ ', browse_dims), else, dispmenu(''setslicesize'',' ], ...
	    varnum, ...
	  [ ', 0); end; else, dispmenu(''setslicesize'',' ], ...
	    varnum, ...
	  [ ', 0); end; clear browse_slice browse_var browse_dims']);
      display_menu{6}(5) = uicontrol('Units','norm', ...
	  'Position', slice6pos, ...
	  'String','', ...
	  'foregroundcolor', colors(1,:), ...
	  'backgroundcolor', colors(3,:), ...
	  'horiz','left', ...
	  'callback', callbackstring, ...
	  'Style','edit');
      display_menu{7}(1) = uicontrol('Units','norm', ...
	  'Position', label7pos, ...
	  'String','Z-data', ...
	  'tooltip', 'Select the data to be imaged/contoured', ...
	  'foregroundcolor', colors(1,:), ...
	  'backgroundcolor', colors(2,:), ...
	  'visible','on', ...
	  'Style','text');
      display_menu{7}(2) = uicontrol('Units','norm', ...
	  'Position', list7pos, ...
	  'String','', ...
	  'callback', 'dispmenu(7)', ...
	  'foregroundcolor', colors(1,:), ...
	  'backgroundcolor', colors(2,:), ...
	  'visible','on', ...
	  'value', 1, ...
	  'Style','listbox');
      display_menu{7}(3) = uicontrol('Units','norm', ...
	  'Position', dim7pos, ...
	  'String','Full Downloaded Size:', ...
	  'foregroundcolor', colors(1,:), ...
	  'backgroundcolor', colors(2,:), ...
	  'horiz','left', ...
	  'Style','text');
      display_menu{7}(4) = uicontrol('Units','norm', ...
	  'Position', slice7dimpos, ...
	  'String','Slice size:', ...
	  'foregroundcolor', colors(1,:), ...
	  'backgroundcolor', colors(2,:), ...
	  'userdata',  colors(1,:), ...
	  'horiz','left', ...
	  'Style','text');
      varnum = 7;
      callbackstring = sprintf('%s%i%s%i%s%i%s%i%s', ...
	  '[browse_var, browse_slice] =  dispmenu(''getslice'',', ...
	    varnum, ...
	  [ '); if ~isempty(browse_slice), ', ...
	      'if exist(browse_var) == 1, browse_dims = nan; ', ...
	      'eval(browse_slice, ''% put error message here'');', ...
	      'dispmenu(''setslicesize'',' ], ...
	    varnum, ...
	  [ ', browse_dims), else, dispmenu(''setslicesize'',' ], ...
	    varnum, ...
	  [ ', 0); end; else, dispmenu(''setslicesize'',' ], ...
	    varnum, ...
	  [ ', 0); end; clear browse_slice browse_var browse_dims']);
      display_menu{7}(5) = uicontrol('Units','norm', ...
	  'Position', slice7pos, ...
	  'String','', ...
	  'foregroundcolor', colors(1,:), ...
	  'backgroundcolor', colors(3,:), ...
	  'horiz','left', ...
	  'callback', callbackstring, ...
	  'Style','edit');
      display_menu{8}(1) = uicontrol('Units','norm', ...
	  'Position', label8pos, ...
	  'String','V-data', ...
	  'tooltip', 'Select the y-component of the data vector', ...
	  'foregroundcolor', colors(1,:), ...
	  'backgroundcolor', colors(2,:), ...
	  'visible','off', ...
	  'Style','text');
      display_menu{8}(2) = uicontrol('Units','norm', ...
	  'Position', list8pos, ...
	  'String','', ...
	  'callback', 'dispmenu(8)', ...
	  'foregroundcolor', colors(1,:), ...
	  'backgroundcolor', colors(2,:), ...
	  'visible','off', ...
	  'value', 1, ...
	  'Style','listbox');
      display_menu{8}(3) = uicontrol('Units','norm', ...
	  'Position', dim8pos, ...
	  'String','Full Downloaded Size:', ...
	  'foregroundcolor', colors(1,:), ...
	  'backgroundcolor', colors(2,:), ...
	  'horiz','left', ...
	  'visible','off', ...
	  'Style','text');
      display_menu{8}(4) = uicontrol('Units','norm', ...
	  'Position', slice8dimpos, ...
	  'String','Slice size:', ...
	  'foregroundcolor', colors(1,:), ...
	  'backgroundcolor', colors(2,:), ...
	  'userdata',  colors(1,:), ...
	  'horiz','left', ...
	  'visible','off', ...
	  'Style','text');
      varnum = 8;
      callbackstring = sprintf('%s%i%s%i%s%i%s%i%s', ...
	  '[browse_var, browse_slice] =  dispmenu(''getslice'',', ...
	    varnum, ...
	  [ '); if ~isempty(browse_slice), ', ...
	      'if exist(browse_var) == 1, browse_dims = nan; ', ...
	      'eval(browse_slice, ''% put error message here'');', ...
	      'dispmenu(''setslicesize'',' ], ...
	    varnum, ...
	  [ ', browse_dims), else, dispmenu(''setslicesize'',' ], ...
	    varnum, ...
	  [ ', 0); end; else, dispmenu(''setslicesize'',' ], ...
	    varnum, ...
	  [ ', 0); end; clear browse_slice browse_var browse_dims']);
      display_menu{8}(5) = uicontrol('Units','norm', ...
	  'Position', slice8pos, ...
	  'String','', ...
	  'foregroundcolor', colors(1,:), ...
	  'backgroundcolor', colors(3,:), ...
	  'horiz','left', ...
	  'visible','off', ...
	  'callback', callbackstring, ...
	  'Style','edit');
      %%%%%%%%%%%%%%%%%% END FRAME 3 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      
      %%%%%%%%%%%%%%%%%% FRAME 4 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      % Frame for Ok Cancel and Apply
      frame4pos = [0 0 1 0.1];
      uicontrol('Units','norm', ...
	  'Position', frame4pos, ...
	  'backgroundcolor', colors(2,:), ...
	  'Style','frame')
      
      % inside frame 4 -- OK, CANCEL, APPLY
      button5pos = [frame4pos(1)+0.02+buttonwidth/2 ...
	    frame4pos(2)+frame4pos(4)/2-buttonheight/2 ...
	    buttonwidth buttonheight];
      button6pos = [frame4pos(1)+frame4pos(3)/2-buttonwidth/2 ...
	    frame4pos(2)+frame4pos(4)/2-buttonheight/2 ...
	    buttonwidth buttonheight];
      button7pos = [frame4pos(1)+frame4pos(3)-0.02-3*buttonwidth/2 ...
	    frame4pos(2)+frame4pos(4)/2-buttonheight/2 ...
	    buttonwidth buttonheight];
      display_menu{17} = uicontrol('Units','norm', ...
	  'Position', button5pos, ...
	  'callback', 'dispmenu(17)', ...
	  'String','Ok');
      display_menu{18} = uicontrol('Units','norm', ...
	  'Position', button6pos, ...
	  'callback', 'dispmenu(18)', ...
	  'String','Cancel');
      display_menu{19} = uicontrol('Units','norm', ...
	  'Position', button7pos, ...
	  'callback', 'dispmenu(19)', ...
	  'String','Apply');

      % disable all of the buttons
      set(cat(2, display_menu{1:16}),'enable','off')
      
      return
      
    case 'reset'
      if isempty(findfig('DODS display'))
	return
      end
      display_data = display_data([]);
      display_choices = display_choices([]);
      set(cat(2, display_menu{1:16}),'enable','off')
  
  end 
  
  % end of string arguments: display the figure!

else % argin1 is not a string
  % These numeric arguments are ONLY called by dispmenu figure
  % buttons, so no check for figure existence is necessary.
  
  switch argin1
    
    case 1 % SELECT WHICH PLOT NUMBER
      whichplot = get(display_menu{1},'value');

      % set the value of the requestnumber listbox
      acqno = display_choices(whichplot).acqno;
      set(display_menu{2}, 'value', acqno);
      
      % set the variable names listboxes
      h = cat(1,display_menu{5:8});
      h = h(:,2);
      set(h, 'string', display_data(acqno).name)
      
      % set the menu values and the size strings
      whichvar = display_choices(whichplot).x;
      set(display_menu{5}(2),'value', whichvar, 'listboxtop', whichvar)
      dispmenu('setvar', 5)
      
      whichvar = display_choices(whichplot).y;
      set(display_menu{6}(2),'value', whichvar, 'listboxtop', whichvar)
      dispmenu('setvar', 6)
      
      whichvar = display_choices(whichplot).z;
      set(display_menu{7}(2),'value', whichvar, 'listboxtop', whichvar)
      dispmenu('setvar', 7)
      
      whichvar = display_choices(whichplot).zz;
      set(display_menu{8}(2),'value', whichvar, 'listboxtop', whichvar)
      dispmenu('setvar', 8)
      
      % set the plot type selection.  This will turn
      %on/off the correct axis buttons
      str = get(display_menu{10},'string');
      for i = 1:size(str,1);
	if strcmp(deblank(lower(str(i,:))), ...
	      display_choices(whichplot).plot_type)
	  break
	end
      end
      plot_type = i;
      set(display_menu{10}, 'value', plot_type)
  
      switch plot_type
	case 1 % plot
	  set(cat(2, display_menu{[7 8]}),'vis','off')
	  
	case 2 % imagesc
	  set(display_menu{7},'vis','on')
	  set(display_menu{7}(1), 'string', 'Z-data', ...
	      'tooltip', 'Select the data to be imaged/contoured')
	  set(display_menu{8},'vis','off')
	  
	case 3 % contour
	  set(display_menu{7},'vis','on')
	  set(display_menu{7}(1),'string', 'Z-data')
	  set(display_menu{8},'vis','off')
	  
	case 4 % contourf
	  set(display_menu{7},'vis','on')
	  set(display_menu{7}(1), 'string', 'Z-data')
	  set(display_menu{8},'vis','off')
	  
	case 5 % pcolor
	  set(display_menu{7},'vis','on')
	  set(display_menu{7}(1),'string', 'Z-data')
	  set(display_menu{8},'vis','off')
	
	case 6 % quiver
	  set(display_menu{7}, 'vis', 'on')
	  set(display_menu{7}(1), 'string', 'U-data', ...
	  'tooltip', 'Select the x-component of the data vector')
	  set(display_menu{8},'vis','on')
	
	case 7 % polar
	  set(cat(2, display_menu{[7 8]}),'vis','off')
      end
      
      % set the special menu values.  Note that visibility
      % of the menu must also be toggled.
      if strcmp(display_choices(whichplot).plot_type, 'plot') | ...
	    strcmp(display_choices(whichplot).plot_type, 'polar')
	% set color menu
	dispmenu('menu11')
	% set linestyle menu
	dispmenu('menu12')
	% set marker menu
	dispmenu('menu13')
	set(cat(2, display_menu{14:16}),'vis','off')
	
      elseif strcmp(display_choices(whichplot).plot_type, 'imagesc')
	% set color limits menu
	dispmenu('menu15')
	set(cat(2, display_menu{[11:14 16]}), 'vis', 'off')
	
      elseif strcmp(display_choices(whichplot).plot_type, 'contour') ...
	    | strcmp(display_choices(whichplot).plot_type, 'contourf')
	% set color menu
	dispmenu('menu11')
	% set linestyle menu
	dispmenu('menu12')
	% set the contour levels menu
	dispmenu('menu16')
	set(cat(2, display_menu{13:15}),'vis','off')
	
      elseif strcmp(display_choices(whichplot).plot_type, 'pcolor')
	% set shading menu
	dispmenu('menu14')
	% set color limits menu
	dispmenu('menu15')
	set(cat(2, display_menu{[11:13 16]}),'vis','off')
      
      elseif strcmp(display_choices(whichplot).plot_type, 'quiver')
	% set color menu
	dispmenu('menu11')
	% set linestyle menu
	dispmenu('menu12')
	set(cat(2, display_menu{13:16}),'vis','off')
	
      end
      
      % set the target figure
      if isstr(display_choices(whichplot).figure)
	if strcmp(display_choices(whichplot).figure,'browse_fig')
	  set(display_menu{3},'value',1)
	  set(display_menu{4},'vis','off')
	elseif strcmp(display_choices(whichplot).figure,'figure')
	  set(display_menu{3},'value',2)
	  set(display_menu{4},'vis','off')
	end
      else
	set(display_menu{3},'value',3)
	str = num2str(display_choices(whichplot).figure);
	set(display_menu{4},'vis','on','string', str)
      end
      
    case 2 % set the acquisition number
      whichplot = get(display_menu{1},'value');
      acqno = get(display_menu{2},'value');
      display_choices(whichplot).acqno = acqno;

      whichvar = display_choices(whichplot).x;
      sz = size(display_data(acqno).name,1);
      if whichvar > sz
	set(display_menu{5}(2),'value',sz);
      end
      set(display_menu{5}(2), 'string', display_data(acqno).name)
      dispmenu('setnewvar', 5)

      whichvar = display_choices(whichplot).y;
      sz = size(display_data(acqno).name,1);
      if whichvar > sz
	set(display_menu{6}(2),'value',sz);
      end
      set(display_menu{6}(2), 'string', display_data(acqno).name)
      dispmenu('setnewvar', 6)

      whichvar = display_choices(whichplot).z;
      sz = size(display_data(acqno).name,1);
      if whichvar > sz
	set(display_menu{7}(2),'value',sz);
      end
      set(display_menu{7}(2), 'string', display_data(acqno).name)
      dispmenu('setnewvar', 7)
      
      whichvar = display_choices(whichplot).zz;
      sz = size(display_data(acqno).name,1);
      if whichvar > sz
	set(display_menu{8}(2),'value',sz);
      end
      set(display_menu{8}(2), 'string', display_data(acqno).name)
      dispmenu('setnewvar', 8)
      
    case 3 % SET THE FIGURE SELECTION FOR THIS PLOT
      whichplot = get(display_menu{1},'value');
      val = get(display_menu{3},'value');
      if val == 1
	set(display_menu{4},'vis','off')
	display_choices(whichplot).figure = 'browse_fig';
      elseif val == 2
	set(display_menu{4},'vis','off')
	display_choices(whichplot).figure = 'figure';
      elseif val == 3
	set(display_menu{4},'vis','on', 'string', '')
      end
    
    case 4
      whichplot = get(display_menu{1},'value');
      if get(display_menu{3},'value') == 3
	figno = get(display_menu{4},'string');
	figno = sscanf(figno, '%i');
	if ~isempty(figno)
	  display_choices(whichplot).figure = figno;
	else
	  % automatically dump to new figure
	  display_choices(whichplot).figure = 'figure';
	end
      end
    
    case 5 % GET THE SELECTED X VARIABLE
      dispmenu('setnewvar', argin1)
    
    case 6 % DISPLAY THE SELECTED Y VARIABLE
      dispmenu('setnewvar', argin1)
    
    case 7 % DISPLAY THE SELECTED Z VARIABLE
      dispmenu('setnewvar', argin1)
    
    case 8 % DISPLAY THE SELECTED ZZ VARIABLE
      dispmenu('setnewvar', argin1)

    case 9
      % case 9 is not used at this point.
      
    case 10 % RESET THE PLOT TYPE FOR THIS PLOT
      whichplot = get(display_menu{1},'value');
      plot_type = get(display_menu{10},'value');
      str = get(display_menu{10},'string');
      
      % save the plot type
      display_choices(whichplot).plot_type = ...
	  deblank(lower(str(plot_type,:)));
      
      % reset all plot type options to their defaults
      display_choices(whichplot).color = '';
      display_choices(whichplot).linestyle = '-';
      display_choices(whichplot).marker = 'none';
      display_choices(whichplot).shading = 'flat';
      display_choices(whichplot).clim = [];
      display_choices(whichplot).cval = [];
      
      switch plot_type
	case 1 % plot
	  set(cat(2, display_menu{[7 8]}),'vis','off')
	  % set the special menus
	  set(display_menu{11}(1), 'vis', 'on', 'val', 1)
	  set(display_menu{11}(2),'vis','on')
	  set(display_menu{12}(1), 'vis', 'on', 'val', 1)
	  set(display_menu{12}(2),'vis','on')
	  set(display_menu{13}(1),'vis', 'on', 'val', 1)
	  set(display_menu{13}(2),'vis','on')
	  set(display_menu{14},'vis','off')
	  set(display_menu{15},'vis','off')
	  set(display_menu{16},'vis','off')
	  set(display_menu{9}(3:4),'enable','off')
	  
	case 2 % imagesc
	  set(display_menu{7},'vis','on')
	  set(display_menu{7}(1), 'string', 'Z-data', ...
	      'tooltip', 'Select the data to be imaged/contoured')
	  set(display_menu{8},'vis','off')
	  % set the special menus
	  set(cat(2,display_menu{11:14}),'vis','off')
	  set(display_menu{15}(1),'vis','on','string', '')
	  set(display_menu{15}(2),'vis','on')
	  set(display_menu{16},'vis','off')
	  set(display_menu{9}(3),'enable','on','label','Set Z-data')
	  set(display_menu{9}(4),'enable','off')
	  
	case 3 % contour
	  set(display_menu{7},'vis','on')
	  set(display_menu{7}(1),'string', 'Z-data')
	  set(display_menu{8},'vis','off')
	  % set the special menus
	  set(display_menu{11}(1),'vis', 'on', 'value', 1)
	  set(display_menu{11}(2),'vis','on')
	  set(display_menu{12}(1),'vis', 'on', 'value', 1)
	  set(display_menu{12}(2),'vis','on')
	  set(display_menu{13},'vis','off')
	  set(display_menu{14},'vis','off')
	  set(display_menu{15},'vis','off')
	  set(display_menu{16}(1),'vis', 'on', 'string', '')
	  set(display_menu{16}(2),'vis','on')
	  set(display_menu{9}(3),'enable','on','label','Set Z-data')
	  set(display_menu{9}(4),'enable','off')
	  
	case 4 % contourf
	  set(display_menu{7},'vis','on')
	  set(display_menu{7}(1), 'string', 'Z-data')
	  set(display_menu{8},'vis','off')
	  % set the special menus
	  set(display_menu{11}(1),'vis', 'on', 'value', 1)
	  set(display_menu{11}(2),'vis','on')
	  set(display_menu{12}(1),'vis','on', 'value', 1)
	  set(display_menu{12}(2),'vis','on')
	  set(display_menu{13},'vis','off')
	  set(display_menu{14},'vis','off')
	  set(display_menu{15},'vis','off')
	  set(display_menu{16}(1),'vis', 'on', 'string', '')
	  set(display_menu{16}(2),'vis','on')
	  set(display_menu{9}(3),'enable','on','label','Set Z-data')
	  set(display_menu{9}(4),'enable','off')
	  
	case 5 % pcolor
	  set(display_menu{7},'vis','on')
	  set(display_menu{7}(1),'string', 'Z-data')
	  set(display_menu{8},'vis','off')
	  % set the special menus
	  set(cat(2, display_menu{11:13}),'vis','off')
	  set(display_menu{14}(1),'vis','on', 'value', 1)
	  set(display_menu{14}(2),'vis','on')
	  set(display_menu{15}(1),'vis','on','string', '')
	  set(display_menu{15}(2),'vis','on')
	  set(display_menu{16},'vis','off')
	  set(display_menu{9}(3),'enable','on','label','Set Z-data')
	  set(display_menu{9}(4),'enable','off')
	  
	case 6 % quiver
	  set(display_menu{7}, 'vis', 'on')
	  set(display_menu{7}(1), 'string', 'U-data', ...
	  'tooltip', 'Select the x-component of the data vector')
	  set(display_menu{8},'vis','on')
	  % set the special menus
	  set(display_menu{11}(1),'vis', 'on', 'value', 1)
	  set(display_menu{11}(2),'vis','on')
	  set(display_menu{12},'vis', 'on', 'value', 1)
	  set(display_menu{12}(2),'vis','on')
	  set(display_menu{13},'vis', 'off')
	  set(display_menu{14},'vis','off')
	  set(display_menu{15},'vis','off')
	  set(display_menu{16},'vis','off')
	  set(display_menu{9}(3),'enable','on','label','Set U-data')
	  set(display_menu{9}(4),'enable','on')
	  
	case 7 % polar
	  set(cat(2, display_menu{[7 8]}),'vis','off')
	  % set the special menus
	  set(display_menu{11}(1), 'vis', 'on', 'val', 1)
	  set(display_menu{11}(2),'vis','on')
	  set(display_menu{12}(1), 'vis', 'on', 'val', 1)
	  set(display_menu{12}(2),'vis','on')
	  set(display_menu{13}(1),'vis', 'on', 'val', 1)
	  set(display_menu{13}(2),'vis','on')
	  set(display_menu{14},'vis','off')
	  set(display_menu{15},'vis','off')
	  set(display_menu{16},'vis','off')
	  set(display_menu{9}(3:4),'enable','off')
      end

    case 11 % SET THE COLOR
      whichplot = get(display_menu{1},'value');
      val = get(display_menu{11}(1),'value');
      str = get(display_menu{11}(1),'string');
      color = deblank(str(val,:));
      if strcmp(color,'default'), color = ''; end
      display_choices(whichplot).color = color;
      
    case 12 % SET THE LINESTYLE
      whichplot = get(display_menu{1},'value');
      val = get(display_menu{12}(1),'value');
      str = get(display_menu{12}(1),'string');
      linestyle = deblank(str(val,:));
      if strcmp(linestyle,'none'), linestyle = ''; end
      display_choices(whichplot).linestyle = linestyle;
      
    case 13 % SET THE PLOT MARKER
      whichplot = get(display_menu{1},'value');
      val = get(display_menu{13}(1),'value');
      str = get(display_menu{13}(1),'string');
      marker = deblank(str(val,:));
      if strcmp(marker,'none'), marker = ''; end
      display_choices(whichplot).marker = marker;
            
    case 14 % SET THE SHADING TYPE
      whichplot = get(display_menu{1},'value');
      val = get(display_menu{14}(1),'value');
      str = get(display_menu{14}(1),'string');
      display_choices(whichplot).shading = deblank(str(val,:));
      
    case 15 % SET COLOR LIMITS FOR THIS PLOT
      whichplot = get(display_menu{1},'value');
      str = get(display_menu{15}(1),'string');
      color_limits = sscanf(str,'%f');
      if all(sort(size(color_limits)) == [1 2])
	color_limits = color_limits(:)';
      else
	color_limits = [];
      end
      display_choices(whichplot).clim = color_limits;
      
    case 16
      whichplot = get(display_menu{1},'value');
      str = get(display_menu{16}(1),'string');
      eval([ 'cval = [' str '];']);
      display_choices(whichplot).cval = cval;
      
    case 17 % OK BUTTON
      set(display_fig,'visible','off')
      browse('enableclear')
      plotfunction(display_choices, display_data)
      return
    
    case 18 % CANCEL BUTTON
      set(display_fig, 'visible', 'off')
      browse('getdata','cancel')
      return
      
    case 19 % APPLY BUTTON
      browse('enableclear')
      plotfunction(display_choices, display_data)
      return
  end % end of switch
end % end of checking for argin1 is string or not
