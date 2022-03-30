function outlist = dlist2slist(inlist)
% Userlist.name is the bookmark name.
% Nestinglevel 0 is the top folder or unsorted datasets.
% If you make a folder, it's at parent level 
% and its contents and endfolder are one level down.
%
% Userlist.string is the name with folder and endfolder symbols 
% removed and proper indentation, userlist.open is the
% open/shut boolean (only can be 1 for folders), and 
% userlist.show is the SHOW/Don't SHOW Boolean (calculated here).

% This function generates userlist.show from the
% userlist.nestinglevel and userlist.open.

if nargin < 1
  error('usage: NEWLIST = DLIST2SLIST(OLDLIST);')
  return
end

global indent_prefix folder_start folder_end 

% used only locally
global closed_folder_prefix opened_folder_prefix
global closed_folder_suffix opened_folder_suffix
indent_prefix = 3; 
closed_folder_prefix = '[+] ';
closed_folder_suffix = ' -->>'; 
opened_folder_prefix = '[-] ';
opened_folder_suffix = ':';
notfolderindent = size(opened_folder_prefix,2)+1;
bold_folder_prefix = '{\it{';
bold_folder_suffix = '}}';
bold_dataset_prefix = 'o {\it{';
bold_dataset_suffix = '}}';

if isempty(inlist)
  outlist = inlist;
  return
end

% initialize and set up local variables
prefix = '';
level = cat(1,inlist.nestinglevel);
psize = size(folder_start,2);
ssize = size(folder_end,2);
len = max(psize,ssize);

% figure out the first entry, which will ALWAYS SHOW
showstring = deblank(inlist(1).name);
if isfolder(inlist,1) % is a folder
  if inlist(1).open == 1
    % show open folder w/open folder symbol
    if strcmp(inlist(1).fontweight,'bold')
      % set italicization
      showstring = [opened_folder_prefix ...
	    bold_folder_prefix ...
	    showstring(psize+1:length(showstring)) ...
	    bold_folder_suffix ...
	    opened_folder_suffix];
    else
      showstring = [opened_folder_prefix ...
	    showstring(psize+1:length(showstring)) ...
	    opened_folder_suffix];
    end
  else
    % show closed folder, w/closed folder symbol
    if strcmp(inlist(1).fontweight,'bold')
      % set italicization
      showstring = [closed_folder_prefix ...
	    bold_folder_prefix ...
	    showstring(psize+1:length(showstring)) ...
	    bold_folder_suffix ...
	    closed_folder_suffix];
    else
      showstring = [closed_folder_prefix ...
	    showstring(psize+1:length(showstring)) ...
	    closed_folder_suffix];
    end
  end
  inlist(1).string = showstring;
else % first entry cannot be an endfolder symbol, so it must be
  % a dataset.  Set the string.
  % set italicization
  if strcmp(inlist(1).fontweight,'bold')
    showstring = [bold_dataset_prefix showstring bold_dataset_suffix];
  end
  inlist(1).string = [blanks(notfolderindent) showstring];
end


for i = 2:size(inlist,1);
  % check for begin and endfolder symbols ...
  showstring = deblank(inlist(i).name);
  if isfolder(inlist,i) % is a folder
    prefix = blanks(indent_prefix*level(i));
    if inlist(i).open == 1
      % show open folder w/open folder symbol
      if strcmp(inlist(i).fontweight,'bold')
	% set italicization
	showstring = [prefix opened_folder_prefix ...
	      bold_folder_prefix ...
	      showstring(psize+1:length(showstring)) ...
	      bold_folder_suffix ...
	      opened_folder_suffix];
      else
	showstring = [prefix opened_folder_prefix ...
	      showstring(psize+1:length(showstring)) ...
	      opened_folder_suffix];
      end
    else
      % show closed folder w/closed folder symbol
      if strcmp(inlist(i).fontweight,'bold')
	% set italicization
	showstring = [prefix closed_folder_prefix ...
	      bold_folder_prefix ...
	      showstring(psize+1:length(showstring)) ...
	      bold_folder_suffix ...
	      closed_folder_suffix];
      else
	showstring = [prefix closed_folder_prefix ...
	      showstring(psize+1:length(showstring)) ...
	      closed_folder_suffix];
      end
    end
    inlist(i).string = showstring;
    if level(i) > 0
      % find next level up
      q = max(find(level(1:i-1) == level(i) - 1));
      if inlist(q).open == 1 & inlist(q).show == 1
	inlist(i).show = 1;
      else
	inlist(i).show = 0;
      end
    else
      inlist(i).show = 1;
    end
  
  elseif isendfolder(inlist,i) % is an endfolder.  Don't show anything
      inlist(i).string = '';
      inlist(i).open = 0;
      inlist(i).show = 0;
  else % is a normal entry
    prefix = blanks(indent_prefix*level(i)+notfolderindent);
    % set italicization
    if strcmp(inlist(i).fontweight,'bold')
      showstring = [bold_dataset_prefix showstring bold_dataset_suffix];
    end
    showstring = [prefix showstring];
    inlist(i).string = showstring;
    if level(i) > 0
      % find parent folder
      q = max(find(level(1:i-1) == level(i) - 1));
      % find out if it's open and find out if it's visible
      % open is open/shut and show is visible/not visible
      % if both open and visible, show this dataset.
      if inlist(q).open == 1 & inlist(q).show == 1
	inlist(i).show = 1;
      else
	inlist(i).show = 0;
      end
    else
      % it's a top-level dataset, not in any folder.  Show it.
      inlist(i).show = 1;
    end
  end

end

% how to see what will show:
%i = cat(1,inlist(:).show);
%i = find(i);
%str = char(inlist(:).string);
%disp(str(i,:))

if nargout > 0
  outlist = inlist;
end
return
