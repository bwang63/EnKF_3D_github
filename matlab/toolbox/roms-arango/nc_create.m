function status=nc_create(fname,L,M,N,Ntime);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright (c) 1998 Rutgers University.                                    %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                           %
% function status=nc_create(fname,L,M,N,Ntime)                              %
%                                                                           %
% This function creates an output NetCDF.                                   %
%                                                                           %
% On Input:                                                                 %
%                                                                           %
%    fname       Output NetCDF file name (character string).                %
%    L           Number of RHO-points in the XI-direction.                  %
%    M           Number of RHO-points in the ETA-direction.                 %
%    N           Number of RHO-points in the S-direction.  If N=0, the      %
%                vertical dimension is not defined.                         %
%    Ntime       Size of the time dimension. If Ntime=Inf, the time         %
%                is defined as unlimited.                                   %
%                                                                           %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%  Supress all error messages from NetCDF.

[ncopts]=mexcdf('setopts',0);

%  Get some NetCDF parameters.

[ncglobal]=mexcdf('parameter','nc_global');
[ncdouble]=mexcdf('parameter','nc_double');
[ncunlim]=mexcdf('parameter','nc_unlimited');
[ncfloat]=mexcdf('parameter','nc_float');
[ncchar]=mexcdf('parameter','nc_char');
[ncclob]=mexcdf('parameter','nc_clobber');

%  Set global attribute.

type='DATA file';
history=['Data from OSCR ', date_stamp];

%  Set some parameters.

%vartyp=ncfloat;                          % single precision variables
vartyp=ncdouble;                          % double precision variables

%  Create NetCDF file.

[ncid,status]=mexcdf('nccreate',fname,'nc_write');
if (ncid == -1),
  error(['NC_CREATE: ncopen - unable to create file: ', fname])
  return
end

%----------------------------------------------------------------------------
%  Define dimensions.
%----------------------------------------------------------------------------

[xrdim]=mexcdf('ncdimdef',ncid,'xi_rho',L);
if (xrdim == -1),
  error(['NC_CREATE: ncdimdef - unable to define dimension: xi_rho.'])
end,

[xudim]=mexcdf('ncdimdef',ncid,'xi_u',L-1);
if (xudim == -1),
  error(['NC_CREATE: ncdimdef - unable to define dimension: xi_u.'])
end,

[xvdim]=mexcdf('ncdimdef',ncid,'xi_v',L);
if (xvdim == -1),
  error(['NC_CREATE: ncdimdef - unable to define dimension: xi_v.'])
end,

%[xpdim]=mexcdf('ncdimdef',ncid,'xi_psi',L-1);
%if (xpdim == -1),
%  error(['NC_CREATE: ncdimdef - unable to define dimension: xi_psi.'])
%end,

[yrdim]=mexcdf('ncdimdef',ncid,'eta_rho',M);
if (yrdim == -1),
  error(['NC_CREATE: ncdimdef - unable to define dimension: eta_rho.'])
end,

[yudim]=mexcdf('ncdimdef',ncid,'eta_u',M);
if (yudim == -1),
  error(['NC_CREATE: ncdimdef - unable to define dimension: eta_u.'])
end,

[yvdim]=mexcdf('ncdimdef',ncid,'eta_v',M-1);
if (yvdim == -1),
  error(['NC_CREATE: ncdimdef - unable to define dimension: eta_v.'])
end,

%[ypdim]=mexcdf('ncdimdef',ncid,'eta_psi',M-1);
%if (ypdim == -1),
%  error(['NC_CREATE: ncdimdef - unable to define dimension: eta_psi.'])
%end,

if (N > 0),
  [srdim]=mexcdf('ncdimdef',ncid,'s_rho',N);
  if (srdim == -1),
    error(['NC_CREATE: ncdimdef - unable to define dimension: s_rho.'])
  end,
  [swdim]=mexcdf('ncdimdef',ncid,'s_w',Np);
  if (yudim == -1),
    error(['NC_CREATE: ncdimdef - unable to define dimension: eta_u.'])
  end,
end,

if (isinf(Ntime)),
  [tdim]=mexcdf('ncdimdef',ncid,'time',ncunlim);
  if (tdim == -1),
    error(['NC_CREATE: ncdimdef - unable to define unlimited dimension: ',...
           ' time.'])
  end,
else
  [tdim]=mexcdf('ncdimdef',ncid,'time',Ntime);
  if (tdim == -1),
    error(['NC_CREATE: ncdimdef - unable to define dimension: time.'])
  end,
end,

%----------------------------------------------------------------------------
%  Create global attribute(s).
%----------------------------------------------------------------------------

lenstr=max(size(type));
[status]=mexcdf('ncattput',ncid,ncglobal,'type',ncchar,lenstr,type);
if (status == -1),
  error(['NC_CREATE: ncattput - unable to global attribure: history.'])
  return
