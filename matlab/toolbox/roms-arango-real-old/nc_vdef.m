function [varid,status]=nc_vdef(ncid,Var);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright (c) 1999 Rutgers University.                                    %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                           %
% [varid,status]=nc_vdef(ncid,Var)                                          %
%                                                                           %
% This function defines a variable into NetCDF file.                        %
%                                                                           %
% On Input:                                                                 %
%                                                                           %
%    ncid        NetCDF file ID (integer).                                  %
%    Var         Variable information (structure array):                    %
%                  Var.name  => variable name.                              %
%                  Var.type  => variable type.                              %
%                  Var.dimid => variable dimension IDs.                     %
%                  Var.long  => variable long-name attribute.               %
%                  Var.units => variable units attribute.                   %
%                  Var.fill  => variable _FillValue attribute.              %
%                  Var.min   => variable valid_min attribute.               %
%                  Var.max   => variable valid_max attribute.               %
%                  Var.opt_T => variable option_T attribute.                %
%                  Var.minus => variable negative attribute.                %
%                  Var.plus  => variable psotive attribute.                 %
%                  Var.opt_0 => variable option_0 attribute.                %
%                  Var.opt_1 => variable option_1 attribute.                %
%                  Var.field => variable field attribute.                   %
%                  Var.pos   => variable spatial positions attribute.       %
%                                                                           %
% On Output:                                                                %
%                                                                           %
%    varid       Variable ID.                                               %
%    status      Error flag.                                                %
%                                                                           %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%-----------------------------------------------------------------------
%  Get some NetCDF parameters.
%-----------------------------------------------------------------------

[ncdouble]=mexcdf('parameter','nc_double');
[ncfloat]=mexcdf('parameter','nc_float');
[ncchar]=mexcdf('parameter','nc_char');

% Set variable type (default: floating point, single precision)

if (isfield(Var,'type')),
  vartyp=Var.type;
else,
  vartyp=ncfloat;
end,

%-----------------------------------------------------------------------
%  Define requested variable.
%-----------------------------------------------------------------------

% Define variable.

if (isfield(Var,'name') & isfield(Var,'dimid')),
  vdid=Var.dimid;
  nvdim=length(vdid);
  [varid]=mexcdf('ncvardef',ncid,Var.name,vartyp,nvdim,vdid);
  if (varid == -1),
    error(['D_NCDX: ncvardef - unable to define variable: ',Var.name]);
    return,
  end,
end,

% Set long-name attribute.

if (isfield(Var,'long')),
  text=Var.long;
  lstr=length(text);
  if (lstr > 0),
    [status]=mexcdf('ncattput',ncid,varid,'long_name',ncchar,lstr,text);
    if (status == -1),
      error(['D_NCDX: ncattput - unable to define attribute: ',...
             Var.name,':long_name.']);
      return,
    end,
  end,
end,

% Set units attribute.

if (isfield(Var,'units')),
  text=Var.units;
  lstr=length(text);
  if (lstr > 0),
    [status]=mexcdf('ncattput',ncid,varid,'units',ncchar,lstr,text);
    if (status == -1),
      error(['D_NCDX: ncattput - unable to define attribute: ',...
             Var.name,':units.']);
      return,
    end,
  end,
end,

% Set _FillValue attribute.

if (isfield(Var,'fill')),
  [status]=mexcdf('ncattput',ncid,varid,'_FillValue',vartyp,1,Var.fill);
  if (status == -1),
    error(['D_NCDX: ncattput - unable to define attribute: ',...
           Vname.name,':_FillValue']);
    return,
  end,
end,

% Set valid_min attribute.

if (isfield(Var,'min')),
  [status]=mexcdf('ncattput',ncid,varid,'valid_min',vartyp,1,Var.min);
  if (status == -1),
    error(['D_NCDX: ncattput - unable to define attribute: ',...
           Vname.name,':valid_min']);
    return,
  end,
end,

% Set valid_max attribute.

if (isfield(Var,'max')),
  [status]=mexcdf('ncattput',ncid,varid,'valid_max',vartyp,1,Var.max);
  if (status == -1),
    error(['D_NCDX: ncattput - unable to define attribute: ',...
           Vname.name,':valid_max.']);
    return,
  end,
end,

% Set option_T attribute.

if (isfield(Var,'opt_T')),
  text=Var.opt_T;
  lstr=length(text);
  if (lstr > 0),
    [status]=mexcdf('ncattput',ncid,varid,'option_T',ncchar,lstr,text);
    if (status == -1),
      error(['D_NCDX: ncattput - unable to define attribute: ',...
             Vname.name,':option_T.']);
      return,
    end,
  end,
end,

% Set option_F attribute.

if (isfield(Var,'opt_F')),
  text=Var.opt_F;
  lstr=length(text);
  if (lstr > 0),
    [status]=mexcdf('ncattput',ncid,varid,'option_F',ncchar,lstr,text);
    if (status == -1),
      error(['D_NCDX: ncattput - unable to define attribute: ',...
             Vname.name,':option_T.']);
      return,
    end,
  end,
end,

% Set positive attribute.

if (isfield(Var,'plus')),
  text=Var.plus;
  lstr=length(text);
  if (lstr > 0),
    [status]=mexcdf('ncattput',ncid,varid,'positive',ncchar,lstr,text);
    if (status == -1),
      error(['D_NCDX: ncattput - unable to define attribute: ',...
             Vname.name,':option_T.']);
      return,
    end,
  end,
end,

% Set negative attribute.

if (isfield(Var,'minus')),
  text=Var.minus;
  lstr=length(text);
  if (lstr > 0),
    [status]=mexcdf('ncattput',ncid,varid,'negative',ncchar,lstr,text);
    if (status == -1),
      error(['D_NCDX: ncattput - unable to define attribute: ',...
             Vname.name,':option_T.']);
      return,
    end,
  end,
end,

% Set option_0 attribute.

if (isfield(Var,'opt_0')),
  text=Var.opt_0;
  lstr=length(text);
  if (lstr > 0),
    [status]=mexcdf('ncattput',ncid,varid,'option_0',ncchar,lstr,text);
    if (status == -1),
      error(['D_NCDX: ncattput - unable to define attribute: ',...
             Vname.name,':option_0.']);
      return,
    end,
  end,
end,

% Set option_1 attribute.

if (isfield(Var,'opt_1')),
  text=Var.opt_1;
  lstr=length(text);
  if (lstr > 0),
    [status]=mexcdf('ncattput',ncid,varid,'option_1',ncchar,lstr,text);
    if (status == -1),
      error(['D_NCDX: ncattput - unable to define attribute: ',...
             Vname.name,':option_1.']);
      return,
    end,
  end,
end,

% Set field attribute.

if (isfield(Var,'field')),
  text=Var.field;
  lstr=length(text);
  if (lstr > 0),
    [status]=mexcdf('ncattput',ncid,varid,'field',ncchar,lstr,text);
    if (status == -1),
      error(['D_NCDX: ncattput - unable to define attribute: ',...
             Vname.name,':field.']);
      return,
    end,
  end,
end,

% Set spatial positions attribute.

if (isfield(Var,'pos')),
  text=Var.pos;
  lstr=length(text);
  if (lstr > 0),
    [status]=mexcdf('ncattput',ncid,varid,'positions',ncchar,lstr,text);
    if (status == -1),
      error(['D_NCDX: ncattput - unable to define attribute: ',...
             Vname.name,':positions']);
    end,
  end,
end,

return
