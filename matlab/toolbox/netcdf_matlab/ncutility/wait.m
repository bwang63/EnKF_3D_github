function wait(theSeconds)

% wait -- Wait for a given amount of time.
%  wait(theSeconds) waits until until theSeconds
%   have elapsed.  Default = 1 second.
 
% Copyright (C) 1997 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.
 
% Version of 02-Oct-1997 13:26:55.

if nargin < 1, theSeconds = 1; end

tic
while toc < theSeconds, end
