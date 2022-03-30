function [nameout, indexout] = sortjgz(namein, indexin)

%
%
%

% klee 09/2000

nameout = [];  indexout = [];  push = [];
for i = [1 3 5]
  theindex = find(indexin == i)
  if length(theindex) >= 1
    if isempty(push)
      nameout = strvcat(nameout, deblank(namein(theindex(1),:)));
      indexout = [indexout, i];
      push = i;
    else
      if ~any(push == i)
        push = [push, i];
        indexout = [indexout, i];
        nameout = strvcat(nameout, deblank(namein(theindex(1),:)));
      end
    end
  end
end

return
