function [name, size] = mcdinq(cdf, dim)

% MCDINQ Inquire about a NetCDF dimension.
%  ['NAME',SIZE]=MCDINQ('CDF',DIM) returns the
%   'NAME' and SIZE if the dimension DIM (id or
%   name) in NetCDF file 'CDF'.
%
% Example:
%    [name, size] = mcdinq('foo.cdf', 'm')

% Copyright (C) 1991 Charles R. Denham, Zydeco.

if nargin < 2
   help mcdinq
   return
end

if ~isstr(dim), dim = int2str(dim); end

cdfid=mexcdf('open', cdf, 'NOWRITE');
[name,size]=mexcdf('diminq',cdfid,dim);
mexcdf('close',cdfid);

