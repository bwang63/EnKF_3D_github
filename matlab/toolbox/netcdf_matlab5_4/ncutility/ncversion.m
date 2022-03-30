function theNCVersion = NCVersion
 
% NetCDF Toolbox For Matlab-5 Version of 05-Sep-1997 08:58:30.

%  NCVersion (no argument) returns or displays the modification
%   date of the current "NetCDF Toolbox For Matlab-5".
 
% Copyright (C) 1997 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.
 
% Version of 05-Sep-1997 08:58:30.

theVersion = '11-Feb-1998 11:05:41';   % <== Put version-date here.

if nargout < 1
   disp([' ## NetCDF Toolbox For Matlab-5.'])
   disp([' ## Version of ' theVersion '.'])
else
   theNCVersion = theVersion;
end
