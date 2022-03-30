function [argout1, argout2, argout3] = listedit(arg1, arg2, arg3, arg4)

% determined externally
global dodsdir dirsep user_variables userlist
global folder_start folder_end

% used locally
global EDIT_FIGURE EDIT_LIST
global datalist_history buffer listlength 
global history_length init_archives

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%         BASIC CONTROL OF FIGURES AND LOADING NEW LISTS             %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
switch arg1
  case 'changecolor'
    if ~isempty(findfig('DODS listedit'))
      foregroundcolor = arg2(1,:);
      backgroundcolor = arg2(2,:);
      set(EDIT_FIGURE, 'color', backgroundcolor)
      clistbox(EDIT_LIST, 'backgroundcolor', backgroundcolor)
    end

  case 'fontsize'
    if ~isempty(findfig('DODS listedit'))
      fontsize = arg2;
      clistbox(EDIT_LIST, 'fontsize', fontsize)
    end

  case 'newlists'
    if isempty(findfig('DODS listedit'))
      fontsize = 0;
      colors = zeros(3,3);
      figsize = zeros(1,4);
      % set up the dataset/folder properties editing windows
      listedit('start', fontsize, colors, figsize)
    end

    % initialize values
    newdata = arg2;
    newvariables = arg3;
  
    % save the initial archive.m files for comparison
    % with final list
    init_archives = strvcat(newdata.archive);

    % nothing is bold or selected in the edit list ....
    [newdata(:).fontweight] = deal('normal');
  
    % reset show strings
    newdata = dlist2slist(newdata);

    % clear the buffer and the stack
    listedit('clearbuffer')
    listedit('clearstack',1:history_length)
  
    % push it onto the stack
    listedit('push',[{newdata},{newvariables}]);

    % set the visible list
    listedit('ereset')
    
    % unselect
    clistbox(EDIT_LIST,'select',0)
    
    % reset eprops
    listedit('eprops')
  
    figure(EDIT_FIGURE)
  
  case 'start'
    % close any existing of these figures
    closefig('DODS listedit')

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
    figpos = arg4(1,:);
    
    % THE EDIT FIGURE
    if any(figpos(3:4) == 0)
      figpos = browse('figpos',5);
    end
    
    if any(figpos(3:4) == 0)
      browse_fig = browse('getfigno');
      un = get(browse_fig,'units');
      set(browse_fig,'units','pixels');
      b_offset = get(browse_fig,'pos');
      set(browse_fig,'units',un)
      fig_size = [370 300];
      fig_offset = [b_offset(1)+125 ...
	    b_offset(2)+b_offset(4)-fig_size(2)+5];
      figpos = [fig_offset fig_size];
    end
      
    EDIT_FIGURE = figure('menubar','none','visible','off', ...
	'units', 'pixels', 'pos', figpos, ...
	'numbertitle', 'off','name', 'Edit DODS Bookmarks', ...
	'resize','on', 'userdata', 'DODS listedit', ...
	'color', backgroundcolor);

    % set history length
    history_length = 100;

    % set up file menu options  
    filemenu = uimenu(EDIT_FIGURE,'label','File');
    fileopts(1) = uimenu(filemenu,'label','Open Bookmarks File', ...
	'callback','listedit(''fopen'')');
    fileopts(2) = uimenu(filemenu,'label','Save as ...', ...
	'callback','listedit(''fsaveas'')');
    fileopts(3) = uimenu(filemenu,'label','Reset to Master List', ...
	'callback','listedit(''freset'')', ...
	'separator','on');
    fileopts(4) = uimenu(filemenu,'label','Apply to GUI', ...
	'callback','listedit(''fapply'')', ...
	'separator','on');
    fileopts(5) = uimenu(filemenu,'label','Apply and Close', ...
	'callback','listedit(''fclose'')');
    fileopts(6) = uimenu(filemenu,'label','Cancel', ...
	'callback','listedit(''fcancel'')');
  
    % set up editing menu options
    editmenu = uimenu(EDIT_FIGURE,'label','Edit');
    editopts(1) = uimenu(editmenu,'label','Undo ...','accelerator','Z');
    undoopts(1) = uimenu(editopts(1),'label','Undo Last', ...
	'callback','listedit(''eundo'')');
    undoopts(2) = uimenu(editopts(1),'label','Undo All', ...
	'callback','listedit(''eundoall'')');
    editopts(2) = uimenu(editmenu,'label','Cut', ...
	'accelerator','X', ...
	'callback','listedit(''ecut'')');
    editopts(3) = uimenu(editmenu,'label','Copy', ...
	'accelerator','C', ...
	'callback','listedit(''ecopy'')');
    editopts(4) = uimenu(editmenu,'label','Paste', ...
	'accelerator','V', ...
	'callback','listedit(''epaste'')');
    editopts(5) = uimenu(editmenu,'label','Select All', ...
	'accelerator','A', ...
	'callback','listedit(''eselall'')');
    editopts(6) = uimenu(editmenu,'label','Properties', ...
	'callback','dodspropedit(''showprops'')');
    editopts(7) = uimenu(editmenu,'label','Insert New ...');
    insertopts(1) = uimenu(editopts(7),'label','Folder', ...
	'callback','listedit(''efolder'')');
    insertopts(2) = uimenu(editopts(7),'label','Dataset', ...
	'callback','listedit(''edataset'')','enable','on');

    % set up view menu
    viewmenu = uimenu(EDIT_FIGURE,'label','View');
    uimenu(viewmenu,'label','Master List', ...
	'callback','mastershow(''mopen'')')
  
    % set up a stack
    datalist_history = cell(history_length,2);
  
    % initialize a cut and paste buffer
    buffer = cell(1,3);

    % set up the figure
    str  = sprintf('%s','Double-click to open/close a folder.');
    EDIT_LIST = clistbox('parent',EDIT_FIGURE, 'tooltip', str, ...
	'backgroundcolor',backgroundcolor, 'doubleclick', ...
	'listedit(''doubleclick'')', ...
	'singleclick', 'listedit(''singleclick'')', ...
	'dragfunction','on', ...
	'units','normalized', ...
	'dropfunction', 'listedit(''drop'')', ...
	'mode', 'override', 'fontsize', fontsize);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%         COLLATING/EVALUATING NEW ARCHIVES AND DEALING FROM         %
