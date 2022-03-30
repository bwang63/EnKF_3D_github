function [status]=nc_dxpos2(oname,fname,gname,T);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright (c) 1998 Rutgers University.                               %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                      %
% function [status]=nc_dxpos2(oname,fname,gname,T)                     %
%                                                                      %
% This function creates a NetCDF file contining the field positions    %
% that is used by the IBM DX data explorer.                            %
%                                                                      %
% On Input:                                                            %
%                                                                      %
%    oname       output positions NetCDF file name (string).           %
%    fname       History NetCDF file name (string).                    %
%    gname       GRID NetCDF file name (string).                       %
%    T           Temperature (array).                                  %
%                                                                      %
% Calls:   MEXCDF (Interface to NetCDF library using Matlab).          %
%          nc_dim, nc_read, nc_write                                   %
%                                                                      %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%  Set-up printing information switch.

global IPRINT

if (isempty(IPRINT)),
  IPRINT=1;
end,

POS_ATT=1;

%-----------------------------------------------------------------------
%  Inquire about input file dimensions.
%-----------------------------------------------------------------------

[dnames,dsizes]=nc_dim(fname);

ndims=length(dsizes);
for n=1:ndims,
  name=dnames(n,:);
  if (name(1:6) == 'xi_rho'),
    Lr=dsizes(n);
  elseif (name(1:4) == 'xi_u'),
    Lu=dsizes(n);
  elseif (name(1:4) == 'xi_v'),
    Lv=dsizes(n);
  elseif (name(1:7) == 'eta_rho'),
    Mr=dsizes(n);
  elseif (name(1:5) == 'eta_u'),
    Mu=dsizes(n);
  elseif (name(1:5) == 'eta_v'),
    Mv=dsizes(n);
  elseif (name(1:5) == 's_rho'),
    Nr=dsizes(n);
  elseif (name(1:3) == 's_w'),
    Nw=dsizes(n);
  end,
end,

if (Nr == Nw),
  Nw=Nr+1;
end,

%-----------------------------------------------------------------------
%  Get some NetCDF parameters.
%-----------------------------------------------------------------------

[ncglobal]=mexcdf('parameter','nc_global');
[ncdouble]=mexcdf('parameter','nc_double');
[ncunlim]=mexcdf('parameter','nc_unlimited');
[ncfloat]=mexcdf('parameter','nc_float');
[ncchar]=mexcdf('parameter','nc_char');
[ncclob]=mexcdf('parameter','nc_clobber');

% Set floating-point variables type.

vartyp=ncfloat;

%-----------------------------------------------------------------------
%  Create output NetCDF file.
%-----------------------------------------------------------------------

[ncid,status]=mexcdf('nccreate',oname,'nc_write');
if (ncid == -1),
  error(['NC_DXPOS: ncopen - unable to create file: ', oname]);
  return
end,

%-----------------------------------------------------------------------
%  Define output file dimensions.
%-----------------------------------------------------------------------

[xrdim]=mexcdf('ncdimdef',ncid,'xi_rho',Lr);
if (xrdim == -1),
  error(['NC_DXPOS: ncdimdef - unable to define dimension: xi_rho.']);
end,

[xudim]=mexcdf('ncdimdef',ncid,'xi_u',Lu);
if (xudim == -1),
  error(['NC_DXPOS: ncdimdef - unable to define dimension: xi_u.']);
end,

[xvdim]=mexcdf('ncdimdef',ncid,'xi_v',Lv);
if (xvdim == -1),
  error(['NC_DXPOS: ncdimdef - unable to define dimension: xi_v.']);
end,

[yrdim]=mexcdf('ncdimdef',ncid,'eta_rho',Mr);
if (yrdim == -1),
  error(['NC_DXPOS: ncdimdef - unable to define dimension: eta_rho.']);
end,

[yudim]=mexcdf('ncdimdef',ncid,'eta_u',Mu);
if (yudim == -1),
  error(['NC_DXPOS: ncdimdef - unable to define dimension: eta_u.']);
end,

[yvdim]=mexcdf('ncdimdef',ncid,'eta_v',Mv);
if (yvdim == -1),
  error(['NC_DXPOS: ncdimdef - unable to define dimension: eta_v.']);
end,

[srdim]=mexcdf('ncdimdef',ncid,'s_rho',Nr);
if (srdim == -1),
  error(['NC_DXPOS: ncdimdef - unable to define dimension: s_rho.']);
end,

[swdim]=mexcdf('ncdimdef',ncid,'s_w',Nw);
if (yudim == -1),
  error(['NC_DXPOS: ncdimdef - unable to define dimension: s_w.']);
end,

