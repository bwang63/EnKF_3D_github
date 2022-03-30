function self = ncitem(theName, theNCid, ...
   theDimid, theVarid, theAttnum, ...
   theRecnum, theRecdimid, theAutoscale)

% ncitem/ncitem -- Constructor for ncitem class.
%  ncitem('theName', theNCid, theDimid, theVarid, ...
%   theAttnum, theRecnum, theRecdimid, theAutoscale)
%   allocates a container for the given information
%   about a NetCDF item.  It serves as a header class
%   for derived NetCDF classes, including netcdf, ncdim,
%   ncvar, ncatt, ncrec, and ncslice.  The result is
%   assigned silently to "ans" if no output argument
%   is given.
 
% Copyright (C) 1996 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.

if nargin < 1 & nargout < 1
   help(mfilename)
   return
end

if nargin < 1, theName = ''; end
if nargin < 2, theNCid = -1; end
if nargin < 3, theDimid = -1; end
if nargin < 4, theVarid= -1; end
if nargin < 5, theAttnum = -1; end
if nargin < 6, theRecnum = -1; end
if nargin < 7, theRecdimid = -1; end
if nargin < 8, theAutoscale = -1; end

if (1)
   theStruct = struct( ...
                      'itsName', theName, ...
                      'itsNCid', theNCid, ...
                      'itsDimid', theDimid, ...
                      'itsVarid', theVarid, ...
                      'itsAttnum', theAttnum, ...
                      'itsRecnum', theRecnum, ...
                      'itsRecdimid', theRecdimid, ...
                      'itsAutoscale', theAutoscale ...
                     );
else
   theStruct.itsName = theName;
   theStruct.itsNCid = theNCid;
   theStruct.itsDimid = theDimid;
   theStruct.itsVarid = theVarid;
   theStruct.itsAttnum = theAttnum;
   theStruct.itsRecnum = theRecnum;
   theStruct.itsRecdimid = theRecdimid;
   theStruct.itsAutoscale = theAutoscale;
end

result = class(theStruct, 'ncitem');

if nargout > 0
   self = result;
else
   ncans(result)
end