%           THE EDITLIST STACK BACK TO THE GLOBAL USERLISTS          %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
switch arg1
  case 'deal'
    % get most recent structure
    newdata = datalist_history{1,1};
    newvariables = datalist_history{1,2};
  
    if isempty(newdata)
      return
    end
    
    % now do a check to see if there are changes in archive.m
    final_archives = char(newdata(:).archive);
    success = [];
    for j = 1:size(final_archives,1)
      arg1 = deblank(final_archives(j,:));
      if ~isempty(arg1)
	evalflag = 1;
	for i = 1:size(init_archives,1)
	  arg2 = deblank(init_archives(i,:));
	  if strcmp(arg1, arg2)
	    evalflag = 0;
	    break
	  end
	end
	
	% evaluate the new archive and add in any new variables
	if evalflag
	  k = listedit('doeval', j);
	  success = [success k];
	end
      end
    end
    
    % get the updated information
    newlist = datalist_history{1,1};
    newvariables = datalist_history{1,2};
    
    % Eliminate any variables with no datasets associated!
    dataprops = cat(1,newlist(:).dataprops);
    i = find(sum(dataprops) == 0);
    if ~isempty(i)
      j = find(sum(dataprops) > 0);
      dataprops = dataprops(:,j);
      newvariables = newvariables(j,:);
      
      for i = 1:size(newdata,1)
	newlist(i).dataprops = dataprops(i,:);
      end
    end
    
    % put values into global lists
    userlist = newlist;
    user_variables = newvariables;

    % warn user about dicey datasets
    if any(success > 0)
      evalerr = sum(success);
      success = find(success);
      arg1 = char(newdata(success).archive);
      arg1 = sprintf('%s ', arg1');
      str = sprintf('%i %s\n\n%s\n\n%s', evalerr, ...
	  [ 'non-fatal errors were encountered', ...
	    ' in evaluating the archive files:'], ...
	  arg1, ...
	  'Please examine these files for problems.');
      dodsmsg(str)
    end
    
    % make user_ global matrices and new rangemin, etc. 
    browse('mkusermats')
    
    % and reset the userlists, the dset and the var
    % this takes care of dreset and vreset
    browse('clearrange')
    
    % reset the selected_datasets list
    browse('newselections')
    
    if nargout > 0
      argout1 = newlist;
      argout2 = newvariables;
    end
    
  case 'doeval'
    if nargin == 1;
      pos = listedit('getpos');
    else
      pos = arg2;
    end
    % get the current lists
    newdata = datalist_history{1,1};
    newvariables = datalist_history{1,2};
    
    % get the archive
    archive = newdata(pos).archive;
    
    % save things the user may have set
    newcolor = newdata(pos).color;
    newname = newdata(pos).name;
    level = newdata(pos).nestinglevel;
    
    success = 0;
    
    if checkfunction(archive)
      str = sprintf('Archive file %s is not on your Matlabpath.  %s', ...
	  archive, 'Unable to load.');
      dodsmsg(str)
      % indicate a fatal error
      success = -1;
      return
    end
    
    % build up structure from new archive
    [newdataset, newvars, success] = addarchive(archive, ...
	newvariables);
    if nargout == 0
      if success > 0
	% some errors were encountered
	str = sprintf('%i %s %s%s', success, ...
	    [ 'non-fatal errors were encountered', ...
	      ' in evaluating your archive file'], ...
	    editboxcontents{2}, ...
	    '.  Please examine the file for problems.');
	dodsmsg(str)
      end
    else
      argout1 = success;
    end

    newdata(pos) = newdataset;
    if ~isempty(newvars)
      [newdata, newvariables] = addvariables(newdata, newvariables, ...
	  newvars, pos);
    end
    % update user-set things
    newdata(pos).name = newname;
    newdata(pos).nestinglevel = level;
    newdata(pos).color = newcolor;
    % reset show strings
    newdata = dlist2slist(newdata);
    
    % push the stack
    listedit('push',[{newdata},{newvariables}])
    
    % reset visible list
    listedit('ereset')
    
    % reset editable properties window
    listedit('eprops')
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                         LIST MANIPULATION COMMANDS                 %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
switch arg1
  case 'doubleclick' % doubleclick opens/closes folder
    
    % this is a double click
    pos = listedit('getpos');
    newdata = datalist_history{1,1};
    newvariables = datalist_history{1,2};
    if isfolder(newdata, pos)
      newdata(pos).open = ~newdata(pos).open;
      newdata = dlist2slist(newdata);
      % push the new stuff onto the stack
      listedit('push',[{newdata},{newvariables}]);
      
      % reset list box with new list
      listedit('ereset')
      
      % reset the editable properties window
      listedit('eprops')
      
    end
    
  case 'drop'
    % get position of selected items:
    pos = listedit('getpos');
    % get current struct
    newdata = datalist_history{1,1};
    newvariables = datalist_history{1,2};
    
    % Note that if a folder is being cut, everything down to the
    % endfolder must be cut out and buffered.
    newpos = [];
    for i = 1:length(pos)
      if isfolder(newdata,pos(i))
	% find the end of the folder
	endfolder = findendfolder(newdata,pos(i));
	newpos = [newpos pos(i):endfolder];
      else
	newpos = [newpos pos(i)];
      end
    end
    newpos = sort(newpos);
    newpos = newpos(findnew(newpos));
    pos = newpos;
    % locally buffer the cut material
    tmpdata = newdata(pos);
    
    % Now, paste tmpdata into a new place
    % get current position in datalist
    droppos = listedit('getdroppos');
    
    if floor(droppos) == droppos
      if droppos > 0
	if ~isfolder(newdata, droppos)
	  % paste after selected position
	  droppos = droppos + 1;
	elseif isfolder(newdata, droppos)
	  % paste INTO a folder, open or closed,
	  % if directly selected like this.
	  droppos = droppos + 1;
	end
      else
	droppos = 1;
      end
    else
      fpos = floor(droppos);
      if ~isfolder(newdata, fpos);
	droppos = fpos + 1;
      elseif isfolder(newdata, fpos)
	if newdata(fpos).open == 1 & ...
	      ~isendfolder(newdata, fpos+1)
	  % this is an open folder with things in it
	  % paste INTO the open folder.
	  droppos = fpos + 1;
	elseif  newdata(fpos).open == 1 & ...
	      isendfolder(newdata, fpos+1)
	  % this is an open folder but it's empty
	  % paste AFTER it
	  droppos = fpos + 2;
	else % this is a CLOSED folder.  Paste AFTER it.
	  % find the end of the folder
	  endfolder = findendfolder(newdata,fpos);
	  droppos = endfolder + 1;
	end
      end
    end
    
    % check for length and nesting of pasted thing
    s = size(tmpdata,1);
    
    % move everything down
    newdata(droppos+s:listlength+s) = newdata(droppos:listlength);
    newdata(droppos:droppos+s-1) = tmpdata;
    
    if droppos >= pos(1)
      % drag paste position is AFTER old position.
      % index of stuff to cut does not change.
    else
      pos = pos+length(pos);
    end
    
    s = size(newdata,1);
    inx = 1:s;
    inx = find(~isin(inx,pos));
    
    % make the cut
    newdata = newdata(inx);
    
    % reset the levels
    s = size(newdata,1);
    level = zeros(s,1);
    for i = 1:s
      if i == 1
	level(i) = 0;
      end
      if isfolder(newdata, i)
	level(i+1:s) = level(i+1:s)+1;
      elseif isendfolder(newdata, i)
	level(i+1:s) = level(i+1:s)-1;
      end
      newdata(i).nestinglevel = level(i);
    end
    
    % reset the showlist
    newdata = dlist2slist(newdata);
    
    % push new list onto the stack
    listedit('push', [{newdata},{newvariables}])
    
    % DE-SELECT THE CUT PLACE
    clistbox(EDIT_LIST,'select', 0)
    
    % reset visible list
    listedit('ereset')
    
    % reset the editable properties window
    listedit('eprops')
    
  case 'ecopy'
    % get position of highlighted row.
    pos = listedit('getpos');
    
    if pos > 0
      
      % get current struct
      newdata = datalist_history{1};
      
      % Note that if a folder is being cut, everything down to the
      % endfolder must be cut out and buffered.
      newpos = [];
      for i = 1:length(pos)
	if isfolder(newdata,pos(i))
	  % find the end of the folder
	  endfolder = findendfolder(newdata,pos(i));
	  % buffer the cut material
	  newpos = [newpos pos(i):endfolder];
	else
	  newpos = [newpos pos(i)];
	end
      end
      
      newpos = sort(newpos);
      newpos = newpos(findnew(newpos));
      pos = newpos;
      
      % buffer the cut material
      listedit('buffer', pos, 'self')
    end
    
  case 'ecut'
    % get position of highlighted row.
    pos = listedit('getpos');
    
    % get current struct
    newdata = datalist_history{1};
    
    newpos = [];
    for i = 1:length(pos)
      % Note that if a folder is being cut, everything down to the
      % endfolder must be cut out and buffered.
      if isfolder(newdata,pos(i))
	% find the end of the folder
	endfolder = findendfolder(newdata,pos(i));
	% buffer the cut material
	newpos = [newpos pos(i):endfolder];
      else
	newpos = [newpos pos(i)];
      end
    end
    newpos = sort(newpos);
    newpos = newpos(findnew(newpos));
    pos = newpos;
    
    % buffer the cut material
    listedit('buffer', pos, 'self')
    % get row number for everything *not* being cut
    inx = [];
    for i = 1:listlength
      if ~any(i == pos)
	inx = [inx i];
      end
    end
    
    % make the cut
    newdata = datalist_history{1,1};
    newvariables = datalist_history{1,2};
    newdata = newdata(inx);
    
    % reset the showlist
    newdata = dlist2slist(newdata);
    
    % push new list onto the stack
    listedit('push', [{newdata},{newvariables}])
    
    % DE-SELECT THE CUT PLACE
    clistbox(EDIT_LIST,'select', 0)
    
    % reset the visible list
    listedit('ereset')
    
    % reset the editable properties window
    listedit('eprops')
    
  case 'edataset'
    % get position in structure
    pos = listedit('getpos');
    
    % get current structure
    newdata = datalist_history{1,1};
    newvariables = datalist_history{1,2};
    
    if pos > 0
      level = newdata(pos).nestinglevel;
      if isfolder(newdata, pos)
	if newdata(pos).open == 1
	  % if open folder, new folder goes INSIDE
	  level = level+1;
	  pos = pos+1;
	else
	  pos = findendfolder(newdata, pos)+1;
	end
      else
	pos = pos+1;
      end
    else
      level = 0;
      pos = 1;
    end
    
    % bump entries following the newfolder DOWN ONE PLACE
    newdata(pos+1:listlength+1) = newdata(pos:listlength);

    % get colors
    dods_colors = browse('getcolors');

    % create new dataset entry
    % new dataset is created in a CLOSED position
    % since datasets can't be 'open'.
    newdata(pos).name = 'New Dataset';
    newdata(pos).archive = '';
    newdata(pos).color = dods_colors(6,:);
    newdata(pos).dataname = '';
    newdata(pos).rangemin = [nan nan nan nan];
    newdata(pos).rangemax = [nan nan nan nan];
    newdata(pos).resolution = nan;
    newdata(pos).getxxx = '';
    newdata(pos).dataprops = zeros(1,size(newvariables,1));
    newdata(pos).nestinglevel = level;
    newdata(pos).open = 0;
    newdata(pos).string = '';
    newdata(pos).fontweight = 'normal';
    newdata(pos).show = 1;
    newdata(pos).URLinfo = [];
    newdata = newdata(:);
    
    % reset show strings
    newdata = dlist2slist(newdata);
    
    % push the stack
    listedit('push', [{newdata}, {newvariables}]);
    
    % reset visible list
    listedit('ereset')
    
    % get the list of things that will be shown
    % where is pos in relation?
    index = cat(1,newdata.show);
    pos = sum(index(1:pos));
    
    % unselect
    clistbox(EDIT_LIST, 'select', 0)
    % select the new thing
    clistbox(EDIT_LIST, 'select', pos)
    
    % reset edit properties window
    listedit('eprops')
    
    % prompt user to edit the new dataset by opening edit window
    dodspropedit('showprops')
    
  case 'efolder'
    % get position in structure
    pos = listedit('getpos');
    
    % get current structure
    newdata = datalist_history{1,1};
    newvariables = datalist_history{1,2};
    % Now add new list elements: the level of nesting will be the 
    % same as the next item above, unless the next item above
    % is a folder.  If the new folder is the first item on the list,
    % the nesting level is automatically 0.  
    
    if pos > 0
      level = newdata(pos).nestinglevel;
      if isfolder(newdata, pos)
	if newdata(pos).open == 1
	  % if open folder, new folder goes INSIDE
	  level = level+1;
	  pos = pos+1;
	else
	  pos = findendfolder(newdata, pos)+1;
	end
      else
	pos = pos+1;
      end
    else
      level = 0;
      pos = 1;
    end
    
    % bump entries following the newfolder DOWN TWO PLACES
    newdata(pos+2:listlength+2) = newdata(pos:listlength);
    
    % get colors
    dods_colors = browse('getcolors');

    % data string for top of new folder
    % new folder is created in an OPEN position
    % folders do not have archives or colors
    newdata(pos).name = [folder_start 'New Folder'];
    newdata(pos).archive = '';
    newdata(pos).color = dods_colors(6,:);
    newdata(pos).dataname = '';
    newdata(pos).rangemin = [nan nan nan nan];
    newdata(pos).rangemax = [nan nan nan nan];
    newdata(pos).resolution = nan;
    newdata(pos).getxxx = '';
    newdata(pos).dataprops = zeros(1,size(newvariables,1));
    newdata(pos).nestinglevel = level;
    newdata(pos).open = 1;
    newdata(pos).string = '';
    newdata(pos).fontweight = 'normal';
    newdata(pos).show = 1;
    newdata(pos).URLinfo = [];
    
    % data string for end of new folder
    % endfolders do not have archives or colors
    newdata(pos+1).name = folder_end;
    newdata(pos+1).archive = '';
    newdata(pos+1).color = dods_colors(6,:);
    newdata(pos+1).dataname = '';
    newdata(pos+1).rangemin = [nan nan nan nan];
    newdata(pos+1).rangemax = [nan nan nan nan];
    newdata(pos+1).resolution = nan;
    newdata(pos+1).getxxx = '';
    newdata(pos+1).dataprops = zeros(1,size(newvariables,1));
    newdata(pos+1).nestinglevel = level+1;
    newdata(pos+1).open = 0;
    newdata(pos+1).string = '';
    newdata(pos+1).fontweight = 'normal';
    newdata(pos+1).show = 0;
    newdata(pos+1).URLinfo = [];
    newdata = newdata(:);
    
    % reset show strings
    newdata = dlist2slist(newdata);
    
    % push the stack
    listedit('push', [{newdata},{newvariables}]);
    
    % reset visible list
    listedit('ereset')
    
    % get the list of things that will be shown
    % where is pos in relation?
    index = cat(1,newdata.show);
    pos = sum(index(1:pos));
    
    % unselect
    clistbox(EDIT_LIST, 'select', 0)
    % select the new thing
    clistbox(EDIT_LIST, 'select', pos)
    
    % reset edit properties window
    listedit('eprops')
    
    % prompt user to edit the folder by opening edit window
    dodspropedit('showprops')
    
  case 'epaste'
    % check that there is something in the buffer
    if isempty(buffer{1})
      return
    end
    
    % unpack the buffer
    buffercontents = buffer{1};
    buffermode = buffer{2};
    
    % get current position in datalist
    pos = listedit('getpos');
    
    % get current userlist
    newdata = datalist_history{1,1};
    newvariables = datalist_history{1,2};
    
    if strcmp(buffermode,'master')
      mastervars = buffer{3};
      % MUST MAKE SURE COLUMNS OF THE DATAPROPS MATCH UP!
      % get masterdataprops in line with userdataprops
      userdataprops = cat(1,newdata(:).dataprops);
      s1 = size(userdataprops);
      dataprops = cat(1,buffercontents(:).dataprops);
      s2 = size(dataprops);
      
      % the list generated from the new MANIFEST is variables while the 
      % old user-list is in newuservariables.
      [index, addvars] = compvars(newvariables, mastervars);
      
      if ~isempty(addvars)
	% rearrange the master dataprops so that any variables
	% not on the current userlist are on the righthand side.
	newdataprops = zeros(s2(1),s1(2)+size(addvars,1));
	newdataprops(:,index) = dataprops;
	
	% add new variables at end of uservariables
	newvariables = str2mat(newvariables, addvars);
	% pad columns of user dataprops w/zeros for the new variables
	userdataprops = [userdataprops zeros(s1(1),size(addvars,1))];
	for i = 1:s1(1)
	  newdata(i).dataprops = userdataprops(i,:);
	end
      else
	newdataprops = zeros(s2(1),s1(2));
	% none of the variables are new -- just make sure in same
	% order and columns of zeros for missing ones.
	newdataprops(:,index) = dataprops;
      end
      for i = 1:s2(1)
	buffercontents(i).dataprops = newdataprops(i,:);
      end
    end
    
    % check for length and nesting of pasted thing
    s = size(buffercontents,1);
    
    if pos > 0
      % if many things are selected, automatically paste after the
      % LAST one.
      if length(pos) > 1
	pos = pos(length(pos));
      end
      % if the highlighted position is a folder, put
      % the buffer "into" the folder by nesting it.
      if isfolder(newdata, pos)
	if newdata(pos).open == 1
	  % this folder is open.  Paste INTO it.
	  % move everything after the paste position down
	  newdata(pos+1+s:listlength+s) = newdata(pos+1:listlength);
	  newdata(pos+1:pos+s) = buffercontents;
	else
	  % this folder is closed. Paste AFTER it.
	  newpos = findendfolder(newdata, pos);
	  newdata(newpos+1+s:listlength+s) = newdata(newpos+1:listlength);
	  newdata(newpos+1:newpos+s) = buffercontents;
	end
      else
	% move everything down
	newdata(pos+s+1:listlength+s) = newdata(pos+1:listlength);
	% paste
	newdata(pos+1:pos+s) = buffercontents;
      end
    else
      % move everything down
      newdata(pos+s+1:listlength+s) = newdata(pos+1:listlength);
      % paste
      newdata(pos+1:pos+s) = buffercontents;
      
    end
    
    % reset the nesting levels
    s = size(newdata,1);
    level = zeros(s,1);
    for i = 1:s
      if i == 1
	level(i) = 0;
      end
      if isfolder(newdata, i)
	level(i+1:s) = level(i+1:s)+1;
      elseif isendfolder(newdata, i)
	level(i+1:s) = level(i+1:s)-1;
      end
      newdata(i).nestinglevel = level(i);
    end
    
    % reset show strings
    newdata = dlist2slist(newdata);
    
    % push the stack
    listedit('push',[{newdata},{newvariables}])
    
    % reset visible list
    listedit('ereset')
    
    % reset the editable properties window
    listedit('eprops')
    
  case 'ereset'
    % set the color frames and text in the visible list to
    % respond to changes due to scrolling, cutting, pasting, etc.
    
    % get current item in history
    newdata = datalist_history{1,1};
    % set/get max length of real list
    listlength = size(newdata,1);
    if listlength > 0
      % extract items that should be shown from the database
      showlist = char(newdata(:).string);
      colors = cat(1,newdata(:).color);
      index = cat(1,newdata.show);
      index = find(index(:));
      showlist = showlist(index,:);
      colors = colors(index,:);
    
      % first column is the string to be shown
      % second column is the color of the string
      % third column is the highlight/don't highlight boolean
      % We start off with nothing highlighted.
      userdata = cellstr(showlist);
      userdata(:,2) = num2cell(colors,2);
      userdata(:,3) = deal({['normal']});
    else
      userdata = cell({});
    end
    % update the userdata in the clistbox
    clistbox(EDIT_LIST,'string',userdata)
    
  case 'eselall'
    % extract items that should be shown from the database
    newdata = datalist_history{1,1};
    index = cat(1,newdata.show);
    index = 1:sum(index);
    if ~isempty(index)
      % select all of them
      clistbox(EDIT_LIST, 'select', index)
    end
    
  case 'eundo'
    % check if there is something to undo
    if isempty(datalist_history{2,1})
      disp('There is nothing to undo!')
      return
    end
    % pop the stack
    listedit('pop',1)
    
    % reset the visible list
    listedit('ereset')
    
  case 'eundoall'
    % check if there is something to undo
    if isempty(datalist_history{2,1})
      disp('There is nothing to undo!')
      return
    end
    
    % if so, search backward from end to see how many edits
    % will need to be popped off of the stack
    for i = 0:history_length-1
      if ~isempty(datalist_history{history_length-i,1})
	break
      end
    end
    % pop the stack
    listedit('pop', history_length - i - 1)
    
    % reset the visible list
    listedit('ereset')
    
  case 'getdroppos'
    % get position on visible list
    droppos = clistbox(EDIT_LIST, 'dropposition');
    % get the relative position in the userlist
    newdata = datalist_history{1,1};
    index = cat(1,newdata(:).show);
    index = find(index);
    if droppos > 0
      if floor(droppos) == droppos
	droppos = index(droppos);
      else
	droppos = index(floor(droppos)) + 0.5;
      end
    end
    argout1 = droppos;
    
  case 'getpos'
    % get position on visible list
    pos = clistbox(EDIT_LIST, 'value');
    % get the relative position in the userlist
    newdata = datalist_history{1,1};
    index = cat(1,newdata(:).show);
    index = find(index);
    if pos > 0
      pos = index(pos);
    end
    argout1 = pos;
    
  case 'getdatalistfile'
    % list of what to save
    if nargout > 0
      % and where to save it
      argout1 = '.dods_datasets.mat';
    end

  case 'getsavestr'
    % list of what to save
    if nargout > 0
      argout1 = [ ' newlist newvariables'];
    end

  case 'singleclick'
    % take care of properties window
    listedit('eprops')
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%        FILE AND WINDOW MANIPULATION COMMANDS                       %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
switch arg1
  case 'fapply'
    % apply changes
    listedit('deal')
    
    % save changes
    listedit('fsave')
    
    % do not close the figure
    
  case 'fcancel'
    % close the figures w/out applying changes
    set(EDIT_FIGURE,'visible','off');
    mastershow('mclose')
    dodspropedit('close')
    
  case 'fclose'
    % apply changes
    listedit('deal')
    
    % save changes
    listedit('fsave')
    
    % close the figures
    set(EDIT_FIGURE,'visible','off');
    mastershow('mclose')
    dodspropedit('close')
    
  case 'fopen'
    if isempty(dodsdir)
      dir = which('browse');
      i = max(findstr(dir,dirsep));
      dodsdir = dir(1:i);
      dodsdir = ['''' dodsdir ''''];
    end
    
    % suggest filename
    datalist_file = listedit('getdatalistfile');
    if isempty(findstr(datalist_file, dirsep))
      fname = [dodsdir datalist_file];
    else
      fname = datalist_file;
    end
    answer = dodsdlg('Open bookmarks list mat-file:', ...
	'DODS Browse: open bookmarks list', 1, {fname}, zeros(3,3));
    
    % do nothing if cancellation
    if isempty(answer)
      return
    end
    
    % parse filename
    fname = char(answer);
    if isempty(findstr(fname,'.mat'))
      fname = [fname '.mat'];
    end
    % load new file
    eval([ 'load ' fname])
    
    % clear the buffer and the stack
    listedit('clearbuffer')
    listedit('clearstack',1:history_length)
    
    % put it onto the stack
    listedit('push',[{newlist}, {newvariables}])
    
%    % save the filename
%    datalist_file = fname;
    
    % reset the listbox
    listedit('ereset')
    
  case 'freset'
    fname = [dodsdir 'brsdat2'];
    eval(['load ' fname])
    
    newdata = masterlist;
    newvariables = master_variables;
    
    % push the new stuff onto the stack
    listedit('push',[{newdata},{newvariables}]);
    
    % reset list box with new list
    listedit('ereset')
    
    % reset edit window
    listedit('eprops')
    
  case 'fsave'
    % write userlist to a file
    if nargin > 1
      newlist = arg2;
      newvariables = arg3;
    else
      newlist = datalist_history{1,1};
      newvariables = datalist_history{1,2};
    end
    
    if isempty(dodsdir)
      dir = which('browse');
      i = max(findstr(dir,dirsep));
      dodsdir = dir(1:i);
      dodsdir = ['''' dodsdir ''''];
    end
    
    datalist_file = listedit('getdatalistfile');
    if isempty(findstr(datalist_file,dirsep))
      fname = [dodsdir datalist_file];
    else
      fname = datalist_file;
    end
    % get list of what to save
    savestr = listedit('getsavestr');
    % save the file
    eval([ 'save ' fname ' ' savestr])
    
  case 'fsaveas'
    if isempty(dodsdir)
      dir = which('browse');
      i = max(findstr(dir,dirsep));
      dodsdir = dir(1:i);
      dodsdir = ['''' dodsdir ''''];
    end
    
    % suggest a filename
    datalist_file = listedit('getdatalistfile');
    if isempty(findstr(datalist_file,dirsep))
      fname = [dodsdir datalist_file];
    else
      fname = datalist_file;
    end
    
    % query user
    answer = dodsdlg('Save bookmarks to mat-file:', ...
	'DODS Browse: save bookmarks', 1, {fname}, zeros(3,3));
    
    if isempty(answer)
      return
    end
    
    fname = char(answer);
    if ~isempty(findstr(fname,'brsdat2'))
      disp('Invalid file name.  Dataset list NOT SAVED.')
      return
    end

    % get the current list
    newlist = datalist_history{1,1};
    newvariables = datalist_history{1,2};

    % make the filename
    if isempty(findstr(fname,'.mat'))
      fname = [deblank(fname) '.mat'];
    end
    % get list of what to save
    savestr = listedit('getsavestr');
    % save the file
    eval([ 'save ' fname ' ' savestr])
    
  case 'getfigpos'
    argout1 = zeros(1,4);
    if isempty(findfig('DODS propedit'))
      return
    end
    % edit figure
    un = get(EDIT_FIGURE, 'units');
    set(EDIT_FIGURE, 'units', 'pixels');
    figpos = get(EDIT_FIGURE, 'pos');
    set(EDIT_FIGURE,'units', un);
    argout1 = figpos;
    
  case 'setfigpos'
    if isempty(findfig('DODS listedit'))
      return
    end

    figpos = arg2;
    % THE EDIT FIGURE
    if any(figpos(3:4) == 0)
      figpos = browse('figpos', 5);
    end
    if any(figpos(3:4) == 0)
      browse_fig = browse('getfigno');
      un = get(browse_fig,'units');
      set(browse_fig,'units','pixels');
      b_offset = get(browse_fig,'pos');
      set(browse_fig,'units',un)
      fig_size = [370 300];
      fig_offset = [b_offset(1)+125 ...
	    b_offset(2)+b_offset(4)-fig_size(2)+5];
      figpos(1,:) = [fig_offset fig_size];
    end
    un = get(EDIT_FIGURE, 'units');
    set(EDIT_FIGURE, 'units', 'pixels', 'pos', figpos);
    set(EDIT_FIGURE,'units', un);
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                         STACK MANIPULATION COMMANDS                %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
switch arg1
  case 'buffer'
    % get the relevant element of the structure 
    newdata = datalist_history{1,1};

    % buffer the relevant entries
    buffer{1} = newdata(arg2);
    buffer{2} = arg3;
    buffer{3} = [];
  
  case 'clearbuffer'
    buffer = cell(1,3);
  
  case 'clearstack'
    for i = 1:length(arg2)
      [datalist_history(arg2(i),:)] = deal({[],[]});
    end
  
  case 'pop'
    numpops = arg2;
  
    % pop the stack numpops times
    datalist_history(1:history_length-numpops,:) = ...
	datalist_history(1+numpops:history_length,:);
    
    % clear bottom of stack
    listedit('clearstack', history_length-numpops+1:history_length);

  case 'push'
    % push the stack
    datalist_history = [arg2; datalist_history(1:history_length-1,:)];
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%         COMMANDS TO INTERFACE WITH THE PROPEDIT WINDOW             %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
switch arg1
  case 'eprops'
    
    pos = listedit('getpos');
    if nargout == 0
      % update properties in the edit window
      if pos > 0
	newdata = datalist_history{1,1};
	newvariables = datalist_history{1,2};
	dodspropedit('eprops', newdata(pos));
      else
	dodspropedit('eprops', []);
      end
    else
      argout1 = [];
      if pos > 0
	newdata = datalist_history{1,1};
	newvariables = datalist_history{1,2};
	argout1 = newdata(pos);
      end
    end
  
  case 'setprops'
    propeditstuff = arg2;
    % set editable properties of the selected dataset/folder
    pos = listedit('getpos');
    newdata = datalist_history{1,1};
    newvariables = datalist_history{1,2};
    newdata(pos) = propeditstuff;

    % reset show strings
    newdata = dlist2slist(newdata);
  
    % push the stack
    listedit('push',[{newdata},{newvariables}])
  
    % reset visible list
    listedit('ereset')
  
end

return
