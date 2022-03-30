function theResult = size(self)

% ncrec/size -- Size (dimensions) of an ncrec object.
%  size(self) returns the size (dimensions) of
%   self, an ncrec object.
 
% Copyright (C) 1997 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.
 
% Version of 07-Aug-1997 16:01:38.

% (N.B. We will want to
%  return a cell-list of sizes, I think.)

if nargin < 1, help(mfilename), return, end

theNCid = ncid(self);
[theSize] = ncmex('recinq', theNCid);

if nargout > 0
   theResult = theSize;
else
   disp(theSize)
end
