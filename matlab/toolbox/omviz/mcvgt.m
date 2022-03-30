function values = mcvgt(cdf, var, corner,count)

% MCVGT Get a NetCDF hyperslab.
%  MCVGT('CDF','VAR',[COORD],[COUNT]) returns the hyperslab 
%   from NetCDF file 'CDF, variable 'VAR', starting at corner 
%   [COORD] and containing [COUNT] elements along the edges.  
%   The starting index of an array is 0 (C-Language convention).
%
% Example:
%    value = mcvgt('foo.cdf', 'x', [0 0], [2 3])

% Show usage if too few arguments.
%
if nargin~=2 & nargin~=4,
   help mcvgt;
   return;
end
%
% Open netCDF file
%
[cdfid,rcode ]=mexcdf('open',cdf,'NOWRITE');
if cdfid < 0
   disp(['Error in mexcdf: Can''t open ' cdf]);
   return
end
% Suppress warning messages from netCDF
[rcode]=mexcdf('setopts',0);
%
% Get variable id
%
[varid]=mexcdf('varid',cdfid,var);
if varid < 0
   disp(['Error in mexcdf: Can''t get variable ' var]);
   return
end
[var_name,var_type,nvdims,var_dim,natts]=mexcdf('varinq',cdfid,varid);
%
% Automagically get all the data if slab is not specified
%
if nargin==2,
  for n=1:nvdims,
    dimid=var_dim(n);
    [dim_name,dim_size,rcode]=mexcdf('diminq',cdfid,dimid);
    corner(n)=0;
    count(n)=dim_size;
  end
end
%
% Get slab
% 
[values,rcode] = mexcdf('varget',cdfid,varid,corner,count,1);
values=values';  % want slowest varying dimension to be # of rows
mexcdf('close',cdfid);
