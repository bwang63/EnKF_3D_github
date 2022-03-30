function nofigs

% nofigs -- Delete all existing figures.
%  nofigs (no argument) deletes all existing
%   figures without additional warning.

% Copyright (C) 1996 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without written explicit consent from the
%    copyright owner does not constitute publication.

f = findobj(0);
f(f == 0) = [];
set(f, 'DeleteFcn', '')
f = findobj('Type', 'figure');;
for i = 1:length(f)
   theName = get(f(i), 'Name');
   delete(f(i))
   disp([' ## figure(' num2str(f(i)) ') -- [''' theName '''] -- deleted.'])
end
