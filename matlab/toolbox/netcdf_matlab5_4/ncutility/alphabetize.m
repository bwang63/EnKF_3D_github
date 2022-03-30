function theResult = Alphabetize(x)

% Alphabetize -- Alphabetize a list of strings.
%  Alphabetize(x) alphabetizes the strings in cell-array x.
%  Alphabetize('demo') demonstrates itself.
 
% Copyright (C) 1997 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.
 
% Version of 15-May-1997 14:21:54.

if nargin < 1, help(mfilename), x = 'demo'; end

if strcmp(x, 'demo')
   original = {'the', 'quick', 'brown', 'fox'}
   alphabetized = alphabetize(original)
   return
end

y = x(:);

switch class(y)
case 'cell'
   maxLen = 0;
   for i = 1:length(y)
      maxLen = max(maxLen, length(y{i}));
   end
   for i = 1:length(y)
      y{i}(maxLen+1) = ' ';
   end
   z = zeros(length(y), maxLen+1);
   for i = 1:length(y)
      z(i, :) = abs(y{i});
   end
   [m, n] = size(z);
   theIndices = 1:m;
   for i = n:-1:1
      [ignore, s] = sort(z(:, i));
      z = z(s, :);
      theIndices = theIndices(s);
   end
   result = x(theIndices);
otherwise
   warning(' ## Requires a cell-array of strings.')
end

if nargout > 0
   theResult = result;
  else
   disp(result)
end