[a2dim]=mexcdf('ncdimdef',ncid,'axis2',2);
if (a2dim == -1),
  error(['NC_DXPOS: ncdimdef - unable to define dimension: axis2.']);
end,

[a3dim]=mexcdf('ncdimdef',ncid,'axis3',3);
if (a2dim == -1),
  error(['NC_DXPOS: ncdimdef - unable to define dimension: axis2.']);
end,

[tdim]=mexcdf('ncdimdef',ncid,'time',ncunlim);
if (a2dim == -1),
  error(['NC_DXPOS: ncdimdef - unable to define dimension: axis2.']);
end,

%----------------------------------------------------------------------------
%  Create global attribute(s).
%----------------------------------------------------------------------------

type='DX POSITIONS file';

lenstr=max(size(type));
[status]=mexcdf('ncattput',ncid,ncglobal,'type',ncchar,lenstr,type);
if (status == -1),
  error(['NC_DXPOS: ncattput - unable to global attribure: history.']);
  return
end

history=['Fields Positions ', date_stamp];

lenstr=max(size(history));
[status]=mexcdf('ncattput',ncid,ncglobal,'history',ncchar,lenstr,history);
if (status == -1),
  error(['NC_DXPOS: ncattput - unable to global attribure: history.']);
  return
end

%----------------------------------------------------------------------------
%  Define positions variables.
%----------------------------------------------------------------------------

% Define 2D positions at RHO-points.

[varid]=mexcdf('ncvardef',ncid,'r_grid2',vartyp,3,[yrdim xrdim a2dim]);
if (varid == -1),
  error(['NC_DXPOS: ncvardef - unable to define variable: r_grid2.']);
end,

[status]=mexcdf('ncattput',ncid,varid,'long_name',ncchar,31,...
                '2D grid positions at RHO-points');
if (status == -1),
  error(['NC_DXPOS: ncattput - unable to define attribute: ',...
         'r_grid2:long_name.']);
end,

[status]=mexcdf('ncattput',ncid,varid,'field',ncchar,15,...
                'r_grid2, vector');
if (status == -1),
  error(['NC_DXPOS: ncattput - unable to define attribute: ',...
         'r_grid2:field.']);
end,

if (POS_ATT),
  [status]=mexcdf('ncattput',ncid,varid,'positions',ncchar,7,...
                  'r_grid2');
  if (status == -1),
    error(['NC_DXPOS: ncattput - unable to define attribute: ',...
           'r_grid2:positions']);
  end,
end,

% Define 2D positions at U-points.

[varid]=mexcdf('ncvardef',ncid,'u_grid2',vartyp,3,[yudim xudim a2dim]);
if (varid == -1),
  error(['NC_DXPOS: ncvardef - unable to define variable: u_grid2.']);
end,

[status]=mexcdf('ncattput',ncid,varid,'long_name',ncchar,29,...
                '2D grid positions at U-points');
if (status == -1),
  error(['NC_DXPOS: ncattput - unable to define attribute: ',...
         'u_grid2:long_name.'])
end,

[status]=mexcdf('ncattput',ncid,varid,'field',ncchar,15,...
                'u_grid2, vector');
if (status == -1),
  error(['NC_DXPOS: ncattput - unable to define attribute: ',...
         'u_grid2:field.']);
end,

if (POS_ATT),
  [status]=mexcdf('ncattput',ncid,varid,'positions',ncchar,7,...
                  'u_grid2');
  if (status == -1),
    error(['NC_DXPOS: ncattput - unable to define attribute: ',...
           'u_grid2:positions']);
  end,
end,

% Define 2D positions at V-points.

[varid]=mexcdf('ncvardef',ncid,'v_grid2',vartyp,3,[yvdim xvdim a2dim]);
if (varid == -1),
  error(['NC_DXPOS: ncvardef - unable to define variable: v_grid2.'])
end,

[status]=mexcdf('ncattput',ncid,varid,'long_name',ncchar,29,...
                '2D grid positions at V-points');
if (status == -1),
  error(['NC_DXPOS: ncattput - unable to define attribute: ',...
         'v_grid2:long_name.']);
end,

[status]=mexcdf('ncattput',ncid,varid,'field',ncchar,15,...
                'v_grid2, vector');
if (status == -1),
  error(['NC_DXPOS: ncattput - unable to define attribute: ',...
         'v_grid2:field.']);
end,

if (POS_ATT),
  [status]=mexcdf('ncattput',ncid,varid,'positions',ncchar,7,...
                  'v_grid2');
  if (status == -1),
    error(['NC_DXPOS: ncattput - unable to define attribute: ',...
           'v_grid2:positions'])
  end,
end,

% Define 3D positions at RHO-points.