end

lenstr=max(size(history));
[status]=mexcdf('ncattput',ncid,ncglobal,'history',ncchar,lenstr,history);
if (status == -1),
  error(['NC_CREATE: ncattput - unable to global attribure: history.'])
  return
end

%----------------------------------------------------------------------------
%  Define variables.
%----------------------------------------------------------------------------

%  Define time variable.

[varid]=mexcdf('ncvardef',ncid,'time',vartyp,1,[tdim]);
if (varid == -1),
  error(['NC_CREATE: ncvardef - unable to define variable: time.'])
end,
[status]=mexcdf('ncattput',ncid,varid,'long_name',ncchar,28,...
                'surface momentum time');
if (status == -1),
  error(['NC_CREATE: ncattput - unable to define attribute: ',...
         'time:long_name.'])
end,
[status]=mexcdf('ncattput',ncid,varid,'units',ncchar,10,...
                'Julian day');
if (status == -1),
  error(['NC_CREATE: ncattput - unable to define attribute: ',...
         'time:units.'])
end,
[status]=mexcdf('ncattput',ncid,varid,'field',ncchar,20,...
                'time, scalar, series');
if (status == -1),
  error(['NC_CREATE: ncattput - unable to define attribute: ',...
         'time:field.'])
end,

%  Define 3D variable #1 at U-points.

[varid]=mexcdf('ncvardef',ncid,'Usur',vartyp,3,[tdim yudim xudim]);
if (varid == -1),
  error(['NC_CREATE: ncvardef - unable to define variable: Usur.'])
end,
[status]=mexcdf('ncattput',ncid,varid,'long_name',ncchar,28,...
                'surface u-momentum component');
if (status == -1),
  error(['NC_CREATE: ncattput - unable to define attribute: ',...
         'Usur:long_name.'])
end,
[status]=mexcdf('ncattput',ncid,varid,'units',ncchar,14,...
                'meter second-1');
if (status == -1),
  error(['NC_CREATE: ncattput - unable to define attribute: ',...
         'Usur:units.'])
end,
[status]=mexcdf('ncattput',ncid,varid,'field',ncchar,25,...
                'u-surface, scalar, series');
if (status == -1),
  error(['NC_CREATE: ncattput - unable to define attribute: ',...
         'Usur:field.'])
end,

%  Define 3D variable #1 at V-points.

[varid]=mexcdf('ncvardef',ncid,'Vsur',vartyp,3,[tdim yvdim xvdim]);
if (varid == -1),
  error(['NC_CREATE: ncvardef - unable to define variable: Vsur.'])
end,
[status]=mexcdf('ncattput',ncid,varid,'long_name',ncchar,28,...
                'surface v-momentum component');
if (status == -1),
  error(['NC_CREATE: ncattput - unable to define attribute: ',...
         'Vsur:long_name.'])
end,
[status]=mexcdf('ncattput',ncid,varid,'units',ncchar,14,...
                'meter second-1');
if (status == -1),
  error(['NC_CREATE: ncattput - unable to define attribute: ',...
         'Vsur:units.'])
end,
[status]=mexcdf('ncattput',ncid,varid,'field',ncchar,25,...
                'v-surface, scalar, series');
if (status == -1),
  error(['NC_CREATE: ncattput - unable to define attribute: ',...
         'Vsur:field.'])
end,

%  Define 3D variable #3 at RHO-points.

[varid]=mexcdf('ncvardef',ncid,'Esur',vartyp,3,[tdim yrdim xrdim]);
if (varid == -1),
  error(['NC_CREATE: ncvardef - unable to define variable: Esur.'])
end,
[status]=mexcdf('ncattput',ncid,varid,'long_name',ncchar,26,...
                'error for surface momentum');
if (status == -1),
  error(['NC_CREATE: ncattput - unable to define attribute: ',...
         'Esur:long_name.'])
end,
[status]=mexcdf('ncattput',ncid,varid,'units',ncchar,14,...
                'nondimensional');
if (status == -1),
  error(['NC_CREATE: ncattput - unable to define attribute: ',...
         'Esur:units.'])
end,
[status]=mexcdf('ncattput',ncid,varid,'field',ncchar,20,...
                'Esur, scalar, series');
if (status == -1),
  error(['NC_CREATE: ncattput - unable to define attribute: ',...
         'Esur:field.'])
end,

%----------------------------------------------------------------------------
%  Leave definition mode.
%----------------------------------------------------------------------------

[status]=mexcdf('ncendef',ncid);
if (status == -1),
  error(['NC_CREATE: ncendef - unable to leave definition mode.'])
end

%----------------------------------------------------------------------------
%  Close NetCDF file.
%----------------------------------------------------------------------------

[status]=mexcdf('ncclose',ncid);
if (status == -1),
  error(['NC_CREATE: ncclose - unable to close NetCDF file: ', fname])
end

return
