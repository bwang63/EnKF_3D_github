function scroll(argin,argin3)
%
% SCROLL         Part of the DODS data browser (browse.m)
%                Scroll maintains the dataset and variable windows.
%
%                Deirdre Byrne, The Island Institute, 19 May 1997 
%                            dbyrne@islandinstitute.org


% The preceding empty line is important.
%
% $Id: scroll.m,v 1.2 2000/06/15 22:59:50 dbyrne Exp $

% $Log: scroll.m,v $
% Revision 1.2  2000/06/15 22:59:50  dbyrne
%
%
% changed 'userdata' property of browse window to make it a little more distinct.
% -- dbyrne, 00/06/14
%
% Revision 1.2  2000/06/15 22:44:28  root
% *** empty log message ***
%
% Revision 1.1  2000/05/31 22:57:20  root
% *** empty log message ***
%
% Revision 1.15  2000/05/24 19:17:30  root
% Fixed more bugs in scroll.m.  Browser now supports URLlists.
%
% Revision 1.14  2000/05/23 16:05:17  root
% FINALLY fixed bug that kept scroll figures from scrolling properly
% if killed using window manager and re-opened.
%
% Also fixed bug that was calling scroll multiple times on startup of
% browser.
%
%  -- dbyrne 00/05/23
%
% Revision 1.14  2000/03/17 08:47:15  dbyrne
%
%
% Changed menu lists to use character units.  This is cleaner but
% not compatible w/v4.  -- dbyrne 00/03/17
%
% Revision 1.13  1999/07/19 19:02:52  dbyrne
%
%
% Dataset scroll window is now modal -- will not show other datasets once
% one is chosen.  Also, dataset name colors changed to black for unselected,
% and choice of black or light gray once selected (depending on dataset color).
%
% Fixed a bug in plotscript that was using an incorrect index into the
% data range (used in scaling images).
%
% dbyrne 99/07/19
%
% Revision 1.12  1999/05/13 03:09:53  dbyrne
%
%
% Added Acknowledge and Data_Use_Policy to archive.m.  Fixed getxxx functions
% to use dodsmsg instead of stdout for errors/info.  Made ChangeLog so that it's
% in Emacs format.  All changes for release 3.0.0 -- dbyrne 99/05/12
%
% Revision 1.13  1999/05/13 00:53:06  root
% Lots of changes for version 3.0.0 of browser.
%
% Revision 1.12  1999/03/04 13:05:27  root
% *** empty log message ***
%
% Revision 1.11  1998/08/27 14:26:56  dbyrne
% Made sure unselecting dataset also refreshes browse window thru 'setdset'
%
% Revision 1.10  1998/08/25 11:22:56  dbyrne
% *** empty log message ***
%
% Revision 1.9  1998/08/24 16:02:04  dbyrne
% % fixing bug when combinations of variables having no datasets are selected
%
% Revision 1.8  1998/08/20 12:49:04  dbyrne
% % changes to permit multiple variable selection
%
% Revision 1.7  1998/08/19 10:34:18  dbyrne
% *** empty log message ***
%
% Revision 1.6  1998/08/18 10:58:53  dbyrne
% *** empty log message ***
%
% Revision 1.5  1998/08/16 19:05:53  dbyrne
% *** empty log message ***
%
% Revision 1.4  1998/08/14 14:52:34  dbyrne
% *** empty log message ***
%
% Revision 1.3  1998/08/13 18:39:29  dbyrne
% *** empty log message ***
%
% Revision 1.2  1998/08/13 13:00:18  dbyrne
% % Adding mutivariable selection: step 1
%
% Revision 1.1  1998/05/17 14:10:52  dbyrne
% *** empty log message ***
%
% Revision 1.5  1997/12/09 00:46:32  dbyrne
% Updated to allow for little colored boxes next to dataset names.
%
% Revision 1.4  1997/10/10 02:34:08  tom
% some cvs problem
%
% Revision 1.3  1997/10/04 00:33:25  jimg
% Release 2.14c fixes
%
% Revision 1.2  1997/10/02 02:45:14  tom
% Got rid of dataset colors. Would like to have added a little spot
% of color before each dataset name, but that will have to wait.
%
% Revision 1.1.1.1  1997/09/22 14:13:53  tom
% Imported Matlab GUI sources to CVS
%

% variables shared with browse.m
global num_sets master_datasets dset num_vars master_variables scroll_fig
global dods_colors browse_fig master_dataprops datacolor var brs_old_dset
global brs_old_var ranges master_rangemin master_rangemax num_rang
global switchon switchoff rangemin rangemax

