function theResult = resize(self, newSize)

% ncdim/resize -- Resize dimension.
%  resize(self, newSize) resizes the length of self,
%   an "ncdim" object.  The newSize is a non-negative
%   integer, possibly 0 in the case of an existing
%   record-dimension.  The new self is returned.
 
% Copyright (C) 1998 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.
 
% Version of 03-Nov-1998 08:52:22.
% Updated    12-Aug-1999 09:42:42.

if nargin < 1, help(mfilename), return, end
if nargout > 0, theResult = self; end

% The following is almost identical to "ncvar/resize".

% Check for no-change.

if isequal(ncsize(self), newSize)
	result = self;
	if nargout > 0
		theResult = result;
	else
		ncans(result)
	end
	return
end

theItemName = name(self);

% Check for writeability.

f = parent(self);
thePermission = permission(f);
theSrcName = name(f);

if isequal(thePermission, 'nowrite')
	disp([' ## NetCDF source file must be writeable.'])
	return
end

% Check request.

if ~isrecdim(self) & newSize <= 0
	disp([' ## Dimension "' name(self) '" size requires positive integer.'])
	return
end

% Create temporary file.

g = [];

i = 0;
while isempty(g)
	i = i + 1;
	theTmpName = ['tmp_' int2str(i) '.nc'];
	if exist(theTmpName, 'file') ~= 2
		g = netcdf(theTmpName, 'noclobber');
	end
end

theTmpName = name(g);

% Copy the affected dimension first.

d = {self};
for i = 1:length(d)
	if isrecdim(d{i})
		g(name(d{i})) = 0;
	else
		g(name(d{i})) = newSize(i);
	end
end

% Copy other dimensions.

d = dim(f);
for i = 1:length(d)
	if isrecdim(d{i})
		g(name(d{i})) = 0;
	else
		g(name(d{i})) = ncsize(d{i});
	end
end

% Copy global attributes.

a = att(f);
for i = 1:length(a)
	copy(a{i}, g)
end

% Copy variable definitions and attributes.

v = var(f);
for i = 1:length(v)
	copy(v{i}, g, 0, 1)
end

% Copy variable data as minimal rectangular array.
%  Note that the "()" operator is out-of-context
%  inside this method, so we have to build our own
%  calls to "ncvar/subsref" and "ncvar/subsasgn".
%  It might be easier for us to use "virtual"
%  variables instead, which could be transferred
%  with the more intelligent "ncvar/copy" method.

v = var(f);
w = var(g);

for i = 1:length(v)
	sv = ncsize(v{i});
	sw = ncsize(w{i});
	if ~isempty(sw)
		d = dim(w{i});
		if isrecdim(d{1})
			if sw(1) == 0
				if isequal(name(d{1}), theItemName)
					sw(1) = newSize;
				else
					sw(1) = sv(1);
				end
			end
		end
	end
	theMinimalSize = min(sv, sw);
	if prod(theMinimalSize) > 0
		if isequal(sv, sw)
			copy(v{i}, g, 1)
		else
			theIndices = cell(size(theMinimalSize));
			for j = 1:length(theIndices)
				theIndices{j} = 1:theMinimalSize(j);
			end
			theStruct.type = '()';
			theStruct.subs = theIndices;
			theData = subsref(v{i}, theStruct);
			w{i} = subsasgn(w{i}, theStruct, theData);
		end
	end
end

% Close both files.

f = close(f);
g = close(g);

% Delete old file.

delete(theSrcName)

% Rename new file to old file name.

fcopy(theTmpName, theSrcName)
delete(theTmpName)

% Open the new file.

g = netcdf(theSrcName, thePermission);

% Return the resized variable.

result = g(theItemName);

if nargout > 0
	theResult = result;
else
	ncans(result)
end
