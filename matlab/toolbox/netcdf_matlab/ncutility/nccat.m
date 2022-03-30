function nccat(theDestinationFile, varargin)

% nccat -- Concatenate two netCDF files.
%  nccat(theDestinationFile, theSourceFile1, theSourceFile2, ...)
%   concatenates theSourceFile1, ... onto theDestinationFile.  This
%   routine behaves similarly to the "nccat" C-language program, which
%   concatenates record-variables, but no other entities.  The files
%   must have the same record structure.
 
% Copyright (C) 1997 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.

if nargin < 2, help nccat, return, end

f = netcdf(theDestinationFile, 'write');
if isempty(f), return, end

for j = 1:length(varargin)
   theSourceFile = varargin{j};
   g = netcdf(theDestinationFile, 'nowrite');
   if isempty(g), break, end
   v = recvar(g)
   for i = 1:length(v)
      u = f{name(v{i})};
      if i == 1, a = size(u); end
      b = size(v{i});
      u(a(1)+1:a(1)+b(1), :) = v{i}(1:b(1), :);
   end
   g = close(g);
end

f = close(f);
