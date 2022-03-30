function files = rnt_getfilenames(direc,prefix,order)
% function files = rnt_getfilenames(direc,prefix,order)
%   prefix = e.g. 'his' | 'roms_his' | 'avg' etc to specify file list
%   direc = path to files (optional) (default is './')
%   order (optional) = 'date' sort by creation date
%                    = 'name' sort by name (default)
%                    = anything else, sort by name
% e.g.:
%
%   files = roms_getfilenames('his');
%   files = roms_getfilenames('his','./','date');

if nargin < 2
  direc = './';
end
if nargin < 3
  order = 'name';
end

% directory listing
% [ direc '/*' prefix '*']
d = dir([ direc '/*' prefix '*']);

% extract name and date information
for i=1:size(d,1)
  dates(i) = datenum(d(i).date);
  names(i,:) = d(i).name;
end

% sort names 
switch order
  case 'name'
    names = sortrows(names);
  case 'date'
    [dates,ilist] = sort(dates); 
    names = names(ilist,:);
  otherwise
    % default to name search
    names = sortrows(names);
end

% prepend the directory to the names, and reorder if necessary
for i=1:size(d,1)
  files{i} = [direc '/' names(i,:)];
end

% advice user on what to do next
% disp([ 'Now create ctl structure to access this file list: '])
% disp([ 'ctl = rnt_timectl(files,''ocean_time'');'])
