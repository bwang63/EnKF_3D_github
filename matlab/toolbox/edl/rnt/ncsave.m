function ncsave(variables,ncfile,varargin)

% create file 
if exist(ncfile)
   disp(['Overwriting ',ncfile]);
end
nc = netcdf(ncfile, 'clobber');

% define dimensions
myvars =evalin('caller',' whos(variables{:}) ');


for ivar=1:length(myvars)     % loop on each variable
   clear dims
   isize = myvars(ivar).size;
   varname = myvars(ivar).name;
   
   for i = 1: length (isize)   % loop to define dimensions
      dim_name = ['var',num2str(ivar),'_',num2str(i)];
      nc{dim_name} = isize(i);
      %nc{dim_name} = nclong(dim_name);
      dims{i} = vardimname;
   end  % end loop dimensions now stored in dims
   
   
   %nc{varname} = ncdouble(vardimname);   
end  % end loop on each variable
nc=close(nc);




% /d1/manu/matlib/netcdf/ncutility/ncexample.m
