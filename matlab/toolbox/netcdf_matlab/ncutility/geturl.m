function theResult = geturl(theURL, theFilename, theApplication)

% geturl -- Get a URL.
%  geturl('theURL', 'theFilename', 'theApplication') calls an
%   AppleScript to get the file specified by 'theURL' and save
%   it to 'theFilename', using 'theApplication' (default = 'Netscape').
%   If no filename is provided, the "uiputfile" dialog is displayed.
%   If less than the full path is given, the current directory is used.
%   If the given filename is '', the file is opened in Netscape, instead
%   of being saved.  N.B. The selection of application is ignored at
%   present.
 
% Copyright (C) 1997 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.
 
% Version of 10-Sep-1997 16:28:22.

if nargin < 1
   help(mfilename)
   return
end

if ~any(findstr(computer, 'MAC'))
   disp([' ## No action taken: "' mfilename '" requires Macintosh computer.'])
   return
end

if nargin < 2
   [theFile, thePath] = uiputfile('unnamed', 'Save File As');
  if any(theFile)
     theFilename = [thePath theFile];
     disp([' ## Saving to "' theFilename '"'])
  else
     disp(' ## No action taken.')
     return
  end 
end

if nargin < 3, theApplication = 'Netscape'; end

if isequal(theApplication, 'Netscape')
   theApplication = 'Netscape Navigatorª Gold 3.01';
end

theAppleScript = 'geturl.mac';

if ~isempty(theFilename)
   if ~any(theFilename == filesep)
      theFilename = [pwd theFilename];
   end
end

theURL = ['"' theURL '"'];
theFilename = ['"' theFilename '"'];
theApplication = ['"' theApplication '"'];   % Not used.

result = feval('applescript', theAppleScript, ...
               'theURL', theURL, ...
               'theFilename', theFilename, ...
               'theApplication', theApplication);

if ~isempty(result), disp(result), end

result = logical(isempty(result));

if nargout > 0, theResult = result; end
