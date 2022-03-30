function theStatus = uisetdir(thePrompt, theInstruction)

% uisetdir -- Open the destination folder via dialog.
%  uisetdir('thePrompt', 'theInstruction') presents the "uiputfile"
%   dialog with 'thePrompt' and 'theInstruction', for selecting the
%   desired destination folder.  The returned status is logical(1)
%   if successful; otherwise, logical(0).
 
% Copyright (C) 1997 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.
 
% Version of 03-Jul-1997 09:16:00.

if nargin < 1, thePrompt = 'Open The Destination Folder'; end
if nargin < 2, theInstruction = 'Save If Okay'; end

theFile = 0; thePath = 0;
[theFile, thePath] = uiputfile(theInstruction, thePrompt);

status = 0;                
if isstr(thePath) & any(thePath)
   status = 1;
   eval('cd(thePath)', 'status = 0;')
end

if nargout > 0, theStatus = any(any(status)); end