[varid]=mexcdf('ncvardef',ncid,'r_grid3',vartyp,4,[srdim yrdim xrdim a3dim]);
if (varid == -1),
  error(['NC_DXPOS: ncvardef - unable to define variable: r_grid3.']);
end,

[status]=mexcdf('ncattput',ncid,varid,'long_name',ncchar,31,...
                '3D grid positions at RHO-points');
if (status == -1),
  error(['NC_DXPOS: ncattput - unable to define attribute: ',...
         'r_grid3:long_name.']);
end,

[status]=mexcdf('ncattput',ncid,varid,'field',ncchar,15,...
                'r_grid3, vector');
if (status == -1),
  error(['NC_DXPOS: ncattput - unable to define attribute: ',...
         'r_grid3:field.']);
end,

if (POS_ATT),
 [status]=mexcdf('ncattput',ncid,varid,'positions',ncchar,7,...
                 'r_grid3');
  if (status == -1),
    error(['NC_DXPOS: ncattput - unable to define attribute: ',...
           'r_grid3:positions']);
  end,
end,

% Define 3D positions at U-points.

[varid]=mexcdf('ncvardef',ncid,'u_grid3',vartyp,4,[srdim yudim xudim a3dim]);
if (varid == -1),
  error(['NC_DXPOS: ncvardef - unable to define variable: u_grid3.']);
end,
[status]=mexcdf('ncattput',ncid,varid,'long_name',ncchar,29,...
                '3D grid positions at U-points');
if (status == -1),
  error(['NC_DXPOS: ncattput - unable to define attribute: ',...
         'u_grid3:long_name.']);
end,

[status]=mexcdf('ncattput',ncid,varid,'field',ncchar,15,...
                'u_grid3, vector');
if (status == -1),
  error(['NC_DXPOS: ncattput - unable to define attribute: ',...
         'u_grid3:field.']);
end,

if (POS_ATT),
  [status]=mexcdf('ncattput',ncid,varid,'positions',ncchar,7,...
                  'u_grid3');
  if (status == -1),
    error(['NC_DXPOS: ncattput - unable to define attribute: ',...
           'u_grid3:positions']);
  end,
end,

% Define 3D positions at V-points.

[varid]=mexcdf('ncvardef',ncid,'v_grid3',vartyp,4,[srdim yvdim xvdim a3dim]);
if (varid == -1),
  error(['NC_DXPOS: ncvardef - unable to define variable: v_grid3.']);
end,

[status]=mexcdf('ncattput',ncid,varid,'long_name',ncchar,29,...
                '3D grid positions at V-points');
if (status == -1),
  error(['NC_DXPOS: ncattput - unable to define attribute: ',...
         'v_grid3:long_name.']);
end,

[status]=mexcdf('ncattput',ncid,varid,'field',ncchar,15,...
                'v_grid3, vector');
if (status == -1),
  error(['NC_DXPOS: ncattput - unable to define attribute: ',...
         'v_grid3:field.']);
end,

if (POS_ATT),
  [status]=mexcdf('ncattput',ncid,varid,'positions',ncchar,7,...
                  'v_grid3');
  if (status == -1),
    error(['NC_DXPOS: ncattput - unable to define attribute: ',...
           'v_grid3:positions']);
  end,
end,

% Define 3D positions at W-points.

[varid]=mexcdf('ncvardef',ncid,'w_grid3',vartyp,4,[swdim yrdim xrdim a3dim]);
if (varid == -1),
  error(['NC_DXPOS: ncvardef - unable to define variable: w_grid3.'])
end,

[status]=mexcdf('ncattput',ncid,varid,'long_name',ncchar,29,...
                '3D grid positions at W-points');
if (status == -1),
  error(['NC_DXPOS: ncattput - unable to define attribute: ',...
         'w_grid3:long_name.']);
end,

[status]=mexcdf('ncattput',ncid,varid,'field',ncchar,15,...
                'w_grid3, vector');
if (status == -1),
  error(['NC_DXPOS: ncattput - unable to define attribute: ',...
         'w_grid3:field.']);
end,

if (POS_ATT),
  [status]=mexcdf('ncattput',ncid,varid,'positions',ncchar,7,...
                  'w_grid3');
  if (status == -1),
    error(['NC_DXPOS: ncattput - unable to define attribute: ',...
          'w_grid3:positions']);
  end,
end,

% Define temperature for testing.

[varid]=mexcdf('ncvardef',ncid,'temp',vartyp,4,[tdim srdim yrdim xrdim ]);
if (varid == -1),
  error(['NC_DXPOS: ncvardef - unable to define variable: temp.'])
end,

