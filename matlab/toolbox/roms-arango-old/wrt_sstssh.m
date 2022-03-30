function [status]=wrt_sstssh(fname,SSTavg,SSTvar,SSHavg,SSHvar);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright (c) 1999 Rutgers University.                                    %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                           %
% function [status]=wrt_sstssh(fname,SSTavg,SSTvar,SSHavg,SSHvar);          %
%                                                                           %
% This function writes out sea surface temperature and free-surface mean    %
% and variance to a existing NetCDF file. It appropriate, it will define    %
% in NetCDF file.                                                           %
%                                                                           %
% On Input:                                                                 %
%                                                                           %
%    fname       GRID NetCDF file name (character string).                  %
%    SSTavg      Sea surface temperature mean.                              %
%    SSTvar      Sea surface temperature variance.                          %
%    SSHavg      Sea surface height mean.                                   %
%    SSHvar      Sea surface height variance.                               %
%                                                                           %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%  Inquire if SST and SSH mean and variace are defined.

[vname,nvars]=nc_vname(fname);

define.SSTavg=1;
define.SSTvar=1;
define.SSHavg=1;
define.SSHvar=1;

for n=1:nvars,
  name=deblank(vname(n,:));
  switch (name),
    case 'SST_mean'
      define.SSTavg=0;
    case 'SST_var'
      define.SSTvar=0;
    case 'SSH_mean'
      define.SSHavg=0;
    case 'SSH_var'
      define.SSHvar=0;
  end,
end,

%----------------------------------------------------------------------------
% Define SST and SSH variables.
%----------------------------------------------------------------------------

if (define.SSTavg | define.SSTvar | define.SSHavg | define.SSHvar ),

% Open GRIDS NetCDF file.

  [ncid]=mexcdf('ncopen',fname,'nc_write');
  if (ncid == -1),
    error(['WRT_SSTSSH: ncopen - unable to open file: ', fname])
    return
  end

% Put file in definition mode.

  [status]=mexcdf('ncredef',ncid);
  if (status == -1),
    error(['WRT_SSTSSH: ncrefdef - unable to put into define mode.'])
    return
  end

% Supress all error messages from NetCDF.

  [ncopts]=mexcdf('setopts',0);

% Define NetCDF parameters.

  [ncglobal]=mexcdf('parameter','nc_global');
  [ncdouble]=mexcdf('parameter','nc_double');
  [ncfloat]=mexcdf('parameter','nc_float');
  [ncchar]=mexcdf('parameter','nc_char');

  vartyp=ncfloat;

% Inquire dimension IDs.  A value of -1 is returned if the dimension is
% not defined.

  [xrdim]=mexcdf('ncdimid',ncid,'xi_rho');
  if (xrdim == -1),
    error(['WRT_SSTSSH: ncdimid - unable to inquire dimension: xi_rho.']);
  end
  [yrdim]=mexcdf('ncdimid',ncid,'eta_rho');
  if (yrdim == -1),
    error(['WRT_SSTSSH: ncdimid - unable to inquire dimension: eta_rho.']);
  end

% Define SST mean.

  if (define.SSTavg),
    [varid]=mexcdf('ncvardef',ncid,'SST_mean',vartyp,2,[yrdim xrdim]);
    if (varid == -1),
      error(['WRT_SSTSSH: ncvardef - unable to define variable: SST_mean.']);
    end
    text='sea surface temperature mean';
    lstr=max(size(text));
    [status]=mexcdf('ncattput',ncid,varid,'long_name',ncchar,lstr,text);
    if (status == -1),
      error(['WRT_SSTSSH: ncattput - unable to define attribute: ',...
             'SST_mean:long_name.']);
    end
    text='Celsius';
    lstr=max(size(text));
    [status]=mexcdf('ncattput',ncid,varid,'units',ncchar,lstr,text);
    if (status == -1),
      error(['WRT_SSTSSH: ncattput - unable to define attribute: ',...
             'SST_mean:units.'])
    end
    text='SST_mean, scalar';
    lstr=max(size(text));
    [status]=mexcdf('ncattput',ncid,varid,'field',ncchar,lstr,text);
    if (status == -1),
      error(['WRT_SSTSSH: ncattput - unable to define attribute: ',...
             'SST_mean:field.'])
    end,
  end,

