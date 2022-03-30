function theResult = ncclose(theNCid)

% ncclose(theNCid) closes the netcdf files whose
%  identifiers are the given theNCid.  The default
%  is 'all', which uses theNCid = [0:15]; end
 
% Copyright (C) 1996 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.

if nargin < 1, theNCid = 'all'; end

if strcmp(theNCid, 'all'), theNCid = 0:15; end

theNCid = -sort(-theNCid);

for i = 1:length(theNCid)
   status(i) = mexcdf('close', theNCid(i));
end

if nargout > 0
   theResult = status;
  else
   for i = 1:length(theNCid)
      if status(i) >= 0
         disp([' ## closed: ncid = ' int2str(theNCid(i)) '.'])
      end
   end
end
