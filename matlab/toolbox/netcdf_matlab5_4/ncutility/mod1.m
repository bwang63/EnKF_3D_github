function theResult = Mod1(theIndices, theSize)

% Mod1 -- Modulo reduction of base-1 indices.
%  Mod1(theIndices, v) adjusts base-1 theIndices to fall
%   within the domain of theSize.  Thus, if theIndices = [16 5]
%   with theSize = [3 4 5], then the adjusted indices = [1 2 3].
%   Partial indices are padded with ones before adjustment.
 
% Copyright (C) 1997 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.
 
% Version of 06-Jun-1997 13:24:45.

if nargin < 1, help(mfilename), theIndices = 'demo'; end

if strcmp(theIndices, 'demo')
   theIndices = [19 4];
   theSize = [3 4 5];
   w = mod1(theIndices, theSize);
   begets('mod1', 2, theIndices, theSize, w)
   return
end

if length(theIndices) > length(theSize)
   error(' ## The length of the indices is too great.')
  elseif any(theIndices < 1) | any(theSize < 1)
   error(' ## The indices and sizes must be positive.')
end

theIndices = theIndices(:).'; theSize = theSize(:).';
while length(theIndices) < length(theSize)
   theIndices = [theIndices 1];
end

k = 2:length(theIndices);

result = theIndices - 1;
for i = 1:length(result)
   temp = result;
   result = rem(result, theSize);
   temp = temp - result;
   result(k) = result(k) + (temp(k-1) ./ theSize(k-1));
end
result = result + 1;

if nargout > 0
   theResult = result;
  else
   disp(result)
end
