function up(nLevels)

% up -- Move to shallower directory.
%  up(nLevels) sets the default directory
%   nLevels shallower (default = 1).

% Copyright (C) 1996-7 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without written consent from the
%    copyright owner does not constitute publication.

if nargin < 1, nLevels = 1; end
if isstr(nLevels), nLevels = eval(nLevels); end

for i = 1:nLevels, cd .., end

disp([' ## ' pwd])
