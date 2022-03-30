function values = mcagt(cdf, var, att)
% MCAGT Get the values of a NetCDF attribute.
%  MCAGT('CDF','VAR','ATT') gets the VALUES
%   of the attribute 'ATT' associated with variable
%   'VAR' in the NetCDF file 'CDF'.
%
% Example:
%    values = mcagt('foo.cdf', 'x', 'complex')

if nargin < 3
   help mcagt
   return
end

cdfid=mexcdf('open',cdf,'nowrite');
values=mexcdf('attget',cdfid,var,att);
mexcdf('close',cdfid);
