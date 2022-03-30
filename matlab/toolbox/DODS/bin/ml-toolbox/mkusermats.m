function [dataprops, lonmin, lonmax] = mkusermats(inlist)

% MKUSERMATS  Make DODS GUI user matrices from user bookmarks dataset.
%
% USAGE:      mkusermats(bookmark_list)
%

% Deirdre Byrne, dbyrne@umeoce.maine.edu, 10/07/00

if nargin < 1
  disp('Usage: mkusermats(userlist)')
  return
end

% generate new lists from userlist
dataprops = cat(1,inlist(:).dataprops);
lonmin = nan*ones(size(dataprops,1),2);
lonmax = nan*ones(size(dataprops,1),2);

for i = 1:size(dataprops,1)
  x = xrange('range', [-180 180 -90 90], ...
      [inlist(i).rangemin(1) inlist(i).rangemax(1)]);

  lonmax(i) = x(2);
  if max(size(x) == 2)
     lonmin(i) = x(1);
  else
     lonmin(i) = x(3);
  end

end

return
