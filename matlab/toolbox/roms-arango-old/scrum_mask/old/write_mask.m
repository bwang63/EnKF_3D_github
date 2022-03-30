function status=write_mask(gname,rmask,umask,vmask,pmask);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright (c) 1996 Rutgers University.                                    %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                           %
% function status=write_mask(gname,rmask,umask,vmask,pmask)                 %
%                                                                           %
% This routine writes out mask data into GRID NetCDF file.                  %
%                                                                           %
% On Input:                                                                 %
%                                                                           %
%    gname       GRID NetCDF file name (character string).                  %
%    rmask       Land/Sea mask on RHO-points (real matrix):                 %
%                rmask=0 land, rmask=1 Sea.                                 %
%    umask       Land/Sea mask on U-points (real matrix):                   %
%                umask=0 land, umask=1 Sea.                                 %
%    vmask       Land/Sea mask on V-points (real matrix):                   %
%                vmask=0 land, vmask=1 Sea.                                 %
%    pmask       Land/Sea mask on PSI-points (real matrix):                 %
%                pmask=0 land, pmask=1 Sea.                                 %
%                                                                           %
% Calls:   MEXCDF (Interface to NetCDF library using Matlab).               %
%          DATE_STAMP                                                       %
%                                                                           %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%  Set history attribute.

version=['Grid Package, Version 5.0 ', date_stamp];

%  Open GRIDS NetCDF file.

[ncid]=mexcdf('ncopen',gname,'nc_write');
if (ncid == -1),
  error(['READ_GRIDS: ncopen - unable to open file: ', gname])
  return
end

%  Supress all error messages from NetCDF.

[ncopts]=mexcdf('setopts',0);

%  Define NetCDF parameters.

[ncglobal]=mexcdf('parameter','nc_global');
[ncdouble]=mexcdf('parameter','nc_double');
[ncfloat]=mexcdf('parameter','nc_float');
[ncchar]=mexcdf('parameter','nc_char');

%  Inquire dimension IDs.  A value of -1 is returned if the dimension is
%  not defined.

[xrdim]=mexcdf('ncdimid',ncid,'xi_rho');
if (xrdim == -1),
  error(['WRITE_MASK: ncdimid - unable to inquire dimension: xi_rho.'])
end
[xpdim]=mexcdf('ncdimid',ncid,'xi_psi');
if (xpdim == -1),
  error(['WRITE_MASK: ncdimid - unable to inquire dimension: xi_psi.'])
end
[xudim]=mexcdf('ncdimid',ncid,'xi_u');
if (xudim == -1),
  error(['WRITE_MASK: ncdimid - unable to inquire dimension: xi_u.'])
end
[xvdim]=mexcdf('ncdimid',ncid,'xi_v');
if (xvdim == -1),
  error(['WRITE_MASK: ncdimid - unable to inquire dimension: xi_v.'])
end
[yrdim]=mexcdf('ncdimid',ncid,'eta_rho');
if (yrdim == -1),
  error(['WRITE_MASK: ncdimid - unable to inquire dimension: eta_rho.'])
end
[ypdim]=mexcdf('ncdimid',ncid,'eta_psi');
if (ypdim == -1),
  error(['WRITE_MASK: ncdimid - unable to inquire dimension: eta_psi.'])
end
[yudim]=mexcdf('ncdimid',ncid,'eta_u');
if (yudim == -1),
  error(['WRITE_MASK: ncdimid - unable to inquire dimension: eta_u.'])
end
[yvdim]=mexcdf('ncdimid',ncid,'eta_v');
if (yvdim == -1),
  error(['WRITE_MASK: ncdimid - unable to inquire dimension: eta_v.'])
end

%  Inquire IDs of Land/Sea mask variables.

[rmaskid]=mexcdf('ncvarid',ncid,'mask_rho');
[pmaskid]=mexcdf('ncvarid',ncid,'mask_psi');
[umaskid]=mexcdf('ncvarid',ncid,'mask_u');
[vmaskid]=mexcdf('ncvarid',ncid,'mask_v');

%  Inquire about precision of float variables (single or double).

[varid]=mexcdf('ncvarid',ncid,'hraw');
if (varid == -1),
  error(['WRITE_MASK: ncvarid - unable to find variable: hraw.'])
end
[vname,nctype,ndims,dims,natts,status]=mexcdf('ncvarinq',ncid,varid);
if (status == -1),
  error(['WRITE_MASK: ncvarinq - unable to inquire about variable: hraw.'])
