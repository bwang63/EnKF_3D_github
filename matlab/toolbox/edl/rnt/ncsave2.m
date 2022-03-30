function ncsave2(ncfile,varargin)
%function ncsave2(ncfile,variables,varargin)

if nargin == 2
   variables = varargin{1};
else
   variables =   evalin('caller','who');
end
   
% create file 
if exist(ncfile)
   disp(['Overwriting ',ncfile]);
end
nc = netcdf(ncfile, 'clobber');

% define dimensions



for ivar=1:length(variables)     % loop on each variable
   myvars =evalin('caller',[' whos(''',variables{ivar},''' )']);
   clear dims
   disp(myvars.name);
   isize = myvars.size;
   varname = myvars.name;
   
   for i = 1: length (isize)   % loop to define dimensions
      dim_name = [varname,'_',num2str(i)];
      nc(dim_name) = isize(i);
      %nc{dim_name} = nclong(dim_name);
      dims{i} = dim_name;
   end  % end loop dimensions now stored in dims
   
   
    nc{varname} = dims;   
    nc{varname}(:)=evalin('caller',myvars.name);
    
end  % end loop on each variable
nc=close(nc);




% /d1/manu/matlib/netcdf/ncutility/ncexample.m
