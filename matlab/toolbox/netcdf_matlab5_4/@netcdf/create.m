function theResult = create(self, thePermission)

% netcdf/create -- Create the file for a netcdf object.
%  create(self, 'thePermission') creates the NetCDF file
%   associated with self, a netcdf object, using
%   thePermission, either 'clobber' or 'noclobber'
%   (default).  The object (self) is returned.

if nargin < 1, help(mfilename), return, end

if nargin < 2, thePermission = 'noclobber'; end

[theNCid, status] = ncmex('create', name(self), thePermission);

if status >= 0
   self = name(self, which(name(self)));
   self = ncid(self, theNCid);
   self.itsDefineMode = 'define';
   [ndims, nvars, ngatts, theRecdim, status] = ...
         ncmex('inquire', ncid(self));
   if status >= 0, self = recdim(self, theRecdim); end
   ncregister(self)
   self = ncregister(self);
end

result = self;

if nargout > 0, theResult = result; end