end

if (nctype == ncfloat),
  vartyp=ncfloat;
elseif (nctype == ncdouble),
  vartyp=ncdouble;
end

%  Set local parameters.

[Mp Lp]=size(rmask);
L=Lp-1;
M=Mp-1;
defmode=0;

%============================================================================
%  If applicable, define Land/Sea mask variables into GRID NetCDF file.
%============================================================================

%  If Land/Sea variables are not defined, put GRID NetCDF file into define
%  mode.

if (rmaskid == -1 | pmaskid == -1 | umaskid == -1 | vmaskid == -1),
  defmode=1;
  [status]=mexcdf('ncredef',ncid);
  if (status == -1),
    error(['WRITE_MASK: ncrefdef - unable to put into define mode.'])
    return
  end
end

%----------------------------------------------------------------------------
%  Define Land/Sea mask variables.
%----------------------------------------------------------------------------

%  Define Land/Sea mask on RHO-points.

if (rmaskid == -1),
  [rmaskid]=mexcdf('ncvardef',ncid,'mask_rho',vartyp,2,[yrdim xrdim]);
  if (rmaskid == -1),
    error(['WRITE_MASK: ncvardef - unable to define variable: mask_rho.'])
  end
  [status]=mexcdf('ncattput',ncid,rmaskid,'long_name',ncchar,18,...
                  'mask on RHO-points');
  if (status == -1),
    error(['WRITE_MASK: ncattput - unable to define attribute: ',...
           'mask_rho:long_name.'])
  end
  [status]=mexcdf('ncattput',ncid,rmaskid,'option(0)',ncchar,4,'land');
  if (status == -1),
    error(['WRITE_MASK: ncattput - unable to define attribute: ',...
           'mask_rho:option(0).'])
  end
  [status]=mexcdf('ncattput',ncid,rmaskid,'option(1)',ncchar,3,'sea');
  if (status == -1),
    error(['WRITE_MASK: ncattput - unable to define attribute: ',...
           'mask_rho:option(1).'])
  end
end

%  Define Land/Sea mask on PSI-points.

if (pmaskid == -1),
  [pmaskid]=mexcdf('ncvardef',ncid,'mask_psi',vartyp,2,[ypdim xpdim]);
  if (rmaskid == -1),
    error(['WRITE_MASK: ncvardef - unable to define variable: mask_psi.'])
  end
  [status]=mexcdf('ncattput',ncid,pmaskid,'long_name',ncchar,18,...
                  'mask on PSI-points');
  if (status == -1),
    error(['WRITE_MASK: ncattput - unable to define attribute: ',...
           'mask_psi:long_name.'])
  end
  [status]=mexcdf('ncattput',ncid,pmaskid,'option(0)',ncchar,4,'land');
  if (status == -1),
    error(['WRITE_MASK: ncattput - unable to define attribute: ',...
           'mask_psi:option(0).'])
  end
  [status]=mexcdf('ncattput',ncid,pmaskid,'option(1)',ncchar,3,'sea');
  if (status == -1),
    error(['WRITE_MASK: ncattput - unable to define attribute: ',...
           'mask_psi:option(1).'])
  end
end

%  Define Land/Sea mask on U-points.

if (umaskid == -1),
  [umaskid]=mexcdf('ncvardef',ncid,'mask_u',vartyp,2,[yudim xudim]);
  if (umaskid == -1),
    error(['WRITE_MASK: ncvardef - unable to define variable: mask_u.'])
  end
  [status]=mexcdf('ncattput',ncid,umaskid,'long_name',ncchar,16,...
                  'mask on U-points');
  if (status == -1),
    error(['WRITE_MASK: ncattput - unable to define attribute: ',...
           'mask_u:long_name.'])
  end
  [status]=mexcdf('ncattput',ncid,umaskid,'option(0)',ncchar,4,'land');
  if (status == -1),
    error(['WRITE_MASK: ncattput - unable to define attribute: ',...
           'mask_u:option(0).'])
  end
  [status]=mexcdf('ncattput',ncid,umaskid,'option(1)',ncchar,3,'sea');
  if (status == -1),
    error(['WRITE_MASK: ncattput - unable to define attribute: ',...
           'mask_u:option(1).'])
  end
end

%  Define Land/Sea mask on V-points.

