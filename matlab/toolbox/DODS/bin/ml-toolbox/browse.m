function [clear_button, url_count, acq_urls, browse_get_variables, ...
      browse_metadata] = browse(arg1, arg2, arg3)

%
% BROWSE    DODS data browser.  A graphical user interface for DODS.
%
% USAGE     browse
%
%           Deirdre Byrne, University of Maine, 7 April 1997-14 April 1999
%                         dbyrne@umeoce.maine.edu
%

% master lists and properties: unchanging during runtime
global timerange master_georange zrange master_guiserver avhrrpal
global browse_version returnstring get_inputstring small_logo logo_map
global dirsep dodsdir dodsdatadir
global dodsBrokenDatasets  % If set to 1 will look for datasets in BROKEN_DATASETS directory.

% some things the user can set via the options file or bookmarks:
global available_resolutions dods_colors palettefile
global axes_vals fontsize popup ranges num_rang manURL
global user_variables userlist_file userlist figsizes

% derivative and changing quantities
global user_num_sets user_num_vars var dset brs_old_var brs_old_dset
global datasets selected_datasets dset_stride
global num_urls lonmin lonmax prev_num_urls variables
global user_dataprops

% handles
global browse_fig image_string AXES range_boxes worldmap thandle
global tstring lhandle ui_display ui_res ui_stride ui_clear 
global gui_buttons prefs ui_manual lyr cbarhandle

% If this is a request for data and the set_up_test flag is set, write
% the appropriate variables to a file.
global set_up_test run_test 
global test_archive_name 
global testsuiteindir       

% Get separator for directory structure.
dirsep = '/';
c = computer;
if strcmp(c(1:2),'PC')
  dirsep = '\';
elseif strcmp(c(1:2),'MA')
  dirsep = ':';
end

if set_up_test
  if exist('arg1')
    if ischar(arg1)
      switch arg1
        case 'getdata'
          global old_dset
          old_dset = 0;      % Force a call to the catalog server

          test_archive_name = userlist(dset).archive;
          test_variable_name = user_variables(var,:);
          test_name = [test_archive_name '_selection'];
          temp_name = userlist(dset).name;
          eval(['save ' dodsdir 'testsuite' dirsep test_name ...
                ' ranges test_archive_name test_variable_name' ...
                ' num_rang dset_stride num_urls temp_name'])
        otherwise
       end
    end
  end
end

if run_test
  if exist('arg1')
    if ischar(arg1)
%      popup = 0;
      switch arg1
        case 'getdata'

          global old_dset
          old_dset = 0;      % Force a call to the catalog server
          if isempty('testsuiteindir')    % Has a testsuite directory been specified?
            testsuiteindir = dodsdir;     % If not, then use dodsdir.
          end

          test_name = [test_archive_name '_selection'];
          eval(['load ' testsuiteindir 'testsuite' dirsep test_name])

          for itest=1:user_num_sets  % Get dataset number
            temp_archive = userlist(itest).archive;
            if length(temp_archive) == length(test_archive_name)
              if temp_archive == test_archive_name
                dset = itest;
              end
            end
          end
	  datasets(:) = 0;
          datasets(dset) = 1;
	  selected_datasets(:) = 0;
          selected_datasets(dset) = 1;
          brs_old_dset = dset;

          var = [];
          for itest=1:user_num_vars  % Get variable number
            temp_variable = user_variables(itest,:);
            ntestvars = size(test_variable_name,1);
            for jtest=1:ntestvars
              temp_test_var = test_variable_name(jtest,:);
              if length(temp_variable) == length(temp_test_var)
                if temp_variable == temp_test_var
                  var = [var itest];
                end
              end
            end
          end
	  variables(:) = 0;
	  variables(var) = 1;
          brs_old_var = var;

        otherwise

      end
    end
  end
end

