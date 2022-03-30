function result = f_recode(x)
% recode elements of vector as consecutive integers
% 
% USAGE result = f_recode(x);
% 
% x = column vector of values to be recoded as 
%     consecutive integers

% This function is primarily a fix for f_designMatrix
% which uses Matlab's DUMMYVAR function. It is used,
% for example, to convert treatment levels [2 2 2 5 5 5]
% to [1 1 1 2 2 2] so proper ANOVA design matrices can be
% constructed.

% See also: f_designMatix, dummvar

% by Dave Jones,<djones@rsmas.miami.edu> Nov-2002
% http://www.rsmas.miami.edu/personal/djones/
% ----------------- DISCLAIMER: -------------------
% This code is provided as is, with no guarantees
% and is only intended for non-commercial use.
% --------------------------------------------------

x      = x(:);            %  make sure it's a column vector
list   = sort(unique(x)); % get sorted list of unique values
noRows = size(list,1);   

for i=1:noRows
	x(find(x==list(i))) = i;
end

result = x;