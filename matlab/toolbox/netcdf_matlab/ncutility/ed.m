function ed(varargin)

% ed -- Edit one or more files.
%  ed(varargin) opens each of the given files
%   in reverse-order, after setting the default
%   to its directory.

% Copyright (C) 1996 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without written consent from the
%    copyright owner does not constitute publication.

if length(varargin) < 1, varargin{1} = 'ed'; end

for i = length(varargin):-1:1
   if isstr(varargin{i})
      setdef(varagin{i})
      eval(['edit ' varargin{i}])
   end
end
