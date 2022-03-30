function [index, outlist] = compvars(oldlist, newlist)
% find which things on the newlist are not on the oldlist
index = zeros(size(newlist,1),1);

for j = 1:size(newlist,1)
  arg1 = deblank(newlist(j,:));

  for i = 1:size(oldlist,1)
    arg2 = deblank(oldlist(i,:));

    if strcmp(arg1, arg2)
      index(j) = i;
      break
    end
      
  end
  
end

% find the variables that had no comparison
addvars = find(index == 0);
outlist = '';
if ~isempty(addvars)
  outlist = newlist(addvars,:);
  index(addvars) = (1:length(addvars))+size(oldlist,1);
end

return
