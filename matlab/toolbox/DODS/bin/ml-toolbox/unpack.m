% UNPACK  Part of the DODS data browser (browse.m)
%
%            Deirdre Byrne, University of Maine, 21 Dec 2000
%                 dbyrne@umeoce.maine.edu
%

% if nothing came back, clean up and quit
if exist('browse_count') ~= 1 | exist('browse_acq_urls') ~= 1
  if exist('browse_clear_button') == 1
    set(browse_clear_button,'enable','on'); clrvars
  end
  return
end

% if the number of urls is 0, clean up and quit
if browse_acq_urls < 1
  if exist('browse_clear_button') == 1
    set(browse_clear_button,'enable','on'); clrvars
  end
  return
end

% find out what variables have been returned
for browse_i = 1:browse_acq_urls
  browse_j = browse_count+browse_i-1;
  browse_string = sprintf('browse_w = whos(''R%i_*'');', browse_j);
  eval(browse_string);
  browse_whos(browse_i).name = char(browse_w.name);
  browse_k = cell(size(browse_w));
  [browse_k{:}] = deal(browse_w.size);
  browse_whos(browse_i).size = browse_k;
  % NOTE: Not using the DataRange any more for scaling.
  % we are letting the user choose scaling. -- dbyrne, 00/01/10
  %browse_whos(browse_i).datarange = browse_data_range{browse_i};
end

% Find any variables that are empty
browse_data_list = ''; 
for browse_i = 1:browse_acq_urls
  browse_sz = size(browse_whos(browse_i).size,1);
  browse_empty = zeros(browse_sz,1);
  for browse_j = 1:browse_sz
    if any(browse_whos(browse_i).size{browse_j} == 0)
      browse_empty(browse_j) = 1;
    end
  end

% Delete them from the workspace and update the variables database
if any(browse_empty)
    eval(sprintf('clear %s ',browse_whos(browse_i).name(find(browse_empty),:)'))
    browse_whos(browse_i).name = ...
	browse_whos(browse_i).name(find(~browse_empty),:);
    browse_whos(browse_i).size = ...
	browse_whos(browse_i).size(find(~browse_empty),:);
    %browse_whos(browse_i).datarange = ...
    %    browse_whos(browse_i).datarange(find(~browse_empty),:);
  end
end

% if no data, exit cleanly
if isempty(strvcat(browse_whos(:).name))
  dodsmsg('This request generated no data')
  set(browse_clear_button,'enable','on'); clrvars
  return
end
  
% show the user what variables have been put in the workspace:
browse_string2 = sprintf('R%i_   ', ...
    browse_count:browse_count+browse_acq_urls-1);
browse_string = sprintf('\n%s%i%s\n%s%s','This request generated ',  ...
    browse_acq_urls, ' separate URLs, ', ...
    'which are stored in the sets:  ', ...
    browse_string2);
browse_string = sprintf('%s\n\n%s\n', ...
    browse_string, ...
    'Each individual argument is stored like so:');

browse_string2 = cellstr(cat(1,browse_whos(1).name));
browse_string = sprintf('%s\n%s\n', browse_string, ...
    browse_string2{:});
dodsmsg(browse_string)

% prevent user from clearing workspace while we're trying to
% manipulate returned variables for plotting
set(browse_clear_button,'enable','off')

% display the plot menu
dispmenu('display', browse_whos, browse_getvariables, browse_count, ...
    browse_metadata)

% clean up the user workspace
clrvars
