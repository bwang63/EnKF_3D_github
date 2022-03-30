function idx = firstOccur(vector)
% - returns indices of the first occurrence of unique elements of input vector
%
% USAGE: idx = f_firstOccur(vector)

% by Dave Jones,<djones@rsmas.miami.edu> July-2002
% http://www.rsmas.miami.edu/personal/djones/
% ----------------- DISCLAIMER: -------------------
% This code is provided as is, with no guarantees
% and is only intended for non-commercial use.
% --------------------------------------------------

theElements = unique(vector); % get unique elements of input vector
theElements = theElements(:); % make sure it's a column vector
noRows = size(theElements,1); 

for i = 1:noRows
   idx(i) = min(find(theElements(i) == vector));
end

idx = idx(:); % make sure it's a column vector