function [] = dods()
% DODS is a command-line interface to the Distributed Oceanographic
% Data System (DODS).  It provides a simple way access to the DODS 
% toolbox function, DODSBOX. 
%
% USAGE:  DODS
%
% ALSO SEE: BROWSE, DODSBOX, LOADDODS

% Copyright 2000 (C) University of Maine
% Deirdre Byrne, U Maine, 00/06/14, dbyrne@umeoce.maine.edu

% set some initial values for important variables
version = '0.1-beta';
dodsfunc = 'start'; 
storfunc(dodsfunc); clear dodsfunc

% set up internally used
global ranges vars sets stride
ranges = nan*ones(4,2); 
vars = nan; 
sets = nan; 
stride = nan;
datacount(1);
disp(' ')
disp([ 'Welcome to the DODS command line interface, version ' ...
      version '.'])
disp('For help, type "help".  To quit, type "quit".')
disp('For a demo session, type "demo".')
disp(' ')
clear version ans

% ENTER THE DODS WORKSPACE!
while ~strcmp(deblank(lower(storfunc)),'quit')
  % reinitialize anything that's been cleared ...
  if exist('sets') ~= 1
    global sets; sets = nan;
  end
  if exist('vars') ~= 1
    global vars; vars = nan;
  end
  if exist('ranges') ~= 1
    global ranges; ranges = nan*ones(4,2);
  else
    if all(size(ranges) == [1 8])
      % catch the most common mistake and correct it.
      ranges = reshape(ranges,2,4)';
    end
  end
  if exist('stride') ~= 1
    global stride; stride = nan;
  end
  if exist('whichurls') ~= 1
    global whichurls; whichurls = nan;
  end

  % display the command line prompt
  dodsfunc = input('dods>> ','s');
  storfunc(dodsfunc); clear dodsfunc
  
  % now interpret the input from the command line
  if strcmp(deblank(lower(storfunc(1:5))),'clear')
    if strcmp(deblank(lower(storfunc(7:9))),'all')
      dodsbox('clearall');
      sets = nan;
      vars = nan;
      ranges = nan*ones(4,2);
      stride = nan;
      datacount(1);
    elseif strcmp(deblank(lower(storfunc(7:10))),'data')
      dodsbox('clearall');
      datacount(1);
    else
      eval(storfunc,'disp(lasterr)')
    end
    % -------------------------------------------------------------------
  elseif strcmp(deblank(lower(storfunc(1:8))),'demo')
    dodsdemo
    % -------------------------------------------------------------------
  elseif strcmp(deblank(lower(storfunc(1:6))),'export')
    % EXPORT: IF THE NEXT WORD IS DATA, EXPORT THE DATA
    % OTHERWISE, EVALUATE THE STANDARD MATLAB COMMAND
    if strcmp(deblank(lower(storfunc(8:11))),'all')
      evalin('base','clear ranges stride sets vars whichurls')
      evalin('base','global ranges stride sets vars whichurls')
      dods_w = whos;
      for dods_inx = 1:length(dods_w)
	if strcmp(dods_w(dods_inx).name(1),'R')
	  if ~isempty(str2num(dods_w(dods_inx).name(2)))
	    if  ~isempty(findstr(dods_w(dods_inx).name,'_'))
	      evalin('base',['clear ' dods_w(dods_inx).name])
	      evalin('base',['global ' dods_w(dods_inx).name])
	    end
	  end
	end
      end
      if exist('CatURL') == 1
	global dodstmpvariable; dodstmpvariable = CatURL;
	evalin('base','global dodstmpvariable; CatURL = dodstmpvariable;');
	clear global dodstmpvariable
      end
      if exist('URLlist') == 1
	global dodstmpvariable; dodstmpvariable = URLlist;
	evalin('base','global dodstmpvariable; URLlist = dodstmpvariable;');
	clear global dodstmpvariable
      end
      if exist('Datasize') == 1
	global dodstmpvariable; dodstmpvariable = Datasize;
	evalin('base','global dodstmpvariable; Datasize = dodstmpvariable;');
	clear global dodstmpvariable
      end
      if exist('Number_of_URLs') == 1
	global dodstmpvariable; dodstmpvariable = Number_of_URLs;
	evalin('base','global dodstmpvariable; Number_of_URLs = dodstmpvariable;');
	clear global dodstmpvariable
      end
    elseif strcmp(deblank(lower(storfunc(8:11))),'data')
      dods_w = whos;
      for dods_inx = 1:length(dods_w)
	if strcmp(dods_w(dods_inx).name(1),'R')
	  if ~isempty(str2num(dods_w(dods_inx).name(2)))
	    if  ~isempty(findstr(dods_w(dods_inx).name,'_'))
	      evalin('base',['clear ' dods_w(dods_inx).name])
	      evalin('base',['global ' dods_w(dods_inx).name])
	    end
	  end
	end
      end
    elseif strcmp(deblank(lower(storfunc(8:17))),'selections')
      evalin('base','clear ranges stride sets vars whichurls')
      evalin('base','global ranges stride sets vars whichurls')
    elseif strcmp(deblank(lower(storfunc(8:11))),'urls')
      if exist('CatURL') == 1
	global dodstmpvariable; dodstmpvariable = CatURL;
	evalin('base','global dodstmpvariable; CatURL = dodstmpvariable;');
	clear global dodstmpvariable
      end
      if exist('URLlist') == 1
	global dodstmpvariable; dodstmpvariable = URLlist;
	evalin('base','global dodstmpvariable; URLlist = dodstmpvariable;');
	clear global dodstmpvariable
      end
      if exist('Datasize') == 1
	global dodstmpvariable; dodstmpvariable = Datasize;
	evalin('base','global dodstmpvariable; Datasize = dodstmpvariable;');
	clear global dodstmpvariable
      end
      if exist('Number_of_URLs') == 1
	global dodstmpvariable; dodstmpvariable = Number_of_URLs;
	evalin('base','global dodstmpvariable; Number_of_URLs = dodstmpvariable;');
	clear global dodstmpvariable
      end
    else
      eval(storfunc,'disp(lasterr)')
    end
    clear dods_w
    % -------------------------------------------------------------------
  elseif strcmp(deblank(lower(storfunc(1:3))),'get')
    if strcmp(deblank(lower(storfunc(5:7))),'cat')
      if isready
	dods_inx = find(~isnan(vars));
	vars = vars(dods_inx);
	dods_inx = find(~isnan(sets));
	sets = sets(dods_inx);
	tmpcat = '';
	tmpurl = '';
	urlvec(0);
	for dods_inx = 1:length(sets)
	  dodsbox('getcat',sets(dods_inx),vars,ranges,stride);
	  if all(size(CatURL) > 0)
	    if isempty(tmpcat)
	      tmpcat = CatURL;
	    else
	      tmpcat = str2mat(tmpcat,CatURL);
	    end
	  end
	  if all(size(URLlist) > 0)
	    urlvec(size(URLlist,1));
	    if isempty(tmpurl)
	      tmpurl = URLlist;
	    else
	      tmpurl = str2mat(tmpurl,URLlist);
	    end
	  end
	end
	CatURL = tmpcat;
	URLlist = tmpurl;
	Number_of_URLs = size(URLlist,1);
	clear tmpcat tmpurl;
	disp(' ')
	disp(sprintf('The TOTAL number of URLs for this request is %i.', ...
	    Number_of_URLs))
	disp(' ')
	disp(' ')
      end
    elseif strcmp(deblank(lower(storfunc(5:8))),'size')
      if isready
	dods_inx = find(~isnan(vars));
	vars = vars(dods_inx);
	dods_inx = find(~isnan(sets));
	sets = sets(dods_inx);
	tmpsize = 0;
	tmpnum = 0;
	urlvec(0);
	for dods_inx = 1:length(sets)
	  dodsbox('datasize',sets(dods_inx),vars,ranges,stride);
	  urlvec(Number_of_URLs);
	  tmpnum = tmpnum + Number_of_URLs;
	  tmpsize = tmpsize + Datasize;
	end
	Number_of_URLs = tmpnum;
	Datasize = tmpsize;
	clear tmpnum tmpsize
	disp(sprintf('TOTALS: Size %g Mb, in %i URLs.', ...
	    Datasize, Number_of_URLs))
      end
    elseif strcmp(deblank(lower(storfunc(5:8))),'data')
      if isready
	dods_inx = find(~isnan(vars));
	vars = vars(dods_inx);
	dods_inx = find(~isnan(sets));
	sets = sets(dods_inx);
	%dods_vec = urlvec;
	if length(sets) == 1
	  % use the whichurl list
	  dodsn = dodsbox('getdata', sets, vars, ranges, ...
	      stride, whichurls, datacount);
	else
	  whichurls = nan;
	  for dods_inx = 1:length(sets)
	    %dods_tmp = find(whichurls > dods_vec(dods_inx) & ...
	    %    whichurls <= dods_vec(dods_inx+1));
	    dodsn = dodsbox('getdata', sets(dods_inx), vars, ranges, ...
		stride, whichurls, datacount);
	    datacount(datacount+dodsn);
	  end
	end
	clear dods_tmp dods_vec
      end
    else
      eval(storfunc,'disp(lasterr)')
    end
  elseif strcmp(deblank(lower(storfunc)),'help')
    disp('  ')
    disp('The following special commands are available in the DODS')
    disp('command-line interface:')
    disp('  ')
    disp('   clear demo export get help quit save show')
    disp(' ')
    disp([ 'and the following variables are reserved and have ', ...
	  'special meaning:'])
    disp(' ')
    disp('             ranges sets stride vars whichurls           ')
    disp(' ')
    disp('Help is also available for these.  Type "help [topic]" for')
    disp('help on one of these specific topics.')
    disp(' ')
    disp('Normal Matlab scripts, functions and topics such as ''whos''')
    disp('are also available and help for all of these is accessed with')
    disp('"help [topic]"  or   "help matlab [topic]".  The latter')
    disp('syntax must be used if the command is both a DODS and a Matlab')
    disp('command.')
    disp(' ')
    disp('To quit the DODS command line interface, type "quit".  This will')
    disp('not exit you from Matlab.  To export your downloaded data to the')
    disp('workspace, type export data".  To save it, type:')
    disp('"save [filename] data".')
    disp(' ')
  elseif strcmp(deblank(lower(storfunc(1:4))),'help')
      disp(' ')
    if strcmp(deblank(lower(storfunc(6:11))),'matlab')
      % catch questions to Matlab
      eval(['help ' deblank(storfunc(13:length(storfunc)))], ...
	  'disp(lasterr)')
    elseif strcmp(deblank(lower(storfunc(6:10))),'clear')
      disp('''clear all'' will clear all downloaded data.')
      disp('clear [names] where names are temporary variables')
      disp('you may have created will clear those from the')
      disp('DODS workspace.  ''clear sets'' or ''clear ranges''')
      disp('or any other reserved name will reset the value of')
      disp('that variable back to NaN(s). ''Clear data'' will')
      disp('clear just the downloaded data.')
      disp(' ')
      disp([ 'For help on the Matlab clear command, type "help ' ...
	    'matlab clear".'])
    elseif strcmp(deblank(lower(storfunc(6:9))),'demo')
      disp('Type "demo" at the command line for a sample DODS command line')
      disp('session.  For general Matlab demos, type "matlab demo".')
      disp(' ')
    elseif strcmp(deblank(lower(storfunc(6:11))),'export')
      disp('"Export" works much like "save" except that the variables')
      disp('in question are written to your main Matlab workspace')
      disp('Available commands are "export data", "export all", ')
      disp('"export selections", "export urls".  For specific')
      disp('definitions of these keywords, see "help save".  If')
      disp('none of the keywords is present, the Matlab Control Toolbox')
      disp('export command will be executed.')
      disp(' ')
      disp([ 'For help on the Matlab export command, type "help ' ...
	    'matlab export".'])
      disp(' ')
    elseif strcmp(deblank(lower(storfunc(6:8))),'get')
      disp('''get cat'' will get a list of URLs matching the')
      disp('selection criteria.')
      disp(' ')
      disp('''get size'' will calculate an estimated size for')
      disp('the amount of data matching your selection criteria,')
      disp('and also tell you number of URLs required to download')
      disp('it.')
      disp(' ')
      disp('''get data'' will download all of the data matching')
      disp('your selection criteria -- first obtaining a list of')
      disp('URLs from the fileserver if you have not done so already.')
      disp(' ')
      disp('If you are missing one or more selection criteria, you')
      disp('will be prompted to set them.')
      disp(' ')
    elseif strcmp(deblank(lower(storfunc(6:9))),'help')
      disp('Type "help [command]" for help on specific commands.  For example,')
      disp([ '"help show" will give help on the DODS command ', ...
	    '"show". If the']) 
      disp([ 'command is not a DODS command, the ', ...
	   'normal Matlab help files will be '])
     disp([ 'searched.  For ', ...
	   'help on the MATLAB version of a function, topic or '])
     disp([ 'script that has the same name as a DODS command', ...
	    '(e.g., "quit") type'])
      disp([ '"help matlab [function]".  For ', ...
	    'general Matlab help, type'])
      disp('"help matlab help".')
      disp(' ')
    elseif strcmp(deblank(lower(storfunc(6:9))),'quit')
      disp('"Quit" will restore you to the normal Matlab user workspace.')
      disp('Unless you export or save them, none of the URLs or downloaded')
      disp('data from the DODS command-line interface will be accessible')
      disp('to you there.  Typing "quit" a second time will exit Matlab.')
      disp(' ')
    elseif strcmp(deblank(lower(storfunc(6:11))),'ranges')
      disp('"ranges" is a 4x2 matrix:')
      disp(' ')
      disp('ranges = [minimum longitude maximum longitude;')
      disp('          "     " latitude  "     " latitude;')
      disp('          "     " depth     "     " depth;')
      disp('          "     " time      "     " time];')
      disp(' ')
      disp('For example:')
      disp(' ')
      disp('dods>> ranges = [-78 -77; 45 50; 0 0; 1995.340 1995.342];')
      disp(' ')
      disp('Simply type ''ranges'' or ''show my ranges''')
      disp('to see the current values of your ranges.')
      disp(' ')
    elseif strcmp(deblank(lower(storfunc(6:9))),'save')
      disp([ 'The save command will either be a special ', ...
	    'DODS command line function'])
      disp([ 'or a regular Matlab', ...
	  'function, depending on how you use it.'])
      disp([ 'Just typing "save" or "save [filename]" or', ...
	    '"save [filename [variables]]"'])
	disp([ 'will execute', ...
	    'the normal Matlab save command.'])
      disp(' ')
      disp('However, these commands are special to DODS:')
      disp([ '"save [filename] all"         saves ranges, sets, ', ...
	  'vars, stride'])
      disp('      and all downloaded data (R*_*).')
      disp([ '"save [filename] data"       saves R*_* to filename'])
      disp([ '"save [filename] selections" saves ranges, ', ...
	    'sets, vars, stride whichurls'])
      disp([ '"save [filename] urls"       saves URLlist CatURL ', ...
	    'ranges sets vars stride'])
      disp([ '                             ', ...
	    'Datasize Number_of_URLs'])
      disp([ '"save [filename] all"        saves URLlist CatURL ', ...
	    'Datasize Number_of_URLs'])
      disp([ '                                   ', ...
	    'ranges sets vars stride whichurls R*_*'])
      disp(' ')
      disp([ 'For help on the Matlab save command, type "help ' ...
	    'matlab save".'])
      disp(' ')
    elseif strcmp(deblank(lower(storfunc(6:9))),'sets')
      disp('sets is the number of your selected datasets.')
      disp('to see index numbers, use the commands "show all sets"')
      disp('or "show my sets" or "show sets with vars".')
      disp(' ')
    elseif strcmp(deblank(lower(storfunc(6:9))),'show')
      disp('"show all sets"  -- to see available datasets.')
      disp('"show my sets"   -- to see selected datasets.')
      disp('"show sets with vars" -- to see a list of datasets')
      disp('containing the selected variables.')
      disp(' ')
      disp('"show all vars"  -- to see available variables.')
      disp('"show my vars"   -- to see selected variables.')
      disp('"show vars" -- to see a list of the variables')
      disp('contained in your selected datasets.  If no datasets')
      disp('are selected, "show vars" works like "show all vars".')
      disp(' ')
      disp('"show all ranges"  -- to see ranges of all datasets.')
      disp('"show my ranges"   -- to see selection ranges.')
      disp('"show ranges" -- to see a ranges of selected datasets')
      disp('contained in your selected datasets.  If no datasets')
      disp('are selected, "show vars" works like "show all vars".')
      disp(' ')
    elseif strcmp(deblank(lower(storfunc(6:11))),'stride')
      disp('The stride is the subsampling stride with which')
      disp('you would like to sample the data.  It is only')
      disp('relevant for gridded datasets (DODS grids or arrays).')
      disp('Just type "stride = [value];" at the command line.')
      disp(' ')
      disp('The stride must be an integer value.  For full ')
      disp('resolution data, the stride is 1.  To obtain every other')
      disp('data point, the stride is 2.  To obtain every')
      disp('fifth data point set the stride to 5.  To see')
      disp('the value you have set, simply type "stride" or')
      disp('"show stride" at the DODS command prompt.')
      disp(' ')
    elseif strcmp(deblank(lower(storfunc(6:9))),'vars')
      disp('"vars" are the numbers of your selected variables')
      disp('You may have as many as you like, but you should check')
      disp('to make sure the datasets')
    elseif strcmp(deblank(lower(storfunc(6:9))),'vars')
      disp('"whichurls" is an index into the URLlist.  Once a catalog')
      disp('request has been made (URLlist created), set whichurls')
      disp('to subselect only some of that catalog.  For example, if')
      disp('the Number_of_URLs is 8, you could set "whichurls = [2:2:8];"')
      disp('and on executing "get data", only every other URL would be')
      disp('dereferenced.')
      disp(' ')
      disp('At this writing, "whichurls" will ONLY work if a single dataset')
      disp('has been selected.  Downloads from multiple datasets will always')
      disp('result in every URL being dereferenced.')
      disp(' ')
      disp('Please note that the dods system keeps an *internal* copy of')
      disp('the URLlist, so that manipulating (editing) the copy visible in')
      disp('the DODS workspace/user workspace won''t affect the URLs that')
      disp('are actually used in a data download.  The internal URLlist')
      disp('is updated in response to changing the ranges, dataset stride,')
      disp('selected variables or datasets.  Once selected, it may further')
      disp('be manipulated by subselecting with "whichurls".')
      disp(' ')
      disp('If "whichurls" is not set, all of the URLs will be deferenced.')
      disp(' ')
      disp('If any of the other parameters (ranges, stride, variables, etc)')
      disp('are changed, whichurls will be reset to the default (thus')
      disp('selecting all URLs).')
      disp(' ')
    else
      % turn to general matlab help
      eval(storfunc,'disp(lasterr)')
    end
    % -------------------------------------------------------------------
  elseif strcmp(deblank(lower(storfunc)),'quit')
    % ----------------------------------------------
    % do nothing ... except DON'T evaluate
    % the command or we'll quit matlab entirely
    % this way, we will simply exit the while loop
    
    % ----------------------------------------------
  elseif strcmp(deblank(lower(storfunc(1:4))),'save')
    % SAVE: SAVE ALL DOWNLOADED DATA
    % Possible DODS command line options:
    % save [filename] all -- ranges, sets, vars, stride, data
    % save [filename] data -- all R*_* in workspace
    % save [filename] session -- ranges, sets, vars, stride 
    % save [filename] urls -- save URLlist CatURL ranges sets vars stride
    % 
    % save, save [filename], and save [filename] [variables]
    % are all plain Matlab commands and will simply be passed
    % on to the interpreter.
    if length(deblank(lower(storfunc))) > 4
      % look for words -- all of the DODS command line
      % commands will have a minimum of 3 words
      dods_inx = findstr(deblank(storfunc), ' ');
      if length(dods_inx) < 2
	% there are only 2 words on the line, 'save' and a filename
	% this is a Matlab command.  Execute it.
	eval(storfunc,'disp(lasterr)')
      else
	% this is potentially a DODS command.  Find the
	% filename and see what comes after it.
	dods_cmd_line = deblank(storfunc);
	dods_savefilename = ...
	    dods_cmd_line(dods_inx(1)+1:dods_inx(2)-1);
	dods_cmd_line = ...
	    dods_cmd_line(dods_inx(2)+1:length(dods_cmd_line));
	if strcmp(deblank(lower(dods_cmd_line)),'all')
	  dods_data_list = '';
	  if exist('CatURL') == 1
	    dods_data_list = [dods_data_list 'CatURL'];
	  end
	  if exist('URLlist') == 1
	    dods_data_list = [dods_data_list ' URLlist'];
	  end
	  if exist('Number_of_URLs') == 1
	    dods_data_list = [dods_data_list ' Number_of_URLs'];
	  end
	  if exist('Datasize') == 1
	    dods_data_list = [dods_data_list ' Datasize'];
	  end
	  dods_data_list = [dods_data_list ...
		' ranges sets vars stride whichurls'];
	  dods_inx = whos('R*_*');
	  if all(size(dods_inx) > 0)
	    dods_data_list = [dods_data_list ' R*_*'];
	  end
	  eval([ 'save ' dods_savefilename ' ' dods_data_list], ...
	      'disp(lasterr)');
	elseif strcmp(deblank(lower(dods_cmd_line)),'data')
	  dods_inx = whos('R*_*');
	  if all(size(dods_inx) > 0)
	    dods_data_list = 'R*_*';
	    eval([ 'save ' dods_savefilename ' ' dods_data_list], ...
		'disp(lasterr)');
	  else
	    disp(' ')
	    disp('No Data here to save.')
	    disp(' ')
	  end
	elseif strcmp(deblank(lower(dods_cmd_line)),'selections')
	  dods_data_list = 'ranges sets vars stride whichurls';
	  eval([ 'save ' dods_savefilename ' ' dods_data_list], ...
	      'disp(lasterr)');
	elseif strcmp(deblank(lower(dods_cmd_line)),'urls')
	  if exist('CatURL') == 1 & ...
		exist('URLlist') == 1 & ...
		exist('Number_of_URLs') == 1
	    dods_data_list = [ 'ranges sets vars stride CatURL', ...
		  ' URLlist Number_of_URLs'];
	    eval([ 'save ' dods_savefilename ' ' dods_data_list], ...
		'disp(lasterr)');
	  else
	    disp(' ')
	    disp('No URL list or catalog URL to save.')
	    disp(' ')
	  end
	else
	  % we have a save command, a filename, and some user-selected
	  % variables
	  eval([ 'save ' dods_savefilename ' ' dods_cmd_line], ...
	      'disp(lasterr)');
	end
      end
    else
      % the only word on the line is 'save'.  This means
      % save to matlab.mat, the matlab default.
      eval(storfunc,'disp(lasterr)')
    end
    clear dods_savefilename dods_cmd_line dods_data_list dods_inx
  elseif strcmp(deblank(lower(storfunc(1:4))),'show')
    % SHOW: DISPLAY AVAILABLE STUFF
    if strcmp(deblank(lower(storfunc(6:8))),'all')
      if strcmp(deblank(lower(storfunc(10:13))),'sets')
	dodsbox('showsets');
      elseif strcmp(deblank(lower(storfunc(10:13))),'vars')
	dodsbox('showvars');
      elseif strcmp(deblank(lower(storfunc(10:13))),'rang')
	dodsbox('showranges');
      end
    elseif strcmp(deblank(lower(storfunc(6:7))),'my')
      if strcmp(deblank(lower(storfunc(9:12))),'sets')
	dods_inx = find(~isnan(sets));
	if ~isempty(dods_inx)
	  dodsbox('showsets',sets(dods_inx));
	else
	  disp(' ')
	  disp('No datasets are selected')
	  disp(' ')
	end
      elseif strcmp(deblank(lower(storfunc(9:12))),'vars')
	dods_inx = find(~isnan(vars));
	if ~isempty(dods_inx)
	  dodsbox('showvars',vars(dods_inx));
	else
	  disp(' ')
	  disp('No variables are selected')
	  disp(' ')
	end
      elseif strcmp(deblank(lower(storfunc(9:12))),'rang')
	disp(' ')
	disp(sprintf('Longitude (deg): %g %g',ranges(1,:)));
	disp(sprintf('Latitude (deg): %g %g',ranges(2,:)));
	disp(sprintf('Depth (m): %g %g',ranges(3,:)));
	disp(sprintf('Time (decimal years): %.5f %.5f\n', ranges(4,:)));
      elseif strcmp(deblank(lower(storfunc(9:12))),'stri')
	if ~isnan(stride)
	  disp(' ')
	  disp(sprintf('Dataset stride: %i', stride))
	  disp(' ')
	else
	  disp(' ')
	  disp('The stride has not been set.')
	  disp(' ')
	end
      end
      
    elseif strcmp(deblank(lower(storfunc(6:9))),'sets')
      if strcmp(deblank(lower(storfunc(11:19))),'with vars')
	if ~any(isnan(vars))
	  dods_inx = find(~isnan(vars));
	  dodsbox('showsets','vars',vars(dods_inx));
	else
	  disp(' ')
	  disp('Please select some variables with ''vars = [values];''')
	  disp(' ')
	end
      else
	disp(' ')
	disp('show MY sets, show ALL sets, or show sets WITH VARS')
	disp(' ')
      end
    elseif strcmp(deblank(lower(storfunc(6:9))),'vars')
      if ~isnan(sets)
	dodsbox('showvars','sets',sets);
      else
	dodsbox('showvars');
      end
    elseif strcmp(deblank(lower(storfunc(6:9))),'rang')
      if ~isnan(sets)
	dodsbox('showranges','sets',sets);
      else
	dodsbox('showranges');
      end
    end
    % -------------------------------------------------------------------
  else
    eval(storfunc,'disp(lasterr)')
  end
  clear dods_inx dodsn ans
end
clear vars sets ranges stride
clear Datasize Number_of_URLs URLlist CatURL
return

function [outarg] = urlvec(inarg)
global url_index
if nargin == 1
  if inarg == 0;
    url_index = [0];
  else
    url_index = [url_index; url_index(length(url_index))+inarg];
  end
end
outarg = url_index;
return

function [outfunc] = storfunc(infunc)
% function to store dodsfunction value away
% from user workspace
global dodsfunc
if nargin == 1
  if isstr(infunc)
    dodsfunc = infunc;
  else
    x = infunc;
    i = find(x <= length(dodsfunc));
    if nargout == 1
      outfunc = dodsfunc(x(i));
    end
  end
else
  if nargout == 1
    outfunc = dodsfunc;
  end
end
return


function [outarg] = datacount(inarg)
% function to store the data count
% in a safe place away from the user workspace
global tmpdatacount
if nargin == 1
  tmpdatacount = inarg;
end
outarg = tmpdatacount;
return

function [value] = isready()
value = 1;
global sets vars stride ranges
if all(isnan(vars)) | any(size(vars) == 0)
  value = 0;
  disp(' ')
  disp('You must select at least one variable.') 
  disp('Type vars = [values]; at the command line,')
  disp('where values are any integers between 1 and the')
  disp('total number of recognized variables.')
  disp('To see a list of variables, type "show all vars".')
  disp(' ')
end
if any(isnan(ranges))
  value = 0;
  disp(' ')
  disp('You must set the selection ranges.') 
  disp('Type ranges = [values]; at the command line,')
  disp('"ranges" is a 4x2 matrix of:')
  disp('[minimum longitude maximum longitude;')
  disp(' "     " latitude  "     " latitude;')
  disp(' "     " depth     "     " depth;')
  disp(' "     " time      "     " time];')
  disp(' ')
end
if ~all(size(ranges) == [4 2])
  if all(size(ranges) == [1 8])
    % catch the most common mistake and correct it.
    ranges = reshape(ranges,2,4)';
  else
    value = 0;
    disp(' ')
    disp('Selection ranges are not set properly') 
    disp('Type ranges = [values]; at the command line,')
    disp('"ranges" is a 4x2 matrix of:')
    disp('[minimum longitude maximum longitude;')
    disp(' "     " latitude  "     " latitude;')
    disp(' "     " depth     "     " depth;')
    disp(' "     " time      "     " time];')
    disp(' ')
  end
end
if isnan(stride)
  value = 0;
  disp(' ')
  disp('You must set the dataset stride.') 
  disp('Just type stride = [value]; at the command line.')
  disp('For full resolution data, the stride is 1.')
  disp('For every other data point, the stride is 2.')
  disp('To obtain every fifth data point set the stride to 5')
  disp(' ')
end
if all(isnan(sets)) | any(size(sets) == 0)
  value = 0;
  disp(' ')
  disp('You must select some datasets.') 
  disp('Type sets = [values]; at the command line,')
  disp('where values are any integers between 1 and the')
  disp('total number of recognized datasets.')
  disp('To see a list of datasets, type "show all sets".')
  disp('To see the list selected datasets, type "show my sets".')
  disp(' ')
end
return

function [] = dodsdemo()

morelen=more;
more on;

clc;
disp(' ')
disp('   >>>>>>>>    DODS COMMAND-LINE INTERFACE SAMPLE SESSION  <<<<<<< ')
disp(' ')
disp(' ')
disp(' ')
disp(' ')
disp('    to advance each screen, press any key')
disp(' ')
pause; clc
disp(' ')
disp('   [Start the interface from the Matlab command line]')
disp(' ')
disp('>> dods')
disp(' ')
disp('Welcome to the DODS command line interface, version 0.1-beta.')
disp('For help, type "help".  To quit, type "quit".')
disp('For a sample session, type "demo".')
disp(' ')
disp('dods>>')
disp(' ')
pause; clc
disp(' ')
disp('dods>> help')
disp('  ')
disp('The following special commands are available in the DODS')
disp('command-line interface:')
disp('  ')
disp('   clear demo export get help quit save show')
disp(' ')
disp('and the following variables are reserved and have special meaning:')
disp(' ')
disp('             ranges sets stride vars                   ')
disp(' ')
disp('Help is also available for these.  Type "help [topic]" for')
disp('help on one of these specific topics.')
disp(' ')
disp('Normal Matlab scripts, functions and topics such as ''whos''')
disp('are also available and help for all of these is accessed with')
disp('"help [topic]"  or   "help matlab [topic]".  The latter')
disp('syntax must be used if the command is both a DODS and a Matlab')
disp('command.')
disp(' ')
disp('To quit the DODS command line interface, type "quit".  This will')
disp('not exit you from Matlab.  To export your downloaded data to the')
disp('workspace, type export data".  To save it, type:')
disp('"save [filename] data".')
disp(' ')
disp('dods>> ')
disp(' ')
pause; clc
disp(' ')
disp('dods>> help show')
disp('"show all sets"  -- to see available datasets.')
disp('"show my sets"   -- to see selected datasets.')
disp('"show sets with vars" -- to see a list of datasets')
disp('containing the selected variables.')
disp(' ')
disp('"show all vars"  -- to see available variables.')
disp('"show my vars"   -- to see selected variables.')
disp('"show vars" -- to see a list of the variables')
disp('contained in your selected datasets.  If no datasets')
disp('are selected, "show vars" works like "show all vars".')
disp(' ')
disp('"show all ranges"  -- to see ranges of all datasets.')
disp('"show my ranges"   -- to see selection ranges.')
disp('"show ranges" -- to see a ranges of selected datasets')
disp('contained in your selected datasets.  If no datasets')
disp('are selected, "show vars" works like "show all vars".')
disp(' ')
disp('dods>> ')
disp(' ')
pause; clc
disp(' ')
disp('dods>> show sets')
disp(' ')
disp('show MY sets, show ALL sets, or show SETS WITH VARS')
disp(' ')
disp('dods>> ')
disp(' ')
pause; clc
disp(' ')
disp('dods>> show all sets')
disp(' ')
disp('AVAILABLE DODS DATASETS')
disp(' ')
disp(' 1 Wind - SSM/I 3.5 - JPL                                           ')
disp(' 2 Wind - Pacific Monthly Pseudostress Averages - FSU               ')
disp(' 3 Wind - Pacific Monthly Climatology Pseudostress (1966-1985) - FSU')
disp(' 4 Wind - Pacific Monthly Climatology Pseudostress (1961-1992) - FSU')
disp(' ')
disp(' ...')
disp(' ')
disp('31 Precip - South America Monthly Mean - Gridded  - GMU             ')
disp('32 Color - CZCS Pigment Concentration (Temporary) - JPL             ')
disp('33 CO2 - Mauna Loa - PMEL                                           ')
disp('34 Bathymetry - TerrainBase Global Land and Ocean Depth - NGDC      ')
disp('35 Bathymetry - Gulf of Maine - USGS                                ')
disp(' ')
disp('dods>> ')
disp(' ')
pause; clc
disp(' ')
disp('dods>> show vars')
disp(' ')
disp('AVAILABLE DODS VARIABLES ')
disp(' ')
disp(' ...')
disp(' ')
disp('10 Temp_Grad            ')
disp('11 Temp_Diff            ')
disp('12 Spec_Humidity        ')
disp('13 Spec_Hum_Diff        ')
disp('14 Silicate             ')
disp('15 Sensible_Heat        ')
disp('16 Sea_Temp             ')
disp('17 Salinity             ')
disp(' ')
disp(' ... ')
disp(' ')
disp('dods>> ')
disp(' ')
pause; clc
disp(' ')
disp('dods>> vars = [4 8];')
disp(' ')
disp('dods>> ')
disp(' ')
pause; clc
disp(' ')
disp('dods>> show sets with vars')
disp(' ')
disp('DODS DATASETS CONTAINING:  V_Wind & U_Wind')
disp(' 1 Wind - SSM/I 3.5 - JPL                                           ')
disp(' 6 Wind - Level 3 NSCAT 1/2-Deg. Averaged - COAPS(FSU)              ')
disp(' 7 Wind - Level 3 NSCAT 1-Deg. Averaged - COAPS(FSU)                ')
disp(' 8 Wind - Level 3 NSCAT - JPL                                       ')
disp('18 Surface - COADS Monthly Datasets - PMEL                          ')
disp('19 Surface - COADS Monthly Climatologies - PMEL                     ')
disp(' ')
disp('dods>> ')
disp(' ')
pause; clc
disp(' ')
disp('dods>> sets = [18 19];')
disp(' ')
disp('dods>> ')
disp(' ')
pause; clc
disp(' ')
disp('dods>> show ranges')
disp(' ')
disp('DODS DATASETS')
disp('[Longitude] [Latitude] [Depth] [Time]')
disp('18 Surface - COADS Monthly Datasets - PMEL                          ')
disp('18 [0 360]  [-90 90] [0 0] [1854 1994]                              ')
disp('19 Surface - COADS Monthly Climatologies - PMEL                     ')
disp('19 [20 380] [-90 90] [0 0] [1800 2000]                              ')
disp(' ')
disp('dods>> ')
disp(' ')
pause; clc
disp('dods>> show my ranges')
disp(' ')
disp('Longitude (deg): NaN NaN')
disp('Latitude (deg): NaN NaN')
disp('Depth (m): NaN NaN')
disp('Time (decimal years): NaN NaN')
disp(' ')
disp('dods>> ')
disp(' ')
pause; clc
disp(' ')
disp('dods>> ranges = [-80 -70; 40 50; 0 0; 1991.0 1991.2];')
disp(' ')
disp('dods>> ')
disp(' ')
pause; clc
disp('dods>> show my ranges')
disp(' ')
disp('Longitude (deg): -80 -70')
disp('Latitude (deg): 40 50')
disp('Depth (m): 0 0')
disp('Time (decimal years): 1991.00000 1991.20000')
disp(' ')
disp('dods>> ')
disp(' ')
pause; clc
disp(' ')
disp('dods>> get cat')
disp(' ')
disp('You must set the dataset stride.')
disp('Just type stride = [value]; at the command line.')
disp('For full resolution data, the stride is 1.')
disp('For every other data point, the stride is 2.')
disp('To obtain every fifth data point set the stride to 5.')
disp(' ')
disp('dods>> ')
disp(' ')
pause; clc
disp(' ')
disp('dods>> stride = 2;')
disp(' ')
disp('dods>> ')
disp(' ')
pause; clc
disp(' ')
disp('dods>> get cat')
disp(' ')
disp('The number of URLs for this data request is 4')
disp('The number of URLs for this data request is 2')
disp(' ... ')
disp(' ')
disp('The TOTAL number of URLs for this request is 6.')
disp(' ')
disp('dods>> ')
disp(' ')
pause; clc
disp(' ')
disp('dods>> whos')
disp('  Name          Size         Bytes  Class')
disp(' ')
disp('  CatURL        0x0              0  char array')
disp('  URLlist       6x127         1524  char array')
disp('  ranges        4x2             64  double array (global)')
disp('  sets          1x2             16  double array (global)')
disp('  stride        1x1              8  double array (global)')
disp('  vars          1x2             16  double array (global)')
disp(' ')
disp('Grand total is 775 elements using 1628 bytes')
disp(' ')
disp('dods>> ')
disp(' ')
pause; clc
disp('dods>> URLlist')
disp('URLlist =')
disp('http://ferret.wrc.noaa.gov/cgi-bin/nph-nc/data/coads_vwnd.nc?VWND[1644:1644][65:2:69][140:2:144]                               ')
disp('http://ferret.wrc.noaa.gov/cgi-bin/nph-nc/data/coads_uwnd.nc?UWND[1644:1644][65:2:69][140:2:144]                               ')
disp('http://ferret.wrc.noaa.gov/cgi-bin/nph-nc/data/coads_vwnd.nc?VWND[1644:1644][65:2:69][140:2:144]                               ')
disp('http://ferret.wrc.noaa.gov/cgi-bin/nph-nc/data/coads_uwnd.nc?UWND[1644:1644][65:2:69][140:2:144]                               ')
disp('http://ferret.wrc.noaa.gov/cgi-bin/nph-nc/data/COADS_climatology.nc?VWND[0:0][65:2:69][130:2:134],UWND[0:0][65:2:69][130:2:134]')
disp('http://ferret.wrc.noaa.gov/cgi-bin/nph-nc/data/COADS_climatology.nc?VWND[1:1][65:2:69][130:2:134],UWND[1:1][65:2:69][130:2:134]')
disp(' ')
disp('dods>> ')
disp(' ')
pause; clc
disp('dods>> help save')
disp(' ')
disp('The save command will either be a special DODS command line ')
disp('function or a regular Matlab function, depending on how you ')
disp('use it.  Just typing "save" or "save [filename]" or "save ')
disp('[filename [variables]]" will execute the normal Matlab save ')
disp('command.')
disp(' ')
disp('However, these commands are special to DODS:')
disp('"save [filename] all"         saves ranges, sets, vars, stride')
disp('      and all downloaded data (R*_*).')
disp('"save [filename] data"        saves R*_* to filename')
disp('"save [filename] selections"  saves ranges, sets, vars, stride')
disp('"save [filename] urls"        saves URLlist CatURL ranges sets vars stride')
disp(' ')
disp('For help on the Matlab save command, type "help matlab save".')
disp(' ')
disp('dods>> ')
disp(' ')
pause; clc
disp(' ')
disp('dods>> save testsession urls')
disp(' ')
disp('dods>> ')
disp(' ')
pause; clc
disp(' ')
disp('dods>> get size')
disp(' ')
disp('Obtaining datasize from Surface - COADS Monthly Datasets - PMEL')
disp('  with variable(s):')
disp('                    V_Wind')
disp('                    U_Wind')
disp('Estimated size of request (in Mb): 0.000288')
disp('Number of URLs 4')
disp(' ')
disp(' ')
disp('Obtaining datasize from Surface - COADS Monthly Climatologies - PMEL')
disp('  with variable(s):')
disp('                    V_Wind')
disp('                    U_Wind')
disp('Estimated size of request (in Mb): 0.000288')
disp('Number of URLs 2')
disp(' ')
disp('TOTALS: Size 0.000576 Mb, in 6 URLs.')
disp(' ')
disp('dods>> ')
disp(' ')
pause; clc
disp(' ')
disp('dods>> get data')
disp(' ')
disp('Obtaining data from Surface - COADS Monthly Datasets - PMEL')
disp('Obtaining variable V_Wind')
disp('Obtaining variable U_Wind')
disp(' ')
disp('Please be patient while the data are transferred .... ')
disp(' ')
disp('Reading: http://ferret.wrc.noaa.gov/cgi-bin/nph-nc/data/coads_vwnd.nc')
disp('  Constraint: VWND[1644:1644][65:2:69][140:2:144]')
disp('Server version: dods/2.22')
disp('Creating matrix VWND (3 by 3) with 9 elements.')
disp('Creating scalar TIME.')
disp('Creating vector LAT with 3 elements.')
disp('Creating vector LON with 3 elements.')
disp(' ')
disp('Reading: http://ferret.wrc.noaa.gov/cgi-bin/nph-nc/data/coads_uwnd.nc')
disp('  Constraint: UWND[1644:1644][65:2:69][140:2:144]')
disp('Server version: dods/2.22')
disp('Creating matrix UWND (3 by 3) with 9 elements.')
disp('Creating scalar TIME.')
disp('Creating vector LAT with 3 elements.')
disp('Creating vector LON with 3 elements.')
disp(' ')
disp('  ...')
disp(' ')
disp('This request generated 4 separate URLs, ')
disp('which are stored in the sets:  R1_   R2_   R3_   R4_   ')
disp(' ')
disp('Obtaining data from Surface - COADS Monthly Climatologies - PMEL')
disp('Obtaining variable V_Wind')
disp('Obtaining variable U_Wind')
disp(' ')
disp('Please be patient while the data are transferred .... ')
disp(' ')
disp('Reading: http://ferret.wrc.noaa.gov/cgi-bin/nph-nc/data/COADS_climatology.nc')
disp('  Constraint: VWND[0:0][65:2:69][130:2:134],UWND[0:0][65:2:69][130:2:134]')
disp('Server version: dods/2.22')
disp('Creating matrix UWND (3 by 3) with 9 elements.')
disp('Creating scalar TIME.')
disp('Creating vector COADSY with 3 elements.')
disp('Creating vector COADSX with 3 elements.')
disp('Creating matrix VWND (3 by 3) with 9 elements.')
disp('Creating scalar TIME.')
disp('Creating vector COADSY with 3 elements.')
disp('Creating vector COADSX with 3 elements.')
disp(' ')
disp('...')
disp(' ')
disp('This request generated 2 separate URLs, ')
disp('which are stored in the sets:  R5_   R6_   ')
disp(' ')
disp('dods>> ')
disp(' ')
pause; clc
disp(' ')
disp('dods>> whos')
disp('  Name                 Size         Bytes  Class')
disp(' ')
disp('  CatURL               0x0              0  char array')
disp('  Datasize             1x1              8  double array')
disp('  Number_of_URLs       1x1              8  double array')
disp(' ')
disp('...')
disp(' ')
disp('  R6_Acknowledge       1x1734        3468  char array (global)')
disp('  R6_Latitude          3x1             24  double array (global)')
disp('  R6_Longitude         3x1             24  double array (global)')
disp('  R6_Time              1x1              8  double array (global)')
disp('  R6_URL               1x127          254  char array (global)')
disp('  R6_U_Wind            3x3             72  double array (global)')
disp('  R6_V_Wind            3x3             72  double array (global)')
disp('  URLlist              6x127         1524  char array')
disp('  ranges               4x2             64  double array (global)')
disp('  sets                 1x2             16  double array (global)')
disp('  stride               1x1              8  double array (global)')
disp('  vars                 1x2             16  double array (global)')
disp(' ')
disp('dods>> ')
disp(' ')
pause; clc
disp(' ')
disp('Grand total is 11917 elements using 24608 bytes')
disp(' ')
disp('dods>> save dodsstuff all')
disp(' ')
disp('dods>> ')
disp(' ')
pause; clc
disp(' ')
disp('dods>> quit')
disp(' ')
disp('        [At this point you are dropped back into the Matlab workspace.]')
disp('>> ')
disp(' ')
disp(' ')
disp(' >>>>>>>>>>> END OF DODS COMMAND-LINE INTERFACE SAMPLE SESSION <<<<<<<<<<<<<< ')
disp(' ')
disp(' ')

if morelen == 0
  more off
end
return