% Define SST variance.

  if (define.SSTvar),
    [varid]=mexcdf('ncvardef',ncid,'SST_var',vartyp,2,[yrdim xrdim]);
    if (varid == -1),
      error(['WRT_SSTSSH: ncvardef - unable to define variable: SST_var.']);
    end
    text='sea surface temperature variance';
    lstr=max(size(text));
    [status]=mexcdf('ncattput',ncid,varid,'long_name',ncchar,lstr,text);
    if (status == -1),
      error(['WRT_SSTSSH: ncattput - unable to define attribute: ',...
             'SST_var:long_name.']);
    end
    text='Celsius2';
    lstr=max(size(text));
    [status]=mexcdf('ncattput',ncid,varid,'units',ncchar,lstr,text);
    if (status == -1),
      error(['WRT_SSTSSH: ncattput - unable to define attribute: ',...
             'SST_mean:units.'])
    end
    text='SST_var, scalar';
    lstr=max(size(text));
    [status]=mexcdf('ncattput',ncid,varid,'field',ncchar,lstr,text);
    if (status == -1),
      error(['WRT_SSTSSH: ncattput - unable to define attribute: ',...
             'SST_var:field.'])
    end,
  end,

% Define SSH mean.

  if (define.SSHavg),
    [varid]=mexcdf('ncvardef',ncid,'SSH_mean',vartyp,2,[yrdim xrdim]);
    if (varid == -1),
      error(['WRT_SSTSSH: ncvardef - unable to define variable: SSH_mean.']);
    end
    text='sea surface temperature mean';
    lstr=max(size(text));
    [status]=mexcdf('ncattput',ncid,varid,'long_name',ncchar,lstr,text);
    if (status == -1),
      error(['WRT_SSTSSH: ncattput - unable to define attribute: ',...
             'SSH_mean:long_name.']);
    end
    text='meter';
    lstr=max(size(text));
    [status]=mexcdf('ncattput',ncid,varid,'units',ncchar,lstr,text);
    if (status == -1),
      error(['WRT_SSTSSH: ncattput - unable to define attribute: ',...
             'SSH_mean:units.'])
    end
    text='SSH_mean, scalar';
    lstr=max(size(text));
    [status]=mexcdf('ncattput',ncid,varid,'field',ncchar,lstr,text);
    if (status == -1),
      error(['WRT_SSTSSH: ncattput - unable to define attribute: ',...
             'SSH_mean:field.'])
    end,
  end,

% Define SSH variance.

  if (define.SSHvar),
    [varid]=mexcdf('ncvardef',ncid,'SSH_var',vartyp,2,[yrdim xrdim]);
    if (varid == -1),
      error(['WRT_SSTSSH: ncvardef - unable to define variable: SSH_var.']);
    end
    text='sea surface height variance';
    lstr=max(size(text));
    [status]=mexcdf('ncattput',ncid,varid,'long_name',ncchar,lstr,text);
    if (status == -1),
      error(['WRT_SSTSSH: ncattput - unable to define attribute: ',...
             'SSH_var:long_name.']);
    end
    text='meter2';
    lstr=max(size(text));
    [status]=mexcdf('ncattput',ncid,varid,'units',ncchar,lstr,text);
    if (status == -1),
      error(['WRT_SSTSSH: ncattput - unable to define attribute: ',...
             'SSH_mean:units.'])
    end
    text='SSH_var, scalar';
    lstr=max(size(text));
    [status]=mexcdf('ncattput',ncid,varid,'field',ncchar,lstr,text);
    if (status == -1),
      error(['WRT_SSTSSH: ncattput - unable to define attribute: ',...
             'SSH_var:field.'])
    end,
  end,

%  Leave definition mode and close NetCDF file.

  [status]=mexcdf('ncendef',ncid);
  if (status == -1),
    error(['WRT_SSTSSH: ncendef - unable to leave definition mode.']);
  end,

  [status]=mexcdf('ncclose',ncid);
  if (status == -1),
    error(['WRT_SSTSSH: ncclose - unable to close NetCDF file: ', fname]);
  end,

end,

%----------------------------------------------------------------------------
%  Write out sea surface height into NetCDF file.
%----------------------------------------------------------------------------

F=SSTavg;
ind=isnan(F);
if (~isempty(ind)), F(ind)=0; end,
[status]=nc_write(fname,'SST_mean',F);

F=SSTvar;
ind=isnan(F);
if (~isempty(ind)), F(ind)=0; end,
[status]=nc_write(fname,'SST_var',F);

F=SSHavg;
ind=isnan(F);
if (~isempty(ind)), F(ind)=0; end,
[status]=nc_write(fname,'SSH_mean',F);

F=SSHvar;
ind=isnan(F);
if (~isempty(ind)), F(ind)=0; end,
[status]=nc_write(fname,'SSH_var',F);

return