% variables used locally
global dataset_slots dataset_buttons variable_slots variable_buttons
global dslide vslide dnum_slots vnum_slots sum_vars sum_sets
global num_slots global datasets variables nsets nvars scr_size height 
global scroll_buttons
% NOTE datasets and variables are simply Boolean indicators

mindatawindowwidth = 105;
minvarwindowwidth = 25;
minbuttonwidth = 3;

% protect against starting up without Browse figure being ready
if isempty(findobj(0,'type','figure','userdata','DODS Matlab GUI'))
  return
end

if ~strcmp(argin,'vopen') & ~strcmp(argin,'dopen')
  % create figures if necessary or else make visible
  k = findobj(0,'type','figure','userdata','DODS variables');
  if ~isempty(k)
    scroll_fig(1) = k;
  else
    scroll('vopen')
  end
  k = findobj(0,'type','figure','userdata','DODS datasets');
  if ~isempty(k)
    scroll_fig(2) = k;
  else
    scroll('dopen')
  end
end

  if strcmp(argin,'dscroll')
    val = round(get(dslide,'value')); % we've scrolled up by val
    x = find(datasets);
    for i = 1:dnum_slots
      set(dataset_buttons(i),'back',datacolor(x(val+i),:))
      if ~isempty(x)
	
	if x(val+i) == dset
	  set(dataset_slots(i),'string',master_datasets(x(val+i),:), ...
	      'userdata',val+i, ...
	      'fore',dods_colors(6,:),'back',datacolor(x(val+i),:))
	else
	  set(dataset_slots(i),'string',master_datasets(x(val+i),:), ...
	      'userdata',x(val+i), ...
	      'fore',dods_colors(6,:),'back',dods_colors(1,:))
	end
      end
    end
  elseif strcmp(argin,'vscroll')
    val = round(get(vslide,'value'));
    x = find(variables);
    for i = 1:vnum_slots
      if ~isempty(x)
	if any(x(val+i) == var)
	  set(variable_slots(i),'string',master_variables(x(val+i),:), ...
	      'userdata',val+i, ...
	      'fore',dods_colors(1,:),'back',dods_colors(6,:))
	else
	  set(variable_slots(i),'string',master_variables(x(val+i),:), ...
	      'userdata',x(val+i), ...
	      'fore',dods_colors(6,:),'back',dods_colors(1,:))
	end
      end
    end

  elseif strcmp(argin,'dselect')
    num = argin3;
    brs_old_dset = dset;
    dset = get(dataset_slots(num),'userdata');
    nsets = 1;
    if brs_old_dset == dset
      % if this was the selected dataset, unselect it 
      dset = nan; nsets = 0; 
      browse('ylabel')
      datasets = zeros(num_sets,1);
      set(dataset_slots(num),'fore',dods_colors(6,:), ...
	  'back',dods_colors(1,:))
      % this calls varset as well to reset other window
      scroll('datset') 
    else      
      dnum_slots = 1;
      % if some of the current variables are not in the dataset, 
      % de-select those variables

      if any(~isnan(var))
	% if ~variables(var)
	if any(~master_dataprops(dset,var))
	  i = find(master_dataprops(dset,var));
	  if ~isempty(i) 
	    var = var(i);
	    nvars = length(var);
	  else
	    var = nan; nvars = 0;
	  end
	end
      end

     % reset the dataset menu figure
      fig_size(2) = round(scr_size(2)*0.7);
      fig_size(1) = size(master_datasets,2)+10; % make it wide enough
      fig_size(2) = min([fig_size(2) (dnum_slots+1)*height]);
      fig_size(1) = max([fig_size(1) mindatawindowwidth]); % minimum acceptable width
      fig_offset = get(scroll_fig(2),'pos'); 
      fig_offset(2) = fig_offset(2)+fig_offset(4)-fig_size(2);
      fig_offset = fig_offset(1:2);
      if sum(datacolor(dset,:)) <= 0.9
	set(dataset_slots(1),'string', master_datasets(dset,:),'visible','on', ...
	    'fore',dods_colors(1,:),'back',datacolor(dset,:), ...
	    'userdata', dset)
      else
	set(dataset_slots(1),'string', master_datasets(dset,:),'visible','on', ...
	    'fore',dods_colors(6,:),'back',datacolor(dset,:), ...
	    'userdata', dset)
      end
      set(dataset_buttons(1),'visible','on','back',datacolor(dset,:))
      set(dataset_slots(2:num_slots),'fore',dods_colors(6,:), ...
	  'back',dods_colors(1,:), 'visible','off')
      % added following line 98/04/13.  don't know if it's needed.  dab
      set(dataset_buttons(2:num_slots),'visible','off')
      for i = 2:dnum_slots
	set(dataset_slots(i),'string','','visible','off')
      end
      set(dslide,'visible','off')
      drawnow
      set(scroll_fig(2),'units','characters','Position',[fig_offset fig_size])
      % reset other window with possible variables
      if ~isnan(dset)
	variables = master_dataprops(dset,:)';
      end
      scroll('varset')
    end

    % reset browser
    browse('setdset')

  elseif strcmp(argin,'vselect')
    num = argin3;
    brs_old_var = var;
    % VARIABLES is a Boolean vector of the currently valid variables
    % NUM_VARS is its length
    % SUM_VARS is its sum (number of currently valid variables)
    % VAR is a vector of indicies of currently selected variables
    % NVARS is its length  
    newvar = get(variable_slots(num),'userdata');
    % first, if this variable has already been selected, unselect it 
    if any(newvar == var)
      i = find(var ~= newvar);
      if isempty(i)
	var = nan;
	% there are no currently selected variables; don't change
	% valid variables list, though (that changes with new
	% selections or changes in the range) or dataset
      else
	var = var(i);
      end
      set(variable_slots(num),'fore',dods_colors(6,:), ...
	  'back',dods_colors(1,:))
    else
      new_variable = zeros(num_vars,1); new_variable(newvar) = 1;
      variables = variables | new_variable;
      var = sort([var; newvar]);
      var = var(find(~isnan(var)));
      if isempty(var)
	var = nan;
      end
    end
    nvars = length(var);
    if isnan(var)
      nvars = 0;
    end
    vnum_slots = min(num_slots,nvars); 
    % reset the figure
    fig_size(2) = round(scr_size(2)*0.7);
    fig_size(1) = size(master_variables,2)+10; % make it wide enough
    fig_size(2) = min([fig_size(2) (vnum_slots+1)*height]);
    fig_size(1) = max([fig_size(1) minvarwindowwidth]); % minimum acceptable width
    fig_offset = get(scroll_fig(1),'pos'); 
    fig_offset(2) = fig_offset(2)+fig_offset(4)-fig_size(2);
    fig_offset = fig_offset(1:2);
      
    % rewrite the lowest slots with the currently selected variables
    for i = 1:vnum_slots
      set(variable_slots(i),'string', master_variables(var(i),:),'visible','on', ...
	  'fore',dods_colors(6,:),'back',dods_colors(6,:), ...
	  'userdata',var(i))
    end
    if nvars < num_slots
      set(variable_slots(nvars+1:num_slots),'fore',dods_colors(6,:), ...
	  'back',dods_colors(1,:), 'string','', 'visible','off')
    end
    if vnum_slots < nvars
      set(vslide,'visible','on','max',num_vars-vnum_slots,'value',0)
    else
      set(vslide,'visible','off','max',num_vars-vnum_slots,'value',0)
    end
    drawnow
      
    set(scroll_fig(1),'units','characters', ...
	'Position', [fig_offset fig_size])
    
    % reset other window
    if isnan(dset)
      scroll('datset')
    else
      scroll('datsubset')
    end
    % reset browser
    browse('choose_var')
  elseif strcmp(argin,'datset') 
    % this is called by vselect or select -- we have chosen a dataset.  Now
    % variable calculate which datasets fall within selected ranges and also 
    % contain that variable.  Set the variable list to reflect that.

    % boolean: which datasets within the given ranges
    % only subselect based on which ranges set
    datamin = zeros(num_sets,1);
    datamax = zeros(num_sets,1);
    if sum(num_rang(1:2)) == 2
      datamin = (ranges(1,1)*ones(num_sets,1) > rangemax);
      datamax = (ranges(1,2)*ones(num_sets,1) < rangemin);
    end
    if sum(num_rang(3:4)) == 2
      datamin = (ranges(2,1)*ones(num_sets,1) > master_rangemax(:,2)) ...
	  | datamin;
      datamax = (ranges(2,2)*ones(num_sets,1) < master_rangemin(:,2)) ...
	  | datamax;
    end
    if sum(num_rang(5:6)) == 2
      datamin = (ranges(3,1)*ones(num_sets,1) > master_rangemax(:,3)) ...
	  | datamin;
      datamax = (ranges(3,2)*ones(num_sets,1) < master_rangemin(:,3)) ...
	  | datamax;
    end
    if sum(num_rang(7:8)) == 2
      datamin = (ranges(4,1)*ones(num_sets,1) > master_rangemax(:,4)) ...
	  | datamin;
      datamax = (ranges(4,2)*ones(num_sets,1) < master_rangemin(:,4)) ...
	  | datamax;
    end
    d = ~(datamin | datamax);
    if any(isnan(var))
      datasets = d;
    else
    % CHANGE 12: valid are datasets which have ALL variables
      datasets = master_dataprops(:,var) & d*ones(1,nvars);
      if nvars > 1 
	datasets = sum(datasets')' == nvars;
      end
    end
    nsets = sum(datasets);
    if ~isnan(dset)
      if ~datasets(dset)
	dset = nan;
      end
    end

    dnum_slots = min(num_slots,nsets); 
    fig_size(2) = round(scr_size(2)*0.7);
    fig_size(1) = size(master_datasets,2)+10; % make it wide enough
    fig_size(2) = min([fig_size(2) (dnum_slots+1)*height]); % max hgt
    fig_size(1) = max([fig_size(1) mindatawindowwidth]); % minimum acceptable width
    fig_offset = get(scroll_fig(2),'pos'); 
    fig_offset(2) = fig_offset(2)+fig_offset(4)-fig_size(2);
    fig_offset = fig_offset(1:2);
    
    x = find(datasets);
    for i = 1:num_slots
      if i <= nsets
	if ~isempty(x)
	  set(dataset_slots(i),'string',master_datasets(x(i),:),'visible','on', ...
	      'userdata', x(i))
	  set(dataset_buttons(i),'back',datacolor(x(i),:),'visible','on')
	  if x(i) == dset
	    if sum(datacolor(dset,:)) <= 0.9
	      set(dataset_slots(i),'fore',dods_colors(1,:),'back',datacolor(dset,:))
	    else
	      set(dataset_slots(i),'fore',dods_colors(6,:),'back',datacolor(dset,:))
	    end
	  else
	    set(dataset_slots(i),'fore',dods_colors(6,:),'back',dods_colors(1,:))
	  end 
	else
	  set(dataset_slots(i),'string','','visible','off')
	  set(dataset_buttons(i),'visible','off')
	end
      end
    end

    if dnum_slots < nsets
      set(dslide,'visible','on','max',nsets-dnum_slots,'value',0)
    else
      set(dslide,'visible','off','max',nsets-dnum_slots,'value',0)
    end
    drawnow

    set(scroll_fig(2),'units','characters', ...
	'Position',[fig_offset fig_size], ...
	'visible','on');
    
    % NEW 98/08/19 now check which variables are valid given this
    % set of valid datasets -- WHAT TO DO IF NONE IS VALID??!
    if ~isempty(x)
      if length(x) == 1
	variables = master_dataprops(x,:)';
      else
	variables = (sum(master_dataprops(x,:)) > 0)';
      end
    else % no dataset is selected
      variables = ones(num_vars,1); nvars = 0;
    end
    scroll('varset')
  
  elseif strcmp(argin,'datsubset') 
    % this is called by vselect or select -- we have chosen a dataset.  Now
    % variable calculate which datasets fall within selected ranges and also 
    % contain that variable.  Set the variable list to reflect that.

    % boolean: which datasets within the given ranges
    % only subselect based on which ranges set
    datamin = zeros(num_sets,1);
    datamax = zeros(num_sets,1);
    if sum(num_rang(1:2)) == 2
      datamin = (ranges(1,1)*ones(num_sets,1) > rangemax);
      datamax = (ranges(1,2)*ones(num_sets,1) < rangemin);
    end
    if sum(num_rang(3:4)) == 2
      datamin = (ranges(2,1)*ones(num_sets,1) > master_rangemax(:,2)) ...
	  | datamin;
      datamax = (ranges(2,2)*ones(num_sets,1) < master_rangemin(:,2)) ...
	  | datamax;
    end
    if sum(num_rang(5:6)) == 2
      datamin = (ranges(3,1)*ones(num_sets,1) > master_rangemax(:,3)) ...
	  | datamin;
      datamax = (ranges(3,2)*ones(num_sets,1) < master_rangemin(:,3)) ...
	  | datamax;
    end
    if sum(num_rang(7:8)) == 2
      datamin = (ranges(4,1)*ones(num_sets,1) > master_rangemax(:,4)) ...
	  | datamin;
      datamax = (ranges(4,2)*ones(num_sets,1) < master_rangemin(:,4)) ...
	  | datamax;
    end
    d = ~(datamin | datamax);
    if any(isnan(var))
      datasets = d;
    else
      datasets = master_dataprops(:,var) & d*ones(1,nvars);
      if nvars > 1 
	datasets = sum(datasets')' == nvars;
      end
    end

    if ~isnan(dset)
      if ~datasets(dset)
	dset = nan;
      end
    end
    
    % now unselect datasets
    datasets = zeros(num_sets,1);
    if ~isnan(dset)
      datasets(dset) = 1;
      nsets = 1;
    else
      nsets = 0;
    end
    
    dnum_slots = min(num_slots,nsets); 
    fig_size(2) = round(scr_size(2)*0.7);
    fig_size(1) = size(master_datasets,2)+10; % make it wide enough
    fig_size(2) = min([fig_size(2) (dnum_slots+1)*height]); % max hgt
    fig_size(1) = max([fig_size(1) mindatawindowwidth]); % minimum acceptable width
    fig_offset = get(scroll_fig(2),'pos'); 
    fig_offset(2) = fig_offset(2)+fig_offset(4)-fig_size(2);
    fig_offset = fig_offset(1:2);
    
    x = find(datasets);
    for i = 1:num_slots
      if i <= nsets
	if ~isempty(x)
	  set(dataset_slots(i),'string',master_datasets(x(i),:),'visible','on', ...
	      'userdata', x(i))
	  set(dataset_buttons(i),'back',datacolor(x(i),:),'visible','on')
	  if x(i) == dset
	    if sum(datacolor(dset,:)) <= 0.9
	      set(dataset_slots(i),'fore',dods_colors(1,:),'back',datacolor(dset,:))
	    else
	      set(dataset_slots(i),'fore',dods_colors(6,:),'back',datacolor(dset,:))
	    end
	  else
	    set(dataset_slots(i),'fore',dods_colors(6,:),'back',dods_colors(1,:))
	  end 
	else
	  set(dataset_slots(i),'string','','visible','off')
	  set(dataset_buttons(i),'visible','off')
	end
      end
    end

    if dnum_slots < nsets
      set(dslide,'visible','on','max',nsets-dnum_slots,'value',0)
    else
      set(dslide,'visible','off','max',nsets-dnum_slots,'value',0)
    end
    drawnow

    set(scroll_fig(2),'units','characters', ...
	'Position',[fig_offset fig_size], ...
	'visible','on');
    
    % NEW 98/08/19 now check which variables are valid given this
    % set of valid datasets -- WHAT TO DO IF NONE IS VALID??!
    if ~isempty(x)
      if length(x) == 1
	variables = master_dataprops(x,:)';
      else
	variables = (sum(master_dataprops(x,:)) > 0)';
      end
    else % no dataset is selected
      variables = ones(num_vars,1); nvars = 0;
    end
    scroll('varset')
  
  elseif strcmp(argin,'varset')
    % this is called by dselect and also by vreset 
    % -- we have chosen a dataset OR selected some ranges
    % and looked at what variables it contains.
    % Now set the variable list to reflect that.
    
    nvars = length(var);
    sum_vars = sum(variables);
    vnum_slots = min(num_slots,sum_vars); 
    fig_size(2) = round(scr_size(2)*0.7);
    fig_size(1) = size(master_variables,2)+10; % make it wide enough
    fig_size(2) = min([fig_size(2) (vnum_slots+1)*height]);
    fig_size(1) = max([fig_size(1) minvarwindowwidth]); % minimum acceptable width
    fig_offset = get(scroll_fig(1),'pos'); 
    fig_offset(2) = fig_offset(2)+fig_offset(4)-fig_size(2);
    fig_offset = fig_offset(1:2);
    x = find(variables);
    for i = 1:num_slots
      if i <= sum_vars
	if ~isempty(x)
	  set(variable_slots(i),'string', master_variables(x(i),:),'visible','on', ...
	      'userdata',x(i))
	  if any(x(i) == var)
	    set(variable_slots(i),'fore',dods_colors(1,:),'back',dods_colors(6,:))
	  else
	    set(variable_slots(i),'fore',dods_colors(6,:),'back',dods_colors(1,:))
	  end	  
	end
      else
	set(variable_slots(i),'string','','visible','off')
      end
    end

    if vnum_slots < sum_vars
      set(vslide,'visible','on','max',sum_vars-vnum_slots,'value',0)
    else
      set(vslide,'visible','off','max',sum_vars-vnum_slots,'value',0)
    end
    drawnow
    
    set(scroll_fig(1),'units','characters', ...
	'Position',[fig_offset fig_size],...
	'visible','on');

  elseif strcmp(argin,'dopen')
    % WINDOW THE SECOND: DATASETS
    % Set up the datasets list window
    % initialize some things
    % boolean: which datasets within the given ranges
    % only subselect based on which ranges set
    datamin = zeros(num_sets,1);
    datamax = zeros(num_sets,1);
    if sum(num_rang(1:2)) == 2
      datamin = (ranges(1,1)*ones(num_sets,1) > rangemax);
      datamax = (ranges(1,2)*ones(num_sets,1) < rangemin);
    end
    if sum(num_rang(3:4)) == 2
      datamin = (ranges(2,1)*ones(num_sets,1) > master_rangemax(:,2)) ...
	  | datamin;
      datamax = (ranges(2,2)*ones(num_sets,1) < master_rangemin(:,2)) ...
	  | datamax;
    end
    if sum(num_rang(5:6)) == 2
      datamin = (ranges(3,1)*ones(num_sets,1) > master_rangemax(:,3)) ...
	  | datamin;
      datamax = (ranges(3,2)*ones(num_sets,1) < master_rangemin(:,3)) ...
	  | datamax;
    end
    if sum(num_rang(7:8)) == 2
      datamin = (ranges(4,1)*ones(num_sets,1) > master_rangemax(:,4)) ...
	  | datamin;
      datamax = (ranges(4,2)*ones(num_sets,1) < master_rangemin(:,4)) ...
	  | datamax;
    end
    d = ~(datamin | datamax);

    % if a variable has been selected, use that as a criterion as well
    if isnan(var)
      datasets = d;
    else
      datasets = master_dataprops(:,var) & d*ones(1,nvars);
    end
    if nvars > 1 
      datasets = sum(datasets')' == nvars;
    end

    nsets = sum(datasets);
    if ~isnan(dset)
      if ~datasets(dset)
	dset = nan;
      end
    end
    
    set(0,'units','characters')
    scr_size = get(0,'ScreenSize');     
    set(0,'units','pixels')
    scr_offset = scr_size(1:2); 
    scr_size = scr_size(3:4);
    set(browse_fig,'units','characters');
    b_offset = get(browse_fig,'pos');
    set(browse_fig,'units','pixels');
    height = 2; % height of each dataset label, in character units
    fig_size(1) = size(master_datasets,2)+10; % make it wide enough
    fig_size(2) = round(scr_size(2)*0.7);
    fig_size(1) = max([fig_size(1) mindatawindowwidth]); % minimum acceptable width
    num_slots = floor((fig_size(2)-height)/height); % leave space
    dnum_slots = min(num_slots,nsets); 
    fig_size(2) = min([fig_size(2) (dnum_slots+1)*height]); % max hgt
    fig_offset = [b_offset(1)-5 b_offset(2)+b_offset(4)-fig_size(2)-3];
    scroll_fig(2) = figure('NumberTitle','off', ...
	'Name','DODS datasets', ...
	'userdata','DODS datasets', ...
	'units','characters', ...
	'resize','on', ...
	'menubar','none', ...
	'Position',[fig_offset fig_size],...
	'interruptible',switchon, ...
	'color',dods_colors(1,:), ...
	'visible','off');

    
    pos = [0 0 floor((fig_size(1)-minbuttonwidth)/2) height];
    callbackstring = 'scroll(''dreset'')';
    scroll_buttons(1) = uicontrol(scroll_fig(2), 'style','push', ...
	'foregroundcolor',dods_colors(6,:), ...
	'backgroundcolor',dods_colors(1,:), ...
	'string', 'Reset List', ...
	'visible','on', ...
	'units', 'characters', ...
	'position', pos, ...
	'callback',callbackstring);

    pos = [(fig_size(1)-floor((fig_size(1)-minbuttonwidth)/2)) 0 ...
	    floor((fig_size(1)-minbuttonwidth)/2) height];
    callbackstring = 'set(gcf,''visible'',''off'')';
    scroll_buttons(2) = uicontrol(scroll_fig(2), 'style','push', ...
	'foregroundcolor',dods_colors(6,:), ...
	'backgroundcolor',dods_colors(9,:), ...
	'string', 'Dismiss', ...
	'visible','on', ...
	'units', 'characters', ...
	'position', pos, ...
	'callback', callbackstring);

    % all the dataset slots are figure width -30 pixels;
    % slider and color buttons are each 15 pix wide. 
    pos = [0 height fig_size(1)-2*minbuttonwidth height];
    buttonpos =  [fig_size(1)-2*minbuttonwidth height minbuttonwidth height];
    x = find(datasets);
    dataset_slots = [];

    for i = 1:num_slots
      callbackstring = sprintf('scroll(''dselect'', %i)',i);
      % where the dataset names are written
      dataset_slots(i) = uicontrol(scroll_fig(2), 'style','push', ...
	  'string','', ...
	  'visible','off', ...
	  'horiz','left', ...
	  'userdata',i, ...
	  'units','characters', ...
	  'position',pos, ...
	  'callback',callbackstring);
      % where the dataset colors are displayed
      dataset_buttons(i) = uicontrol(scroll_fig(2), 'style','frame', ...
	  'string','', ...
	  'visible','off', ...
	  'userdata',i, ...
	  'units','characters', ...
	  'position',buttonpos);
      pos = pos + [0 height 0 0];
      buttonpos = buttonpos + [0 height 0 0];
      if i <= nsets
	if ~isempty(x)
	  set(dataset_buttons(i),'visible','on','back',datacolor(x(i),:))
	  if x(i) == dset
	    set(dataset_slots(i),'string',master_datasets(x(i),:), ...
		'visible','on', 'fore',dods_colors(6,:),'back', ...
		datacolor(x(i),:),'userdata',x(i))
	  else
	    set(dataset_slots(i),'string',master_datasets(x(i),:), ...
	    'visible','on', ...
		'fore',dods_colors(6,:),'back',dods_colors(1,:), ...
		'userdata',x(i))
	  end
	end
      end
    end

    dslide = uicontrol(scroll_fig(2),'style','slider', ...
	'units', 'characters', ...
	'interruptible',switchon, ...
	'position', ...
	[fig_size(1)-minbuttonwidth height minbuttonwidth height*num_slots], ...
	'min',0, 'max',nsets-dnum_slots, ...
	'value', 0, ...
	'visible','off', ...
	'callback','scroll(''dscroll'')');
    if dnum_slots < nsets
      set(dslide,'visible','on')
    end
    drawnow
    if ~isnan(dset)
      scroll('datsubset')
    end
    set(scroll_fig(2),'visible','on')
  
  elseif strcmp(argin,'vopen')
    % WINDOW THE FIRST -- VARIABLES WINDOW
    % Set up the datasets list window
    % initialize variables if necc.
    if isnan(dset) & isnan(var)
      variables = ones(num_vars,1); nvars = 0;
      sum_vars = sum(variables);
    end
    
    set(0,'units','characters')
    scr_size = get(0,'ScreenSize');     
    set(0,'units','pixels')
    scr_offset = scr_size(1:2); 
    scr_size = scr_size(3:4);
    set(browse_fig,'units','characters');
    b_offset = get(browse_fig,'pos');
    set(browse_fig,'units','pixels');
    height = 2; % height of each dataset label, in character units
    fig_size(1) = size(master_variables,2)+10; % make it wide enough
    fig_size(2) = round(scr_size(2)*0.7);
    fig_size(1) = max([fig_size(1) minvarwindowwidth]); % minimum acceptable width
    num_slots = floor((fig_size(2)-height)/height); % leave space
    vnum_slots = min(num_slots,num_vars); 
    fig_size(2) = round(scr_size(2)*0.7);
    fig_size(2) = min([fig_size(2) (vnum_slots+1)*height]);
    fig_offset = [b_offset(1)-10 b_offset(2)+b_offset(4)-fig_size(2)-6];
    
    scroll_fig(1) = figure('NumberTitle','off', ...
	'Name','DODS variables', ...
	'units','characters', ...
	'resize','on', ...
	'menubar','none', ...
	'userdata','DODS variables', ...
	'Position',[fig_offset fig_size],...
	'interruptible',switchon, ...
	'color',dods_colors(1,:), ...
	'visible','off');

    pos = [0 0 floor((fig_size(1)-minbuttonwidth)/2) height];
    callbackstring = 'scroll(''vreset'')';
    scroll_buttons(3) = uicontrol(scroll_fig(1), 'style','push', ...
	'foregroundcolor',dods_colors(6,:), ...
	'backgroundcolor',dods_colors(1,:), ...
	'string', 'Reset List', ...
	'visible','on', ...
	'units', 'characters', ...
	'position', pos, ...
	'callback',callbackstring);
    
    pos = [(fig_size(1)-floor((fig_size(1)-minbuttonwidth)/2)) 0 ...
	    floor((fig_size(1)-minbuttonwidth)/2) height];
    callbackstring = 'set(gcf,''visible'',''off'')';
    scroll_buttons(4) = uicontrol(scroll_fig(1), 'style','push', ...
	'foregroundcolor',dods_colors(6,:), ...
	'backgroundcolor',dods_colors(9,:), ...
	'string', 'Dismiss', ...
	'visible','on', ...
	'units', 'characters', ...
	'position', pos, ...
	'callback', callbackstring);
    
    pos = [0 height fig_size(1)-minbuttonwidth height];
    variable_slots = [];
    for i = 1:num_slots
      callbackstring = sprintf('scroll(''vselect'', %i)',i);
      variable_slots(i) = uicontrol(scroll_fig(1), 'style','push', ...
	  'string','', ...
	  'horiz','left', ...
	  'visible','off', ...
	  'userdata',i, ...
	  'units','characters', ...
	  'position',pos, ...
	  'callback',callbackstring);
      pos = pos + [0 height 0 0];
	if i <= num_vars
	  set(variable_slots(i),'string',master_variables(i,:),'visible','on')
	end
    end

    vslide = uicontrol(scroll_fig(1),'style','slider', ...
	'units', 'characters', ...
	'interruptible', switchon, ...
	'position', ...
	[fig_size(1)-minbuttonwidth fig_size(2)-height*num_slots ...
	  minbuttonwidth height*num_slots], ...
	'min',0, 'max', num_vars-vnum_slots, ...
	'value', 0, ...
	'visible','off', ...
	'callback','scroll(''vscroll'')');
    if vnum_slots < num_vars
      set(vslide,'visible','on')
    end
    drawnow
    scroll('varset', var)
    set(scroll_fig(1),'visible','on')
  elseif strcmp(argin,'dreset')
    dnum_slots = num_slots;
    datasets = ones(num_sets,1);
    nsets = num_sets;
    dnum_slots = min(num_slots,nsets); 
    fig_size(2) = round(scr_size(2)*0.7);
    fig_size(1) = size(master_datasets,2)+10; % make it wide enough
    fig_size(2) = min([fig_size(2) (dnum_slots+1)*height]); % max hgt
    fig_size(1) = max([fig_size(1) mindatawindowwidth]); % minimum acceptable width
    fig_offset = get(scroll_fig(2),'pos'); 
    fig_offset(2) = fig_offset(2)+fig_offset(4)-fig_size(2);
    fig_offset = fig_offset(1:2);
    
    x = find(datasets);
    for i = 1:dnum_slots
      if i <= nsets
	if ~isempty(x)
	  set(dataset_slots(i),'string',master_datasets(x(i),:),'visible','on', ...
	      'userdata', x(i))
	  set(dataset_buttons(i),'back',datacolor(x(i),:),'visible','on')
	  if x(i) == dset
	    if sum(datacolor(dset,:)) <= 0.9
	      set(dataset_slots(i),'fore',dods_colors(1,:),'back',datacolor(dset,:))
	    else
	      set(dataset_slots(i),'fore',dods_colors(6,:),'back',datacolor(dset,:))
	    end
	  else
	    set(dataset_slots(i),'fore',dods_colors(6,:),'back',dods_colors(1,:))
	  end 
	else
	  set(dataset_slots(i),'string','','visible','off')
	end
      end
    end

    if dnum_slots < nsets
      set(dslide,'visible','on','max',nsets-dnum_slots,'value',0)
    else
      set(dslide,'visible','off','max',nsets-dnum_slots,'value',0)
    end
    drawnow

    set(scroll_fig(2),'units','characters', ...
	'Position',[fig_offset fig_size], ...
	'visible','on');

  elseif strcmp(argin,'vreset')
    % set all variables to valid
    variables = ones(num_vars,1);
    x = find(variables);
    vnum_slots = min(num_slots,num_vars); 
    fig_size(2) = round(scr_size(2)*0.7);
    fig_size(1) = size(master_variables,2)+10; % make it wide enough
    fig_size(2) = min([fig_size(2) (vnum_slots+1)*height]);
    fig_size(1) = max([fig_size(1) minvarwindowwidth]); % minimum acceptable width
    fig_offset = get(scroll_fig(1),'pos'); 
    fig_offset(2) = fig_offset(2)+fig_offset(4)-fig_size(2);
    fig_offset = fig_offset(1:2);

    for i = 1:num_slots
      if i <= num_vars
	if ~isempty(x)
	  set(variable_slots(i),'string', master_variables(x(i),:),'visible','on', ...
	      'userdata',x(i))
	  if any(x(i) == var)
	    set(variable_slots(i),'fore',dods_colors(1,:),'back',dods_colors(6,:))
	  else
	    set(variable_slots(i),'fore',dods_colors(6,:),'back',dods_colors(1,:))
	  end	  
	end
      else
	set(variable_slots(i),'string','','visible','off')
      end
    end

    if vnum_slots < num_vars
      set(vslide,'visible','on','max',num_vars-vnum_slots,'value',0)
    else
      set(vslide,'visible','off','max',num_vars-vnum_slots,'value',0)
    end
    drawnow

    set(scroll_fig(1),'units','characters', ...
	'Position',[fig_offset fig_size],...
	'visible','on');

  elseif strcmp(argin,'fontsize')
    set([dataset_slots variable_slots scroll_buttons],'fontsize',argin3)
  end
  return