% things to save for the display menu
if nargin == 0
  % prevent multiple sessions and invisible 'failed' sessions
  % this method is O(10) faster than using findobj.
  kids = get(0,'children');
  j = [];
  for i = 1:length(kids),
    if strcmp(get(kids(i),'userdata'),'DODS Matlab GUI')
      if strcmp(get(kids(i),'visible'),'on')
	disp('Only one copy of the DODS browser can be run at a time')
	return
      else
	j = [j kids(i)];
      end
    end
  end
  if ~isempty(j)
    close(j)
  end

  % SET WARNINGS TO A DECENT LEVEL!
  warning once
  
  % set up some values. the path:
  dodsdir = which('browse');
  dodsdir = dodsdir(1:max(findstr(dodsdir,dirsep)));
  dodsdir = ['''' dodsdir ''''];
  dodsdatadir = [dodsdir 'DATASETS' dirsep];
  if exist('dodsBrokenDatasets')     % If set look for data sets in BROKEN_DATASETS directory.
    if ~isempty(dodsBrokenDatasets)
      if dodsBrokenDatasets == 1
        dodsdatadir = [dodsdir 'BROKEN_DATASETS' dirsep];
      end
    end
  end
  fname = [dodsdir 'brsdat1'];
  eval(['load ' fname])
  nn = find(dodsdir~='''');  % addpath does not want to see quotes in the directory name
  dodsdirnq = dodsdir(nn);
  addpath(dodsdirnq)
  nn = find(dodsdatadir~='''');
  dodsdatadirnq = dodsdatadir(nn);
  addpath(dodsdatadirnq)
  
  % read the version number
  browse_version = '';
  fname = [dodsdir 'browseversion.m'];
  nn = find(fname~='''');  % Can not have quotes in fopen.
  fnamenq = fname(nn);
  fid = fopen(fnamenq,'r');
  if fid > -1
    browse_version = fscanf(fid,'%s',1);
    browse_version = deblank(browse_version);
    fclose(fid);
  end
  
  % START !!!
  disp(' ')
  disp(' ')
  disp('   *********>>>> Welcome to the DODS data browser. <<<<<<<<******** ')
  str = sprintf('%s%s%s', ...
      '                     This is browse v', ...
      browse_version, '                       ');
  disp(str)
  disp(' ')
  disp(' ')
  disp('              Please wait while I set up your screen ...')
  disp(' ')
  disp('         There is a bug in early releases of Matlab v5 which prevents')
  disp('         slider controls from working smoothly on Unix/Linux platforms.')
  disp('         If you experience this behavior, please contact the Mathworks')
  disp('         at tech-support@mathworks.com or (508) 653-1415 to see about')
  disp('         a patch to correct it.')
  disp(' ')
  disp('To see which version you are using, type ''version'' at the Matlab prompt') 
  disp(' ')

  % Set some initial values: absolute ranges that limit the 
  % extent of data selection. These will not change during runtime.
  % Guiserver, etc.
  master_georange = [-180 180 -90 90]; 	% W E S N
  master_guiserver = ...
      'http://dodsdev.gso.uri.edu/cgi-bin/dods-3.2/nph-dods/DODS/GUI/';
%      'http://www.unidata.ucar.edu/packages/dods/mlgui-datasets/';
  gui_buttons = zeros(59,1); 
  prefs = zeros(9,1); 
  browse_fig = [];

  % set up output return string from browser to main workspace and
  % from 'get' functions to browser once and for all *HERE*.
  returnstring = [ 'browse_clear_button browse_count browse_acq_urls ',...
	'browse_getvariables browse_metadata'];
  get_inputstring = [ 'ranges, dset, var, dset_stride, num_urls, ', ...
	'master_georange, get_variables, archive'];

  % BEGIN OPTIONS THAT MAY BE SET IN BROWSOPT.M
  % set up saveable values and then check them
  dods_colors = []; ranges = []; palettefile = ''; 
  figsizes = zeros(8,4); timetoggle = []; fontsize = [];
  check_level = []; num_rang = []; axes_vals = [];
  popup = 1; guiserver = ''; manURL = ''; dset = []; var = [];

  % load user preferences
  if exist('browsopt') == 2
    fname = which('browsopt');
    str = ['Loading saved preferences file ' fname]; 
    disp(str)
    eval('browsopt')
  else
    str = 'No preferences file in Matlabpath.  Loading default preferences.';
    disp(str)
  end
  
  % User bookmarks file
  if isempty(userlist_file)
    userlist_file = '.dods_datasets.mat';
    userlist_file = [dodsdir userlist_file];
  end
  nn = find(userlist_file~='''');   % find quotes and remove for nq version; exist does not like quotes
  userlist_filenq = userlist_file(nn);

  % load bookmarks
  if exist(userlist_filenq) == 2
    disp(' ')
    disp([ 'Loading saved bookmarks file ' userlist_file])
    disp(' ')
    eval([ 'load ' userlist_file])
    userlist = newlist;
    user_variables = newvariables;
  else
    % load master lists
    fname = [dodsdir 'brsdat2'];
    eval(['load ' fname])

    % set up global things
    userlist = masterlist;
    user_variables = master_variables;
  end
  
  % protect against messed up bookmarks file!
  if isempty(userlist)
    % load master lists
    fname = [dodsdir 'brsdat2'];
    eval(['load ' fname])

    % set up global things
    userlist = masterlist;
    user_variables = master_variables;
  end
  
  % make up time and depthranges from dataset ranges
  rangemin = cat(1,userlist(:).rangemin);
  rangemax = cat(1,userlist(:).rangemax);
  z1 = min(rangemin(:,3));
  z2 = max(rangemax(:,3));
  zrange = [z1-50 z2+50];
  t1 = min(rangemin(:,4));
  t2 = max(rangemax(:,4));
  timerange = [t1-10 t2+10];

  % make up some more quantities we'll want
  user_num_sets = size(userlist(:),1);
  user_num_vars = size(user_variables,1);
  browse('mkusermats')
  selected_datasets = zeros(size(userlist,1),1);

  % check saved dataset values
  if isempty(dset)
    dset = nan;
  else
    if any(dset > user_num_sets)
      dset = nan;
    end
  end
  
  % check saved variables values
  if isempty(var)
    var = nan;
  else
    if any(var > user_num_vars)
      var = nan;
    end
  end

  % Dods messages to workspace or popup window
  if exist('message_prefs') == 1
    if strcmp(message_prefs,'popup')
      popup = 1;
    elseif strcmp(message_prefs,'workspace')
      popup = 0;
    else % default to popup
      popup = 1;
    end
  else % default to popup
    popup = 1;
  end

  % Location of HTML documentation
  if isempty(deblank(manURL))
    manURL = 'http://www.unidata.ucar.edu/packages/dods/user/mgui-html/mgui.html';
  end

  % location of UPDATE directory
  if isempty(guiserver)
    guiserver = master_guiserver;
  end
  
  % set initial axis values: first make sure all args are present
  default_axes_vals = [master_georange(1:2)+[-5 5] ...
	master_georange(3:4)+[-1 1] ...
	zrange timerange];
  if isempty(axes_vals)
    axes_vals = default_axes_vals;
  else
    if ~all(size(axes_vals) == [1 8])
      axes_vals = default_axes_vals;
    end
  end
  % now check to make sure limits are valid
  if axes_vals(2) <= axes_vals(1)
    str = 'Unable to restore saved Longitude range';
    dodsmsg(popup,str)
    axes_vals(1:2) = default_axes_vals(1:2);
  end
  if axes_vals(4) <= axes_vals(3)
    str = 'Unable to restore saved Latitude range';
    dodsmsg(popup,str)
    axes_vals(3:4) = default_axes_vals(3:4);
  end
  if axes_vals(6) <= axes_vals(5)
    str = 'Unable to restore saved Depth range';
    dodsmsg(popup,str)
    axes_vals(5:6) = default_axes_vals(5:6);
  end
  if axes_vals(8) <= axes_vals(7)
    str = 'Unable to restore saved Time range';
    dodsmsg(popup,str)
    axes_vals(7:8) = default_axes_vals(7:8);
  end

  % set the global color scheme
  browse('getcolors')

  % how many ranges have been selected
  if isempty(num_rang)
    num_rang = zeros(8,1);
  elseif ~all(size(num_rang(:)) == [8 1]) | ...
	sum((num_rang == 0)+(num_rang == 1)) < 8
    num_rang = zeros(8,1);
  end

  % values of user-selected ranges
  range_boxes = zeros(1,3);
  if isempty(ranges) 
    ranges = nan*ones(4,2);
  else
    if any(ranges(1,:) < master_georange(1)) | ...
	  any(ranges(1,:) > master_georange(2))
      ranges(1,:) = [nan nan];
      num_rang(1:2) = [0 0]';
    end
    if any(ranges(2,:) < master_georange(3)) | ...
	  any(ranges(2,:) > master_georange(4))
      ranges(2,:) = [nan nan];
      num_rang(3:4) = [0 0]';
    end
    if any(ranges(3,:) < zrange(1)) | ...
	  any(ranges(3,:) > zrange(2))
      ranges(3,:) = [nan nan];
      num_rang(5:6) = [0 0]';
    end
    if any(ranges(4,:) < timerange(1)) | ...
	  any(ranges(4,:) > timerange(2))
      ranges(4,:) = [nan nan];
      num_rang(7:8) = [0 0]';
    end
  end
  
  % time on time axis in YR/MO/DY or YR/YRDAY
  if isempty(timetoggle)
    timetoggle = 1; 
  end

  % fontsize
  if isempty(fontsize)
    fontsize = 10;   
  end
  
  % step sizes
  if isempty(available_resolutions)
    available_resolutions = [32 24 16 12 8 4 3 2 1];
  end

  % size of download
  if isempty(check_level)
    check_level = 1;
  end
  
  % load palette file
  browse('paletteswap')
  
  % Get screen params and check save window sizes
  scr_size = get(0,'ScreenSize'); scr_offset = scr_size(1:2); 
  scr_size = scr_size(3:4);
  % figsizes(1,:) is the browser
  % figsizes(2,:) is the color chooser
  % figsizes(3,:) is the display menu
  % figsizes(4,:) is the dataset scrolllist
  % figsizes(5,:) is the dataset edit figure
  % figsizes(6,:) is the master list
  % figsizes(7,:) is the properties edit figure
  % figsizes(8,:) is the variables list
  figsizebadflag = 1;
  if all(size(figsizes) == [8 4])
    if all((figsizes(:,1)+figsizes(:,3)) < scr_size(1)) & ...
	  all((figsizes(:,2)+figsizes(:,4)) < scr_size(2)) & ...
	  all(figsizes(:,3) < scr_size(1)) & ...
	  all(figsizes(:,4) < scr_size(2))
      figsizebadflag = 0;
    end
  end

  if figsizebadflag
    % reset figsizes to trigger default sizes to be used
    figsizes = zeros(8,4);
  end
  
  % END OF OPTIONS THAT MAY BE SET IN BROWSOPT.M
  

  % initialize variables
  lhandle = []; thandle = []; 
  brs_old_var = nan; prev_num_urls = nan;
  brs_old_dset = nan; dset_stride = []; num_urls = 0;
  datasets = []; worldmap = []; requestnumber(1);
  lyr = [0 0]; range_day = [0 0]; 

  % OPEN THE BROWSER
  % check the size
  figpos = figsizes(1,:);

  if any(figpos(3:4) == 0)
    % set default browser figure size:
    fig_size = [round(scr_size(1)*0.9) round(scr_size(2)*0.67)];
    fig_size(1) = max([fig_size(1) 600]);
    fig_size(2) = max([fig_size(2) 400]);
    fig_offset = scr_size - fig_size - [0 55];
    figpos = [fig_offset fig_size];
  end
  
  % set the name
  str = sprintf('%s%s', ...
      'Distributed Oceanographic Data System Browser v', ...
      browse_version);

  % create the figure
  browse_fig = figure('NumberTitle','off', ...
      'Name', str, ...
      'units','pixels' ,...
      'Position', figpos, ...
      'interruptible','on', ...
      'resize','on', ...
      'color',dods_colors(2,:), ...
      'visible','off', ...
      'userdata','DODS Matlab GUI', ...
      'menubar','none');

  % SETUP UI MENUS: 
  % combined 1) and 2) the datasets and variable lists
  d = uimenu(browse_fig,'label','Data');
  uimenu(d, 'label', 'Show Data Bookmarks ...', ...
      'callback','browse(''scrollfig'')');
  uimenu(d,'label','Edit Bookmarks ...', ...
      'callback','dscrolllist(''edit'')');
  % CLEAR DATA IN MAIN WORKSPACE
  ui_clear = uimenu(d,'label','Clear Rxx_ from workspace', ...
      'callback','browse(''resetcount'')');
  % UPDATE DATASET LIST
  ui_update = uimenu(d,'label','Update Bookmarks', ...
      'foregroundcolor',dods_colors(7,:), ...
      'callback','browse(''updatedlg'')');
  
  % 3) the Resolution menu
  ui_res = uimenu(browse_fig,'label','Resolution');

  % 4) The Display menu
  ui_plots = uimenu(browse_fig, 'label', 'Display');
  uimenu(ui_plots,'label','Zoom out', ...
      'callback','browse(''zoomout'')');
  uimenu(ui_plots,'label','Clear Display', ...
      'callback','browse(''clrimg'')');
  ui_display = uimenu(ui_plots,'label','Data Display ...', ...
      'callback','browse(''display'')');
  set(ui_display,'enable','off')
  % LONGITUDE VIEW
  if any(axes_vals(1:2) > default_axes_vals(2))
    prefs(3) = uimenu(ui_plots,'label','Start Longitude 180W', ...
	'callback','browse(''setlon'',0)');
    master_georange = [0 360 -90 90];
    offset = 360;
  else
    prefs(3) = uimenu(ui_plots,'label','Start Longitude 0E', ...
	'callback','browse(''setlon'',360)');
    offset = 0;
  end
  %  uimenu(ui_plots,'label','View Plotted Objects ...', ...
  %      'callback','browse('''')');
  
  % 5) The Preferences menu
  ui_prefs = uimenu(browse_fig,'label','Preferences');
  
  % TIME AXIS UNITS
  if timetoggle
    prefs(4) = uimenu(ui_prefs,'label','Time in Year/Yearday', ...
	'callback','browse(''timetoggle'',0)');
  else
    prefs(4) = uimenu(ui_prefs,'label','Time in Year/Month/Day', ...
	'callback','browse(''timetoggle'',1)');
  end

  % USE POPUP WINDOWS?
  if popup
    label = 'Messages to Workspace';
  else
    label = 'Messages to Pop-up Window';
  end
  prefs(1) = uimenu(ui_prefs,'label',label, ...
      'callback','browse(''popupvalue'',1)', ...
      'interruptible', 'on');

  % QUERY LEVEL FOR DATASET SIZE
  prefs(5) = uimenu(ui_prefs,'label','<<Get Data!>> Threshold', ...
      'callback','browse(''qlevel'')','interruptible', 'on');
  posit = [round(figpos(3)/3.5) round(figpos(4)/2)];
  % METADATA WINDOW -- must be "underneath" check_level buttons
  % (which it is not now) and also transfer status buttons
  gui_buttons(31) = uicontrol(browse_fig, ...
      'units','normalized','style','frame', ...
      'position',[0.15 0.18 0.84 0.6], ...
      'horizontalalign','left', ...
      'visible','off', ...
      'foregroundcolor',dods_colors(6,:), ...
      'backgroundcolor',dods_colors(1,:));
  gui_buttons(39) = uicontrol(browse_fig, ...
      'units','normalized','style','edit', ...
      'max',2, ... 
      'position',[0.16 0.19 0.82 0.58], ...
      'horizontalalign','left', ...
      'visible','off', ...
      'foregroundcolor',dods_colors(6,:), ...
      'backgroundcolor',dods_colors(1,:), ...
      'string','');

  % buttons for checking/changing transfer limit size
  gui_buttons(19) = uicontrol(browse_fig, ...
      'style','frame','units','pixels', ...
      'position', [posit 240 140], ...
      'horizontalalign','left', ...
      'backgroundcolor',dods_colors(1,:), ...
      'visible','off');
  string = sprintf('%s\n%s\n%s\n%s\n',' Double-check any requests to', ...
      '  transfer datasets larger than:','','                      in Mb');
  gui_buttons(20) = uicontrol(browse_fig, ...
      'style','edit','units','pixels', ...
      'position', [posit(1)+10 posit(2)+50 220 80], ...
      'max',2, ...
      'string', string, ...
      'horizontalalign','center', ...
      'foregroundcolor',dods_colors(6,:), ...
      'backgroundcolor',dods_colors(1,:), ...
      'visible','off');
  gui_buttons(21) = uicontrol(browse_fig, ...
      'style','edit','units','pixels', ...
      'string', '1', ...
      'position', [posit(1)+30 posit(2)+10 100 30], ...
      'interruptible', 'on', ...
      'horizontalalign','center', ...
      'foregroundcolor',dods_colors(6,:), ...
      'backgroundcolor',dods_colors(1,:), ...
      'visible','off', ...
      'callback', 'browse(''setlevel'')');
  gui_buttons(29) = uicontrol(browse_fig, ...
      'style','push','units','pixels', ...
      'string','OK', ...
      'position',[posit(1)+147 posit(2)+10 40 30], ...
      'interruptible', 'on', ...
      'horizontalalign','center', ...
      'foregroundcolor',dods_colors(6,:), ...
      'backgroundcolor',dods_colors(1,:), ...
      'visible','off', ...
      'callback', 'browse(''setlevel'')');
  
  % ABORT AND WARNING BUTTONS
  gui_buttons(26) = uicontrol(browse_fig, ...
      'style','frame','units','normalized', ...
      'position',[0.20 0.37 0.20 0.18],'backgroundcolor', ...
      dods_colors(1,:), 'visible','off'); 
  string = str2mat('   Hang on!','   Transferring', ...
      '   information ...');
  gui_buttons(27) = uicontrol(browse_fig, ...
      'style','edit','units','normalized', ...
      'position',[0.21 0.38 0.18 0.16], ...
      'backgroundcolor', dods_colors(1,:), ...
      'foregroundcolor',dods_colors(6,:), ...
      'max', 2, 'string', string, ...
      'visible','off'); 
  gui_buttons(28) = uicontrol(browse_fig, ...
      'style','radio','units','normalized', ...
      'position',[0.31 0.38 0.08 0.06], ...
      'backgroundcolor', dods_colors(9,:), ...
      'foregroundcolor',dods_colors(6,:), ...
      'value', 0, ...
      'string', 'Cancel', ...
      'callback','browse(''oops!'')', ...
      'visible','off'); 

  posit = [round(figpos(3)/5) 100];
  gui_buttons(22) = uicontrol(browse_fig, ...
      'style','frame','units','pixels', ...
      'position', [posit 330 140], ...
      'horizontalalign','left', ...
      'backgroundcolor',dods_colors(1,:), ...
      'visible','off');
  gui_buttons(23) = uicontrol(browse_fig, ...
      'style','edit','units','pixels', ...
      'position', [posit(1)+10 posit(2)+50 300 80], ...
      'max',2, ...
      'string', '', ...
      'horizontalalign','center', ...
      'foregroundcolor',dods_colors(6,:), ...
      'backgroundcolor',dods_colors(1,:), ...
      'visible','off', 'userdata', check_level);
  gui_buttons(24) = uicontrol(browse_fig, ...
      'style','push','units','pixels', ...
      'string', 'Ok', ...
      'position', [posit(1)+80 posit(2)+10 50 30], ...
      'interruptible', 'on', ...
      'horizontalalign','center', ...
      'foregroundcolor',dods_colors(6,:), ...
      'backgroundcolor',dods_colors(1,:), ...
      'visible','off');
  gui_buttons(25) = uicontrol(browse_fig, ...
      'style','push','units','pixels', ...
      'string', 'Cancel', ...
      'position', [posit(1)+180 posit(2)+10 60 30], ...
      'interruptible', 'on', ...
      'horizontalalign','center', ...
      'foregroundcolor',dods_colors(6,:), ...
      'backgroundcolor',dods_colors(1,:), ...
      'visible','off');

  % FONTSIZE
  prefs(6) = uimenu(ui_prefs,'label','Fontsize','separator','on');
  for i = 1:5
    j = 2*i+6;
    callbackstring = sprintf('browse(''fontsize'', %i)',j);
    uimenu(prefs(6),'label',sprintf(' 	%2i point',j), ...
	'callback',callbackstring);
  end
  
  prefs(7) = uimenu(ui_prefs,'label','Colors');
  clrmenu(1) = uimenu(prefs(7),'label','Map');
  uimenu(clrmenu(1),'label', 'Foreground', ...
      'callback','choosecolor(''choosecolor'', 3)');
  uimenu(clrmenu(1),'label', 'Background', ...
      'callback','choosecolor(''choosecolor'', 2)');
  clrmenu(2) = uimenu(prefs(7),'label','Text');
  uimenu(clrmenu(2),'label','Foreground', ...
      'callback','choosecolor(''choosecolor'', 6)');
  uimenu(clrmenu(2),'label','Background', ...
      'callback','choosecolor(''choosecolor'', 1)');
  uimenu(prefs(7),'label','Time Labels', ...
      'callback','choosecolor(''choosecolor'', 8)');
  uimenu(prefs(7),'label','Data Range', ...
      'callback','choosecolor(''choosecolor'', 10)');
  uimenu(prefs(7),'label','Editable Text', ...
      'callback','choosecolor(''choosecolor'', 5)');
  uimenu(prefs(7),'label','Use Defaults', ...
      'callback', ...
      'browse(''setdefaultcolors''); browse(''changecolor'');');
  
  % save options
  uimenu(ui_prefs,'label','Save', ...
      'callback','browse(''saveopts'')','separator','on');

  % data color palette 
  prefs(8) = uimenu(ui_prefs,'label','Load Palette', ...
      'callback','browse(''listpalettes'')', 'separator', 'on');
  
  % set guiserver
  prefs(9) = uimenu(ui_prefs,'label','Set GUI server', ...
      'callback','browse(''guiserverdlg'')', ...
      'tag', guiserver, 'separator', 'on');
  
  % save options
  uimenu(ui_prefs,'label','Save As ...', ...
      'callback','browse(''savedlg'')','separator','on');

  % save options
  uimenu(ui_prefs,'label','Load File ...', ...
      'callback','browse(''loaddlg'')');

  % reset to defaults
  uimenu(ui_prefs,'label','Use Defaults', ...
      'callback','browse(''resetdefault'')');
  
  %  % error messages to workspace or to screen?
  %  prefs(13) = uimenu(ui_prefs,'label','Error messages to workspace', ...
  %      'callback','browse(''errors'')');
  
  % 5) THE HELP MENU
  ui_help = uimenu(browse_fig, 'label','Help!', ...
      'foregroundcolor',dods_colors(9,:));
% THIS NEEDS TO BE CLEANED UP!!!!!!!!!!!!!!!!!!
  for j = 1:4	% number of items on the help menu
    str = [];
    arg = sprintf('%s%i%s%i%s%i%s''''''''%s''''''''%s', ...
	'for i = 1:size(dlgstring', j, ...
	',1), str = [str deblank(dlgstring', j, ...
        '(i,:)) '' '']; end; dlgstring', j, ...
        ' = [', ' str ', '];');
    eval(arg)
  end

  label = 'Guided Tour ...';
  [docu, options] = docopt;
  starturl = ...
      'http://www.unidata.ucar.edu/packages/dods/user/mgui-html/mgui_14.html';
  callbackstring = sprintf('!%s %s %s &', docu, options, starturl);
  uimenu(ui_help, 'label', label, 'callback', callbackstring);
  label = 'A quick note on using the Browser';
  callbackstring = sprintf('helpdlg(%s, ''%s'');', ...
      dlgstring2,label);
  uimenu(ui_help, 'label', label, 'callback', callbackstring);
  label = 'User Manual';
  [docu, options] = docopt;
  callbackstring = sprintf('!%s %s %s &', docu, options, manURL);
  ui_manual = uimenu(ui_help, 'label', label, 'callback', callbackstring);
  label = 'Updating the dataset list';
  callbackstring = sprintf('helpdlg(%s, ''%s'');', ...
      dlgstring3,label);
  uimenu(ui_help, 'label', label, 'callback', callbackstring);
  label = 'Report a Bug or send a Suggestion';
  callbackstring = sprintf('helpdlg(%s, ''%s'');', ...
      dlgstring4,label);
  uimenu(ui_help, 'label', label, 'callback', callbackstring);
  label = 'What is DODS?';
  homeurl = 'http://www.unidata.ucar.edu/packages/dods/';
  callbackstring = sprintf('!%s %s %s &', docu, options, homeurl);
  uimenu(ui_help, 'label', label, 'callback', callbackstring);
  label = 'About DODS ...';
  callbackstring = 'browse(''aboutdods'')';
  uimenu(ui_help,'label',label, 'callback',callbackstring);
   
% 6) THE PUSHBUTTONS AND EDIT BOXES
  % set up pushbutton positions
  buttonwidth = 0.12; buttonhgt = 0.06;
  fatbuttonwidth = 0.18;
  posit = [0.01 0.01 buttonwidth buttonhgt];
  shift = [buttonwidth 0 0 0]; gap = [0.01 0 0 0];  
  fatshift = [fatbuttonwidth 0 0 0];
  gui_buttons(30) = uicontrol(browse_fig, ...
      'units','normalized','style','push', ...
      'position', posit, ...
      'horizontalalign','center', ...
      'foregroundcolor',dods_colors(6,:), ...
      'backgroundcolor',dods_colors(1,:), ...
      'callback','browse(''swapview'')', ...
      'string','View Text');
  posit(3) = fatbuttonwidth;
  gui_buttons(3) = uicontrol(browse_fig, ...
      'style','push','units','normalized', ...
      'position',posit+shift+4*gap, ...
      'foregroundcolor',dods_colors(6,:), ...
      'backgroundcolor',dods_colors(1,:), ...
      'string','Set Data Range', ...
      'interruptible','on', ...
      'callback', 'browse(''setrange'')');
  gui_buttons(4) = uicontrol(browse_fig, ...
      'style','push','units','normalized', ...
      'position',posit+shift+fatshift+5*gap, ...
      'string', 'Clear Selections', ...
      'foregroundcolor', dods_colors(6,:), ...
      'backgroundcolor', dods_colors(1,:), ...
      'callback','browse(''clearrange'')');
  posit(3) = buttonwidth;
  gui_buttons(5) = uicontrol(browse_fig, ...
      'style','push','units','normalized', ...
      'position',posit+shift+2*fatshift+9*gap, ...
      'string','Zoom', ...
      'foregroundcolor',dods_colors(6,:), ...
      'backgroundcolor',dods_colors(1,:), ...
      'interruptible','on', ...
      'callback', 'browse(''zoom'')');
  gui_buttons(6) = uicontrol(browse_fig, ...
      'style','push','units','normalized', ...
      'position',posit+2*shift+2*fatshift+10*gap, ...
      'string','Next Plot', ...
      'interruptible','on', ...
      'visible','off', ...
      'backgroundcolor',dods_colors(9,:), ...
      'callback','browse(''nextplot'')');
  callbackstring = sprintf('%s; %s; %s', ...
      '[browse_figs] = browse(''quit'') ', ...
      'close(browse_figs)', ...
      'clear browse_figs'); 
  gui_buttons(7) = uicontrol(browse_fig, ...
      'style','push','units','normalized', ...
      'position',posit+3*shift+2*fatshift+14*gap, ...
      'foregroundcolor', dods_colors(6,:), ...
      'backgroundcolor', dods_colors(1,:), ...
      'string','QUIT', ...
      'callback', callbackstring);

  % DRAW GEOGRAPHIC AXIS, THE WORLDMAP, THE GEOGRAPHIC BUTTONS
  % set up button chars
  buttonwidth = 0.105; buttonhgt = 0.05; buttonsep = 0.01;

  axpos = [0.05 0.1 0.82 0.7];
  AXES(1) = axes('parent', browse_fig, ...
      'Units', 'Normalized', 'Position', axpos,...
      'drawmode','fast','xlim', axes_vals(1:2), ...
      'ylim', axes_vals(3:4), 'box','on', ...
      'color',dods_colors(2,:), ...
      'xcolor',dods_colors(3,:), ...
      'ycolor',dods_colors(3,:), ...
      'nextplot','add', ...
      'userdata', 'GEOPLOT', ...
      'ytick',[-60:30:60],'xtickmode','auto', ...
      'ytickmode','auto');

  axpos = [0.7921 0.12 0.03 0.65];
  AXES(4) = colorbar;
  set(AXES(4),'drawmode','fast',...
      'color',dods_colors(2,:), ...
      'xcolor',dods_colors(3,:), ...
      'ycolor',dods_colors(3,:), ...
      'position', axpos, ...
      'visible','off');
  cbarhandle = findobj(AXES(4),'type','image');
  set(cbarhandle,'vis','off')
  
  % set up coastline
  if isempty(dodsdir)
    dir = which('browse');
%    dirsep = '/';   I moved this outside of main loop so no longer needed here.
%    c = computer;
%    if strcmp(c(1:2),'PC')
%      dirsep = '\';
%    elseif strcmp(c(1:2),'MA')
%      dirsep = ':';
%    end
    i = max(findstr(dir,dirsep));
    dodsdir = dir(1:i);
    dodsdir = ['''' dodsdir ''''];
  end
  fname = [dodsdir 'coastln'];
  eval(['load ' fname])
  x = coastlines(1,:); 
  x(coastinx) = x(coastinx)+offset;
  worldmap = line(x,coastlines(2,:), 'Color',dods_colors(3,:), ...
      'Erasemode','none','linewidth',0.5,'linestyle','-');
  clear coastlines
  set(AXES(1), 'PlotBoxAspectRatio', [diff(axes_vals(1:2)) ...
	diff(axes_vals(3:4)) 1], ...
      'DataAspectRatio', [1 1 1]);

  % BUTTONS TO MANUALLY EDIT GEOGRAPHIC RANGES
  % WEST
  gui_buttons(8) = uicontrol(browse_fig,...
      'style','edit',...
      'foregroundcolor',dods_colors(6,:), ...
      'backgroundcolor', dods_colors(5,:), ...
      'units','normalized', ...
      'position', [0.01 0.42 buttonwidth buttonhgt], ...
      'horizontalalign','right', ...
      'visible','off', ...
      'callback','browse(''wesn'')', ...
      'String','');
  % EAST
  gui_buttons(9) = uicontrol(browse_fig,...
      'style','edit',...
      'foregroundcolor',dods_colors(6,:), ...
      'backgroundcolor', dods_colors(5,:), ...
      'units','normalized', ...
      'position',[0.01 0.49 buttonwidth, buttonhgt], ...
      'horizontalalign','right', ...
      'visible','off', ...
      'callback','browse(''wesn'')', ...
      'String','');
  % SOUTH
  gui_buttons(10) = uicontrol(browse_fig, ...
      'style','edit',...
      'foregroundcolor',dods_colors(6,:), ...
      'backgroundcolor', dods_colors(5,:), ...
      'units','normalized', ...
      'position', [0.01 0.56 buttonwidth, buttonhgt], ...
      'horizontalalign','right', ...
      'visible','off', ...
      'callback','browse(''wesn'')', ...
      'String','');
  % NORTH
  gui_buttons(11) = uicontrol(browse_fig,...
      'style','edit',...
      'foregroundcolor',dods_colors(6,:), ...
      'backgroundcolor', dods_colors(5,:), ...
      'units','normalized', ...
      'position',[0.01 0.63 buttonwidth, buttonhgt], ...
      'horizontalalign','right', ...
      'visible','off', ...
      'callback','browse(''wesn'')', ...
      'String','');
  
  gui_buttons(32) = uicontrol(browse_fig,'style','text', ...
      'units','normalized', ...
      'horiz','left', ...
      'foregroundcolor',dods_colors(3,:), ...
      'backgroundcolor',dods_colors(2,:), ...
      'visible','off', ...
      'position', [0.115 0.63 0.03 0.05], ...
      'string','N');
  gui_buttons(33) = uicontrol(browse_fig,'style','text', ...
      'units','normalized', ...
      'horiz','left', ...
      'foregroundcolor',dods_colors(3,:), ...
      'backgroundcolor',dods_colors(2,:), ...
      'visible','off', ...
      'pos',[0.115 0.56 0.03 0.05], ...
      'string','S');
  gui_buttons(34) = uicontrol(browse_fig,'style','text', ...
      'units','normalized', ...
      'horiz','left', ...
      'foregroundcolor',dods_colors(3,:), ...
      'backgroundcolor',dods_colors(2,:), ...
      'visible','off', ...
      'pos',[0.115 0.49 0.03 0.05], ...
      'string','E');
  gui_buttons(35) = uicontrol(browse_fig,'style','text', ...
      'units','normalized', ...
      'horiz','left', ...
      'foregroundcolor',dods_colors(3,:), ...
      'backgroundcolor',dods_colors(2,:), ...
      'visible','off', ...
      'pos',[0.115 0.42 0.03 0.05], ...
      'string','W');
  % label the WESN buttons
  gui_buttons(16) = uicontrol(browse_fig, ...
      'style','text', 'units','normalized', ...
      'position',[0.01 0.69 buttonwidth buttonhgt+0.01], ...
      'horizontalalign','center', ...
      'foregroundcolor',dods_colors(3,:), ...
      'backgroundcolor',dods_colors(2,:), ...
      'visible','off', ...
      'string','Range');
  gui_buttons(17) = uicontrol(browse_fig, ...
      'style','text', 'units','normalized', ...
      'position', [0.01 0.75 buttonwidth buttonhgt], ...
      'horizontalalign','center', ...
      'foregroundcolor',dods_colors(3,:), ...
      'backgroundcolor',dods_colors(2,:), ...
      'visible','off', ...
      'string','Set Data');

  % the all-important GET DATA button
  posit = [0.11 0.87 0.18 0.06];
  gui_buttons(1) =  uicontrol(browse_fig, ...
      'style','push','string','<< Get Data! >>', ...
      'units','normalized', 'position', posit, ...
      'foregroundcolor',dods_colors(6,:), ...
      'backgroundcolor', dods_colors(7,:), ...
      'callback','browse(''getdata'')');
  % the all-important GET DETAILS button
  gui_buttons(18) =  uicontrol(browse_fig, ...
      'style','push','string','Get Details', ...
      'units','normalized', 'position', posit+[0 0.06 0 0], ...
      'foregroundcolor',dods_colors(6,:), ...
      'backgroundcolor', dods_colors(7,:)+[0.3 0.2 0], ...
      'callback','browse(''getcat'')');
  % the all-important ACKNOWLEDGEMENTS button
  gui_buttons(59) =  uicontrol(browse_fig, ...
      'style','push','string','Acknowledgements', ...
      'units','normalized', 'position', posit+[0 -0.06 0 0], ...
      'foregroundcolor',dods_colors(6,:), ...
      'backgroundcolor', dods_colors(7,:)+[0.3 0.2 0], ...
      'callback', 'browse(''getack'')');
  % THE URL BOX
  gui_buttons(2) = uicontrol(browse_fig, ...
      'units','normalized','style','edit', ...
      'position',[0.01 0.09 0.98 0.06], ...
      'visible','off', ...
      'horizontalalign','left', ...
      'foregroundcolor',dods_colors(6,:), ...
      'backgroundcolor',dods_colors(5,:), ...
      'string','');
  
  % Z-BAR AND ASSOCIATED BUTTONS
  axpos = [0.95 0.1 0.05 0.65];
  AXES(2) = axes('parent', browse_fig, ...
      'Units', 'Normalized', ...
      'Position', axpos, ...
      'drawmode','fast', ...
      'color', dods_colors(2,:), ...
      'xcolor',dods_colors(3,:), ...
      'ycolor',dods_colors(3,:), ...
      'box', 'on', ...
      'xlim',[0 1],'xtick',[], ...
      'nextplot','add', ...
      'ylim',axes_vals(5:6), ...
      'userdata',zrange, ...
      'ydir','reverse', ...
      'visible','on'); set(get(AXES(2), ...
      'ylabel'),'string','', ...
      'color',dods_colors(3,:));

  % buttons to manually edit z-range
  gui_buttons(12) = uicontrol(browse_fig,...
      'style','edit',...
      'foregroundcolor',dods_colors(6,:), ...
      'backgroundcolor', dods_colors(5,:), ...
      'units','normalized', ...
      'position', [0.01 0.2 0.105 0.05], ...
      'horizontalalign','right', ...
      'visible','off', ...
      'callback','browse(''zrange'')', ...
      'String','');
  posit(2) = axpos(2)+axpos(4)+0.01;
  gui_buttons(13) = uicontrol(browse_fig,...
      'style','edit',...
      'foregroundcolor',dods_colors(6,:), ...
      'backgroundcolor', dods_colors(5,:), ...
      'units','normalized', ...
      'position', [0.01 0.27 0.105 0.05], ...
      'horizontalalign','right', ...
      'visible','off', ...
      'callback','browse(''zrange'')', ...
      'String','');
  gui_buttons(36) = uicontrol(browse_fig, 'style','text', ...
      'units','normalized', ...
      'foregroundcolor',dods_colors(3,:), ...
      'backgroundcolor',dods_colors(2,:), ...
      'visible','off', ...
      'pos',[0.01 0.33 0.09 0.05], ... 
      'string','Depth');
 
  % TIME SCALE AND ITS BOXES
  axpos = [0.3 0.84 0.68 0.1];
  AXES(3) = axes('parent', browse_fig, ...
      'Units', 'Normalized', ...
      'Position', axpos,...
      'drawmode','fast', ...
      'box','on', ...
      'color',dods_colors(2,:), ...
      'xcolor',dods_colors(3,:), ...
      'ycolor',dods_colors(3,:), ...
      'xlim', axes_vals(7:8), ...
      'visible','on', ...
      'nextplot','add', ...
      'tag', num2str(timetoggle), ...
      'ylim',[0 1], 'ytick', [], ...
      'userdata', timerange); 
  % note: tstring color is set by timelbl
  tstring(1) = text(0.5, 1.1,'Time in Years', 'horiz','center', ...
      'vert','bottom', 'erasemode','background',...
      'clipping','off','units','normalized');

  if timetoggle
    string = '1 JAN 1800';
  else
    string = '1 1800';
  end

  tstring(2) = text(0, 1.1, string, 'horiz','left', ...
      'vert','bottom','color',dods_colors(8,:), 'erasemode','background',...
      'clipping','off','units','normalized');
  [thandle, lhandle] = timelbl(axes_vals(7:8), timetoggle, thandle, ...
      lhandle, tstring, AXES, dods_colors, fontsize);

  % BUTTONS TO MANUALLY EDIT THE TIME RANGE
  gui_buttons(14) = uicontrol(browse_fig,...
      'style','edit',...
      'foregroundcolor',dods_colors(6,:), ...
      'backgroundcolor', dods_colors(5,:), ...
      'units','normalized', ...
      'position', [0.39 0.89 0.135 0.05], ...
      'horizontalalign','right', ...
      'visible','off', ...
      'callback','browse(''trange'')', ...
      'String','');
  gui_buttons(15) = uicontrol(browse_fig,...
      'style','edit',...
      'foregroundcolor',dods_colors(6,:), ...
      'backgroundcolor', dods_colors(5,:), ...
      'units','normalized', ...
      'position', [0.39 0.82 0.135 0.05], ...
      'horizontalalign','right', ...
      'visible','off', ...
      'callback','browse(''trange'')', ...
      'String','');
  gui_buttons(37) = uicontrol(browse_fig, 'style', 'text', ...
      'units','normalized', ...
      'foregroundcolor',dods_colors(3,:), ...
      'backgroundcolor',dods_colors(2,:), ...
      'visible','off', ...
      'position',[0.3 0.89 0.08 0.05], ...
      'horiz','right', ...
      'string','Begin');
  gui_buttons(38) = uicontrol(browse_fig, 'style', 'text', ...
      'units','normalized', ...
      'foregroundcolor',dods_colors(3,:), ...
      'backgroundcolor',dods_colors(2,:), ...
      'visible','off', ...
      'position',[0.3 0.82 0.08 0.05], ...
      'horiz','right', ...
      'string','End');
  posit = [0.535 0.89 0.05 0.05];
  for i = 1:5;
    gui_buttons(39+i) = uicontrol(browse_fig,'style','text', ...
	'units','normalized', ...
	'foregroundcolor',dods_colors(6,:), ...
	'backgroundcolor',dods_colors(1,:), ...
	'string','', ...
	'visible','off', ...
	'position',posit);
    posit = posit + [0.06 0 0 0];
  end
  posit = [0.535 0.82 0.05 0.05];
  for i = 1:5
    gui_buttons(44+i) = uicontrol(browse_fig,'style','text', ...
	'units','normalized', ...
	'foregroundcolor',dods_colors(6,:), ...
	'backgroundcolor',dods_colors(1,:), ...
	'visible','off', ...
	'string','', ...
	'position',posit);
    posit = posit + [0.06 0 0 0];
  end
  posit = [0.535 0.95 0.05 0.05];
  string = str2mat('Mo','Day','Hr','min','sec');
  for i = 1:5
    gui_buttons(53+i) = uicontrol(browse_fig,'style','text', ...
	'units','normalized', ...
	'foregroundcolor',dods_colors(3,:), ...
	'backgroundcolor',dods_colors(2,:), ...
	'horiz','center', ...
	'visible','off', ...
	'string', string(i,:), ...
	'position',posit);
    posit = posit + [0.06 0 0 0];
  end
  
  % The URL count buttons
  gui_buttons(50) = uicontrol(browse_fig, 'style', 'text', ...
      'units','normalized', ...
      'foregroundcolor',dods_colors(3,:), ...
      'backgroundcolor',dods_colors(2,:), ...
      'visible','off', ...
      'position',[0.825 0.90 0.105 0.05], ...
      'horiz','right', ...
      'string','Number of');
  gui_buttons(51) = uicontrol(browse_fig, 'style', 'text', ...
      'units','normalized', ...
      'foregroundcolor',dods_colors(3,:), ...
      'backgroundcolor',dods_colors(2,:), ...
      'visible','off', ...
      'position',[0.825 0.85 0.105 0.05], ...
      'horiz','right', ...
      'string','URLS in');
  gui_buttons(52) = uicontrol(browse_fig, 'style', 'text', ...
      'units','normalized', ...
      'foregroundcolor',dods_colors(3,:), ...
      'backgroundcolor',dods_colors(2,:), ...
      'visible','off', ...
      'position',[0.825 0.80 0.105 0.05], ...
      'horiz','right', ...
      'string','Request');
  % this one actually shows the count:
  gui_buttons(53) = uicontrol(browse_fig, 'style', 'text', ...
      'units','normalized', ...
      'foregroundcolor',dods_colors(6,:), ...
      'backgroundcolor',dods_colors(1,:), ...
      'visible','off', ...
      'position',[0.94 0.84 0.05 0.06], ...
      'horiz','left', ...
      'string','');
  
  AXES(5) = axes('parent', browse_fig, ...
      'Units', 'Normalized', ...
      'Position', [-0.02 0.82 0.15 0.15],...
      'drawmode','fast', ...
      'box','off', ...
      'clim',[0 255], ...
      'color',dods_colors(2,:), ...
      'xcolor',dods_colors(2,:), ...
      'ycolor',dods_colors(2,:), ...
      'xlim', [1 92], 'xtick', [], ...
      'ylim',[1 92], 'ytick', [], ...
      'visible','off', ...
      'nextplot','add');
  set(AXES(5),'plotboxaspectratio',[1 1 1])
  load smlogo; 
  image(small_logo); colormap(avhrrpal);

  subplot(AXES(1)); range_boxes(1) = line([ranges(1,1:2) ranges(1,2) ranges(1,2) ...
      ranges(1,2) ranges(1,1) ranges(1,1) ranges(1,1)], ...
  [ranges(2,1) ranges(2,1) ranges(2,1) ranges(2,2) ranges(2,2) ranges(2,2) ...
      ranges(2,2) ranges(2,1)], ... 
      'color',dods_colors(10,:),'visible','off', ...
      'linewidth', 2);
  subplot(AXES(2)); range_boxes(2) = line([0.01 0.99 0.99 0.99 ...
	  0.99 0.01 0.01 0.01], ...
      [ranges(3,1) ranges(3,1) ranges(3,1) ranges(3,2) ...
	  ranges(3,2) ranges(3,2) ranges(3,2) ranges(3,1)], ...
      'color',dods_colors(10,:), ...
      'linewidth', 2, 'visible','off');
  subplot(AXES(3)); range_boxes(3) = line([ranges(4,1) ranges(4,2) ...
	  ranges(4,2) ranges(4,2) ranges(4,2) ranges(4,1) ...
	  ranges(4,1) ranges(4,1)], ...
      [0.01 0.01 0.01 0.99 0.99 0.99 0.99 0.01], ...
      'color',dods_colors(10,:), ...
      'linewidth', 2, 'visible', 'off');

  % reset axes all the way 'out'
  %set(get(AXES(1),'zlabel'),'userdata', ...
  %    [master_georange(1:2)+[-5 5] master_georange(3:4)+[-1 1]])
  %set(get(AXES(2),'zlabel'),'userdata',[0 1 zrange])
  %set(get(AXES(3),'zlabel'),'userdata',[timerange 0 1])
  subplot(AXES(1))

  % set range boxes with saved ranges
  % because the browse figure now exists, this will
  % start the display menu, dscroll and vscroll lists,
  % and thus the listedit windows as well.
  browse('setrangeboxes')

  % set edit boxes with saved ranges
  browse('bsetrange') 
  
  % set fontsizes of things in browse window
  set([gui_buttons(:); tstring(:); AXES(:); get(AXES(2),'ylabel'); ...
    thandle(:)], 'fontsize', fontsize)

  % clear the event queue
  drawnow
  
  % reveal the figure  
  set(browse_fig,'visible','on')
  
  % open bookmarks and variables: dscrolllist will automagically
  % start the vscrolllist

  dscrolllist('start', fontsize, dods_colors(1,:), figsizes(4,:))
%  vscrolllist('start', fontsize, dods_colors([6 1],:), figsizes(8,:))

  return
end

% CHECK ARGUMENT
switch arg1
  case 'aboutdods'
    k = get(0,'children');
    for i = 1:length(k),
      if strcmp(get(k(i),'userdata'),'About DODS')
	figure(k(i))
	return
	break
      end
    end
    load lglogo;
    scr_size = get(0,'ScreenSize');
    h = figure('position',[round(scr_size(3)/3) scr_size(4)-352 425 300], ...
	'color',[1 1 1],'numbertitle','off', ...
	'name','About DODS', 'resize','off', ...
	'userdata','About DODS');
    i = axes('parent', h, 'units', 'normalized', ...
	'position', [0.175 0.3 0.65 0.65], ...
	'xlim',[0 260],'ylim',[0 260], 'nextplot','add', ...
	'plotboxaspectratio', [1 1 1], 'visible','off');
    image(large_logo); colormap(logo_map);  drawnow
    text('parent', i, 'position', [-0.55, 0.08], ...
	'string', [setstr(169) ' 1994-1997 URI/MIT'], ...
	'color','k', ...
	'horiz','left','units','normalized')
    text('parent', i, 'position', [-0.55, -0.08], ...
	'string', ['DODS was written by James Gallagher, '...
	    'Reza Nekovei, and Dan Holloway'], ...
	'color','k','horiz','left','units','normalized')
    text('parent', i, 'position', [-0.55,-0.16], ...
	'string', ['Matlab Interface (Loaddods package) by ', ...
	    'James Gallagher, Glenn Flierl,'], 'color','k', ...
	'horiz','left','units','normalized')
    text('parent', i, 'position', [0,-0.24], ...
	'string', ['Peter Cornillon, and George Milkowksi '], ...
	    'color','k', 'horiz','left','units','normalized')
    text('parent', i, 'position', [-0.55, -0.32], ...
	'string', ['Graphical User Interface by Deirdre Byrne, ', ...
	  'University of Maine'], ...
	'horiz','left',	'color','k','units','normalized')
    callbackstring = sprintf('delete(%i)',h);
    uicontrol(h,'style','push', 'units','normalized', ...
	'position',[0.86 0.02 0.12 0.08], ...
	'string','OK','callback',callbackstring)
    return
    
  case 'bsetrange'
    % set edit button text with ranges.  Called by resetdefault,
    % setdset, and loadopts modes
    if (num_rang(1) == 0 & num_rang(2) == 1)
      x = ranges(1,:);
      if master_georange(1) < 0
	% we're fine
      else % master_georange(1:2) == [0 360]
	if x(2) < 0
	  x(2) = x(2)+360;
	end
      end
      set(gui_buttons(8),'string','')
      if ~isnan(x(2))
	set(gui_buttons(9),'String',sprintf(' %.2f',x(2)))
      end
    elseif (num_rang(1) == 1 & num_rang(2) == 0)
      x = ranges(1,:);
      if master_georange(1) < 0
	% we're fine
      else % master_georange(1:2) == [0 360]
	if x(1) < 0
	  x(1) = x(1)+360;
	end
      end
      if ~isnan(x(1))
	set(gui_buttons(8),'String',sprintf(' %.2f',x(1)))
      end
      set(gui_buttons(9),'string','')
    elseif sum(num_rang(1:2)) == 2
      x = xrange('range', master_georange, ranges(1,:));
      tmpx = xrange('range', [-180 180 -90 90], ranges(1,:));
      if max(size(x) == 2) % one-box mode
	if all(size(tmpx) == [1 2])
	  if ~isnan(x(1))
	    set(gui_buttons(8),'String',sprintf(' %.2f',x(1)))
	  end
	  if ~isnan(x(2))
	    set(gui_buttons(9),'String',sprintf(' %.2f',x(2)))
	  end
	else
	  if master_georange(1) < 0 % I don't think this ever occurs ...
	    xl = nan*ones(1,8);
	  else
	    if ~isnan(x(1))
	      set(gui_buttons(8),'String',sprintf(' %.2f',x(1)))
	    end
	    if ~isnan(x(2))
	      set(gui_buttons(9),'String',sprintf(' %.2f',x(2)))
	    end
	  end
	end
      else % we are in two-box mode
	set(gui_buttons(8:9),'String','')
      end
    else % none of the x-ranges are set
      set(gui_buttons(8:9),'String','')
    end
    % set S and N range edit buttons
    if all(num_rang(3:4) == 1)
      set(gui_buttons(10),'String',sprintf('%.3f',ranges(2,1)))
      set(gui_buttons(11),'String',sprintf('%.3f',ranges(2,2)))
    else
      set(gui_buttons(10),'String','')
      set(gui_buttons(11),'String','')
    end
    if sum(num_rang(5:6)) == 2
      set(gui_buttons(12),'String',sprintf(' %.2f',ranges(3,2)))
      set(gui_buttons(13),'String',sprintf(' %.2f',ranges(3,1)))
    else
      set(gui_buttons(12),'String','')
      set(gui_buttons(13),'String','')
    end
    if sum(num_rang(7:8)) == 2
      set(gui_buttons(14),'String',sprintf(' %.5f',ranges(4,1)))
      lmo = [31 28 31 30 31 30 31 31 30 31 30 31];
      if rem(floor(ranges(4,1)),4) == 0
	if floor(ranges(4,1)) == 1900 	% 1900 was apparently not a leap year!
	  lyr = 365;
	else
	  lyr = 366;
	  lmo(2) = 29;
	end
      else
	lyr = 365;
      end
      range_day = floor((ranges(4,1)-floor(ranges(4,1)))*lyr(1))+1; % day of year
      
      t = min(find(range_day < cumsum(lmo)));
      if isempty(t)
	t = 12;
      end
      % day
      t(2) = range_day(1) - sum(lmo(1:t(1)-1));
      % hr
      t(3) = floor((((ranges(4,1)-floor(ranges(4,1)))*lyr(1)+1)-range_day(1))*24);
      % min
      t(4) = floor(((((ranges(4,1)-floor(ranges(4,1)))*lyr(1)+1)*24 - ...
	  range_day(1)*24)-t(3))*60);
      % sec
      t(5) = floor(((((ranges(4,1)-floor(ranges(4,1)))*lyr(1)+1)*24*60 - ...
	  range_day(1)*24*60)-t(3)*60)*60-t(4)*60);
      for i = 1:5;
	set(gui_buttons(39+i),'string',sprintf(' %i',t(i)))
      end
      
      set(gui_buttons(15),'String',sprintf(' %.5f',ranges(4,2)))
      lmo = [31 28 31 30 31 30 31 31 30 31 30 31];
      if rem(floor(ranges(4,2)),4) == 0
	if floor(ranges(4,2)) == 1900 	% 1900 was apparently not a leap year!
	  lyr(2) = 365;
	else
	  lyr(2) = 366;
	  lmo(2) = 29;
	end
      else
	lyr(2) = 365;
      end
      range_day(2) = floor((ranges(4,2)-floor(ranges(4,2)))*lyr(2))+1; % day of year
      t = min(find(range_day(2) < cumsum(lmo)));
      if isempty(t)
	t = 12;
      end
      % day
      t(2) = range_day(2) - sum(lmo(1:t(1)-1));
      % hr
      t(3) = floor((((ranges(4,2)-floor(ranges(4,2)))*lyr(2)+1)-range_day(2))*24);
      % min
      t(4) = floor(((((ranges(4,2)-floor(ranges(4,2)))*lyr(2)+1)*24 - ...
	  range_day(2)*24)-t(3))*60);
      % sec
      t(5) = floor(((((ranges(4,2)-floor(ranges(4,2)))*lyr(2)+1)*24*60 - ...
	  range_day(2)*24*60)-t(3)*60)*60-t(4)*60);
      for i = 1:5;
	set(gui_buttons(44+i),'string',sprintf(' %i',t(i)))
      end
    else
      set(gui_buttons(14),'String','')
      set(gui_buttons(15),'String','')
      set(gui_buttons(40:49),'string','')
    end
    return
    
  case 'changecolor'
    % map backgroundcolor
    set(AXES(1:3), 'color', dods_colors(2,:))
    set(browse_fig,'color', dods_colors(2,:))
    set(gui_buttons([16:17 32:38 50:52 54:58]),'backgroundcolor',dods_colors(2,:))
    avhrrpal(1,:) = dods_colors(2,:);
    set(0,'currentfigure',browse_fig); colormap(avhrrpal); drawnow

    % map foregroundcolor
    set(AXES(1:3), 'xcolor', dods_colors(3,:))
    set(AXES(1:3), 'ycolor', dods_colors(3,:))
    set(worldmap, 'color', dods_colors(3,:))
    set(tstring(1), 'color', dods_colors(3,:))
    set(gui_buttons([16:17 32:38 50:52 54:58]), 'foregroundcolor', dods_colors(3,:))
    set(get(AXES(2), 'ylabel'), 'color', dods_colors(3,:))
    
    % time labels
    set(tstring(2), 'color', dods_colors(8,:))
    if ~isempty(thandle)
      set(thandle, 'color', dods_colors(8,:))
    end
    if ~isempty(lhandle)
      set(lhandle, 'color', dods_colors(8,:))
    end

    % range boxes
    set(range_boxes, 'color', dods_colors(10,:))
    
    % note: button/text foreground is dods_colors(6,:)
    % button/text background is dods_colors(1,:)
    % and edit box background is dods_colors(5,:)

    % GUI buttons
    % 20 21 23 27, while in 'edit' style, are not editable!
    set(gui_buttons([4 7 19:27 29:31 39:49 53]), ...
	'foregroundcolor', dods_colors(6,:), ...
	'backgroundcolor', dods_colors(1,:))
    set(gui_buttons([2 8 9 10:15]), ...
	'foregroundcolor', dods_colors(6,:), ...
	'backgroundcolor', dods_colors(5,:))
    
    set(gui_buttons([3 5]),'foregroundcolor', dods_colors(6,:))
    if ~all(get(gui_buttons(3),'backgroundcolor') == dods_colors(9,:))
      set(gui_buttons(3),'backgroundcolor', dods_colors(1,:))
    end
    if ~all(get(gui_buttons(5),'backgroundcolor') == dods_colors(9,:))
      set(gui_buttons(5),'backgroundcolor', dods_colors(1,:))
    end

    % other figures
    dscrolllist('changecolor', dods_colors([6 1],:))
    vscrolllist('changecolor', dods_colors([6 1],:))
    dispmenu('changecolor',dods_colors([6 1 5],:))
    listedit('changecolor', dods_colors([6 1],:))
    dodspropedit('changecolor', dods_colors([6 1 5],:))
    mastershow('changecolor', dods_colors([6 1],:))
    choosecolor('changecolor', dods_colors);
    return
    
  case 'checkarchive'
    exarch = 0;
    if ~isnan(dset)
      archive = deblank(userlist(dset).archive);
      if ~isempty(archive)
	if ~checkfunction(archive)
	  exarch = 1;
	else
	  
	  str = sprintf('Required file: %s %s', ...
	      archive, 'not found on your system!');
	  dodsmsg(popup,str)
	end
      else
	str = 'Required metadata file (archive.m) is undefined!';
	dodsmsg(popup,str)
      end
    end
    if nargout > 0
      clear_button = exarch;
    end
    return
    
  case 'checkplots'
    % if there is only one plot in the image_string,
    % then it has been visible to the user and can be
    % deleted.  DAB 98/09/12
    if length(image_string) > 0
      if length(image_string) == (image_string(1)+1)
	% maybe people want to overlay on last plot?	
	%	delete(image_string(2:image_string(1)+1));
	image_string = [];
      end
    end
    return

  case 'choose_var'
    % we have chosen/unchosen a variable from the scroll menu
    if any(isnan(var))
      return
    end
    % Note: button 2 is the URL edit box
    % button 54 is the num_urls display box
    if ~isnan(dset)
      if ~datasets(dset)
	% if the selected dataset does not contain this
	% variable, unselect it
	dset = nan;
	set(gui_buttons(2),'string','');
	set(gui_buttons(39),'string','');
	set(gui_buttons(53),'string','');
	set(gui_buttons(1),'callback','browse(''getdata'')')
	return
      else
	if any(size(brs_old_var) ~= size(var))
	  set(gui_buttons(2),'string','');
	  set(gui_buttons(53),'string','');
	else % number of old and new variables the same
	  if any(brs_old_var ~= var)
	    set(gui_buttons(2),'string','');
	    set(gui_buttons(53),'string','');
	  end
	end
      end
    else
      set(gui_buttons(2),'string','');
      set(gui_buttons(39),'string','');
      set(gui_buttons(53),'string','');
      set(gui_buttons(1),'callback','browse(''getdata'')')
      return
    end

    callbackstring = sprintf('browse(''getdata'',''cancel''); clear %s', ...
	returnstring);
    set(gui_buttons(25),'callback',callbackstring);

    if sum(num_rang) == 8 & sum(isnan(ranges)) == 0
      callbackstring = sprintf('[%s] = browse(''getdata''); unpack', ...
	  returnstring);
      set(gui_buttons(1),'callback', callbackstring, ...
	'backgroundcolor',dods_colors(7,:))
      callbackstring = sprintf('[%s] = browse(''getdata'',''ok''); unpack', ...
	  returnstring);
      set(gui_buttons(24), 'callback',callbackstring)
    
    else
      set(gui_buttons(1),'callback','browse(''getdata'')')
    end
    
    return
    
  case 'clearrange'
    % reset graphic ranges
    select(0); set(gui_buttons(3),'backgroundcolor', dods_colors(1,:));
    ranges = nan*ones(4,2);
    num_rang = zeros(8,1);

    set(gui_buttons(8:15),'String','')
    set(range_boxes,'visible','off')
    
    % reset lengths
    user_num_sets = size(userlist(:),1);
    user_num_vars = size(user_variables,1);

    % reset dataset list
    dscrolllist('dreset')
    
    % reset variables list
    vscrolllist('vreset')

    % clear URL & Selections, metadata
    set(gui_buttons(1),'callback','browse(''getdata'')')
    set(gui_buttons(2),'string','');
    set(gui_buttons(53),'string','');
    set(gui_buttons(39:49),'string','');

    % clear Hang on ... and 'Cancel' and Resolutions
    set(gui_buttons(26:28),'visible','off')
    if ~isempty(ui_stride)
      for i = 1:length(ui_stride)
	if any(findobj(ui_res,'type','uimenu') == ui_stride(i))
	  delete(ui_stride(i))
	end
      end
    end

    return
  
  
  case 'clrimg'
    set(0,'currentfigure',browse_fig)
    % save zoom limits
    x = get(get(AXES(1),'zlabel'),'userdata');
    if isempty(x)
      x = axes_vals(1:4);
    end
    y = get(get(AXES(2),'zlabel'),'userdata');
    if isempty(y)
      y = [0 1 axes_vals(5:6)];
    end
    z = get(get(AXES(3),'zlabel'),'userdata');
    if isempty(z)
      z = [axes_vals(7:8) 0 1];
    end
    
    % delete random things that have been plotted
    kids = get(AXES(1),'children');
    j = findobj(AXES(1),'Tag','ColorbarDeleteProxy');
    if ~isempty(j), kids = kids(~isin(kids,j)); end
    i = find(kids ~= worldmap & kids ~= range_boxes(1));
    delete(kids(i)); 
    kids = get(AXES(2),'children');
    i = find(kids ~= range_boxes(2));
    delete(kids(i)); 
    kids = get(AXES(3),'children');
    for i = 1:length(kids)
      if ~any(kids(i) == [range_boxes(3); tstring(:); thandle(:); lhandle(:)])
	delete(kids(i));
      end
    end
    % hide the colorbar
    set([AXES(4) cbarhandle],'vis','off')

    % delete num_urls text
    set(gui_buttons(53),'string','')
    
    % reset zoom limits
    if ~isempty(x)
      set(get(AXES(1), 'zlabel'), 'userdata', x)
    end
    if ~isempty(y)
      set(get(AXES(2), 'zlabel'), 'userdata', y)
    end
    if ~isempty(z)
      set(get(AXES(3), 'zlabel'), 'userdata', z)
    end
    
    % replot selected dataset ranges on maps
    if ~isnan(dset)
      subplot(AXES(1)); 
      x = xrange('range',master_georange,[userlist(dset).rangemin(1) ...
	      userlist(dset).rangemax(1)]);
      y = [userlist(dset).rangemin(2) userlist(dset).rangemax(2)];
      if max(size(x) == 2)
	xl = [x(1:2) x(2) x(2) x(2) x(1) x(1) x(1)];
	yl = [y(1) y(1) y(1:2) y(2) y(2) y(2) y(1)];
      else
	% two boxes
	xl = [x(1:2) x(2) x(2) x(2) x(1) x(1) x(1) nan ...
		x(3:4) x(4) x(4) x(4) x(3) x(3) x(3)];
	yl = [y(1) y(1) y(1:2) y(2) y(2) y(2) y(1) nan ...
		y(1) y(1) y(1:2) y(2) y(2) y(2) y(1)];
      end

      h = line(xl,yl, 'color',userlist(dset).color,'erasemode','none', ...
	  'clipping','on','visible','off'); drawnow
      i = plot(xl,yl, 's','color',userlist(dset).color,'erasemode','none', ...
	  'clipping','on','visible','off'); drawnow
      if strcmp(get(gui_buttons(30),'string'),'View Text')
	h = [h(:); i(:)];
	set(h,'visible','on')
      end

      subplot(AXES(2)); 
      x = 0.90*dset/user_num_sets;
      yl = [userlist(dset).rangemin(3) userlist(dset).rangemax(3)];
      h = line([x x], yl, 'color',userlist(dset).color,'erasemode','none', ...
	  'clipping','on','visible','off'); drawnow
      i = plot([x x], yl, 's','color',userlist(dset).color,'erasemode','none', ...
	  'clipping','on','visible','off'); drawnow
      if strcmp(get(gui_buttons(30),'string'),'View Text')
	h = [h(:); i(:)];
	set(h,'visible','on')
      end
    
      subplot(AXES(3)); 
      xl = [userlist(dset).rangemin(4) userlist(dset).rangemax(4)];
      y = 0.90*dset/user_num_sets;
      h = line(xl, [y y], 'color',userlist(dset).color,'erasemode','none', ...
	  'clipping','on','visible','off'); drawnow
      i = plot(xl, [y y], 's','color',userlist(dset).color,'erasemode','none', ...
	  'clipping','on','visible','off'); drawnow
      if strcmp(get(gui_buttons(30),'string'),'View Text')
	h = [h(:); i(:)];
	set(h,'visible','on')
      end

    end

    % clean up GUI buttons
    % Abort and Datasize Warning buttons
    set(gui_buttons(22:28),'visible','off')
    % Get Data button
    set(gui_buttons(1), 'backgroundcolor', dods_colors(7,:))
    % Get Details button
    set(gui_buttons(18), 'backgroundcolor', dods_colors(7,:)+[0.3 0.2 0])
    
    % clear queued images, if any
    image_string = [];
    % this is the Next Plot button
    set(gui_buttons(6),'visible','off','userdata','')

    % refresh the figure
    refresh(browse_fig)
    return
    
  case 'display'
    set(ui_clear,'enable','off')
    dispmenu('display')
    return
    
  case 'dodsdatadir'
    k = findobj(gcf,'style','edit','userdata','DODSDATADIR');
    dir = get(k,'string');
    if ~isempty(dir)
      dodsdatadir = dir;
    end
%    dirsep = '/';     Moved outside of main loop so no longer needed.
%    c = computer;
%    if strcmp(c(1:2),'PC')
%      dirsep = '\';
%    elseif strcmp(c(1:2),'MA')
%      dirsep = ':';
%    end
%    dodsdatadir = deblank(dodsdatadir);
    if ~strcmp(dodsdatadir(length(dodsdatadir)),dirsep)
      dodsdatadir = [dodsdatadir dirsep];
    end
    dodsdatadir = ['''' dodsdatadir ''''];
    return
    
  case 'enableclear'
    set(ui_clear,'enable','on')
  
  case 'errors'
    % SET ERROR MESSAGE PREFERENCES
    return
    
  case 'figpos'
    fig = arg2;
    if nargout > 0
      clear_button = figsizes(fig,:);
    end
    
  case 'fontsize'
    fontsize = arg2;
    set(gui_buttons, 'fontsize', fontsize)
    dispmenu('fontsize', fontsize)
    dscrolllist('fontsize', fontsize)
    listedit('fontsize', fontsize)
    mastershow('fontsize', fontsize)
    dodspropedit('fontsize', fontsize)
    vscrolllist('fontsize', fontsize)
    set(tstring,'fontsize',fontsize)
    set(AXES,'fontsize',fontsize)
    set(get(AXES(2),'ylabel'),'fontsize',fontsize)
    set(thandle,'fontsize',fontsize)
    
  case 'getack'
    if isnan(dset)
      str = 'Please choose a dataset from the menus above.';
      dodsmsg(popup,str)
    end
    % set getxxx and archive files
    if dset <= user_num_sets
      getxxx = userlist(dset).getxxx;
      archive = deblank(userlist(dset).archive);
    else
      str = 'Selected dataset is not valid';
      dodsmsg(popup,str)
      return
    end

%    % Pass in the Metadata name and query the Catalogue server
    if (exist('loaddods') ~= 3) & (exist('loaddods') ~= 2)
      str = sprintf('%s\n%s', ...
	  'Unable to find the loaddods MEX-file', ...
	  'Please make sure it is in your matlabpath');
      dodsmsg(popup,str)
      set(gui_buttons(59),'backgroundcolor',dods_colors(7,:)+[0.3 0.2 0])
      return
    end
    % turn off all other buttons
    select(0);
    set(gui_buttons(3),'backgroundcolor', ...
	dods_colors(1,:)); set(gui_buttons(5), ...
	'backgroundcolor',dods_colors(9,:)); drawnow
    set(gui_buttons(5),'backgroundcolor',dods_colors(1,:))
    subplot(AXES(1)); newzoom off; subplot(AXES(2)); newzoom off; 
    subplot(AXES(3)); newzoom off; 

    % turn on relevant buttons
    set(gui_buttons(59),'backgroundcolor',dods_colors(9,:)); drawnow
    set(gui_buttons(26:28),'visible','on'); drawnow
    % this is perhaps needed only to construct the URL
    if all(~isnan(var))
      get_variables = user_variables(var,:);
    else
      get_variables = [];
    end
    % but maybe it isn't ....
    eval(sprintf('Acknowledge = getack(%s);', ...
        [get_inputstring ', 0, browse_version']));
    if ~isempty(Acknowledge)
      dodsmsg(popup, Acknowledge)
    end

    set(gui_buttons(59),'backgroundcolor',dods_colors(7,:)+[0.3 0.2 0])
    set(gui_buttons(26:28),'visible','off'); 
    refresh(browse_fig)
    return

  case 'getcat'
    if ~isnan(dset) & ~isnan(var)
      if sum(num_rang) == 8
	% check -- is this a valid request, given the dataset range?
	% boolean: which datasets within the given ranges
	% only subselect based on which ranges set
	% first check if x-ranges are swapped:
	if ranges(1,1) > ranges(1,2)
	  tmpranges = [ranges(1,1)-360 ranges(1,2); ranges(2:4,:)];
	else
	  tmpranges = ranges;
	end
 
        datamin = tmpranges(2:4,1)' > [userlist(dset).rangemax(2:4)];
     	datamax = tmpranges(2:4,2)' < [userlist(dset).rangemin(2:4)];
        [datamin, datamax] = get_lon_rng( tmpranges, lonmin(dset), lonmax(dset), datamin, datamax);

        d = ~(any(datamin')' | any(datamax')');

	if ~d
	  dset = nan;
          dscrolllist('datset','full')
	  str = 'Dataset out of range';
	  dodsmsg(popup,str)
	  return
	end

	% set getxxx and archive and URLinfo
	getxxx = userlist(dset).getxxx;
	archive = deblank(userlist(dset).archive);
	URLinfo = userlist(dset).URLinfo;
	
	% Pass in the Metadata name and query the Catalogue server
	if exist(getxxx) == 2
	  if (exist('loaddods') ~= 3) & (exist('loaddods') ~= 2)
	    str = sprintf('%s\n%s', ...
		'Unable to find the loaddods MEX-file', ...
		'Please make sure it is in your matlabpath');
	    dodsmsg(popup,str)
	    set(gui_buttons(18),'backgroundcolor',dods_colors(7,:)+[0.3 0.2 0])
	    return
	  end
	  % turn off all other buttons
	  select(0);
	  set(gui_buttons(3),'backgroundcolor', ...
	      dods_colors(1,:)); set(gui_buttons(5), ...
	      'backgroundcolor',dods_colors(9,:)); drawnow
	  set(gui_buttons(5),'backgroundcolor',dods_colors(1,:))
	  subplot(AXES(1)); newzoom off; subplot(AXES(2)); newzoom off; 
	  subplot(AXES(3)); newzoom off; 
	  % turn on relevant buttons
	  % HERE
	  set(gui_buttons(18),'backgroundcolor',dods_colors(9,:)); drawnow
	  set(gui_buttons(26:27),'visible','on'); drawnow
	  x = []; y = []; z = []; n = []; t = []; url = [];
	  if all(~isnan(var))
	    get_variables = user_variables(var,:);
	  else
	    get_variables = [];
	  end

	  eval(sprintf('[x,y,z,t,n,url,urllist,urlinfo] = %s(''cat'', %s);', ...
	      getxxx, [get_inputstring, ',', 'URLinfo']))
	  
	  if ~isequal(urlinfo, URLinfo)
	    if ~isempty(urlinfo)
	      userlist(dset).URLinfo = urlinfo;
	      % first save the user bookmarks
	      listedit('fsave', userlist, user_variables)
	    end
	  end

	  if ~isempty(n)
	    num_urls = n;
	  else
	    num_urls = 0;
	  end
	  % set the Get Data button to really go ahead
	  callbackstring = sprintf('[%s] = browse(''getdata''); unpack', ...
	      returnstring);
	  set(gui_buttons(1),'callback',callbackstring)
	  set(gui_buttons(53),'string',sprintf('%i',num_urls))
	  if isstr(url)
	    if size(url,1) > 1
	      urlstring = '';
	      for i = 1:size(url,1)
		urlstring = sprintf('%s %s',urlstring, url(i,:));
	      end
	    else
	      urlstring = url;
	    end
    	    set(gui_buttons(2),'string',urlstring)
	  end
	  if ~isempty(x)
	    if ~isempty(y)
	      set(0,'currentfigure',browse_fig) 
	      subplot(AXES(1)); h = plot(x, y,'+', ...
		  'color',userlist(dset).color,'erasemode','none', ...
		  'clipping','on','visible','off'); drawnow
	      if strcmp(get(gui_buttons(30),'string'),'View Text')
		set(h,'visible','on')
	      end
	    end
	  end
	  if ~isempty(z)
	    num_depths = length(z);
	    x = 0.90*dset/user_num_sets; x=x*ones(num_depths,1);
	    subplot(AXES(2)); h = plot(x, z,'*', ...
		'color',userlist(dset).color,'erasemode','none', ...
		'clipping','on','visible','off'); drawnow
	    if strcmp(get(gui_buttons(30),'string'),'View Text')
	      set(h,'visible','on')
	    end
	  end
	  if ~isempty(t)
	    num_dates = length(t);
	    y = 0.90*dset/user_num_sets; y=y*ones(num_dates,1);
	    subplot(AXES(3)); h = plot(t, y,'*', ...
		'color',userlist(dset).color,'erasemode','none', ...
		'clipping','on','visible','off'); drawnow
	    if strcmp(get(gui_buttons(30),'string'),'View Text')
	      set(h,'visible','on')
	    end
	    
	  end
	  % NEW FOR 2000 -- return a URL list using 'evalin'
	  if ~isempty(urllist)
	    clear browse_urllist
	    global browse_urllist
	    browse_urllist = urllist;
	    evalin('base',[ 'clear browse_urllist; ', ...
		  'global browse_urllist; URLlist = browse_urllist;'])
	    clear global browse_urllist
	  else
	    evalin('base','URLlist = '''';')
	  end
	  
