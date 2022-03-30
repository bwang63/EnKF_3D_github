function copyright

% copyright -- Emit the copyright message.
%  copyright (no arguments) displays the
%   copyright message.

% Copyright (C) 1997 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without written explicit consent from the
%    copyright owner does not constitute publication.

disp([' '])
disp(['% Copyright (C) 1997 Dr. Charles R. Denham, ZYDECO.'])
disp(['%  All Rights Reserved.'])
disp(['%   Disclosure without explicit written consent from the'])
disp(['%    copyright owner does not constitute publication.'])
disp([' '])
theDate = datestr(now);
disp(['% Version of ' theDate '.'])
disp([' '])
disp(['% Started    ' theDate '.'])
disp(['% Revised    ' theDate '.'])
disp(['% Updated    ' theDate '.'])
disp([' '])
