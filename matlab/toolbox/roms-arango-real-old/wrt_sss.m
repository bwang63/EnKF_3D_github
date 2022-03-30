function [status]=wrt_sss(fname,sss,tsss);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright (c) 1999 Rutgers University.                                    %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                           %
% function status=wrt_sss(fname,sss)                                        %
%                                                                           %
% This routine writes out sea surface ssalinity into FORCING NetCDF file.   %
%                                                                           %
% On Input:                                                                 %
%                                                                           %
%    fname       GRID NetCDF file name (character string).                  %
%    sss         Sea surface salinityt (real matrix or 3D vector).          %
%    tsss        Time for sea surface salinity (real vector).               %
%                                                                           %
% Calls:   MEXCDF (Interface to NetCDF library using Matlab).               %
%          nc_write                                                         %
%                                                                           %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%  Open GRIDS NetCDF file.

[ncid]=mexcdf('ncopen',fname,'nc_write');
if (ncid == -1),
  error(['WRT_SSS: ncopen - unable to open file: ', fname])
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
  error(['WRT_SSS: ncdimid - unable to inquire dimension: xi_rho.'])
end
[yrdim]=mexcdf('ncdimid',ncid,'eta_rho');
if (yrdim == -1),
  error(['WRT_SSS: ncdimid - unable to inquire dimension: eta_rho.'])
end
[tsssdim]=mexcdf('ncdimid',ncid,'sss_time');

%  Inquire IDs of sea surface salinity variables.

[sssid]=mexcdf('ncvarid',ncid,'SSS');
[tsssid]=mexcdf('ncvarid',ncid,'sss_time');

%  Inquire about precision of float variables (single or double).

[varid]=mexcdf('ncvarid',ncid,'shflux');
if (varid == -1),
  error(['WRT_SSS: ncvarid - unable to find variable: shflux.'])
end
[vname,nctype,ndims,dims,natts,status]=mexcdf('ncvarinq',ncid,varid);
if (status == -1),
  error(['WRT_SSS: ncvarinq - unable to inquire about variable: shflux.'])
end

if (nctype == ncfloat),
  vartyp=ncfloat;
elseif (nctype == ncdouble),
  vartyp=ncdouble;
end

%  Set local parameters.

[nt]=length(tsss);
[Lp Mp NT]=size(sss);
cycle=360.0;

defmode=0;

%============================================================================
%  If applicable, define sea surface salinity in NetCDF file.
%============================================================================

%  If sea surface variables are not defined, put NetCDF file into define
%  mode.

if (sssid == -1),
  defmode=1;
  [status]=mexcdf('ncredef',ncid);
  if (status == -1),
    error(['WRT_SSS: ncrefdef - unable to put into define mode.'])
    return
  end
end

%  Define sea surface salinity time dimension.

if (tsssdim == -1),
  [tsssdim]=mexcdf('ncdimdef',ncid,'sss_time',NT);
   if (tsssdim == -1),
     error(['WRT_SSS: ncvardef - unable to define dimension: sss_time.'])
   end
end

%  Define sea surface salinity time.

if (tsssid == -1),
  [tsssid]=mexcdf('ncvardef',ncid,'sss_time',ncdouble,1,tsssdim);
  if (tsssid == -1),
    error(['WRT_SSS: ncvardef - unable to define variable: sss_time.'])
  end
  text='time for sea surface salinity';
  lstr=max(size(text));
  [status]=mexcdf('ncattput',ncid,tsssid,'long_name',ncchar,lstr,text);
  if (status == -1),
    error(['WRT_SSS: ncattput - unable to define attribute: ',...
           'sss_time:long_name.'])
  end
  [status]=mexcdf('ncattput',ncid,tsssid,'units',ncchar,3,'day');
  if (status == -1),
    error(['WRT_SSS: ncattput - unable to define attribute: ',...
           'sss_time:units.'])
  end
  [status]=mexcdf('ncattput',ncid,tsssid,'cycle_length',ncdouble,1,...
                  cycle);
  if (status == -1),
    error(['WRT_SSS: ncattput - unable to define attribute: ',...
           'sss_time:cycleength.'])
  end
  text='sss_time, scalar, series';
  lstr=max(size(text));
  [status]=mexcdf('ncattput',ncid,tsssid,'field',ncchar,lstr,text);

  if (status == -1),
    error(['WRT_SSS: ncattput - unable to define attribute: ',...
           'sss_time:field.'])
  end
end

%  Define sea surface salinity.

if (sssid == -1),
  [sssid]=mexcdf('ncvardef',ncid,'SSS',vartyp,3,[tsssdim yrdim xrdim]);
  if (sssid == -1),
    error(['WRT_SSS: ncvardef - unable to define variable: SSS.'])
  end
  text='sea surface salinity';
  lstr=max(size(text));
  [status]=mexcdf('ncattput',ncid,sssid,'long_name',ncchar,lstr,text);
  if (status == -1),
    error(['WRT_SSS: ncattput - unable to define attribute: ',...
           'SSS:long_name.'])
  end
  [status]=mexcdf('ncattput',ncid,sssid,'units',ncchar,3,'PSU');
  if (status == -1),
    error(['WRT_SSS: ncattput - unable to define attribute: ',...
           'SSS:units.'])
  end
  text='SSS, scalar, series';
  lstr=max(size(text));
  [status]=mexcdf('ncattput',ncid,sssid,'field',ncchar,lstr,text);
  if (status == -1),
    error(['WRT_SSS: ncattput - unable to define attribute: ',...
           'SSS:field.'])
  end
end

%----------------------------------------------------------------------------
%  Leave definition mode and close NetCDF file.
%----------------------------------------------------------------------------

if (defmode == 1),
   [status]=mexcdf('ncendef',ncid);
   if (status == -1),
     error(['WRT_SSS: ncendef - unable to leave definition mode.'])
   end
end

[status]=mexcdf('ncclose',ncid);
if (status == -1),
  error(['WRT_SSS: ncclose - unable to close NetCDF file: ', fname])
end

%============================================================================
%  Write out sea surface height into NetCDF file.
%============================================================================

[status]=nc_write(fname,'sss_time',tsss);
[status]=nc_write(fname,'SSS',sss);

return