%	  % HERE
%	  str = sprintf('%s\n', '          .......done');
%	  dodsmsg(popup,str)
	else
	  str = sprintf('Error! Cannot find your '' %s'' function.',getxxx);
	  dodsmsg(popup,str)
	end
      else
	str = 'Please select time, depth, longitude and latitude ranges';
	dodsmsg(popup,str)
      end
    else
      str = 'Please choose a variable and a dataset from the menus above.';
      dodsmsg(popup,str)
    end
    set(gui_buttons(18),'backgroundcolor',dods_colors(7,:)+[0.3 0.2 0])
    set(gui_buttons(1),'backgroundcolor',dods_colors(7,:))
    set(gui_buttons(26:28),'visible','off'); 
    refresh(browse_fig)
    return

  case 'getcolors'
    % return the color scheme
    default_colors = [0.702 0.702 0.702; % 1 color for text background
	0.702 0.702 0.702; % 2 color for map background
	0     0     0;     % 3 color for map foreground
	nan   nan   nan;   % 4 this is unused but preserved for compatibility
	1     0.5   0.5;   % 5 color for edit boxes (pink)
	0     0     0;     % 6 color for uicontrol labels and text foreground
	0.3   0.5   1;     % 7 color for Get Data! button
	0     0     1;     % 8 color for special time labels
	0.7   0     0;     % 9 whizzo -- the special color
	1     0     0];    % 10 selection range box color 
    if isempty(dods_colors)
      dods_colors = default_colors;
    else
      if ~all(size(dods_colors) == [10 3])
	dods_colors = default_colors;
      end
      i = find(~isnan(dods_colors));
      if any(dods_colors(i) < 0) | any(dods_colors(i) > 1)
	dods_colors = default_colors;
      end
    end
    if nargout > 0
      clear_button = dods_colors;
    end
    return

  case 'getdata'
    % set getxxx and archive files
    if ~isnan(dset) 
      if dset <= user_num_sets
	getxxx = userlist(dset).getxxx;
	archive = deblank(userlist(dset).archive);
	URLinfo = userlist(dset).URLinfo;
      else
	str = 'Selected dataset is not valid';
	dodsmsg(popup,str)
	return
      end
    end
    % set the getvariables
    if all(~isnan(var))
      if all(var <= user_num_vars)
	get_variables = user_variables(var,:);
      else
	str = 'Some of selected variables are not valid.';
	dodsmsg(popup,str)
	return
      end
    else
      get_variables = [];
    end

    if nargin == 2 % grab cancellations from big datasize first
      if strcmp(arg2,'cancel')
	set(gui_buttons(22:25),'units','pixels','visible','off')
	set(gui_buttons(1),'backgroundcolor',dods_colors(7,:))
	set(gui_buttons(26:28),'visible','off'); drawnow
	set(ui_clear,'enable','on')
	return
      else
	set(gui_buttons(22:25),'units','pixels','visible','off'); drawnow
      end
    end
    
    if nargin == 1
      if (sum(num_rang) < 8)
	str = sprintf('%s%s', ...
	    'Please select geographic and time ranges ', ...
	    'with the ''set data range'' functions');
	dodsmsg(popup,str)
	return
      elseif isnan(dset) 
	str = 'Please select a data set from the pulldown list.';
	dodsmsg(popup,str)
	return
      elseif isnan(var)
	str = 'Please select some variables from the pulldown list.';
	dodsmsg(popup,str)
	return
      else
	if ~isnan(userlist(dset).resolution) & isempty(dset_stride)
	  str = 'Please select a resolution';
	  dodsmsg(popup,str)
	  return
	end
      end

      if (exist('loaddods') ~= 3) & (exist('loaddods') ~= 2)
	str = sprintf('%s\n%s', ...
	    'Unable to find the loaddods MEX-file', ...
	    'Please make sure it is in your Matlabpath');
	dodsmsg(popup,str)
	set(gui_buttons(1),'backgroundcolor',dods_colors(7,:))
	return
      end

      % a final check -- is this a valid request, given the dataset range?
      if ranges(1,1) > ranges(1,2)
	tmpranges = [ranges(1,1)-360 ranges(1,2); ranges(2:4,:)];
      else
	tmpranges = ranges;
      end

      datamin = tmpranges(2:4,1)' > [userlist(dset).rangemax(2:4)];
      datamax = tmpranges(2:4,2)' < [userlist(dset).rangemin(2:4)];
      [datamin, datamax] = get_lon_rng( tmpranges, lonmin(dset), lonmax(dset), datamin, datamax);

      d = ~(any(datamin')' | any(datamax')');
      if ~d
	dset = nan;
	dscrolllist('datset','full')
	str = 'Dataset out of range';
	dodsmsg(popup,str)
	return
      end
      
      % check for getxxx file
      if exist(getxxx) ~= 2
        str = sprintf('Error! Cannot find your ''%s'' function.',getxxx);
	dodsmsg(popup,str)
	return
      end
      
      % check for the archive.m file
      isarch = browse('checkarchive');
      if ~isarch
	return
      end
          
      % turn off all data range selection
      select(0);
      set(gui_buttons(3),'backgroundcolor',dods_colors(1,:))
      % turn off the zoom feature
      set(gui_buttons(5),'backgroundcolor',dods_colors(1,:))
      set(0,'currentfigure',browse_fig)
      subplot(AXES(1)); newzoom off; subplot(AXES(2)); newzoom off; 
      subplot(AXES(3)); newzoom off; 

      % GET THE SIZE OF THE REQUEST -- the getfunction in 'datasize'
      % mode will check if the catalog is current and will call
      % the catalogue server (anew) if needed
      set(gui_buttons(1),'backgroundcolor',dods_colors(9,:))
      set(gui_buttons(26:27),'visible','on'); drawnow
      eval(sprintf('[datasize, nurls, urlinfo] = %s(''datasize'', %s);', ...
	  getxxx, [get_inputstring, ',', 'URLinfo']));
      % Save urlinfo if it has changed - this was added to make
      % sure that the URLinfo is updated when a getdata call is
      % made but a catalog request which normally writes this
      % information out has not yet been performed.
      if ~isequal(urlinfo, URLinfo)
	if ~isempty(urlinfo)
	  userlist(dset).URLinfo = urlinfo;
	  % first save the user bookmarks
	  listedit('fsave', userlist, user_variables)
	end
      end

      if isempty(datasize)
	datasize = 0;
      end
      if ~isempty(nurls)
	num_urls = nurls;
      else
	num_urls = 0;
      end
      set(gui_buttons(53),'string',sprintf('%i',num_urls)); drawnow

      callbackstring = sprintf('[%s] = browse(''getdata'',''ok''); unpack', ...
	  returnstring);
      % gui_buttons(24) is the 'ok' button on the size warning message
      set(gui_buttons(24), 'callback',callbackstring)
      % REMEMBER: MUST ISSUE NEW CALLBACK ARGOUTS AFTER 
      % HAVING RE-ISSUED REQUEST FOR DATA
      check_level = get(gui_buttons(23),'userdata');
      if datasize > check_level
	% HERE
        string = sprintf('%s%i%s\n%s%g%s\n%s%g%s\n%s', ...
	    ' WARNING: These ', nurls, ' dataset(s) take up', ...
	    ' a total of ', datasize, ' Mb, and your maximum ', ...
	    ' transfer threshold is set to: ', check_level, ...
	    ' Mb.',  ...
	    ' Would you still like to transfer the data?');
	set(gui_buttons(23),'string',string)
	set(gui_buttons(22:25),'units','pixels','visible','on', ...
	    'interruptible', 'on');
	return
      end
    end  %end of 'if nargin == 1'

    % if we are here, it is a small enough dataset or we said 'ok'
    % abort if there is nothing to get

    if num_urls == 0
      % reset button callbacks and buttons
      callbackstring = sprintf('[%s] = browse(''getdata''); unpack', ...
	  returnstring);
      set(gui_buttons(1),'callback', callbackstring, ...
	  'backgroundcolor',dods_colors(7,:))
      callbackstring = sprintf('[%s] = browse(''getdata'',''ok''); unpack', ...
	  returnstring);
      set(gui_buttons(24), 'callback',callbackstring)
      callbackstring = sprintf('browse(''getdata'',''cancel''); clear %s', ...
	  returnstring);
      set(gui_buttons(25),'callback',callbackstring)
      set(gui_buttons(26:28),'visible','off')
      set(ui_display,'enable','on')
      brs_old_dset = dset;
      brs_old_var = var;
      prev_num_urls = num_urls;
      str = 'You have not selected any data to get!';
      dodsmsg(popup,str)
      return
    end

    % >>>>>>>>   GET THE DATA   <<<<<<<<<<<

    % check for the archive.m file
    isarch = browse('checkarchive');
    if ~isarch
      return
    else
      eval(archive)
    end
    
    % set output arguments that are info contained in browser
    clear_button = ui_clear;
    % set output arguments that are info from archive.m file
    %depth_name = DepthName;
% see if depth_name is used anywhere?  I think not.
depth_name = 'youareinsane';
    url_count = requestnumber;
    % get the data
    image_string = [];
%    sizes = []; data = []; names = []; urls = []; index = [];
    set(gui_buttons(28),'value',0); button_value = 0;
    set(gui_buttons(26:28),'visible','on')
    set(gui_buttons(53),'string',sprintf('%i',num_urls))
    errquit = 0;

    if all(~isnan(var))
      get_variables = user_variables(var,:);
    else
      get_variables = [];
    end

    for j = 1:num_urls
      % here we actually issue the data request and deref the URL
      string = 'tmpurl, tmperr, tmpmsg';
      eval(sprintf('[%s] = %s(''get'', %s, %i, URLinfo);', string, ...
	  getxxx, get_inputstring, j));
      if ~isempty(tmpurl)
	set(gui_buttons(2),'string',tmpurl); drawnow
      end

      % catch errors first!
      if tmperr
        str = sprintf('%s\n', tmpmsg, 'Error response: Quit now?');
	if run_test
          disp(' ')
          disp([' Error acquiring data in ' test_archive_name])         
	  disp(' ')
	  disp(tmpmsg)
	  disp(' ')
          errquit = 1;
        else
          quitnow = dodsquestdlg(str, 'DODS ERROR', ...
	  'Yes', 'No (resume)', 'Yes', dods_colors([6 1],:));
          if strcmp(quitnow(1:2),'Ye')
	    errquit = 1;
          else
	    errquit = 0;
          end
        end
      end

      % if user wanted to quit due to error, DO SO NOW
      if errquit
	j = j - 1;
	break
      else
	% only if the user went ahead do we get acknowledgements
	eval(sprintf('getack(%s);', ...
	    [get_inputstring, ', 0, browse_version']));
      end

      % LOOK FOR A CALL TO ABORT from red "cancel" button
      pause(1)
      button_value = get(gui_buttons(28),'value');
      if button_value
	set(gui_buttons(53),'string',sprintf(' %i',j))
	break
      end
      % advance the count
      count = requestnumber;
      requestnumber(count+1);
    end % end of num_urls loop
    
    % set number of acquired urls.
    acq_urls = j;

    % HERE
%    str = sprintf('\n%s', ...
%	'   ..... data transfer complete');
%    dodsmsg(popup,str)
    refresh(browse_fig)
    % upload color palette w/corrected backgroundcolor
    palette = avhrrpal;

    % reset button callbacks and buttons
    callbackstring = sprintf('[%s] = browse(''getdata''); unpack', ...
	returnstring);
    set(gui_buttons(1),'callback', callbackstring, ...
	'backgroundcolor',dods_colors(7,:))
    callbackstring = sprintf('[%s] = browse(''getdata'',''ok''); unpack', ...
	returnstring);
    set(gui_buttons(24), 'callback',callbackstring)
    callbackstring = sprintf('browse(''getdata'',''cancel''); clear %s', ...
	returnstring);
    set(gui_buttons(25),'callback',callbackstring)
    set(gui_buttons(26:28),'visible','off')
    set(ui_display,'enable','on')
    
    % set internal history keepers
    brs_old_dset = dset;
    brs_old_var = var;
    prev_num_urls = num_urls;
    
    browse_get_variables = get_variables;
    browse_metadata = userlist(dset).URLinfo;
    set(ui_display, 'enable', 'on')

    % Added by PCC 4/1/02 for test runs.
    if set_up_test
      test_name = [test_archive_name '_data'];
      evalin('base', ['clear rlist;', ...
                      'global rlist;', ...
                      'rlist = who(''R*'');'])
      global rlist
      nlist = [];
      for itest=1:length(rlist)
        nn = length(rlist{itest});
        xlist = ['T' rlist{itest}(2:nn)];
        evalin('base',[ xlist '=' rlist{itest} ';'])
        nlist = [nlist ' ' xlist];
      end
      evalin('base', ...
        ['save ' dodsdir 'testsuite' dirsep test_name nlist])
    end

    return

  case 'getfigno'
    if nargout > 0
      clear_button = browse_fig;
    end
    return
    
  case 'getfigpos'
    % figsizes(1,:) is the browser
    % figsizes(2,:) is the color chooser
    % figsizes(3,:) is the display menu
    % figsizes(4,:) is the dataset scrolllist
    % figsizes(5,:) is the dataset edit figure
    % figsizes(6,:) is the master list
    % figsizes(7,:) is the properties edit figure
    % figsizes(8,:) is the variables list
    fig_sizes(1,:) = get(browse_fig,'position');
    fig_sizes(2,:) = choosecolor('getfigpos');
    fig_sizes(3,:) = dispmenu('getfigpos');
    fig_sizes(4,:) = dscrolllist('getfigpos');
    fig_sizes(5,:) = listedit('getfigpos');
    fig_sizes(6,:) = mastershow('getfigpos');
    fig_sizes(7,:) = dodspropedit('getfigpos');
    fig_sizes(8,:) = vscrolllist('getfigpos');
    figsizes = ((fig_sizes(:,3) > 0 & fig_sizes(:,4) > 0) ...
	* ones(1,4)) .* fig_sizes + ...
	((fig_sizes(:,3) <= 0 | fig_sizes(:,4) <= 0) * ones(1,4)) ...
    .* figsizes;
    if nargout > 0
      clear_button = figsizes;
    end
    return
    
  case 'getfontsize'
    if isempty(fontsize)
      fontsize = 10;
    else
      if fontsize <= 0
	fontsize = 10;
      end
    end
    if nargout > 0
      clear_button = fontsize;
    end
    return
    
  case 'getvar'
    if nargout > 0
      eval([ 'clear_button = ' arg2 ';'])
    end
    return
    
  case 'gsetrange'
    % remove text from num_urls & URL edit line
    % after something has changed (a dataset, a range)
    set(gui_buttons(2),'string','')
    set(gui_buttons(53),'string','')
    % remove 'transferring data' warning
    set(gui_buttons(26:28),'visible','off')
    % reset display menu 'ok' button callback
    callbackstring = sprintf('[%s] = browse(''getdata''); unpack', ...
	returnstring);
    % only set the returnstring if everything is ready to go
    if sum(num_rang) == 8 & ~isnan(dset) & all(~isnan(var))
      set(gui_buttons(1),'callback',callbackstring)
    end
    set(gui_buttons(1), ...
	'foregroundcolor',dods_colors(6,:), ...
	'backgroundcolor', dods_colors(7,:))
    return
  
  case 'guiserver'
    if ~isempty(arg2)
      if isstr(arg2)
	guiserver = arg2;
      else
	guiserver = master_guiserver;
      end
    else
      guiserver = master_guiserver;
    end
    set(prefs(9), 'tag', guiserver);
    return
    
  case 'guiserverdlg'
    guiserver = get(prefs(9),'tag');
    answer = inputdlg('change GUI server:', ...
	'DODS Browse: change GUI server', 1, {guiserver});
      if ~isempty(answer)
	answer = char(answer);
	browse('guiserver',answer)
      end
    return
    
  case 'listpalettes'
    % enable only for matlab 5
    if isempty(dodsdir)
      dir = which('browse');
%      dirsep = '/';     Moved outside of main loop, should not be needed.
%      c = computer;
%      if strcmp(c(1:2),'PC')
%	dirsep = '\';
%      elseif strcmp(c(1:2),'MA')
%	dirsep = ':';
%      end
      i = max(findstr(dir,dirsep));
      dodsdir = dir(1:i);
      dodsdir = ['''' dodsdir ''''];
    end
    [file, dir] = uigetfile([dodsdir '*.pal'],'Load Palette File');
    file = [dir file];
    if file > 0 & isstr(file)
      browse('paletteswap',file)
    end
    
  case 'loaddlg'
    fname = 'browsopt.m';
    if exist(fname) ~= 2
      % there are no saved options in a default filename
      % user must supply a filename
      fname = '';
    end
    answer = inputdlg(sprintf('%s\n%s', ...
	'Load preferences from m-file: (this file MUST be', ...
	'in your Matlabpath)'), ...
	'DODS Browse: load preferences', 1, {fname});
    if ~isempty(answer)
      answer = char(answer);
      browse('loadopts',answer)
    end
    return

  case 'loadopts'
%    fname = deblank(arg2);  Blanks are allowed IN the name on PC 
    fname = arg2;
    while fname(1) == ' '    % Get rid of blanks at beginning of fname
      tname = fname; clear fname
      fname = tname(2:length(fname));
    end
    while fname(length(fname)) == ' '  % Get rid of blanks at end of fname
      tname = fname; clear fname
      fname = tname(1:length(fname)-1);
    end
    l = length(fname);
    if l > 1
      % strip off '.m' if there is one
      if strcmp(fname(l-1:l),'.m')
	fname = fname(1:l-2);
      end
    end
%    dirsep = '/';    Moved outside of main loop. Should not be needed.
%    c = computer;
%    if strcmp(c(1:2),'PC')
%      dirsep = '\';
%    elseif strcmp(c(1:2),'MA')
%      dirsep = ':';
%    end
    if any(findstr(fname,dirsep))
      str = [ 'Error! Preferences file specification cannot ', ...
	    'contain any directory information!'];
      dodsmsg(popup,str)
      i = max(findstr(fname,dirsep));
      fname = fname(i+1:length(fname));
      if exist(fname) == 2
	s = which(fname);
	str = [ 'Evaluating and loading preferences file on your path: ' s];
	dodsmsg(popup,str)
      else
	str = [ 'No preferences files with that name found. Please ', ...
	      'check your Matlabpath and ', ...
	      'filename specfications.'];
	dodsmsg(popup,str)
	return
      end
    else % no directory info was included
      if exist(fname) == 2
	s = which(fname);
	str = [ 'loading saved preferences file ' s];
	dodsmsg(popup,str)
      else
	str = [ 'Preferences file not found. Please check path and ', ...
	      'filename specfications.'];
	dodsmsg(popup,str)
	return
      end
    end

    % first preserve some values in case the options file is buggy
    old_axes_vals = axes_vals;
    old_ranges = ranges;
    old_manURL = manURL;
    old_dods_colors = dods_colors;
    old_num_rang = num_rang;
    old_timetoggle = str2num(get(AXES(3),'tag'));
    old_available_resolutions = available_resolutions;
    old_check_level = get(gui_buttons(23),'userdata');
    old_figsizes = browse('getfigpos');

    % now load the new options
    eval(fname)

    % Set Location of HTML documentation
    if isempty(deblank(manURL))
      manURL = 'http://www.unidata.ucar.edu/packages/dods/user/mgui-html/mgui.html';
    else
      manURL = old_manURL;
    end
    [docu, options] = docopt;
    callbackstring = sprintf('!%s %s %s &', docu, options, manURL);
    set(ui_manual, 'callback', callbackstring);
    
    % color scheme
    if ~isempty(dods_colors) 
      if all(size(dods_colors) == [10 3]) & ...
	    all(dods_colors >= 0) & all(dods_colors <= 1)
	% do nothing, we're fine
      else
	dods_colors = old_dods_colors;
      end
    else
      dods_colors = old_dods_colors;
    end
    % set the dodscolors
    browse('changecolor')

    if ~isempty(num_rang)
      if all(size(num_rang(:)) == [8 1]) & ...
	    all ((num_rang == 0) | (num_rang == 1))
	% we're fine, do nothing
      else
	num_rang = old_num_rang;
      end
    else
      num_rang = old_num_rang;
    end

    % relative ranges & vars: these will vary
    if isempty(ranges) 
      ranges = old_ranges;
    end
    
    % axis values
    if ~isempty(axes_vals)
      if all(size(axes_vals) == [1 8])
	% now check to make sure limits are valid
	if axes_vals(2) >= axes_vals(1) & ...
	      axes_vals(4) >= axes_vals(3) & ...
	      axes_vals(6) >= axes_vals(5) & ...
	      axes_vals(8) >= axes_vals(7)
	  % we're fine
	else
	  axes_vals = old_axes_vals;
	end
      else
	axes_vals = old_axes_vals;
      end
    else
      axes_vals = old_axes_vals;
    end
    % now set longitude to match axes vals
    % this should take care of master_georange,
    % ranges, and the map
    if any(axes_vals(1:2) > 180)
      browse('setlon',360)
    else
      browse('setlon',0);
    end
    set(0,'currentfigure',browse_fig)
    set(AXES(1), 'xlim', axes_vals(1:2), 'ylim', axes_vals(3:4), ...
	'PlotBoxAspectRatio', [diff(axes_vals(1:2)) ...
	  diff(axes_vals(3:4)) 1], 'DataAspectRatio', ...
	[1 1 1])
    set(AXES(2), 'xlim', [0 1], 'ylim', axes_vals(5:6))
    set(AXES(3), 'xlim', axes_vals(7:8), 'ylim', [0 1])
    
    if ~isempty(timetoggle)
      if timetoggle == 0 | timetoggle == 1
	% we're fine, do nothing
      else
	timetoggle = old_timetoggle; 
      end
    else
      timetoggle = old_timetoggle; 
    end
    set(AXES(3),'tag',num2str(timetoggle))
    % reset the timelabel
    browse('timetoggle',timetoggle)
  
    if ~isempty(fontsize)
      if fontsize >= 10 & fontsize <= 16 & fontsize == round(fontsize) 
	%we're fine, do nothing
      else
	fontsize = old_fontsize;
      end
    else
      fontsize = old_fontsize;
    end
    % set the fontsize
    browse('fontsize',fontsize)
  
    if ~isempty(available_resolutions)
      if all(available_resolutions == round(available_resolutions)) & ...
	    all(available_resolutions == abs(available_resolutions))
	%we're fine, do nothing
      else  
	available_resolutions = old_available_resolutions;
      end
    else
      available_resolutions = old_available_resolutions;
    end
    
    if ~isempty(figsizes)
      if all(size(figsizes) == [8 4]) & all(figsizes(3:4) > 0)
      else
	figsizes = old_figsizes;
      end
    else
      figsizes = old_figsizes;
    end
    % set the figure sizes and locations
    browse('setfigpos')
    
    % MUST RESTORE SELECTED DATASET AND VAR HERE!
    % must do after resize command ...
    if ~isnan(dset)
      dscrolllist('dselect', dset)
      dscrolllist('specialselect')
    end

    % for these last two, nothing further need be done
    if isempty(check_level)
      check_level = old_check_level;
    end
    set(gui_buttons(23),'userdata',check_level)
  
    % Dods messages to workspace or popup window
    if exist('message_prefs') == 1
      if strcmp(message_prefs,'popup')
	popup = 1;
      elseif strcmp(message_prefs,'workspace')
	popup = 0;
      else % default to popup
	popup = 1;
      end
    else % default to popup
      popup = 1;
    end

    % END OF OPTIONS THAT MAY BE SET IN BROWSOPT.M
  
    % now we need to: 
    % set the help manual location
    % set the resolutions menu
    % set the figure sizes and locations
    % set the font size
    % refresh the figure with new dodscolors
    % reset the time labels
    % set the axes
    % set the color limits
    % refresh the figure with a new palette
    
    % clear URL count and URL string
    browse('gsetrange')

    % set up the new palette
    if ~isempty(palettefile)
      nn = find(palettefile~='''');
      palettefilenq = palettefile(nn);
      if exist(palettefilenq) == 2
	browse('paletteswap')
      end
    end
    return
    
  case 'mkusermats'
    % make up the global user matrices
    [user_dataprops, lonmin, lonmax] = mkusermats(userlist);

  case 'moreon'
    num_plots = arg2;
    if num_plots > 1
      set(gui_buttons(6),'visible','on','userdata','more images')
    elseif ~isempty(image_string)
      if length(image_string) == (image_string(1)+1)
	set(gui_buttons(6),'visible','off','userdata','')
      end
    end
    return
  
  case 'newboxes'
    set(0,'currentfigure',browse_fig)
    subplot(AXES(1)); 
    % delete current range box and worldmap
    if range_boxes(1) > 0
      delete(range_boxes(1))
    end
    if ~isempty(worldmap)
      delete(worldmap)
    end
    
    % reset worldmap
    if master_georange(1) == 0;
      offset = 360;
    else
      offset = 0;
    end
    if isempty(dodsdir)
      dir = which('browse');
%      dirsep = '/';    Moved out of main loop, should no longer be needed.
%      c = computer;
%      if strcmp(c(1:2),'PC')
%	dirsep = '\';
%      elseif strcmp(c(1:2),'MA')
%	dirsep = ':';
%      end
      i = max(findstr(dir,dirsep));
      dodsdir = dir(1:i);
      dodsdir = ['''' dodsdir ''''];
    end
    fname = [dodsdir 'coastln'];
    eval(['load ' fname])
    x = coastlines(1,:); 
    x(coastinx) = x(coastinx)+offset;
    worldmap = line(x,coastlines(2,:), ...
	'Color',dods_colors(3,:), ...
	'Erasemode','none','visible','off', ...
	'linewidth',0.5,'linestyle','-'); drawnow
    if strcmp(get(gui_buttons(30),'string'),'View Text')
      set(worldmap,'visible','on')
    end
    clear coastlines
    % set x-range: THIS IS A MESS AND NEEDS TO BE FIXED UP
    % less of a mess as of 98/04/20 
    xl = ranges(1,:);
    xl = xrange('range', master_georange, ranges(1,:));
    if max(size(xl) > 2)
       xl = nan*ones(1,8);
    else
      xl = [xl(1:2) xl(2) xl(2) xl(2) xl(1) xl(1) xl(1)];
    end
    
    yl = [ranges(2,1) ranges(2,1) ranges(2,1) ranges(2,2) ...
	  ranges(2,2) ranges(2,2) ranges(2,2) ranges(2,1)];
    range_boxes(1) = line(xl, yl,'color',dods_colors(10,:), ...
	'visible','off', 'linewidth', 2);
    if strcmp(get(gui_buttons(30),'string'),'View Text')
      set(range_boxes(1),'visible','on')
    end

    if ~isempty(image_string)
      if strcmp(get(gui_buttons(30),'string'),'View Text')
	% reveal current images
	set(image_string(2:image_string(1)+1),'visible','on')
	
	% set colorbar if necessary
	if strcmp(get(image_string(2),'type'),'image') | ...
	      strcmp(get(image_string(2),'type'),'surface') | ...
	      strcmp(get(image_string(2),'type'),'patch')
	  clim = get(image_string(2),'userdata');
	  if ~isempty(clim)
	    set(AXES(1),'clim', clim);
	  end
	  colorbar; cbarhandle = findobj(AXES(4),'type','image');
	  set(AXES(4), 'color',dods_colors(2,:), ...
	      'xcolor',dods_colors(3,:), ...
	      'ycolor',dods_colors(3,:), ...
	      'visible','on');
	else
	  set([AXES(4) cbarhandle], 'vis','off')
	end
	
      end
    end
    return
    
  case 'newplot'
    % this keeps a list of image handles
    image_string = [image_string; size(arg2,1); arg2(:)];
    return
    
  case 'newselections'
    % reset the list of new datasets
    selected_datasets = zeros(size(userlist,1),1);
    return
    
  case 'nextplot'
    if length(image_string) > 0
      delete(image_string(2:image_string(1)+1));
      k = image_string(1)+1;
      if length(image_string) > k
	kk = k+1;
	l = image_string(k+1);
	% reveal current images
	set(image_string(kk+1:kk+l),'visible','on');
	
	% set the colorbar
	if strcmp(get(image_string(kk+1),'type'),'image') | ...
	      strcmp(get(image_string(kk+1),'type'),'surface') | ...
	      strcmp(get(image_string(kk+1),'type'),'patch')
	  clim = get(image_string(kk+1),'userdata');
	  if ~isempty(clim)
	    set(AXES(1),'clim',clim);
	  end
	  % in case user has zoomed in or out, re-focus on geo axis
	  subplot(AXES(1))
	  colorbar; cbarhandle = findobj(AXES(4),'type','image');
	  set(AXES(4), 'color',dods_colors(2,:), ...
	      'xcolor',dods_colors(3,:), ...
	      'ycolor',dods_colors(3,:), ...
	      'visible','on');
	else
	  set([AXES(4) cbarhandle],'vis','off')
	end
	image_string = image_string(kk:size(image_string,1),:);
	set(gui_buttons(6),'userdata','more images')
      end
      if length(image_string) == (image_string(1)+1)
	set(gui_buttons(6),'visible','off','userdata','')
      end
    else
      set(gui_buttons(6),'visible','off','userdata','')
    end
    return
    
  case 'oops!'
    set(gui_buttons(26:28),'visible','off')
    set(gui_buttons(1),'backgroundcolor',dods_colors(7,:))
    set(gui_buttons(59),'backgroundcolor',dods_colors(7,:)+[0.3 0.2 0])
    return
    
  case 'palettedlg'
      answer = inputdlg('Load palette file:', ...
	  'DODS Browse: load palette', 1, {palettefile});
      if ~isempty(answer)
	answer = char(answer);
	browse('paletteswap',answer)
      end
    return
    
  case 'paletteswap'
    if nargin == 2
      palettefile = arg2;
    end
    % load palette file
    avhrrpal = []; i = []; j = [];
    if ~isempty(palettefile)
%      dirsep = '/';    Moved out of main loop. Should no longer be needed.
%      c = computer;
%      if strcmp(c(1:2),'PC')
%	dirsep = '\';
%      elseif strcmp(c(1:2),'MA')
%	dirsep = ':';
%      end
      nn = find(palettefile~='''');
      palettefilenq = palettefile(nn);
      i = max(findstr(palettefilenq,dirsep))+1;
      if isempty(i)
	i = 1;
      end
      j = max(findstr(palettefilenq,'.'))-1;  
      if isempty(j)
	j = length(palettefilenq);
      end
      if exist(palettefilenq) == 2
	eval(['load ' palettefile])
	eval(['avhrrpal = ' palettefilenq(i:j) ';'])
      else
	str = 'Not able to load requested palettefile!';
	dodsmsg(popup,str)
	dir = which('browse');
	l = findstr(dir,'browse.m')-1;
	dir = dir(1:l);
        dir = ['''' dir ''''];
	palettefile = [dir 'avhrrpal.pal'];
	eval(['load ' palettefile])
      end
    else % set the default palettefile
      dir = which('browse');
      l = findstr(dir,'browse.m')-1;
      dir = dir(1:l);
      dir = ['''' dir ''''];
      palettefile = [dir 'avhrrpal.pal'];
      eval(['load ' palettefile])
    end
    avhrrpal(1,:) = dods_colors(2,:);
    % THIS IS A NEW AS OF 98/09/13 -- dbyrne
    if ~isempty(browse_fig)
      c1 = get(browse_fig,'colormap');
      c1 = size(c1,1);
      set(browse_fig,'colormap',avhrrpal)
      c2 = size(avhrrpal,1);
      % if the size of the color palettes is different,
      % rescale any images on the geographic window 
      if c1 ~= c2
	k = findobj(AXES(1), 'type', 'image');
	k = [k; findobj(AXES(1), 'type', 'surface')];
	k = [k; findobj(AXES(1), 'type', 'patch')];
	for i = 1:length(k)
	  x = get(k(i),'cdata');
	  x = x*c2/c1;  
	  set(k(i),'cdata',x)
	end
      end
    end
    % END OF NEW PART
    return
    
  case  'popupvalue'
    if nargin == 1
      % it's a query for the current value
      if nargout > 0
	clear_button = popup;
      end
    elseif nargin == 2
      % toggle the value of popup
      if strcmp(get(prefs(1),'label'), 'Messages to Workspace')
	popup = 0;
	label = 'Messages to Pop-up Window';
      else
	popup = 1;
	label = 'Messages to Workspace';
      end
      set(prefs(1),'label',label)
    end
    return
    
  case 'qlevel'
    check_level = get(gui_buttons(23),'userdata');
    set(gui_buttons([19:21 29]),'visible','on','units','pixels')
    set(gui_buttons(21),'string',sprintf('%g',check_level))
    return
    
  case 'quit'
    % FIGFLAG IS OBSOLETE.  REPLACE WITH FINDFIG!
    browse_figs = [];
    [flag, fig] = figflag('DODS Color Chooser',1);
    if flag
      browse_figs = [browse_figs fig];
    end
    [flag, fig] = figflag('DODS Variables',1);
    if flag
      browse_figs = [browse_figs fig];
    end
    [flag, fig] = figflag('DODS Browse Bookmarks',1);
    if flag
      browse_figs = [browse_figs fig];
    end
    [flag, fig] = figflag('DODS Master Bookmarks List',1);
    if flag
      browse_figs = [browse_figs fig];
    end
    [flag, fig] = figflag('Edit DODS Bookmarks',1);
    if flag
      browse_figs = [browse_figs fig];
    end
    [flag, fig] = figflag('DODS Bookmark Properties',1);
    if flag
      browse_figs = [browse_figs fig];
    end
    % get dispmenu figure
    [flag, fig] = figflag('Display acquired data',1);
    if flag
      browse_figs = [browse_figs fig];
    end
    % get message window
    [flag,fig] = figflag('DODS Browser Message',1);
    if flag
      browse_figs = [browse_figs fig];
    end
    % get browser window -- simple but pretty foolproof method.
    browse_figs = [browse_figs gcf];
    % set first return argument to be figures that we need to close
    if nargout > 0
      clear_button = browse_figs;
    end
    return
    
  case 'resetcount'
    evalin('base','clear R*_* URLlist');
    
    requestnumber(1);
    % turn off the 'clear all Rxx button'
    set(ui_clear,'enable','off');
    set(ui_display,'enable','off')
    dispmenu('reset')

    % reset button callbacks and buttons
    if ~isnan(dset) & ~isnan(var) & sum(num_rang) == 8
      callbackstring = sprintf('[%s] = browse(''getdata''); unpack', ...
	  returnstring);
      set(gui_buttons(1),'callback', callbackstring, ...
	  'backgroundcolor',dods_colors(7,:))
      callbackstring = sprintf('[%s] = browse(''getdata'',''ok''); unpack', ...
	  returnstring);
      set(gui_buttons(24), 'callback',callbackstring)

      callbackstring = sprintf('browse(''getdata'',''cancel''); clear %s', ...
	  returnstring);
      set(gui_buttons(25),'callback',callbackstring)
    else
      set(gui_buttons(1),'callback','browse(''getdata'')')
    end
    return
    
  case 'resetdefault'
    dset = nan; var = nan;
    % figure size and position
    figsizes = zeros(8,4);
    browse('setfigpos')

    % resolution
    available_resolutions = [32 24 16 12 8 4 3 2 1];
    
    % master ranges
    master_georange = [-180 180 -90 90]; % W E S N
    rangemin = cat(1,userlist(:).rangemin);
    rangemax = cat(1,userlist(:).rangemax);
    z1 = min(rangemin(:,3));
    z2 = max(rangemax(:,3));
    zrange = [z1-50 z2+50];
    t1 = min(rangemin(:,4));
    t2 = max(rangemax(:,4));
    timerange = [t1-10 t2+10];
    
    % font
    fontsize = 10;
    browse('fontsize',fontsize)

    % the color scheme
    browse('setdefaultcolors')
    browse('changecolor')
    
    % the time
    timetoggle = 1;
    set(prefs(4),'label','Time in Year/Yearday', ...
	'callback','browse(''timetoggle'',0)');
    browse('timetoggle',1)

    % selection ranges
    num_rang = zeros(8,1);
    ranges = nan*ones(4,2);
    
    % dataset and variable and lists
    dscrolllist('dreset')
    vscrolllist('vreset')
    
    % AXIS LIMITS
    axes_vals = [master_georange(1:2)+[-5 5] master_georange(3:4)+[-1 1] ...
	    zrange timerange];

    % Geographic axis
    set(get(AXES(1),'zlabel'),'userdata',axes_vals(1:4))
    set(AXES(1), 'xlim', axes_vals(1:2), 'ylim', axes_vals(3:4))

    % the longitude (includes aspect ratio)
    browse('setlon',0)
    
    % Depth axis
    set(get(AXES(2),'zlabel'),'userdata',[0 1 axes_vals(5:6)])
    set(AXES(2), 'xlim', [0 1], 'ylim', axes_vals(5:6))
    set(get(AXES(2),'ylabel'),'string','')
    kids = get(AXES(2),'children');
    i = find(kids ~= range_boxes(2));
    delete(kids(i)); 
    xl = [0.01 0.99];
    set(range_boxes(2),'xdata',[xl(1:2) xl(2) xl(2) xl(2) xl(1) xl(1) xl(1)], ...
	'ydata', [ranges(3,1) ranges(3,1) ranges(3,1) ranges(3,2) ...
	    ranges(3,2) ranges(3,2) ranges(3,2) ranges(3,1)], ...
	'visible','on')

    % Time axis
    set(get(AXES(3),'zlabel'),'userdata',[axes_vals(7:8) 0 1])
    set(AXES(3),'xlim', axes_vals(7:8),'ylim',[0 1], ...
	'xtickmode','auto','xticklabelmode','auto', 'tag', num2str(1))
    set(tstring(1),'string','Time in Years','color',dods_colors(3,:))
    set(tstring(2),'string','1 JAN 1800','color',dods_colors(8,:))

    % clear old labels and dataset plots
    if ~isempty(thandle), delete(thandle); thandle = []; end
    if ~isempty(lhandle), delete(lhandle); lhandle = []; end
    kids = get(AXES(3),'children');
    for i = 1:length(kids)
      if ~any(kids(i) == [range_boxes(3); tstring(:)])
	delete(kids(i));
      end
    end

    % check_level is 1Mb
    check_level = 1;
    set(gui_buttons(23),'userdata',check_level);

    % palettefile is avhrr
    dir = which('browse');
%    dirsep = '/';    Moved out of main loop. Should no longer be needed.
%    c = computer;
%    if strcmp(c(1:2),'PC')
%      dirsep = '\';
%    elseif strcmp(c(1:2),'MA')
%      dirsep = ':';
%    end
    i = max(findstr(dir,dirsep));
    dodsdir = dir(1:i);
    dodsdir = ['''' dodsdir ''''];
    palettefile = [dodsdir 'avhrrpal.pal'];
    browse('paletteswap')
    browse('setrangeboxes')
    browse('bsetrange')
    set(gui_buttons(39),'string','')
    refresh(browse_fig)

    manURL = ...
	'http://www.unidata.ucar.edu/packages/dods/user/mgui-html/mgui.html';
    set(prefs(9),'tag', master_guiserver);
    
    popup = 1;
    return
    
  case 'resolution'
    % set subsampling resolution, if possible
    dset_stride = available_resolutions(arg2);
    set(ui_stride(arg2),'checked','on')
    k = 1:length(available_resolutions);
    ii = find(k ~= arg2);
    set(ui_stride(ii),'checked','off')
    return
    
  case 'savedlg'
    if isempty(dodsdir)
      dir = which('browse');
%      dirsep = '/';    Moved out of main loop. Should no longer be needed.
%      c = computer;
%      if strcmp(c(1:2),'PC')
%	dirsep = '\';
%      elseif strcmp(c(1:2),'MA')
%	dirsep = ':';
%      end
      i = max(findstr(dir,dirsep));
      dodsdir = dir(1:i);
      dodsdir = ['''' dodsdir ''''];
    end
    fname = [dodsdir 'browsopt.m'];
    answer = inputdlg('Save preferences to m-file:', ...
	'DODS Browse: save preferences', 1, {fname});
      if ~isempty(answer)
	answer = char(answer);
	browse('saveopts',answer)
      end
    return
  case 'saveopts'
    % first save the user bookmarks
    listedit('fsave', userlist, user_variables)

    if nargin == 2
      fname = deblank(arg2);
    else
      % user clicked on 'save' not 'save as' ....
      if isempty(dodsdir)
	dir = which('browse');
%	dirsep = '/';    Moved out of main loop. Should no longer be needed.
%	c = computer;
%	if strcmp(c(1:2),'PC')
%	  dirsep = '\';
%	elseif strcmp(c(1:2),'MA')
%	  dirsep = ':';
%	end
	i = max(findstr(dir,dirsep));
	dodsdir = dir(1:i);
	dodsdir = ['''' dodsdir ''''];
      end
      fname = [dodsdir 'browsopt.m'];
    end
    
    if ~isempty(fname)
      % add a '.m' if necessary
      l = length(fname);
      if ~strcmp(fname(l-1:l),'.m')
	fname = [fname '.m'];
      end
      nn = find(fname~='''');
      fnamenq = fname(nn);
      fid = fopen(fnamenq,'w');
      if fid > -1
	% do save stuff (create browsopt.m)
	fprintf(fid,'%s\n','% DODS browse.m preferences file.  This is a matlab');
	fprintf(fid,'%s\n','% script file.  Customize by hand if you wish.');
        fprintf(fid,'\n');
	fprintf(fid,'%s\n', ...
	    '% Use popup messages or report to workspace window');
	if popup
	  message_prefs = 'popup';
	else
	  message_prefs = 'workspace';
	end
	fprintf(fid,'message_prefs = ''%s'';\n', message_prefs);
        fprintf(fid,'\n');
	fprintf(fid,'%s\n','% Year in YEAR/MONTH/DAY or YEAR/YEARDAY');
	timetoggle = str2num(get(AXES(3),'tag'));
	fprintf(fid,'%s%i%s\n','timetoggle = ',timetoggle,';');
        fprintf(fid,'\n');
	% make sure colors are ok
	browse('getcolors')
	fprintf(fid,'%s\n', ...
	    '% COLORS: the color scheme. See browse.m ''getcolors'' for color usage.');
	fprintf(fid,'%s\n','dods_colors = [');
	fprintf(fid,'%g %g %g;\n', dods_colors');
	fprintf(fid,'];\n');
        fprintf(fid,'\n');
        fprintf(fid,'%s%i%s\n', 'fontsize = ', fontsize, ';');
        fprintf(fid,'\n');
	figsizes = browse('getfigpos');
	fprintf(fid,'figsizes = [');
	fprintf(fid, '%i %i %i %i;\n', figsizes');
	fprintf(fid, '];\n');
        fprintf(fid,'\n');
	axes_vals = [get(AXES(1),'xlim') get(AXES(1),'ylim') ...
	      get(AXES(2),'ylim') get(AXES(3),'xlim')];
	if all(size(axes_vals) == [1 8])
	  fprintf(fid,'%s[%g %g %g %g %g %g %11.6f %11.6f];\n', ...
	      'axes_vals = ', axes_vals);
	else
	  % use defaults
	  fprintf(fid,'%s[%g %g %g %g %g %g %11.6f %11.6f];\n', ...
	      'axes_vals = ', [master_georange(1:2)+[-5 5] ...
		master_georange(3:4)+[-1 1] ...
		zrange timerange]);
	end
        fprintf(fid,'\n');
	fprintf(fid,'%s\n','% Selection ranges: Longitude, Latitude, Depth and Time');
	fprintf(fid,'%s\n','ranges = [');
	fprintf(fid,'%g %g\n',ranges');
	fprintf(fid,'%s\n','];');
        fprintf(fid,'\n');
	fprintf(fid,'%s\n','% Which were user-set.');
	fprintf(fid,'%s','num_rang = [');
	fprintf(fid,'%g ',num_rang');
	fprintf(fid,'%s\n',']'';');
        fprintf(fid,'\n');
	fprintf(fid,'%s\n','% Dataset and Variable');
	fprintf(fid,'dset = [%i];\n', dset);
	fprintf(fid,'var = [');
	fprintf(fid,'%i ', var);
	fprintf(fid,'];\n');
	fprintf(fid,'\n');
        fprintf(fid, '%s\n', ...
	    '% PALETTE FILE -- 255-color default palette.  A 3-column array');
	fprintf(fid,'%s\n','% of R G B values.  Values must lie between 0 and 1.');
        nn = find(palettefile == '''');
        jjpp = 0;
        for iipp=1:length(palettefile)
          jjpp = jjpp + 1;
          palettefile2q(jjpp) = palettefile(iipp); 
          if palettefile(iipp) == ''''
            jjpp = jjpp + 1;
            palettefile2q(jjpp) = palettefile(iipp); 
          end
        end
	fprintf(fid,'%s%s%s\n', 'palettefile = ''', palettefile2q, ''';');
        fprintf(fid,'\n');
	fprintf(fid,'%s\n', ...
	    '% Threshold size in Mb of largest dataset to download automatically.');
	check_level = get(gui_buttons(23),'userdata');
	fprintf(fid,'%s%g%s\n', 'check_level = ', check_level, ';');
        fprintf(fid,'\n');
	fprintf(fid,'%s\n', ...
	    '% Available resolutions in multiples of the dataset stride.');
	fprintf(fid,'%s', 'available_resolutions = [');
	fprintf(fid,'%g ',available_resolutions);
	fprintf(fid,'%s\n', '];');
	fprintf(fid,'\n');
	fprintf(fid,'%s\n', ...
	    '% The location of the HTML version of the GUI user manual.');
	fprintf(fid,'manURL = ''%s'';\n', manURL);
        fprintf(fid,'\n');
	fprintf(fid,'%s\n', ...
	    '% The location of the preferred GUI server for script updates.');
	guiserver = get(prefs(9),'tag');
	fprintf(fid,'guiserver = ''%s'';\n', guiserver);
        fprintf(fid,'\n');
	fprintf(fid,'%s\n', ...
	    '% The name/location of the user bookmarks file.');
        jjpp = 0;
        for iipp=1:length(userlist_file)
          jjpp = jjpp + 1;
          userlist_file2q(jjpp) = userlist_file(iipp); 
          if userlist_file(iipp) == ''''
            jjpp = jjpp + 1;
            userlist_file2q(jjpp) = userlist_file(iipp); 
          end
        end
	fprintf(fid,'userlist_file = ''%s'';\n', userlist_file2q);
        fprintf(fid,'\n');
	fclose(fid);
      else
	str = ['File ' fname ' unable to be opened. ', ...
		'Please check path and write permissions.'];
	  dodsmsg(popup,str)
	  %	errordlg(['File ' fname ' unable to be opened. ', ...
	  %		'Please check path and write permissions.'], ...
	  %	    'DODS browser: unable to save preferences');
      end
    end
    return
    
  case 'scrollfig'
    dscrolllist('showlist')
    vscrolllist('showlist')
    return
    
  case 'setcolor'
    whichcolor = arg2;
    newcolor = arg3;
    dods_colors(whichcolor,:) = newcolor;
    browse('changecolor')
    return
    
  case 'setdefaultcolors'
    % clear colors
    dods_colors = [];
    % force reload of default colors
    browse('getcolors')
    if nargout > 0
      clear_button = dods_colors;
    end
    return

  case 'setdset'
    % set current and previous datasets
    if isnan(dset)
      set(gui_buttons(1),'callback','browse(''getdata'')')
      set(gui_buttons(2),'string','')
      set(gui_buttons(53),'string','')
      set(gui_buttons(39),'string','')
      % NEW 
      set(gui_buttons(26:28),'visible','off')
      if ~isempty(ui_stride)
	for i = 1:length(ui_stride)
	  if any(findobj(ui_res,'type','uimenu') == ui_stride(i))
	    delete(ui_stride(i))
	  end
	end
      end
      return
    end

    % set and check for the archive.m file
    isarch = browse('checkarchive');
    if ~isarch
      dset = nan;
      set(gui_buttons(1),'callback','browse(''getdata'')')
      set(gui_buttons(2),'string','')
      set(gui_buttons(53),'string','')
      set(gui_buttons(39),'string','')
      set(get(AXES(2),'ylabel'),'string','')
      % THIS IS NEEDED ONLY IF WE FOLLOW THE POLICY OF UNSELECTING
      % ANY DATASET WITH UNAVAILABLE ARCHIVES.
      dscrolllist('datset','full')
      return
    else
      archive = deblank(userlist(dset).archive);
      eval(archive)
    end

    % pop up the data use policy if dataset not previously
    % selected this session
    if ~selected_datasets(dset)
      if exist('Data_Use_Policy') == 1
	if ~isempty(Data_Use_Policy)
	  dodsmsg(1,sprintf('%s\n%s','Data Use Policy: ', Data_Use_Policy))
	end
      end
      selected_datasets(dset) = 1;
    end
    % SET THE RESOLUTION MENU
    if ~isempty(ui_stride)
      for i = 1:length(ui_stride)
	if any(findobj(ui_res,'type','uimenu') == ui_stride(i))
	  delete(ui_stride(i))
	end
      end
    end
    if ~isnan(userlist(dset).resolution)
      l = length(available_resolutions);
      for i = 1:l
	res = available_resolutions(i);
	if exist('ResolutionUnits') == 1
	  str1 = sprintf('%4.1f %s', res*userlist(dset).resolution, ...
	      ResolutionUnits);
	else
	  str1 = sprintf('%4.1f km', res*userlist(dset).resolution);
	end
	str2 = sprintf('browse(''resolution'',%i)',i);
        ui_stride(i) = uimenu(ui_res,'label',str1,'callback',str2);
      end
      browse('resolution',l)
    end

    if brs_old_dset ~= dset
      set(gui_buttons(2),'string','');
      set(gui_buttons(53),'string','');
    end
    
    % set the metadata
    if exist('Comments') == 1
      set(gui_buttons(39),'string',Comments)
    else
      set(gui_buttons(39),'string','')
    end
    
    % set the depth axis
    if exist('DepthUnits') == 1
      set(get(AXES(2),'ylabel'),'string',DepthUnits)
    else
      set(get(AXES(2),'ylabel'),'string','')
    end

    if all(size(brs_old_var) == size(var))
      if all(brs_old_var ~= var)
	set(gui_buttons(2),'string','');
	set(gui_buttons(53),'string','');
      end
    end
    
    callbackstring = sprintf('browse(''getdata'',''cancel''); clear %s', ...
	returnstring);
    set(gui_buttons(25),'callback',callbackstring)
    callbackstring = sprintf('[%s] = browse(''getdata''); unpack', ...
	returnstring);
    if sum(num_rang) == 8 & sum(isnan(ranges)) == 0 & ~isnan(dset) & ...
	  all(~isnan(var))
      set(gui_buttons(1),'callback', callbackstring, ...
	  'backgroundcolor',dods_colors(7,:))
      callbackstring = sprintf('[%s] = browse(''getdata'',''ok''); unpack', ...
	  returnstring);
      set(gui_buttons(24), 'callback',callbackstring)
    else
      set(gui_buttons(1),'callback','browse(''getdata'')')
      set(gui_buttons(24),'callback','')
    end

    % set the user range selections
    if sum(num_rang(1:2)) == 0
      % SET USER X-RANGE
      x = xrange('range', master_georange, ...
	  [userlist(dset).rangemin(1) userlist(dset).rangemax(1)]);
      tmpx = xrange('range', [-180 180 -90 90], ...
	  [userlist(dset).rangemin(1) userlist(dset).rangemax(1)]);
      if max(size(x) == 2) % one-box mode
	if all(size(tmpx) == [1 2])
	  ranges(1,:) = tmpx;
	  num_rang(1:2) = [1 1]';
	else
	  if master_georange(1) < 0 % I don't think this ever occurs ...
	    ranges(1,:) = [tmpx(2) tmpx(3)];
	    num_rang(1:2) = [1 1]';
	  else
	    ranges(1,:) = [tmpx(3) tmpx(2)];
	    num_rang(1:2) = [1 1]';
	  end
	end
      else % we are in two-box mode
	if all(size(tmpx) == [1 2])
	  if master_georange(1) < 0
	    ranges(1,:) = tmpx(2:-1:1);
	  else
	    ranges(1,:) = tmpx(1:2);
	  end
	  num_rang(1:2) = [1 1]';
	else
	  if master_georange(1) < 0
	    ranges(1,:) = [tmpx(3) tmpx(2)];
	    num_rang(1:2) = [1 1]';
	  else
	    ranges(1,:) = [tmpx(2) tmpx(3)];
	    num_rang(1:2) = [1 1]';
	  end
	end
      end
    end
    if sum(num_rang(3:4)) == 0
      ranges(2,:) = [userlist(dset).rangemin(2) userlist(dset).rangemax(2)];
      num_rang(3:4) = [1 1]';
    end
    if sum(num_rang(5:6)) == 0
      ranges(3,:) = [userlist(dset).rangemin(3) userlist(dset).rangemax(3)];
      num_rang(5:6) = [1 1]';
    end
    % don't ever set the time range!
    %    if sum(num_rang(7:8)) == 0
    %      ranges(4,:) = [userlist(dset).rangemin(4) userlist(dset).rangemax(4)];
    %      num_rang(7:8) = [1 1]';
    %    end

    browse('setrangeboxes') % set dset and user range boxes
    browse('bsetrange') % set edit box text 
    return
    
  case 'setfigpos'
    % FIGURE 1
    figpos = figsizes(1,:);
    if any(figpos(3:4) == 0)
      % set default browser figure size:
      scr_size = get(0,'ScreenSize'); scr_offset = scr_size(1:2); 
      scr_size = scr_size(3:4);
      fig_size = [round(scr_size(1)*0.9) round(scr_size(2)*0.67)];
      fig_size(1) = max([fig_size(1) 600]);
      fig_size(2) = max([fig_size(2) 400]);
      fig_offset = scr_size - fig_size - [0 55];
      figpos = [fig_offset fig_size];
    end
    set(browse_fig, 'Position', figpos)
    % FIGURE 2
    choosecolor('setfigpos', figsizes(2,:))
    % FIGURE 3
    dispmenu('setfigpos', figsizes(3,:))
    % FIGURE 4
    dscrolllist('setfigpos',figsizes(4,:))
    % FIGURES 5
    listedit('setfigpos', figsizes(5,:));
    % FIGURE 6
    mastershow('setfigpos', figsizes(6,:));
    % FIGURE 7
    dodspropedit('setfigpos', figsizes(7,:));
    % FIGURE 8
    vscrolllist('setfigpos',figsizes(8,:))
    
  case 'setlevel'
    x = get(gui_buttons(21),'string');
    if ~isempty(x)
      check_level = sscanf(x,'%g');
      set(gui_buttons(23),'userdata',check_level)
    end
    set(gui_buttons([19:21 29]),'visible','off')
    return
    
  case 'setlon'
    % set the master georange
    offset = arg2;
    if offset == 360
      callbackstring = 'browse(''setlon'',0)';
      set(prefs(3),'label','Start Longitude 180W','callback',callbackstring);
      master_georange = [0 360 -90 90];
    elseif offset == 0
      callbackstring = 'browse(''setlon'',360)';
      set(prefs(3),'label','Start Longitude 0E','callback',callbackstring);
      master_georange = [-180 180 -90 90];
    end
    % now turn off zoom -- saved axes values will be incorrect 
    subplot(AXES(1)); newzoom off; subplot(AXES(2)); newzoom off; 
    subplot(AXES(3)); newzoom off
    set(gui_buttons(5),'backgroundcolor', dods_colors(1,:));
    % reset axes all the way 'out'
    set(get(AXES(1),'zlabel'),'userdata', ...
	[master_georange(1:2)+[-5 5] master_georange(3:4)+[-1 1]])
    set(get(AXES(2),'zlabel'),'userdata',[0 1 zrange])
    set(get(AXES(3),'zlabel'),'userdata',[timerange 0 1])
    subplot(AXES(1))
    % turn "set data range" off
    select(0);
    set(gui_buttons(3),'backgroundcolor', dods_colors(1,:)); 
    % set new coastline
    if isempty(dodsdir)
      dir = which('browse');
%      dirsep = '/';    Moved outside of main loop. Should no longer be needed.
%      c = computer;
%      if strcmp(c(1:2),'PC')
%	dirsep = '\';
%      elseif strcmp(c(1:2),'MA')
%	dirsep = ':';
%      end
      i = max(findstr(dir,dirsep));
      dodsdir = dir(1:i);
      dodsdir = ['''' dodsdir ''''];
    end
    fname = [dodsdir 'coastln'];
    eval(['load ' fname])
    x = coastlines(1,:); 
    x(coastinx) = x(coastinx)+offset;

    if ~isempty(worldmap)
      if any(findobj(AXES(1),'type','line') == worldmap)
	set(worldmap,'xdata',x); 
      else
	worldmap = line(x,coastlines(2,:), 'Color',dods_colors(3,:), ...
	    'Erasemode','none','linewidth',0.5,'linestyle','-'); drawnow
      end
    else
      worldmap = line(x,coastlines(2,:), 'Color',dods_colors(3,:), ...
	  'Erasemode','none','linewidth',0.5,'linestyle','-'); drawnow
    end
    clear coastlines
    
    % swap longitudes in view
    tmpx = xrange('range',master_georange,axes_vals(1:2));
    if all(size(tmpx) == [1 2])
      axes_vals(1:2) = tmpx;
    else
      axes_vals(1:4) = master_georange(1:4)+[-5 5 -1 1];
    end
    
    set(AXES(1),'xlim',axes_vals(1:2),'ylim',axes_vals(3:4));
    % reset aspect ratio
    set(AXES(1), 'PlotBoxAspectRatio', [diff(axes_vals(1:2)) ...
	  diff(axes_vals(3:4)) 1], ...
	'DataAspectRatio', [1 1 1])
 
    if ranges(1,1) < ranges(1,2)
      x = ranges(1,:);
    else
      x = [ranges(1,1) ranges(1,2)+360];
    end
    x = xrange('range', master_georange, x);
    if max(size(x) > 2)
      % do not allow wraparound range selection
      if range_boxes(1) > 0
	set(range_boxes(1),'visible','off');
	% UNSET USER LON RANGES -- NEW 00/10/06
	ranges(1,:) = [nan nan];
	num_rang(1:2) = [0 0];
	set(gui_buttons(8:9),'string','')
      end
    end

    browse('setrangeboxes')
    browse('bsetrange')
    if isnan(dset)
      dscrolllist('datset','full')
    else
      dscrolllist('datset','sub')
    end
    return
    
  case 'setrange' % turn zoom off and stasel on
    set(0,'currentfigure', browse_fig)
    if all(get(gui_buttons(3),'backgroundcolor') == dods_colors(9,:))
      select(0);
      set(gui_buttons(3),'backgroundcolor',dods_colors(1,:))
    else
      subplot(AXES(1)); newzoom off; subplot(AXES(2)); newzoom off; 
      subplot(AXES(3)); newzoom off
      set(gui_buttons(5),'backgroundcolor',dods_colors(1,:))
      select(1);
      set(gui_buttons(3),'backgroundcolor',dods_colors(9,:))
    end
    return
    
  case 'setrangeboxes' % set dataset and range boxes
    % DRAW DATASET RANGE INFO ON MAPS
    set(0,'currentfigure', browse_fig)
    h = []; i = [];
    if ~isnan(dset)
      x = xrange('range', master_georange, [userlist(dset).rangemin(1) ...
	    userlist(dset).rangemax(1)]);
      y = [userlist(dset).rangemin(2) userlist(dset).rangemax(2)];

      if max(size(x) == 2)
	xl = [x(1:2) x(2) x(2) x(2) x(1) x(1) x(1)];
	yl = [y(1) y(1) y(1:2) y(2) y(2) y(2) y(1)];
      else
	% two boxes
	xl = [x(1:2) x(2) x(2) x(2) x(1) x(1) x(1) nan ...
	      x(3:4) x(4) x(4) x(4) x(3) x(3) x(3)];
	yl = [y(1) y(1) y(1:2) y(2) y(2) y(2) y(1) nan ...
	      y(1) y(1) y(1:2) y(2) y(2) y(2) y(1)];
      end
    
      subplot(AXES(1)); 
      h = line(xl,yl, 'color',userlist(dset).color, ...
	  'erasemode','none','clipping','on','visible','off'); drawnow
      i = plot(xl,yl, 's','color',userlist(dset).color, ...
	  'erasemode','none','clipping','on','visible','off'); drawnow
      if strcmp(get(gui_buttons(30),'string'),'View Text')
%	if ~isempty(h)
	  h = [h(:); i(:)];
	  set(h,'visible','on')
%	end
      end

    end
    % Totally rewritten 99/04/12 -- dbyrne
    % default to whole georange of dataset, politely 
    if sum(num_rang(3:4)) == 2
      % SET USER Y-RANGE
      yl = [ranges(2,1) ranges(2,1) ranges(2,1) ranges(2,2) ...
	    ranges(2,2) ranges(2,2) ranges(2,2) ranges(2,1)];
    else
      yl = nan*ones(1,8);
    end
    if sum(num_rang(1:2)) == 2
      x = xrange('range', master_georange, ranges(1,:));
      % SET USER X-RANGE
      tmpx = xrange('range', [-180 180 -90 90], ranges(1,:));
    else 
      tmpx = [nan nan];
      x = [nan nan]; 
    end

    if max(size(x) == 2) % one-box mode
      if all(size(tmpx) == [1 2])
	xl = [x(1:2) x(2) x(2) x(2) x(1) x(1) x(1)];
      else
	if master_georange(1) < 0 % I don't think this ever actually occurs!
	  xl = nan*ones(1,8); 
	else
	  xl = [x(1:2) x(2) x(2) x(2) x(1) x(1) x(1)];
	end
      end
    else % we are in two-box mode
      xl = nan*ones(1,8);
    end
      
    % make sure x- and y- components match up!
    if length(xl) ~= length(yl)
      y = ranges(2,:);
      if length(xl) == 8
	yl = [y(1) y(1) y(1:2) y(2) y(2) y(2) y(1)];
      elseif length(xl) == 17 
	yl = [y(1) y(1) y(1:2) y(2) y(2) y(2) y(1) nan ...
	      y(1) y(1) y(1:2) y(2) y(2) y(2) y(1)];
      end
    end

    set(range_boxes(1),'xdata', xl, 'ydata', yl,'visible','off')
    if strcmp(get(gui_buttons(30),'string'),'View Text')
      set(range_boxes(1),'visible','on')
    end

    set(0,'currentfigure',browse_fig); subplot(AXES(2)); 
    if ~isnan(dset)
      x = 0.90*dset/user_num_sets;
      yl = [userlist(dset).rangemin(3) userlist(dset).rangemax(3)];
      h = line([x x], yl, 'color',userlist(dset).color,'erasemode','none', ...
	  'clipping','on','visible','off'); drawnow
      i = plot([x x], yl, 's','color',userlist(dset).color,'erasemode','none', ...
	  'clipping','on','visible','off'); drawnow
      if strcmp(get(gui_buttons(30),'string'),'View Text')
	set([h i], 'visible','on')
      end
      % default to whole depth of dataset. 
      % OVERRIDES USER-SET RANGES! RUDE! (Peter insisted.)
      if ~isnan(userlist(dset).rangemin(3)) & ~isnan(userlist(dset).rangemax(3))
	ranges(3,:) = [userlist(dset).rangemin(3) userlist(dset).rangemax(3)];
      end
    end
    if ~isnan(ranges(3,1)) & ~isnan(ranges(3,2))
      num_rang(5:6) = [1 1]';
      set(gui_buttons(12),'String',sprintf(' %.2f',ranges(3,2)))
      set(gui_buttons(13),'String',sprintf(' %.2f',ranges(3,1)))
    end
    xl = [0.01 0.99];
    set(range_boxes(2),'xdata',[xl(1:2) xl(2) xl(2) xl(2) xl(1) xl(1) xl(1)], ...
	'ydata', [ranges(3,1) ranges(3,1) ranges(3,1) ranges(3,2) ...
	  ranges(3,2) ranges(3,2) ranges(3,2) ranges(3,1)])
    if strcmp(get(gui_buttons(30),'string'),'View Text')
      set(range_boxes(2),'visible','on')
    end
      
    if ~isnan(dset)
      xl = [userlist(dset).rangemin(4) userlist(dset).rangemax(4)];
      yl = 0.90*dset/user_num_sets;
       subplot(AXES(3)); 
       h = line(xl, [yl yl], 'color',userlist(dset).color,'erasemode','none', ...
	   'clipping','on','visible','off'); drawnow
       i = plot(xl, [yl yl], 's','color',userlist(dset).color,'erasemode','none', ...
	   'clipping','on','visible','off'); drawnow
       if strcmp(get(gui_buttons(30),'string'),'View Text')
	 set([h i], 'visible','on')
       end
     end

     if sum(num_rang(7:8)) == 2
       % SET USER T-RANGE
       xl = [ranges(4,1:2) ranges(4,2) ranges(4,2) ranges(4,2) ...
	     ranges(4,1) ranges(4,1) ranges(4,1)];
     else
       xl = nan*ones(1,8);
     end
     yl = [0.01 0.01 0.01 0.99 0.99 0.99 0.99 0.01];
     set(range_boxes(3),'xdata', xl,'ydata', yl)
     if strcmp(get(gui_buttons(30),'string'),'View Text')
       set(range_boxes(3),'visible','on')
     end

    return
    
  case 'swapview'
    view = get(gui_buttons(30),'string');
    if strcmp(view,'View Text') % we are switching to text-only
      set([AXES(1:4) cbarhandle worldmap range_boxes(:)' ...
	    tstring(:)'],'visible','off')
	
      if ~isempty(thandle)
	set(thandle,'visible','off')
      end
      if ~isempty(lhandle)
	set(lhandle,'visible','off')
      end
      lines = findobj(AXES(1:3),'type','line');
      lines = [lines; findobj(AXES(1:3),'type','image')];
      lines = [lines; findobj(AXES(1:3),'type','surface')];
      lines = [lines; findobj(AXES(1:3),'type','patch')];
      set(lines,'visible','off')
      set(gui_buttons(30),'string','View Plots')
      set(gui_buttons([3 5 6]),'visible','off')
      set(gui_buttons([2 8:17 31:58]),'visible','on')
    else % we are switching to graphic mode
      if sum(num_rang(1:4)) == 4
	set(range_boxes(1),'visible','on')
      end
      if sum(num_rang(5:6)) == 2
	set(range_boxes(2),'visible','on')
      end
      if sum(num_rang(7:8)) == 2
	set(range_boxes(3),'visible','on')
      end
      if ~isempty(thandle)
	set(thandle,'visible','on')
      end
      if ~isempty(lhandle)
	set(lhandle,'visible','on')
      end
      set([AXES(1:3) worldmap tstring(:)'],'visible','on')
      images = [];
      images = [images; findobj(AXES(1),'type','image')];
      images = [images; findobj(AXES(1),'type','surface')];
      images = [images; findobj(AXES(1),'type','patch')];
      lines = findobj(browse_fig,'type','line');
      lines = [lines; images];
      % honor image_string sequence
      if length(image_string) > 0 & ~isempty(get(gui_buttons(6),'userdata'))
	set(gui_buttons(6),'visible','on')
	% skip the first image
	h = []; l = image_string(1)+2;
	while l < length(image_string)
	  k = image_string(l);
	  h = [h; image_string(l+1:l+k)];
	  l = l+k+1;
	end
	for i = 1:length(lines),
	  if ~any(lines(i) == [range_boxes(:); h])
	    set(lines(i),'visible','on')
	  end
	end
      else
	for i = 1:length(lines),
	  if ~any(lines(i) == range_boxes)
	    set(lines(i),'visible','on')
	  end
	end
      end

      % if there are any images, reveal the colorbar
      if ~isempty(images)
	vis = get(images,'vis');
	s = strmatch('on', vis);
	if ~isempty(s)
	  s = s(1);
	  clim = get(images(s),'userdata');
	  if ~isempty(clim);
	    set(gca,'clim', clim);
	  end
	  colorbar; cbarhandle = findobj(AXES(4),'type','image');
	  set(AXES(4), 'color',dods_colors(2,:), ...
	      'xcolor',dods_colors(3,:), ...
	      'ycolor',dods_colors(3,:), ...
	      'visible','on');
	end
      end
      
      set(gui_buttons([3 5]),'visible','on')
      set(gui_buttons([2 8:17 31:58]),'visible','off')
      set(gui_buttons(30),'string','View Text')
    end
    return
    
  case  'timetoggle'
    timetoggle = arg2;
    set(AXES(3), 'tag', num2str(timetoggle))
    if timetoggle == 0
      callbackstring = 'browse(''timetoggle'',1)';
      set(prefs(4),'label','Time in Year/Month/Day','callback',callbackstring);
    elseif timetoggle == 1
      callbackstring = 'browse(''timetoggle'',0)';
      set(prefs(4),'label','Time in Year/Yearday','callback',callbackstring);
    end
    [thandle, lhandle] = timelbl(get(AXES(3),'xlim'), timetoggle, ...
	thandle, lhandle, tstring, AXES, dods_colors, fontsize);
    return
    
  case 'trange'
    x = sscanf(get(gui_buttons(14),'string'),'%g');
    if ~isempty(x)
      ranges(4,1) = x;
      num_rang(7) = 1;
      lmo = [31 28 31 30 31 30 31 31 30 31 30 31];
      if rem(floor(ranges(4,1)),4) == 0
	if floor(ranges(4,1)) == 1900 	% 1900 was apparently not a leap year!
	  lyr = 365;
	else
	  lyr = 366;
	  lmo(2) = 29;
	end
      else
	lyr = 365;
      end
      range_day = floor((ranges(4,1)-floor(ranges(4,1)))*lyr(1))+1; % day of year
      t = min(find(range_day < cumsum(lmo)));
      if isempty(t)
	t = 12;
      end
      % day
      t(2) = range_day(1) - sum(lmo(1:t(1)-1));
      % hr
      t(3) = floor((((ranges(4,1)-floor(ranges(4,1)))*lyr(1)+1)-range_day(1))*24);
      % min
      t(4) = floor(((((ranges(4,1)-floor(ranges(4,1)))*lyr(1)+1)*24 - ...
	  range_day(1)*24)-t(3))*60);
      % sec
      t(5) = floor(((((ranges(4,1)-floor(ranges(4,1)))*lyr(1)+1)*24*60 - ...
	  range_day(1)*24*60)-t(3)*60)*60-t(4)*60);
      for i = 1:5;
	set(gui_buttons(39+i),'string',sprintf('%i',t(i)))
      end
    end
    x = sscanf(get(gui_buttons(15),'string'),'%g');
    if ~isempty(x)
      ranges(4,2) = x;
      num_rang(8) = 1;
      lmo = [31 28 31 30 31 30 31 31 30 31 30 31];
      if rem(floor(ranges(4,2)),4) == 0
	if floor(ranges(4,2)) == 1900 	% 1900 was apparently not a leap year!
	  lyr(2) = 365;
	else
	  lyr(2) = 366;
	  lmo(2) = 29;
	end
      else
	lyr(2) = 365;
      end
      range_day(2) = floor((ranges(4,2)-floor(ranges(4,2)))*lyr(2))+1; % day of year
      t = min(find(range_day(2) < cumsum(lmo)));
      if isempty(t)
	t = 12;
      end
      % day
      t(2) = range_day(2) - sum(lmo(1:t(1)-1));
      % hr
      t(3) = floor((((ranges(4,2)-floor(ranges(4,2)))*lyr(2)+1)-range_day(2))*24);
      % min
      t(4) = floor(((((ranges(4,2)-floor(ranges(4,2)))*lyr(2)+1)*24 - ...
	  range_day(2)*24)-t(3))*60);
      % sec
      t(5) = floor(((((ranges(4,2)-floor(ranges(4,2)))*lyr(2)+1)*24*60 - ...
	  range_day(2)*24*60)-t(3)*60)*60-t(4)*60);
      for i = 1:5;
	set(gui_buttons(44+i),'string',sprintf('%i',t(i)))
      end
    end
    if sum(num_rang(7:8)) == 2
      yl = [0.01 0.99];
      set(range_boxes(3),'xdata',[ranges(4,1:2) ranges(4,2) ranges(4,2) ...
	      ranges(4,2) ranges(4,1) ranges(4,1) ranges(4,1)], ...
	  'ydata', [yl(1) yl(1) yl(1:2) yl(2) yl(2) yl(2) yl(1)])
      if strcmp(get(gui_buttons(30),'string'),'View Text')
	set(range_boxes(3),'visible','on')
      end
    end
    browse('gsetrange')
    % reset other window
    if isnan(dset)
      dscrolllist('datset','full')
    else
      dscrolllist('datset','sub')
    end
    return
    
  case 'update'
    % for safety's sake, deselect any current selections
    guiserver = get(prefs(9),'tag');
    [err, newlist, newvars] = update(guiserver, dodsdatadir, ...
    userlist, user_variables);
    if ~err % update completed successfully
      userlist = newlist;
      user_variables = newvars;
      selected_datasets = zeros(size(userlist,1),1);
      % check how many sets and variables we have now
      user_num_sets = size(userlist,1);
      user_num_vars = size(user_variables,1);
      % make global matrices
      browse('mkusermats')

      % RESET THE VARS and DSETS LISTS
      vscrolllist('vreset')
      dscrolllist('dreset')
      
      % reset the master list
      mastershow('newmaster')
      
      % save user bookmarks w/new datasets added:
      listedit('fsave', userlist, user_variables)
      
      % now check if master ranges need to be updated?
      
    end
    return
    
  case 'updatedlg'
    if isempty(dodsdatadir)
%      dirsep = '/';  Moved of out main loop. Should no longer be needed
%      c = computer;
%      if strcmp(c(1:2),'PC')
%	dirsep = '\';
%      elseif strcmp(c(1:2),'MA')
%	dirsep = ':';
%      end
      if isempty(dodsdir)
	dir = which('browse');
	i = max(findstr(dir,dirsep));
	dodsdir = dir(1:i);
	dodsdir = ['''' dodsdir ''''];
      end
      dodsdatadir = [dodsdir 'DATASETS' dirsep];
      if exist('dodsBrokenDatasets') % If set look for data sets in BROKEN_DATASETS directory.
        if dodsBrokenDatasets == 1
          dodsdatadir = [dodsdir 'BROKEN_DATASETS' dirsep];
        end
      end
    end
    % the dialog string
    str = sprintf('%s\n', ...
	'  Updating the dataset list requires the browser to go', ...
	'  out over the Web to fetch what could be fairly large', ...
	'  number of files.', ...
	'  ', ...
	'  Updated files will be written to the following directory,', ...
	'  which will be created if it does not already exist.', ...
	'  ', ...
	'  Use the default or specify your own choice.  If selecting', ...
	'  an alternate make sure to add it to your MATLABPATH!');
    
    set(0,'units','pixels')
    scr_size = get(0,'ScreenSize'); scr_offset = scr_size(1:2); 
    scr_size = scr_size(3:4);
    % set up window characteristics
    fig_size = [round(scr_size(1)*0.3) round(scr_size(2)*0.3)];
    % minimum acceptable size
    fig_size(1) = max([fig_size(1) 380]);
    fig_size(2) = max([fig_size(2) 155]);
    fig_offset(1) = 100;
    fig_offset(2) = scr_size(2)*0.5;
    if fig_offset(2)+155 > scr_size(2),
      fig_offset(2) = scr_size(2)-155; 
    end
    h = figure('Name','Update dataset list?', 'numbertitle','off', ...
	'interruptible','on', ...
	'units','pixels', ...
	'resize','off',...
	'userdata','DODS updatedlg', ...
	'color',dods_colors(2,:), ...
	'position', [fig_offset fig_size]);
    uicontrol(h,'style','frame', ...
	'units','normalized', ...
	'position',[0 0 1 1], ...
	'backgroundcolor', dods_colors(1,:))
    uicontrol(h,'style','edit', ...
	'max',2, ...
	'units','normalized', ...
	'string', str, ...
	'position',[0 0.4 1 0.6], ...
	'foregroundcolor', dods_colors(6,:), ...
	'backgroundcolor', dods_colors(1,:))
    uicontrol(h,'style','edit', ...
	'units','normalized', ...
	'string',dodsdatadir, ...
	'userdata','DODSDATADIR', ...
	'position',[0.02 0.3 0.96 0.1], ...
	'foregroundcolor', dods_colors(6,:), ...
	'backgroundcolor', dods_colors(5,:), ...
	'callback','browse(''dodsdatadir'')')
    uicontrol(h,'style','frame', ...
	'units','normalized', ...
	'position',[0 0 1 0.3], ...
	'foregroundcolor', dods_colors(6,:), ...
	'backgroundcolor', dods_colors(1,:))
    callbackstring = sprintf('%s; delete(%i); %s', ...
	'browse(''dodsdatadir'')', h, ...
	'browse(''update'')');
    uicontrol(h,'style','pushbutton', ...
	'units','normalized', ...
	'string','Ok', ...
	'position',[0.2 0.05 0.18 0.15], ...
	'foregroundcolor', dods_colors(6,:), ...
	'backgroundcolor', dods_colors(7,:), ...
	'callback',callbackstring)
    callbackstring = sprintf('delete(%i)',h);
    uicontrol(h,'style','pushbutton', ...
	'units','normalized', ...
	'string','Cancel', ...
	'position',[0.62 0.05 0.18 0.15], ...
	'foregroundcolor', dods_colors(6,:), ...
	'backgroundcolor', dods_colors(1,:), ...
	'callback',callbackstring)
    return
    
  case 'wesn'
    % get y-range: not complicated
    x = sscanf(get(gui_buttons(10),'string'),'%g');
    if ~isempty(x)
      if x < master_georange(3)
	x = master_georange(3);
	set(gui_buttons(10),'string',sprintf('%.3f',x));
      elseif x > master_georange(4)
	x = master_georange(4);
	set(gui_buttons(10),'string',sprintf('%.3f',x));
      end
      ranges(2,1) = x;
      num_rang(3) = 1;
    end
    x = sscanf(get(gui_buttons(11),'string'),'%g');
    if ~isempty(x)
      if x < master_georange(3)
	x = master_georange(3);
	set(gui_buttons(11),'string',sprintf('%.3f',x));
      elseif x > master_georange(4)
	x = master_georange(4);
	set(gui_buttons(11),'string',sprintf('%.3f',x));
      end
      ranges(2,2) = x;
      num_rang(4) = 1;
    end

    % get/set x-range: this is complicated
    x = sscanf(get(gui_buttons(8),'string'),' %g');
    if master_georange(1) == 0
      if ~isempty(x)
	if x < master_georange(1)
	  x = master_georange(1);
	  set(gui_buttons(8), 'string', sprintf('%.3f',x))
	elseif x > master_georange(2)
	  x = master_georange(2);
	  set(gui_buttons(8), 'string', sprintf('%.3f',x))
	end	  
	if (x >= 0) & (x < 180)
	  ranges(1,1) = x;
	elseif x >= 180
	  ranges(1,1) = x - 360;
	end
	temp_xrange(1) = x;
	num_rang(1) = 1;
      else
	temp_xrange(1) = nan;
	num_rang(1) = 0;
	ranges(1,1) = nan;
      end
      x = sscanf(get(gui_buttons(9),'string'),'%g');
      if ~isempty(x)
	if x < master_georange(1)
	  x == master_georange(1);
	  set(gui_buttons(9), 'string', sprintf('%.3f',x))
	elseif x > master_georange(2)
	  x = master_georange(2);
	  set(gui_buttons(9), 'string', sprintf('%.3f',x))
	end	  
	if (x >= 0) & (x <= 180)
	  ranges(1,2) = x;
	elseif x > 180
	  ranges(1,2) = x - 360;
	end
	temp_xrange(2) = x;
	num_rang(2) = 1;
      else
	temp_xrange(2) = nan;
	ranges(1,2) = nan;
	num_rang(2) = 0;
      end
      if all(ranges(1,:) == [0 0])
	ranges(1,:) = [-180 180];
      end
      xl = [temp_xrange temp_xrange(2) temp_xrange(2) ...
	    temp_xrange(2) temp_xrange(1) temp_xrange(1) temp_xrange(1)]; 
      yl = [ranges(2,1) ranges(2,1) ranges(2,1) ranges(2,2) ...
	    ranges(2,2) ranges(2,2) ranges(2,2) ranges(2,1)];
    else % master georange is [0 360]
      if ~isempty(x)
	if x < master_georange(1)
	  x = master_georange(1);
	  set(gui_buttons(8),'string', sprintf('%i',x))
	elseif x > master_georange(2)
	  x = master_georange(2);
	  set(gui_buttons(8),'string', sprintf('%i',x))
	end
	ranges(1,1) = x;
	num_rang(1) = 1;
      else
	% what to do if x is empty?
	ranges(1,1) = nan;
	num_rang(1) = 0;
      end
      x = sscanf(get(gui_buttons(9),'string'),'%g');
      if ~isempty(x)
	if x < master_georange(1)
	  x = master_georange(1);
	  set(gui_buttons(9),'string', sprintf('%i',x))
	elseif x > master_georange(2)
	  x = master_georange(2);
	  set(gui_buttons(9),'string', sprintf('%i',x))
	end
	ranges(1,2) = x;
	num_rang(2) = 1;
      else
	% what to do if x is empty?
	ranges(1,2) = nan;
	num_rang(2) = 0;
      end
      xl = [ranges(1,1:2) ranges(1,2) ranges(1,2)  ...
	    ranges(1,2) ranges(1,1) ranges(1,1) ranges(1,1)];
      yl = [ranges(2,1) ranges(2,1) ranges(2,1) ranges(2,2) ...
	    ranges(2,2) ranges(2,2) ranges(2,2) ranges(2,1)];
    end
    if sum(num_rang(1:4)) == 4
      set(range_boxes(1),'xdata', xl, 'ydata', yl, 'visible','off')
    end
    if strcmp(get(gui_buttons(30),'string'),'View Text')
      set(range_boxes(1),'visible','on')
    end
    % remove URL count
    browse('gsetrange')
    % check for valid datasets/variables and reset other windows
    if isnan(dset)
      dscrolllist('datset','full')
    else
      dscrolllist('datset','sub')
    end
    return
    
  case 'ylabel'
    % we have just unset a dataset
    set(get(AXES(2),'ylabel'),'string','')
    set(gui_buttons(1),'callback','browse(''getdata'')')
    set(gui_buttons(2),'string','')
    set(gui_buttons(24),'callback','')
    set(gui_buttons(53),'string','')
    return
  
  case 'zoom'
    if all(get(gui_buttons(5),'backgroundcolor') == dods_colors(9,:))
      set(gui_buttons(5),'backgroundcolor',dods_colors(1,:))
      subplot(AXES(1)); newzoom off; subplot(AXES(2)); newzoom off; 
      subplot(AXES(3)); newzoom off; 
    else
      select(0);
      set(gui_buttons(3),'backgroundcolor', ...
	  dods_colors(1,:)); set(gui_buttons(5), ...
	  'backgroundcolor',dods_colors(9,:))
      subplot(AXES(1)); newzoom on; subplot(AXES(2)); newzoom on; 
      subplot(AXES(3)); newzoom on; 
    end
    return
  
  case 'zoomout'
    % turn zoom off
    subplot(AXES(1)); newzoom off; subplot(AXES(2)); newzoom off; 
    subplot(AXES(3)); newzoom off
    
    % set the zoom button to gray
    set(gui_buttons(5),'backgroundcolor', dods_colors(1,:));
    
    % reset axes all the way 'out'
    axes_vals = [master_georange(1:2)+[-5 5] master_georange(3:4)+[-1 1] ...
	  zrange timerange];
    set(AXES(1),'xlim',axes_vals(1:2),'ylim',axes_vals(3:4));
    set(get(AXES(1),'zlabel'),'userdata',axes_vals(1:4))
    set(AXES(2),'xlim',[0 1],'ylim',axes_vals(5:6));
    set(get(AXES(2),'zlabel'),'userdata',[0 1 axes_vals(5:6)])
    set(AXES(3),'xlim', axes_vals(7:8),'ylim',[0 1], ...
	'xtickmode','auto','xticklabelmode','auto')
    delete([thandle(:); lhandle(:)])
    thandle = []; lhandle = [];
    set(get(AXES(3),'zlabel'),'userdata',[axes_vals(7:8) 0 1])
    set(AXES(1), 'PlotBoxAspectRatio', [diff(axes_vals(1:2)) ...
	  diff(axes_vals(3:4)) 1], ...
	'DataAspectRatio', [1 1 1])

  case 'zrange'
    % this is called
    x = sscanf(get(gui_buttons(12),'string'),'%g');
    if ~isempty(x)
      if x < zrange(1)
	x = zrange(1);
	set(gui_buttons(12),'string',sprintf('%.2f',x));
      elseif x > zrange(2)
	x = zrange(2);
	set(gui_buttons(12),'string',sprintf('%.2f',x));
      end
      ranges(3,2) = x;
      num_rang(5) = 1;
    end
    x = sscanf(get(gui_buttons(13),'string'),'%g');
    if ~isempty(x)
      if x < zrange(1)
	x = zrange(1);
	set(gui_buttons(13),'string',sprintf('%.2f',x));
      elseif x > zrange(2)
	x = zrange(2);
	set(gui_buttons(13),'string',sprintf('%.2f',x));
      end
      ranges(3,1) = x;
      num_rang(6) = 1;
    end
    if sum(num_rang(5:6)) == 2
      xl = [0.01 0.99];
      set(range_boxes(2),'xdata',[xl(1:2) xl(2) xl(2) xl(2) xl(1) xl(1) xl(1)], ...
	  'ydata', [ranges(3,1) ranges(3,1) ranges(3,1) ranges(3,2) ...
	      ranges(3,2) ranges(3,2) ranges(3,2) ranges(3,1)], 'visible', 'off')
      if strcmp(get(gui_buttons(30),'string'),'View Text')
	set(range_boxes(2),'visible','on')
      end
    end
    dscrolllist('datset','full')
    return

end % end of switch arg1
% The preceding empty line is important.
%
% $Id: browse.m,v 1.25 2002/08/14 06:24:01 dan Exp $

% $Log: browse.m,v $
% Revision 1.25  2002/08/14 06:24:01  dan
% Fixed problem with returned (actually not returned) time.
%
% Revision 1.24  2002/08/13 14:36:29  dan
% Modified to save URLinfo when a getdata request is issued and URLinfo has to be updated.
%
% Revision 1.23  2002/08/04 04:29:04  dan
% Changed location of update site to URI.
%
% Revision 1.22  2002/07/11 17:19:38  dan
% Allowed for a default directory the testsuite.
%
% Revision 1.21  2002/07/11 16:33:33  dbyrne
%
%
% Removed spurious ^M characters from file.   -- dbyrne 2002/07/11
%
% Revision 1.20  2002/07/10 15:46:42  dan
% Fixed formatting of write for browsopt to include double quoutes.
%
% Revision 1.19  2002/07/10 10:43:12  dan
% Many changes to address space in PC directory names.
%
% Revision 1.18  2002/04/29 15:49:00  dan
% Fixed reference to empty dodsBrokenDatasets.
%
% Revision 1.17  2002/04/15 20:34:56  dan
% Added code to allow selection of BROKEN_DATASET directory. Not tested yet.
%
% Revision 1.16  2002/04/12 21:19:04  dan
% Added ; to line that printed out all the time.
%
% Revision 1.15  2002/04/10 16:48:01  dbyrne
%
%
% Modified dodsdatadir and update procedure.  dbyrne 2002/04/10
%
% Revision 1.14  2002/04/09 16:36:33  dan
% Changed test direcorty to testsuite under the ml-toolbox direcotry.
%
% Revision 1.13  2002/04/08 21:16:56  dan
% Added code for testing.
%
% Revision 1.12  2002/03/06 00:19:17  dan
% Fixed problem with data set ranges versus selected ranges
%
% Revision 1.11  2002/01/23 06:48:49  dbyrne
%
%
% Eliminated use of 'DepthName' variable, which I think was obsolete.
% -- dbyrne 2002/01/22
%
% Revision 1.10  2002/01/22 21:16:43  dbyrne
%
%
% Really fixed colorbar this time.  I promise.  dbyrne 2002/02/22
%
% Revision 1.9  2002/01/22 20:41:49  dbyrne
%
%
% Fixed bug hiding Acknowledgments button when switching to Text view.
% Fixed bug accidentally deleting colorbar. -- dbyrne 2002/01/22
%
% Revision 1.8  2002/01/11 03:55:11  dbyrne
%
%
% Modified loaddods check to work with java-loaddods.  Note that this is not
% really compatible with rigorously checking for loaddods.mex.  Passed URLinfo
% to getfunction in 'datasize' mode -- required to silently update catalog
% in the case of a new dataset.  Removed some extraneous verbiage.  -- dbyrne 2002/01/10
%
% Revision 1.7  2001/06/26 16:20:12  dbyrne
%
%
% Small modifications to pass out metadata to dispmenu.
% Fixed bug producing extra colorbar when zooming in or out
% while advancing a series of plots. -- dbyrne 01/06/26
%
% Revision 1.6  2001/01/18 16:36:45  dbyrne
%
%
% Changes for GUI 5.0 -- dbyrne 2001/01/17
%
% Revision 1.6  2000/12/21 21:02:49  root
% Updated use of archive, getxxx, and getack
%
% Revision 1.5  2000/11/27 16:20:22  root
% Changed default colors.
%
% Revision 1.4  2000/11/20 16:11:16  root
% Changes and addition for Folders Edition.  -- dbyrne 00/11/20
%
% Revision 1.3  2000/09/01 18:30:10  root
% *** empty log message ***
%
% Revision 1.2  2000/06/15 22:44:29  root
% *** empty log message ***
%
% Revision 1.1  2000/05/31 22:57:19  root
% *** empty log message ***
%
% Revision 1.46  2000/05/24 19:17:30  root
% Fixed more bugs in scroll.m.  Browser now supports URLlists.
%
% Revision 1.32  2000/03/23 02:50:35  dbyrne
%
%
% Changed incorrect use of 'num_urls' in 'nextplot' function to
% 'num_plots'.  -- dbyrne 00/03/22
%
% Revision 1.31  2000/03/17 09:38:11  dbyrne
%
%
% Added line style and width specification to coastline, changed timerange
% as per Paul's request, changed startup position of browse window to (hopefully)
% upper right of user's screen.
%
% Happy St. Patrick's Day!
%
% dbyrne, 00/03/17
%
% Revision 1.30  2000/03/16 05:59:07  dbyrne
% *** empty log message ***
%
% Revision 1.29  2000/03/16 03:47:52  dbyrne
%
%
% Changed names of four of the output arguments to browse:
% #3 get_variables, #5 axes_vals, #6 color_limits, #7 georange
% to browse_[same] so that a 'Cancelled' getdata request does
% not leave spurious output in user workspace.  -- dbyrne 00/03/14
%
% Revision 1.28  1999/11/05 22:13:59  dbyrne
%
%
% Fixed restoration of saved axes values and longitude ranges.
% Fixed 'setlon' so that it doesn't zoom "out" unless it has to.
%
% Revision 1.45  1999/11/05 22:05:09  root
% Fixed restoring saved axes values.  Fixed 'setlon' so that it doesn't always
% zoom "out" unless it has to. -- dbyrne 99/11/5
%
% Revision 1.44  1999/10/28 18:41:42  root
% *** empty log message ***
%
% Revision 1.43  1999/10/27 20:49:54  root
% Fixed bug in Bugs list.
%
% Revision 1.42  1999/09/02 18:15:09  root
% *** empty log message ***
%
% Revision 1.25  1999/07/22 18:33:21  dbyrne
%
%
% Changed upper end of zrange height to accommodate some datasets.  dbyrne 99/07/22
%
% Revision 1.24  1999/07/21 15:23:46  dbyrne
% *** empty log message ***
%
% Revision 1.23  1999/07/20 16:12:59  dbyrne
% *** empty log message ***
%
% Revision 1.22  1999/07/20 15:04:05  dbyrne
%
%
% Finished modifications to make dataset selection a modal operation.
% -- dbyrne 99/07/20
%
% Revision 1.21  1999/07/19 22:38:22  dbyrne
%
%
% Fixed a bug that carried over datarange from previous datasets!  Nasty.
% dbyrne 99/07/19
%
% Revision 1.20  1999/06/01 16:12:36  dbyrne
%
%
% quick bug fixes for AGU -- dbyrne 99/06/01
%
% Revision 1.19  1999/05/25 18:31:09  dbyrne
%
%
% Changed xrange to use dodsmsg.  Changed browse to fix error in display of
% user range boxes when swapping start longitude. -- dbyrne 99/05/25
%
% Revision 1.41  1999/05/25 18:18:01  root
% Fixed display of user ranges when switching starting longitude.
%
% Revision 1.40  1999/05/25 00:02:06  root
% Found a bug in user ranges display during plotting, and fixed plotscript
% to default to pcolor if image is to be split into 2 pieces. -- dbyrne 99/05/23
%
% Revision 1.39  1999/05/13 00:53:05  root
% Lots of changes for version 3.0.0 of browser.
%
% Revision 1.38  1999/03/03 16:43:36  root
% Updated manual location.  Changed 'DODS help' to 'DODS GUI Help'. dbyrne 3/3/99
%
% Revision 1.37  1998/12/09 20:01:00  dods
% Workaround for Matlab/fvwm2 window manager for Datasets & Variables lists.
%
% Revision 1.36  1998/11/26 07:59:35  root
% Fixed a bug in unpack that incorrectly eliminate names of
% properly returned variables.
%
% Revision 1.35  1998/11/24 10:47:45  root
% Changed datasize 'cancel' callback so that it's the same for both v matlab.
%
% Revision 1.34  1998/11/24 10:28:18  root
% Changed mater_zrange to max depth of 5600 since Levitus goes to 5500.
%
% Revision 1.33  1998/11/24 10:27:29  root
% *** empty log message ***
%
% Revision 1.32  1998/11/09 12:47:04  root
% Fixed small things in display.
%
% Revision 1.31  1998/11/05 16:02:05  root
% Changed LonVector and LatVector to be used if no Lon returned and tried the update function.
% DataScale and DataNull should now be optional!
%
% Revision 1.30  1998/10/23 15:26:02  root
% updating NSCAT 3.0
%
% Revision 1.29  1998/10/22 14:50:20  root
% Made datarange more consistent.
%
% Revision 1.28  1998/10/22 14:39:20  root
% made plotting coastline a little more sensible.
%
% Revision 1.27  1998/09/13 16:01:41  root
% *** empty log message ***
%
% Revision 1.26  1998/09/13 14:59:23  root
% Fixed 'clear all Rxx_' once again.
%
% Revision 1.25  1998/09/13 14:51:24  root
% Encountered (as usual) some weird problems with longitude.
%
% Revision 1.24  1998/09/12 20:54:50  root
% *** empty log message ***
%
% Revision 1.23  1998/09/12 20:00:50  root
% Finished changes so that dispmenu can be used again & again.
% Added 'checkplot' to pop the image stack if only one image in it.
%
% Revision 1.22  1998/09/12 16:49:06  root
% *** empty log message ***
%
% Revision 1.21  1998/09/12 15:28:40  root
% Made modifications necessary to let display menu be called numerous times.
%
% Revision 1.20  1998/09/12 11:20:17  root
% changing display menu
%
% Revision 1.19  1998/09/10 21:11:32  dbyrne
% Removed informative blurbs returned to user from getrectg and added
% them in here.
%
% Revision 1.18  1998/09/10 08:56:16  dbyrne
% Changed input to getfunctions so mode is first arg.
%
% Revision 1.17  1998/09/09 08:09:59  dbyrne
% changed Data_Range to DataRange
%
% Revision 1.16  1998/09/08 21:14:03  dbyrne
% *** empty log message ***
%
% Revision 1.15  1998/09/08 16:04:20  dbyrne
% browse_get_variables and browse_display_choices too long for v4. Changed
% them to browse_getvariables and browse_dispchoices
%
% Revision 1.14  1998/09/08 16:00:25  dbyrne
% *** empty log message ***
%
% Revision 1.13  1998/09/04 19:48:19  dbyrne
% Looking for a bug in 'cat' call.
%
% Revision 1.12  1998/09/04 11:26:24  dbyrne
% updating 'display' function
%
% Revision 1.11  1998/09/03 20:32:40  dbyrne
% CLeaning up multivariable plot items.
%
% Revision 1.10  1998/09/03 18:17:59  dbyrne
% finishing up multivariables
%
% Revision 1.9  1998/09/03 17:12:57  dbyrne
% Added index into returned variables as output argument for use w/plotscript
%
% Revision 1.8  1998/09/01 06:51:32  dbyrne
% working on changes in how data is passed in and out of browser
% (from get functions to unpack.m)
%
% Revision 1.7  1998/08/31 08:59:35  dbyrne
% Caught some bugs: working on new version of getrectangular
%
% Revision 1.6  1998/08/27 16:35:44  dbyrne
% making changes to universalize returned variables
%
% Revision 1.5  1998/08/27 04:44:14  dbyrne
% continuing with multivar changes. DAB 98/08/26
%
% Revision 1.4  1998/08/26 14:19:34  dbyrne
% Beginning to change how browser returns arguments to main workspace. What a mess.
% DAB 98/08/26
%
% Revision 1.3  1998/08/25 14:57:05  dbyrne
% *** empty log message ***
%
% Revision 1.2  1998/08/20 12:48:31  dbyrne
% % changes to allow for multiple variables
%
% Revision 1.1  1998/05/17 14:10:42  dbyrne
% *** empty log message ***
%
% Revision 1.7  1997/10/27 19:01:10  tom
% fixed default manual location
%
% Revision 1.6  1997/10/24 18:50:00  tom
% forgot a semicolon.
%
% Revision 1.5  1997/10/24 16:41:34  tom
% Made html access slightly more general by using the docopt command.
% of course this means that the docopt file must be correct...
%
% Revision 1.4  1997/10/24 15:50:37  tom
% added documentation, fixed dialog box behavior (found and
% exterminated bug in window management), added access to html
% documentation, modified browsopt.m.
%
% Revision 1.3  1997/10/14 02:47:41  tom
% Repaired input dialog behavior for v5. Callbacks were getting
% called, which seems wrong to me.
%
% Revision 1.2  1997/09/24 01:09:31  tom
% Added local manifest capability. Various small bug fixes.
%
% Revision 1.1.1.1  1997/09/22 14:13:53  tom
% Imported Matlab GUI sources to CVS
%
