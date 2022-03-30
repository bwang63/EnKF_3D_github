function [x, varargout] = dodssort(std, varargin)

%
%  [x, varargout] = dodssort(std, varargin)
%
%  Given two vectors, sort and elimilate redundant elements,
%  and arrange the rest of the argins according to the first sorted std
%  For example,  std = [1 5 3];
%                vector2 = ['a','b','c'];
%                x returns [1 3 5]
%                varargout returns ['a','c','b']
%

%
%

x = [];  varargout = [];
tmp = [];  tmptmp = [];  tmpstd = [];  keep = [];  push = [];
n = nargin;  
if n == 1
  x = varargin{1};
  return
else
  sortedstd = sort(std);
  sortedstd = [sortedstd sortedstd(length(sortedstd))+1];
  for i = 1:length(sortedstd)-1
    if (sortedstd(i+1) - sortedstd(i)) ~= 0
      keep = [keep i];
    end
  end
  sortedstd = sortedstd(keep);
  for i = 1:n-1
    tmp = varargin{i};
    for j = 1:length(sortedstd)
      for k = 1:length(std)
        if sortedstd(j) == std(k)
          if isempty(push)
            push = std(k);
            tmptmp = strvcat(tmptmp, tmp(k,:));
          else
            if ~any(push == std(k))
              push = [push, std(k)];
              tmptmp = strvcat(tmptmp, tmp(k,:));
            end
          end
        end
      end  
    end
    varargout{i} = tmptmp;
  end
  x = sortedstd;
end

return

