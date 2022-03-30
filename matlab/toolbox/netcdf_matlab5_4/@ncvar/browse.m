function theResult = browse(varargin)

% ncvar/browse -- Interactive plot of NetCDF variable.
%  browse(z, 'thePen') plots NetCDF variable z as
%   an interactive "pxline", using 'thePen'.  The syntax
%   is the same as the "ncvar/plot" function.
 
% Copyright (C) 1997 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.
 
% Version of 28-Apr-1997 09:44:36.

if nargin < 1, help(mfilename), return, end

varargout = cell(1, 1);
v = vargstr('plot', length(varargin), length(varargout))
eval(v)
h = varargout{1};
result = pxline(h);
delete(h);

if nargout > 0, theResult = result; end
