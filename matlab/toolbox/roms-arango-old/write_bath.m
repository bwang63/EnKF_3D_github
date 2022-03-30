function status=write_bath(gname,bath);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright (c) 1996 Rutgers University.                                    %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                           %
% function status=write_bath(gname,bath)                                    %
%                                                                           %
% This routine writes out bathymetry into GRID NetCDF file.                 %
%                                                                           %
% On Input:                                                                 %
%                                                                           %
%    gname       GRID NetCDF file name (character string).                  %
%    bath        bathymetry at RHO-points (real matrix; meters).            %
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
  error(['WRITE_BATH: ncdimid - unable to inquire dimension: xi_rho.'])
end
[yrdim]=mexcdf('ncdimid',ncid,'eta_rho');
if (yrdim == -1),
  error(['WRITE_BATH: ncdimid - unable to inquire dimension: eta_rho.'])
end

%  Inquire ID of bathymetry variable.

[bathid]=mexcdf('ncvarid',ncid,'h');

%  Inquire about precision of float variables (single or double).

[varid]=mexcdf('ncvarid',ncid,'hraw');
if (bathid == -1),
  error(['WRITE_BATH: ncvarid - unable to find variable: hraw.'])
end
[vname,nctype,ndims,dims,natts,status]=mexcdf('ncvarinq',ncid,bathid);
if (status == -1),
  error(['WRITE_BATH: ncvarinq - unable to inquire about variable: hraw.'])
end

if (nctype == ncfloat),
  vartyp=ncfloat;
elseif (nctype == ncdouble),
  vartyp=ncdouble;
end

%  Set local parameters.

[Mp Lp]=size(bath);
L=Lp-1;
M=Mp-1;
defmode=0;

%============================================================================
%  If applicable, define bathymetry variable into GRID NetCDF file.
%============================================================================

%  If bathymetry is not defined, put GRID NetCDF file into define mode.

if (bathid == -1),
  defmode=1;
  [status]=mexcdf('ncredef',ncid);
  if (status == -1),
    error(['WRITE_BATH: ncrefdef - unable to put into define mode.'])
    return
  end
end

%----------------------------------------------------------------------------
%  Define bathymetry variable.
%----------------------------------------------------------------------------

if (bathid == -1),
  [bathid]=mexcdf('ncvardef',ncid,'h',vartyp,2,[yrdim xrdim]);
  if (bathid == -1),
    error(['WRITE_BATH: ncvardef - unable to define variable: h.'])
  end
  [status]=mexcdf('ncattput',ncid,bathid,'long_name',ncchar,21,...
                  'bathymetry RHO-points');
  if (status == -1),
    error(['WRITE_BATH: ncattput - unable to define attribute: ',...
           'h:long_name.'])
  end
  [status]=mexcdf('ncattput',ncid,bathid,'units',ncchar,5,'meter');
  if (status == -1),
    error(['WRITE_BATH: ncattput - unable to define attribute: ',...
           'h:units.'])
  end
  [status]=mexcdf('ncattput',ncid,bathid,'field',ncchar,12,...
                  'bath, scalar');
  if (status == -1),
    error(['WRITE_BATH: ncattput - unable to define attribute: ',...
           'h:field.'])
  end
end

%----------------------------------------------------------------------------
%  Leave definition mode.
%----------------------------------------------------------------------------

if (defmode == 1),
   [status]=mexcdf('ncendef',ncid);
   if (status == -1),
     error(['WRITE_BATH: ncendef - unable to leave definition mode.'])
   end
end

%============================================================================
%  Write out bathymetry into GRIDS NetCDF file.
%============================================================================

[status]=mexcdf('ncvarput',ncid,bathid,[0 0],[Mp Lp],bath');
if (status == -1),
  error(['WRITE_BATH: ncvarput - error while writting variable: h.'])
end

%----------------------------------------------------------------------------
%  Close NetCDF file.
%----------------------------------------------------------------------------

[status]=mexcdf('ncclose',ncid);
if (status == -1),
  error(['WRITE_BATH: ncclose - unable to close NetCDF file: ', gname])
end

return
