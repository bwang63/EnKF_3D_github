function keep(varargin)

% keep -- Opposite of "clear".
%  keep('var1', 'var2', ...) keeps the variables
%   named 'var1', var2', ... in the caller's
%   workspace and clears the rest.  (The non-
%   functional form is "keep var1 var2 ...".)
%  keep (no argument) shows help.
 
% Copyright (C) 1997 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.
 
% Version of 05-Feb-1998 09:16:54.

if nargin < 1, help(mfilename), return, end

w = evalin('caller', 'who');

for j = length(varargin):-1:1
    for i = length(w):-1:1
        if isequal(w{i}, varargin{j})
            w(i) = [];
        end
    end
end

for i = length(w):-1:1
    evalin('caller', ['clear ' w{i}]);
end
