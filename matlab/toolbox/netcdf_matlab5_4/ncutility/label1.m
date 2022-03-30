function Label1(theLabel, theLocation)

% Label1 -- Label the plot1 axes.
%  Label1('theLabel', 'theLocation') places 'theLabel' at
%   'theLocation', one of {'xlabel', 'ylabel', 'zlabel',
%   'title'}; default = 'ylabel'.  The "plot1" axes is
%   used.
 
% Copyright (C) 1997 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.
 
% Version of 06-May-1997 15:48:32.

if nargin < 1, help(mfilename), return, end
if nargin < 2, theLocation = 'ylabel'; end

plot1
feval(theLocation, theLabel)
