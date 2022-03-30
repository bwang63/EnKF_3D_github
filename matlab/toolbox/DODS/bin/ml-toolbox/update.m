function [val, outlist, outvars] = update(guiserver, datadir, inlist, invars)
% UPDATE: interpret the DODS MANIFEST line by line.

% global arguments
global dodsdir dirsep folder_start folder_end

% initialize an error flag that will only be set to zero
% if the whole update proceeds smoothly.
val = 1;
if nargout > 0
  outlist = '';
  outvars = '';
end

% check that we are on a supported system
%if ~(isunix | ispc) 
%  str = [ 'Warning: unable to determine your system architecture!'...
%	'  Cannot continue with update.'];
%  dodsmsg(popup,str)
%  return
%end

% get colors
dods_colors = browse('getcolors');

% NOTE: to stop popup window that operates with geturl, use:
% ! setenv DODS_USE_GUI no ; geturl ....
% this is far from ideal but the -g flag does not appear to be
% working, and if a file is not found the geturl warning will
% hang the entire update procedure.  -- dbyrne 2002/04/10

%***** CHECK THE VERSION NUMBER ON  THE LOCAL SYSTEM AGAINST THAT ON THE UPDATE SYSTEM *****

% new as of 2002/04/09.  Check browser version with update site version.
fname = [dodsdir 'browseversion.m'];
nn = find(fname ~= '''');   % fopen does not like quotes in path name.
fnamenq = fname(nn);
fid = fopen(fnamenq,'r');

if fid > -1
  bv = fscanf(fid,'%f',1);    % Get version number at clients site.
  fclose(fid);

  function_name = 'updateversion';
  loaddods([guiserver function_name]);  % Read remote file with current update version number
  if exist('content')
    line = content(1,:);              % Get current line%    lineLength = size(temp,2);
    nn = findstr(line,'.');
    if length(nn) >= 2
      uv = str2num(line(1:nn(2)-1));
    else
      uv = str2num(line);
    end
  else
    str = sprintf('%s  ', ...
	'Warning: unable to determine update site version!', ...
	'Updating may create files incompatible with your DODS browser.', ...
	'Abort the update now?');
    quitnow = dodsquestdlg(str, 'DODS ERROR', ...
	'Yes', 'No (resume)', 'Yes', dods_colors);
    if strcmp(quitnow(1:2),'Ye')
      errquit = 1;
    else
      errquit = 0;
    end
    if errquit
      return
    end
  end

  if isempty(uv)    % Now compare the version numbers
    str = sprintf('%s  ', ...
          'Warning: unable to determine update site version!', ...
	  'Updating may create files incompatible with your DODS browser.', ...
	  'Abort the update now?');
    quitnow = dodsquestdlg(str, 'DODS ERROR', ...
	  'Yes', 'No (resume)', 'Yes', dods_colors);
    if strcmp(quitnow(1:2),'Ye')
      errquit = 1;
    else
      errquit = 0;
      uv = 0;
    end
    if errquit
      return
    end
  end

  % THIS IS THE CRITERION FOR WARNING THE USER
  % A minor version change of 0.1
  if uv-bv >= 0.1
    str = sprintf('%s  ', ...
	  'Warning: The files on the update site are a more recent version!', ...
	  [ 'Your version is: ' num2str(bv), ...
	    '.  The update site version is: ' num2str(uv) '.'], ...
	  'Updating may create files incompatible with your DODS browser.', ...
	  'Abort the update now?');
    quitnow = dodsquestdlg(str, 'DODS ERROR', 'Yes', 'No (resume)', ...
	  'Yes', dods_colors);
    if strcmp(quitnow(1:2),'Ye')
      errquit = 1;
    else
      errquit = 0;
    end
    if errquit
      return
    end
  else
    % there is no version difference or only a minor one.
    % tell the user that all is well.
    % NOTE: 7/10/2002
    % WE DON'T HAVE THE FACILITY TO DO THIS RIGHT NOW.
    % DODSMSG COULD USE A BIG UPDATE -- IT IS HACKED TO USED
    % WAITFORBUTTONPRESS TO SUPPORT THE DEC SYSTEM, WHICH
    % DID NOT RECOGNIZE THE 'modal' DIALOG flag.  IF DODSMSG
    % WAS REWRITTEN TO USE 'windowstyle' (see msgbox.m), THEN
    % WE COULD HAVE A NON-MODAL, CONVERSATIONAL MESSAGE POP UP,
    % ALLOWING EXECUTION TO CONTINUE UNDERNEATH.  PLUS, WE
    % COULD SUPPORT TWO MODES FOR THE TEXT INTERFACE AS WELL.
  end
else % could not open updateversion.m on local system
  str = sprintf('%s  ', ...
	'Warning: unable to determine update site version!', ...
	'Updating may create files incompatible with your DODS browser.', ...
	'Abort the update now?');
  quitnow = dodsquestdlg(str, 'DODS ERROR', 'Yes', 'No (resume)', ...
	'Yes', dods_colors);
  if strcmp(quitnow(1:2),'Ye')
    errquit = 1;
  else
    errquit = 0;
  end
  if errquit
    return
  end
end
  
%****************** MAKE THE LOCAL DATASETS DIRECTORY *******************

% It is OK if it already exists. We have to go thru some shenanigans 
% because matlab 'mkdir' makes only relative directories.

dirsep = '/';
c = computer;
if strcmp(c(1:2),'PC')
  dirsep = '\';
elseif strcmp(c(1:2),'MA')
  dirsep = ':';
end
l = max(findstr(datadir(1:length(datadir)-1),dirsep));
parent = datadir(1:l);
nn = find(parent ~= '''');   % mkdir does not like quotes in path name.
parentnq = parent(nn);
reldir = datadir(l+1:length(datadir)-1);
nn = find(reldir ~= '''');   % mkdir does not like quotes in path name.
reldirnq = reldir(nn);
status = mkdir(parentnq, reldirnq);
if status == 0
  str = sprintf('%s\n%s', 'Destination folder does not exist or ', ...
      'cannot be created.  Please try again.');
  dodsmsg(str)
  return
else
  nn = find(datadir ~= '''');   % addpath does not like quotes in path name.
  datadirnq = datadir(nn);
  addpath(datadirnq)
end

%********************* NOW GET THE MANIFEST *************************

fname = [datadir 'MANIFEST'];
err = getfunction( guiserver, 'MANIFEST', datadir); 

if err
  str = sprintf('%s\n%s','       Unable to retrieve new manifest', ...
      '       Please contact DODS support at support@unidata.ucar.edu');
  dodsmsg(str)
  return
end

% initialize arguments
newlist = '';
variables = '';
fatal_archive_list = '';
bad_archive_list = '';
archerr = [];
pos = 1;
function_name_list = '';
linenumber = 1;

% read through the manifest and close the file
disp('Reading MANIFEST ...')
nn = find(fname ~= '''');
fnamenq = fname(nn);
fid = fopen(fnamenq,'r');
files = fscanf(fid,'%c');
fclose(fid);
lines = findstr(files,setstr(10));
numlines = length(lines);
% add a final newline character if missing
if lines(numlines) < length(files)
  numlines = numlines + 1;
  files = [files setstr(10)];
  lines = [lines length(files)];
end
lines = [0 lines];

% start reading individual arguments
disp('evaluating archive files ...')
t0 = clock;
while linenumber <= numlines
  line = files((lines(linenumber)+1):(lines(linenumber+1)-1));
  if etime(clock,t0) > 10
    disp('still evaluating archive files ...')
    t0 = clock;
  end
%
%  Strip out any comments from the line. Note that some lines may have
%  more than one comment character in them, strip from the first.
%
  ii = min(findstr(line,'%'));  
  if ~isempty(ii)
    line = line(1:ii(1)-1);
  end

  while isempty(deblank(line)) % if line is blank, read next
    linenumber = linenumber + 1;
    line = files((lines(linenumber)+1):(lines(linenumber+1)-1));
    ii = min(findstr(line,'%'));
    if ~isempty(ii)
      line = line(1:ii-1);
    end
  end

  % at this point we should have a readable line
  while ~isempty(findstr(line,'  ')) % get rid of extraneous whitespace
    line = strrep(line,'  ',' ');
  end
  line = deblank(line);
  spaces = findstr(line,' '); % find number of files on the line
  numargs = length(spaces)+1;
  spaces = [0 spaces length(line)+1];
  for whicharg = 1:numargs
    function_name = deblank(line((spaces(whicharg)+1):(spaces(whicharg+1)-1)));
    new = 1; 
    
    % Check to see if we've fetched THIS function during THIS update 
    % procedure.
    if new
      for i = 1:size(function_name_list,1)
	if strcmp(deblank(function_name_list(i,:)), function_name)
	  new = 0;
	  break
	end
      end
    end
    
    if new % if STILL new, add to list 
      function_name_list = str2mat(function_name_list, ...
	  function_name);
      % obtain the function
      err = getfunction(guiserver, [function_name '.m'], datadir); % function_name does not have .m on it.
      
      if ~err & whicharg == 1       % We have a new archive.m file
	% put the archive info into the database
	eval(['clear ' function_name])
	newvariables = '';
	% this step will catch inoperative archive.m files, prevent
	% them from being added to the browser, and alert the user.
	[newdata, newvariables, evalerr] = addarchive(function_name, ...
	    variables);
	if isnan(evalerr)
	    fatal_archive_list = str2mat(fatal_archive_list,function_name);
	else
	  % take care of completely empty list dbyrne: 2002/04/10
	  if isempty(newlist)
	    newlist = newdata;
	  else
	    newlist(pos) = newdata;
	  end
	  if ~isempty(newvariables)
	    [newlist, variables] = addvariables(newlist, variables, ...
		newvariables, pos);
	  end
	  if evalerr > 0
	    archerr = [archerr evalerr];
	    bad_archive_list = str2mat(bad_archive_list,function_name);
	  end
	  pos = pos+1;
	end
      end
    end % end of checking whether function is NEW or not.
    
  end % end of looping through args on one line (whicharg)
  linenumber = linenumber + 1;
end % end of while loop thru MANIFEST.

% report all errors to the user
fatal_archive_list = fatal_archive_list(2:size(fatal_archive_list,1),:);
str = '';
if ~isempty(fatal_archive_list)
  str = sprintf('%s\n', ...
      'Fatal errors, preventing the dataset from being added', ...
      'to the browser, were encountered in the following file(s):');
  for i = 1:size(fatal_archive_list,1)
    str = sprintf('%s%s\n',str, deblank(fatal_archive_list(i,:)));
  end
  str = sprintf('%s\n', str);
end
if ~isempty(archerr)
  bad_archive_list = bad_archive_list(2:size(bad_archive_list,1),:);
  str = sprintf('%s%s\n%s\n', str, ...
      'Non-fatal errors were encountered in the following file(s):', ...
      [ 'Filename' sprintf('\t\t') 'number of errors']);
  for i = 1:length(archerr)
str = sprintf('%s%s\t\t%i\n', str, ...
	pad(deblank(bad_archive_list(i,:)),8), archerr(i));
  end
  str = sprintf('%s\n\n%s', str, ...
      'Please examine the above files and correct all errors before continuing.');
end
if ~isempty(str)
  dodsmsg(str)
end

newlist = newlist(:);

% Lastly, do some basic checks of array integrity
if allsizesok(newlist, variables)

%  THERE IS SOME REASON THIS IS NEVER USED: WHY???  I FORGET.
%  % Eliminate any variables with no datasets associated!
%  dataprops = cat(1,newlist(:).dataprops);
%  i = find(sum(dataprops) == 0);
%  if ~isempty(i)
%    j = find(sum(dataprops) > 0);
%    dataprops = dataprops(:,j);
%    variables = variables(j,:);
%  end
%
%  for i = 1:size(newlist,1)
%    newlist(i).dataprops = dataprops(i,:);
%  end

  % alphabetize the master variables list
  dataprops = cat(1,newlist(:).dataprops);
  tmplist = lower(variables);
  [inx] = alphabet(tmplist);
  variables = variables(inx,:);
  dataprops = dataprops(:,inx);
  for i = 1:size(newlist,1)
    newlist(i).dataprops = dataprops(i,:);
  end
  
  % alphabetize the master datasets list
  showlist = char(newlist(:).name);
  [inx] = alphabet(lower(showlist));
  newlist = newlist(inx);

  % cache the master list information
  masterlist = newlist;
  masterlist = dlist2slist(masterlist);
  master_variables = variables;
  
  disp('Caching the new information in brsdat2.mat ...')
  fname = [dodsdir 'brsdat2'];
  string = [' masterlist master_variables'];
  eval(['save ' fname string])
  
  % NOW UPDATE THE USERLIST DATABASE
  newuserlist = inlist;
  newuservariables = invars;
  userdataprops = cat(1,newuserlist(:).dataprops);
  s1 = size(userdataprops);
  dataprops = cat(1,newlist(:).dataprops);
  s2 = size(dataprops);

  % the list generated from the new MANIFEST is variables while the 
  % old user-list is in newuservariables.
  [index, addvars] = compvars(newuservariables, variables);

  if ~isempty(addvars)
    % rearrange the master dataprops so that any variables
    % not on the current userlist are on the righthand side.
    newdataprops = zeros(s2(1),s1(2)+size(addvars,1));
    newdataprops(:,index) = dataprops;
    
    % add new variables at end of uservariables
    newuservariables = str2mat(newuservariables, addvars);
    % pad columns of user dataprops w/zeros for the new variables
    userdataprops = [userdataprops zeros(s1(1),size(addvars,1))];
    for i = 1:s1(1)
      newuserlist(i).dataprops = userdataprops(i,:);
    end
  else
    newdataprops = zeros(s2(1),s1(2));
    % none of the variables are new -- just make sure in same
    % order and columns of zeros for missing ones.
    newdataprops(:,index) = dataprops;
  end
  
  % now check the archive names of the newly downloaded stuff.
  % if the archive name doesn't match anything on the userlist,
  % add the new archive on the end of the list.
  % But if the new archive name matches one on the user list,
  % replace selected information -- things that are preserved
  % are the user's bookmark name, color, and folder level.
  newFileCounter = 0;
  for i = 1:size(newlist,1)
    pos = size(newuserlist,1)+1;
    isoldarchive = 0;

    for j = 1:size(newuserlist,1)
      if ~isfolder(newuserlist,j) & ~isendfolder(newuserlist,j)
	if strcmp(deblank(newlist(i).archive), ...
	      deblank(newuserlist(j).archive))
	  pos = j;
	  isoldarchive = 1;
	  break
	end
      end
    end
    if isoldarchive
      % preserve some things
      newcolor = newuserlist(pos).color;
      newname = newuserlist(pos).name;
      level = newuserlist(pos).nestinglevel;
      % REFRESH THE DATASET
      newuserlist(pos) = newlist(i);
      newuserlist(pos).dataprops = newdataprops(i,:);
      % restore the preserved values
      newuserlist(pos).color = newcolor;
      newuserlist(pos).name = newname;
      newuserlist(pos).nestinglevel = level;
    else
      % ADD A NEW DATASET - Create New data set folder if this is the first new data set.
      newFileCounter = newFileCounter + 1;
      if newFileCounter == 1
        % MAKE A FOLDER FOR THE NEW DATASETS
         newuserlist(pos).name = [folder_start 'New Datasets'];
         newuserlist(pos).archive = '';
         newuserlist(pos).color = dods_colors(6,:);
         newuserlist(pos).dataname = '';
         newuserlist(pos).rangemin = [nan nan nan nan];
         newuserlist(pos).rangemax = [nan nan nan nan];
         newuserlist(pos).resolution = nan;
         newuserlist(pos).getxxx = '';
         newuserlist(pos).dataprops = zeros(1,size(userdataprops,2));
         newuserlist(pos).nestinglevel = 0;
         newuserlist(pos).open = 0;
         newuserlist(pos).string = '';
         newuserlist(pos).fontweight = 'bold';
         newuserlist(pos).show = 1;
         newuserlist(pos).URLinfo = [];
      end
      newuserlist(pos) = newlist(i);
      newuserlist(pos).dataprops = newdataprops(i,:);
      newuserlist(pos).nestinglevel = 1;
    end
  end

  % end of new folder
  pos = size(newuserlist,1);
  newuserlist(pos+1).name = folder_end;
  newuserlist(pos+1).archive = '';
  newuserlist(pos+1).color = dods_colors(6,:);
  newuserlist(pos+1).dataname = '';
  newuserlist(pos+1).rangemin = [nan nan nan nan];
  newuserlist(pos+1).rangemax = [nan nan nan nan];
  newuserlist(pos+1).resolution = nan;
  newuserlist(pos+1).getxxx = '';
  newuserlist(pos+1).dataprops = zeros(1,size(userdataprops,2));
  newuserlist(pos+1).nestinglevel = 1;
  newuserlist(pos+1).open = 0;
  newuserlist(pos+1).string = '';
  newuserlist(pos+1).fontweight = 'normal';
  newuserlist(pos+1).show = 0;
  newuserlist(pos+1).URLinfo = [];

  % lastly, re-alphabetize the user variables and dataprops
  newdataprops = cat(1,newuserlist(:).dataprops);
  tmplist = lower(newuservariables);
  [inx] = alphabet(tmplist);
  newuservariables = newuservariables(inx,:);
  newdataprops = newdataprops(:,inx);
  for i = 1:size(newuserlist,1)
    newuserlist(i).dataprops = newdataprops(i,:);
  end

  dodsmsg('Update has finished successfully!')

  % SUCCESS
  val = 0;
  outlist = newuserlist;
  outvars = newuservariables;
else
  % there is serious trouble with one of the array sizes
  dodsmg([ 'Unable to complete update! Your bookmarks have ', ...
	' not been changed'])
end
return

