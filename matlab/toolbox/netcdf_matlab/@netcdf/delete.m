function theResult = delete(self, varargin)

% netcdf/delete -- Delete items from NetCDF file.
%  delete(self, item1, item2, ...) deletes the given items
%   ("ncdim", "ncvar", or "ncatt" objects) from the NetCDF
%   file represented by self, a "netcdf" object.  The
%   updated "netcdf" object is returned.
 
% Copyright (C) 1997 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.
 
% Version of 13-Aug-1997 08:51:21.

result = [];
if nargout > 0, theResult = result; end

if nargin < 2, help(mfilename), return, end

self = ncregister(self);

theItems = varargin;
if length(varargin) < 1, return, end

switch permission(self)
case 'nowrite'
   disp([' ## No "' mfilename '" action taken; ' ...
              'file "' name(self) '" permission is "nowrite".'])
   return
otherwise
end

% All objects.

theObjects = [att(self) dim(self) var(self)];

% Cull items to be deleted.

for k = length(theObjects):-1:1
   for i = 1:length(theItems)
      if isequal(theObjects{k}, theItems{i})
         theObjects(k) = [];
      end
   end
end

% Temporary file.

temp = netcdf('random');
if isempty(temp), return, end

% Copy dimensions and global attributes.

for k = 1:length(theObjects)
   switch ncclass(theObjects{k})
   case 'ncdim'
      d = theObjects{k};
      copy(d, temp)
   case 'ncatt'
      g = theObjects{k};
      if isglobal(g), copy(g, temp), end
   otherwise
   end
end

% Copy variable definitions and attributes.

for k = 1:length(theObjects)
   switch ncclass(theObjects{k})
   case 'ncvar'
      v = theObjects{k};
      copy(v, temp, 0, 0, 0)
      a = att(v);
      for j = length(a):-1:1
         for i = 1:length(theItems)
            if isequal(a{j}, theItems{i}), a(j) = []; end
         end
      end
      u = temp{name(v)};
      for j = 1:length(a), copy(a{j}, u), end
   end
end

% Copy variable data.

for k = 1:length(theObjects)
   switch ncclass(theObjects{k})
   case 'ncvar'
      v = theObjects{k};
      copy(v, temp, 1, 0, 0)
   otherwise
   end
end

theTempFilename = name(temp);
theFilename = name(self);

close(temp)
close(self)

fcopy(theTempFilename, theFilename)
delete(theTempFilename)

result = netcdf(theFilename, 'write');

if nargout > 0
   theResult = result;
else
   ncans(result)
end
