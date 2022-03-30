function silent(annoying)

% Silent -- Disable beep-on-error.
%  Silent (no argument) disables the beep-on-error.
%  Silent(annoying) enables it, for any non-zero
%   scalar argument.
 
% Copyright (C) 1997 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.
 
% Version of 25-Jun-1997 09:53:25.

if nargin < 1, annoying = 0; end

if any(findstr(computer, 'MAC'))
   system_dependent(14, ~isequal(annoying, 0));
else
   disp(' ## For Macintosh only.')
end
