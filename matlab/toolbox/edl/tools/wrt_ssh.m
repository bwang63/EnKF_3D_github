function [status]=wrt_ssh(fname,ssh,tssh);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright (c) 1997 Rutgers University.                                    %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                           %
% function status=wrt_ssh(fname,ssh)                                        %
%                                                                           %
% This routine writes out sea surface height data into a NetCDF file.       %
%                                                                           %
% On Input:                                                                 %
%                                                                           %
%    fname       NetCDF file name (character string).                       %
%    ssh         Sea surface height (real matrix or 3D-array).              %
%    tssh        Time for sea surface height (real vector).                 %
%                                                                           %
% Calls:   MEXCDF (Interface to NetCDF library using Matlab).               %
%          nc_write                                                         %
%                                                                           %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%  Open NetCDF file.

[ncid]=mexcdf('ncopen',fname,'nc_write');
if (ncid == -1),
  error(['WRT_SSH: ncopen - unable to open file: ', fname])
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
  error(['WRT_SSH: ncdimid - unable to inquire dimension: xi_rho.'])
end
[yrdim]=mexcdf('ncdimid',ncid,'eta_rho');
if (yrdim == -1),
  error(['WRT_SSH: ncdimid - unable to inquire dimension: eta_rho.'])
end
[tsshdim]=mexcdf('ncdimid',ncid,'ssh_time');

%  Inquire IDs of sea surface height variables.

[sshid]=mexcdf('ncvarid',ncid,'SSH');
[tsshid]=mexcdf('ncvarid',ncid,'ssh_time');

%  Inquire about precision of float variables (single or double).

[varid]=mexcdf('ncvarid',ncid,'temp');
if (varid == -1),
  error(['WRT_SSH: ncvarid - unable to find variable: temp.'])
end
[vname,nctype,ndims,dims,natts,status]=mexcdf('ncvarinq',ncid,varid);
if (status == -1),
  error(['WRT_SSH: ncvarinq - unable to inquire about variable: temp.'])
end

if (nctype == ncfloat),
  vartyp=ncfloat;
elseif (nctype == ncdouble),
  vartyp=ncdouble;
end

%  Set local parameters.

[nt]=length(tssh);
[Lp Mp NT]=size(ssh);
cycle=360.0;

defmode=0;

%============================================================================
%  If applicable, define sea surface height in NetCDF file.
%============================================================================

%  If sea surface variables are not defined, put NetCDF file into define
%  mode.

if (sshid == -1),
  defmode=1;
  [status]=mexcdf('ncredef',ncid);
  if (status == -1),
    error(['WRT_SSH: ncrefdef - unable to put into define mode.'])
    return
  end
end

%  Define sea surface height time dimension.

if (tsshdim == -1),
  [tsshdim]=mexcdf('ncdimdef',ncid,'ssh_time',NT);
   if (tsshdim == -1),
     error(['WRT_SSH: ncvardef - unable to define dimension: ssh_time.'])
   end
end

%  Define sea surface height time.

if (tsshid == -1),
  [tsshid]=mexcdf('ncvardef',ncid,'ssh_time',ncdouble,1,tsshdim);
  if (tsshid == -1),
    error(['WRT_SSH: ncvardef - unable to define variable: ssh_time.'])
  end
  [status]=mexcdf('ncattput',ncid,tsshid,'long_name',ncchar,27,...
                  'time for sea surface height');
  if (status == -1),
    error(['WRT_SSH: ncattput - unable to define attribute: ',...
           'ssh_time:long_name.'])
  end
  [status]=mexcdf('ncattput',ncid,tsshid,'units',ncchar,3,'day');
  if (status == -1),
    error(['WRT_SSH: ncattput - unable to define attribute: ',...
           'ssh_time:units.'])
  end
  [status]=mexcdf('ncattput',ncid,tsshid,'cycle_length',ncdouble,1,...
                  cycle);
  if (status == -1),
    error(['WRT_SSH: ncattput - unable to define attribute: ',...
           'ssh_time:cycleength.'])
  end
  [status]=mexcdf('ncattput',ncid,tsshid,'field',ncchar,24,...
                  'ssh_time, scalar, series');
  if (status == -1),
    error(['WRT_SSH: ncattput - unable to define attribute: ',...
           'ssh_time:field.'])
  end
end

%  Define sea surface height.

if (sshid == -1),
  [sshid]=mexcdf('ncvardef',ncid,'SSH',vartyp,3,[tsshdim yrdim xrdim]);
  if (sshid == -1),
    error(['WRT_SSH: ncvardef - unable to define variable: SSH.'])
  end
  [status]=mexcdf('ncattput',ncid,sshid,'long_name',ncchar,18,...
                  'sea surface height');
  if (status == -1),
    error(['WRT_SSH: ncattput - unable to define attribute: ',...
           'SSH:long_name.'])
  end
  [status]=mexcdf('ncattput',ncid,sshid,'units',ncchar,5,'meter');
  if (status == -1),
    error(['WRT_SSH: ncattput - unable to define attribute: ',...
           'SSH:units.'])
  end
  [status]=mexcdf('ncattput',ncid,sshid,'field',ncchar,19,...
                  'SSH, scalar, series');
  if (status == -1),
    error(['WRT_SSH: ncattput - unable to define attribute: ',...
           'SSH:field.'])
  end
end

%----------------------------------------------------------------------------
%  Leave definition mode and close NetCDF file.
%----------------------------------------------------------------------------

if (defmode == 1),
   [status]=mexcdf('ncendef',ncid);
   if (status == -1),
     error(['WRT_SSH: ncendef - unable to leave definition mode.'])
   end
end

[status]=mexcdf('ncclose',ncid);
if (status == -1),
  error(['WRT_SSH: ncclose - unable to close NetCDF file: ', fname])
end

%============================================================================
%  Write out sea surface height into NetCDF file.
%============================================================================

[status]=nc_write(fname,'ssh_time',tssh);
[status]=nc_write(fname,'SSH',ssh);

return
