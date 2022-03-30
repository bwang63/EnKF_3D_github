function illegal(theOperation)

% illegal -- Issue a warning about an illegal operation.
%  illegal ('theOperation') issues a warning message
%   that theOperation (default = 'previous') is illegal.
 
% Copyright (C) 1997 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.

if nargin < 1, theOperation = 'previous'; end

warning([' ## The ' theOperation ' operation is illegal.'])