[status]=mexcdf('ncattput',ncid,varid,'long_name',ncchar,21,...
                'potential temperature');
if (status == -1),
  error(['NC_DXPOS: ncattput - unable to define attribute: ',...
         'temp:long_name.']);
end,

[status]=mexcdf('ncattput',ncid,varid,'field',ncchar,27,...
                'temperature, scalar, series');
if (status == -1),
  error(['NC_DXPOS: ncattput - unable to define attribute: ',...
         'temp:field.']);
end,

if (POS_ATT),
  [status]=mexcdf('ncattput',ncid,varid,'positions',ncchar,7,...
                  'r_grid3');
  if (status == -1),
    error(['NC_DXPOS: ncattput - unable to define attribute: ',...
          'w_grid3:positions']);
  end,
end,

%----------------------------------------------------------------------------
%  Leave definition mode.
%----------------------------------------------------------------------------

[status]=mexcdf('ncendef',ncid);
if (status == -1),
  error(['NC_DXPOS: ncendef - unable to leave definition mode.'])
end

%----------------------------------------------------------------------------
%  Close NetCDF file.
%----------------------------------------------------------------------------

[status]=mexcdf('ncclose',ncid);
if (status == -1),
  error(['NC_DXPOS: ncclose - unable to close NetCDF file: ', fname])
end

%----------------------------------------------------------------------------
%  Write out potisions.
%----------------------------------------------------------------------------

%  2D and 3D positions at RHO-points.

lon=nc_read(gname,'lon_rho');
lat=nc_read(gname,'lat_rho');

grid2(1,:,:)=lon;
grid2(2,:,:)=lat;
[status]=nc_write(oname,'r_grid2',grid2);
if (status ~= 0),
  error(['NC_DXPOS: nc_write - error while writing r_grid2.'])
end
clear grid2

lon3=repmat(lon,[1 1 Nr]);
lat3=repmat(lat,[1 1 Nr]);
[z]=depths(fname,gname,1,0,0);

grid3(1,:,:,:)=lon3;
grid3(2,:,:,:)=lat3;
grid3(3,:,:,:)=z;
[status]=nc_write(oname,'r_grid3',grid3);
if (status ~= 0),
  error(['NC_DXPOS: nc_write - error while writing r_grid3.'])
end
clear grid3 lon3 lat3

%  2D and 3D positions at U-points.

lon=nc_read(gname,'lon_u');
lat=nc_read(gname,'lat_u');

grid2(1,:,:)=lon;
grid2(2,:,:)=lat;
[status]=nc_write(oname,'u_grid2',grid2);
if (status ~= 0),
  error(['NC_DXPOS: nc_write - error while writing u_grid2.'])
end
clear grid2

lon3=repmat(lon,[1 1 Nr]);
lat3=repmat(lat,[1 1 Nr]);
[z]=depths(fname,gname,3,0,0);

grid3(1,:,:,:)=lon3;
grid3(2,:,:,:)=lat3;
grid3(3,:,:,:)=z;
[status]=nc_write(oname,'u_grid3',grid3);
if (status ~= 0),
  error(['NC_DXPOS: nc_write - error while writing u_grid3.'])
end
clear grid3 lon3 lat3

%  2D and 3D positions at V-points.

lon=nc_read(gname,'lon_v');
lat=nc_read(gname,'lat_v');

grid2(1,:,:)=lon;
grid2(2,:,:)=lat;
[status]=nc_write(oname,'v_grid2',grid2);
if (status ~= 0),
  error(['NC_DXPOS: nc_write - error while writing v_grid2.'])
end
clear grid2

lon3=repmat(lon,[1 1 Nr]);
lat3=repmat(lat,[1 1 Nr]);
[z]=depths(fname,gname,4,0,0);

grid3(1,:,:,:)=lon3;
grid3(2,:,:,:)=lat3;
grid3(3,:,:,:)=z;
[status]=nc_write(oname,'v_grid3',grid3);
if (status ~= 0),
  error(['NC_DXPOS: nc_write - error while writing v_grid3.'])
end
clear grid3 lon3 lat3

%  2D and 3D positions at W-points.

lon=nc_read(gname,'lon_rho');
lat=nc_read(gname,'lat_rho');

lon3=repmat(lon,[1 1 Nw]);
lat3=repmat(lat,[1 1 Nw]);
[z]=depths(fname,gname,5,0,0);

grid3(1,:,:,:)=lon3;
grid3(2,:,:,:)=lat3;
grid3(3,:,:,:)=z;
[status]=nc_write(oname,'w_grid3',grid3);
if (status ~= 0),
  error(['NC_DXPOS: nc_write - error while writing w_grid3.'])
end
clear grid3 lon3 lat3

return





