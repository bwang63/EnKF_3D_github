function o = findnew(x)
%
% FINDNEW returns the position of non-duplicate data in a vector, eg
%
%         x = [4 1 1 2]; i = findnew(x); 
% returns: i = [1 2 4], 
%
%              and
%
%         x = [4 1 1 2]; x = x(findnew(x)); 
% returns: x = [4 1 2].
%
% In the case of duplication, findnew will return the first occurance. 
%
% usage:    i = findnew(x), or x = x(findnew(x)).

% Deirdre Byrne, L-DEO 95/5/12
% Concept the same, new algorithm, 10x faster. D.Byrne, UMO, 98/1/23.
%
x = x(:);
[d n] = sort(x);
x = [1; diff(d)];
o = sort(n([find(x & ~isnan(x)); min(find(isnan(x)))]));