if (vmaskid == -1),
  [vmaskid]=mexcdf('ncvardef',ncid,'mask_v',vartyp,2,[yvdim xvdim]);
  if (vmaskid == -1),
    error(['WRITE_MASK: ncvardef - unable to define variable: mask_v.'])
  end
  [status]=mexcdf('ncattput',ncid,rmaskid,'long_name',ncchar,16,...
                  'mask on V-points');
  if (status == -1),
    error(['WRITE_MASK: ncattput - unable to define attribute: ',...
           'mask_v:long_name.'])
  end
  [status]=mexcdf('ncattput',ncid,vmaskid,'option(0)',ncchar,4,'land');
  if (status == -1),
    error(['WRITE_MASK: ncattput - unable to define attribute: ',...
           'mask_v:option(0).'])
  end
  [status]=mexcdf('ncattput',ncid,vmaskid,'option(1)',ncchar,3,'sea');
  if (status == -1),
    error(['WRITE_MASK: ncattput - unable to define attribute: ',...
           'mask_v:option(1).'])
  end
end

%  Define Land/Sea mask on PSI-points.

if (pmaskid == -1),
  [pmaskid]=mexcdf('ncvardef',ncid,'mask_psi',vartyp,2,[ypdim xpdim]);
  if (rmaskid == -1),
    error(['WRITE_MASK: ncvardef - unable to define variable: mask_psi.'])
  end
  [status]=mexcdf('ncattput',ncid,pmaskid,'long_name',ncchar,18,...
                  'mask on PSI-points');
  if (status == -1),
    error(['WRITE_MASK: ncattput - unable to define attribute: ',...
           'mask_psi:long_name.'])
  end
  [status]=mexcdf('ncattput',ncid,pmaskid,'option(0)',ncchar,4,'land');
  if (status == -1),
    error(['WRITE_MASK: ncattput - unable to define attribute: ',...
           'mask_psi:option(0).'])
  end
  [status]=mexcdf('ncattput',ncid,pmaskid,'option(1)',ncchar,3,'sea');
  if (status == -1),
    error(['WRITE_MASK: ncattput - unable to define attribute: ',...
           'mask_psi:option(1).'])
  end
end

%----------------------------------------------------------------------------
%  Leave definition mode.
%----------------------------------------------------------------------------

if (defmode == 1),
   [status]=mexcdf('ncendef',ncid);
   if (status == -1),
     error(['WRITE_MASK: ncendef - unable to leave definition mode.'])
   end
end

%============================================================================
%  Write out mask data into GRIDS NetCDF file.
%============================================================================

%  Write out coastal Land/Sea mask on RHO-points.

[status]=mexcdf('ncvarput',ncid,rmaskid,[0 0],[Mp Lp],rmask');
if (status == -1),
  error(['WRITE_MASK: ncvarput - error while writting variable: mask_rho.'])
end

%  Write out coastal Land/Sea mask on U-points.

[status]=mexcdf('ncvarput',ncid,umaskid,[0 0],[Mp L],umask');
if (status == -1),
  error(['WRITE_MASK: ncvarput - error while writting variable: mask_u.'])
end

%  Write out coastal Land/Sea mask on V-points.

[status]=mexcdf('ncvarput',ncid,vmaskid,[0 0],[M Lp],vmask');
if (status == -1),
  error(['WRITE_MASK: ncvarput - error while writting variable: mask_v.'])
end

%  Write out coastal Land/Sea mask on PSI-points.

[status]=mexcdf('ncvarput',ncid,pmaskid,[0 0],[M L],pmask');
if (status == -1),
  error(['WRITE_MASK: ncvarput - error while writting variable: mask_psi.'])
end

%----------------------------------------------------------------------------
%  Write new global attribute.
%----------------------------------------------------------------------------

[status]=mexcdf('ncredef',ncid);
if (status == -1),
  error(['WRITE_MASK: ncrefdef - unable to put into define mode.'])
  return
end
lenstr=max(size(version));
[status]=mexcdf('ncattput',ncid,ncglobal,'mask',ncchar,lenstr,version);
if (status == -1),
  error(['WRITE_MASK: ncattput - unable to global attribure: history.'])
  return
end
[status]=mexcdf('ncendef',ncid);
if (status == -1),
  error(['WRITE_MASK: ncendef - unable to leave definition mode.'])
end

%----------------------------------------------------------------------------
%  Close NetCDF file.
%----------------------------------------------------------------------------

[status]=mexcdf('ncclose',ncid);
if (status == -1),
  error(['WRITE_MASK: ncclose - unable to close NetCDF file: ', gname])
end

return
