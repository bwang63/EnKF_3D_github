function theResult = subsasgn(self, theStruct, other)

% ncvar/subsasgn -- Assignment with subscripting.
%  subsasgn(self, theStruct, other) is called whenever
%   self is used with subscripting on the left-side of
%   an assignment, such as in self(...) = other, for
%   self, an "ncvar" object.  All other usages are illegal.
%   If fewer than the full number of indices are provided,
%   the unsupplied ones default to 1, unless the last one
%   provided is ':', in which case the rest default to ':'
%   as well.  Indices beyond the full number needed are
%   ignored.  The argument called "other" must be a scalar,
%   a vector having any orientation, or an array having
%   the same shape as the destination slab.
%   ## Only a constant stride is permitted at present.

% Also see: ncvar/subsref.
 
% Copyright (C) 1996-7 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.
 
% Version of 07-Aug-1997 15:55:19.

if nargin < 1, help(mfilename), return, end

% Composite-variable processing.
%  We construct the full virtual-variable array,
%  substitute the desired piece, then restore.

theVars = var(self);   % A cell.
if ~isempty(theVars)
   [theSrcsubs, theDstsubs] = subs(self);  % The mappings.
   result = [];
   for i = length(theVars):-1:1   % Construct.
      src = theSrcsubs{i};   % A cell.
      dst = theDstsubs{i};   % A cell.
      x = theVars{i}(src{:});
      result(dst{:}) = x;
   end
   result(theStruct(1).subs{:}) = other;  % Substitute.
   for i = 1:length(theVars)   % Restore.
      src = theSrcsubs{i};   % A cell.
      dst = theDstsubs{i};   % A cell.
      x = result(dst{:});
      theVars{i}(src{:}) = x;
   end
   result = self;
   if nargout > 0
      theResult = result;
   else
      disp(result)
   end
   return
end

% Regular processing.
   
result = [];
if nargout > 0, theResult = result; end

s = theStruct;
theType = s(1).type;
theSubs = s(1).subs;
s(1) = [];

theAutoscaleflag = (autoscale(self) == 1);

switch theType
case '()'
   if isempty(other) & length(theSubs) == 1 & strcmp(theSubs{1}, ':')
      result = delete(self);   % Delete.
      if nargout >  0
         theResult = result;
      else
         disp(result)
      end
      return
   end
otherwise
end

switch theType
case '()'
   indices = theSubs;
   theSize = size(self);
   
   for i = 1:length(indices)
      if isa(indices{i}, 'double')
         if any(diff(diff(indices{i})))
            disp(' ## Indexing strides must be positive and constant.')
            return
         end
      end
   end
   
% Flip and permute indices before proceeding,
%  since we are using virtual indexing.
   
   theOrientation = orient(self);
   if any(theOrientation < 0) | any(diff(theOrientation) ~= 1)
      for i = 1:length(theOrientation)
         if theOrientation(i) < 0
            if isa(indices{i}, 'double')   % Slide the indices.
               indices{i} = fliplr(theSize(i) + 1 - indices{i});
            end
         end
      end
      indices(abs(theOrientation)) = indices;
      theSize(abs(theOrientation)) = theSize;
   end

   start = zeros(1, length(theSize));
   count = ones(1, length(theSize));
   stride = ones(1, length(theSize));
   for i = 1:min(length(indices), length(theSize))
      k = indices{i};
      if ~isstr(k) & ~strcmp(k, ':')
         start(i) = k(1)-1;
         count(i) = length(k);
         d = 0;
         if length(k) > 1, d = diff(k); end
         stride(i) = max(d(1), 1);
      else
         count(i) = -1;
         if i == length(indices) & i < length(theSize)
            j = i+1:length(theSize);
            count(j) = -ones(1, length(j));
         end
      end
   end
   start(start < 0) = 0;
   stride(stride < 0) = 1;
   for i = 1:length(count)
      if count(i) == -1
         maxcount = fix((theSize(i)-start(i)+stride(i)-1) ./ ...
                                                   stride(i));
         count(i) = maxcount;
      end
   end
   count(count < 0) = 0;
   if any(count == 0), error(' ## Bad count.'), end
   while length(count) < 2, count = [count 1]; end
   temp = zeros(count);
   if isa(other, 'ncitem'), other = other(:); end
   if isstr(other), temp = setstr(temp); end
   temp(:) = other;
   theOrientation = orient(self);
   if any(theOrientation < 0) | any(diff(theOrientation) ~= 1)
      if length(theOrientation) < 2
         theOrientation = [theOrientation 2];
      end
      temp = ipermute(temp, abs(theOrientation));
      for i = 1:length(theOrientation)
         if theOrientation(i) < 0
            temp = flipdim(temp, abs(theOrientation(i)));
         end
      end
   end
   temp = permute(temp, length(size(temp)):-1:1);
   theNetCDF = parent(self);
   theNetCDF = endef(theNetCDF);
   if all(count == 1)
      status = ncmex('varput1', ncid(self), varid(self), ...
                  start, temp, theAutoscaleflag);
   elseif all(stride == 1)
      status = ncmex('varput', ncid(self), varid(self), ...
                  start, count, temp, theAutoscaleflag);
   else
      imap = [];
      status = ncmex('varputg', ncid(self), varid(self), ...
                  start, count, stride, imap, temp, ...
                  theAutoscaleflag);
   end
   result = self;
case '.'   % Attribute by name: self.theAttname(...).
   theAttname = theSubs;
   while length(s) > 0   % Dotted name.
      switch s(1).type
      case '.'
         theAttname = [theAttname '.' s(1).subs];
         s(1) = [];
      otherwise
         break
      end
   end
   if length(s) < 1 & isa(other, 'cell') & length(other) == 2
      theAtttype = other{1};
      theAttvalue = other{2};
      result = ncatt(theAttname, theAtttype, theAttvalue, self);
   elseif length(s) < 1
      if ~isempty(other)
         result = ncatt(theAttname, other, self);
      else
         result = delete(ncatt(theAttname, self));   % Delete.
      end
   else
      result = subsasgn(att(self, theAttname), s, other);
   end
   result = self;
otherwise
   warning([' ## Illegal syntax: "' theType '"'])
end

if nargout >  0
   theResult = result;
else
   disp(result)
end
