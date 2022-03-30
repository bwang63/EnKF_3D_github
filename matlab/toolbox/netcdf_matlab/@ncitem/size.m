function [theResult, nvars, ngatts, recdim] = size(self, index)

% ncitem/size -- Sizes (dimensions) of an "ncitem" object.
%  size(self) returns the size of self, an object
%   derived from the "ncitem" class.  Depending on
%   the class of self, this will be either its
%   dimension-length, variable-size, or attribute-
%   length.  N.B. This usage of size() differs from
%   that for Matlab arrays.
%   If self is a "netcdf" object, the returned value
%   is [ndims nvars ngatts recdimid].  Optionally,
%   four separate output variables can be requested.
%  size(self, index) returns the size-component at
%   the given index.
%
% Also see: ncitem/name, ncitem/datatype.
 
% Copyright (C) 1997 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.
 
% Version of 07-Aug-1997 10:00:59.

if nargin < 1, help(mfilename), return, end

result = [];

theNCid = ncid(self);

theClass = ncclass(self);
switch theClass
case 'ncitem'
   theSize = [];
   status = 0;
case 'netcdf'
   [ndims, nvars, ngatts, recdim, status] = ...
         ncmex('ncinquire', theNCid);
   if nargout > 1
      theSize = ndims;
   else
      theSize = [ndims nvars ngatts recdim];
   end
case 'ncdim'
   theSize = [];
   theDimid = dimid(self);
   if theDimid >= 0
      [theDimname, theSize, status] = ...
            ncmex('diminq', theNCid, theDimid);
   end
case 'ncatt'
   theSize = [];
   theVarid = varid(self);
   if theVarid >= 0
      theAttname = name(self);
      [theType, theSize, status] = ...
            ncmex('attinq', theNCid, theVarid, theAttname);
   end
case 'ncvar'   % ncvar/size() is used instead.
   theSize = [];
   theVarid = varid(self);
   if theVarid >= 0
      [theVarname, theVartype, theVarndims, ...
            theVardimids, theVarnatts, status] = ...
            ncmex('varinq', theNCid, theVarid);
      if status >= 0
         theSize = -ones(1, length(theVardimids));
         for i = 1:length(theVardimids)
            [theDimname, theSize(i), status] = ...
                  ncmex('diminq', theNCid, theVardimids(i));
            if status < 0, break, end
         end
      end
   end
otherwise
   theSize = [];
   status = -1;
   warning(' ## Illegal syntax.')
end

result = theSize;
if nargin > 1 & index <= length(result)
   result = result(index);
end

if nargout > 0
   theResult = result;
else
   disp(result)
end
