function [x] = isin(group1,group2)

% ISIN   Find if any elements of Group 1 are members of Group 2.
%
% USAGE    X = ISIN(Group1,Group2);
%
%          X is size(Group1). X(i) = 1 where Group1(i) is in Group2.

if nargin == 2
  if ~isempty(group1) & ~isempty(group2)
    x = zeros(size(group1));
    for i = 1:length(group1)
      if any(group2 == group1(i));
	x(i) = 1;
      end
    end
  else
    x = [];
  end
else
  disp('Usage:  X = isin(group1,group2);')
end
return
