function [str_matrix,index] = strisin(strmat1, strmat2, varargin)

%
%  return a str matrix with all the matching str in strmat2
%         index is the member of strmat1 matching strmat2
%
%  Usage:  [str_matrix, index] = strisin(strmat1, strmat2, varargin)
%         varargin could be:  'exact', find the exact match
%                             'all',  find all in strmat2 that match strmat1
%                             [],  find any in strmat2 that match strmat1
% 

str_matrix = [];  index = [];
 
if isempty(strmat1)
  return
elseif isempty(strmat2)
  str_matrix = strmat1;
  index = [1:size(strmat1,1)];
  return
end

if nargin == 2
  for i = 1:size(strmat1,1)
    for j = 1:size(strmat2,1)
      if findstr(deblank(strmat1(i,:)), deblank(strmat2(j,:)))
        str_matrix = strvcat(str_matrix, deblank(strmat1(i,:)));
        index = [index; i];
      end
    end
  end
elseif nargin == 3
  if strcmp(varargin(1), 'exact')
    for i = 1:size(strmat1,1)
      for j = 1:size(strmat2,1)
        if strcmp(deblank(strmat1(i,:)), deblank(strmat2(j,:)))
          str_matrix = strvcat(str_matrix, deblank(strmat1(i,:)));
          index = [index; i];
        end
      end
    end
  elseif strcmp(varargin(1), 'all')
    for i = 1:size(strmat1,1)
      tmpindex = [];  touch = 0;
      for j = 1:size(strmat2,1)
        if findstr(deblank(strmat1(i,:)), deblank(strmat2(j,:)))
          touch = touch + 1;
          tmpindex = [tmpindex; i];
        end
      end
      if touch == size(strmat2,1), index = [index; tmpindex(1)];  end 
      str_matrix = strmat1(index,:);
    end
  end
end

return
