function [status]=wrt_wave(fname,wave);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright (c) 2000 Rutgers University.                                    %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                           %
% function status=wrt_wave(fname,wave)                                      %
%                                                                           %
% This routine writes out wind induced wave data into a FORCING NetCDF      %
% file.                                                                     %
%                                                                           %
% On Input:                                                                 %
%                                                                           %
%    fname       FORCING NetCDF file name (character string).               %
%    wave        Wave data (structure array):                               %
%                  wave.time =>  Time (Modified Julian Day).                %
%                  wave.amp  =>  Wave amplitude (m).                        %
%                  wave.dir  =>  Wave direction (degrees).                  %
%                  wave.per  =>  Wave period (seconds).                     %
%                                                                           %
% Calls:   MEXCDF (Interface to NetCDF library using Matlab).               %
%          nc_write                                                         %
%                                                                           %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global IPRINT
IPRINT=0;

Nrec=length(wave.time);
grided=length(size(wave.amp))-2;

%---------------------------------------------------------------------------
% Set variable names.
%---------------------------------------------------------------------------

define.Tdim=1;
define.Twave=1;
define.Awave=1;
define.Dwave=1;
define.Pwave=1;

Vname.Tdim ='wave_time';
Vname.Twave='wave_time';
Vname.Awave='Awave';
Vname.Dwave='Dwave';
Vname.Pwave='Pwave';

[vname,nvars]=nc_vname(fname);
for n=1:nvars,
  name=deblank(vname(n,:));
  switch (name),  
    case 'wave_time',
      define.Twave=0;
    case 'Awave',
      define.Awave=0;
    case 'Dwave',
      define.Dwave=0;
    case 'Pwave',
      define.Pwave=0;
  end,
end,

defmode = define.Twave | define.Awave | define.Dwave | define.Pwave;

%---------------------------------------------------------------------------
%  If applicable, define wave variables.
%---------------------------------------------------------------------------

if ( defmode ),

%  Open FORCING NetCDF file.

  [ncid]=mexcdf('ncopen',fname,'nc_write');
  if (ncid == -1),
    error(['WRT_WAVE: ncopen - unable to open file: ', fname])
    return
  end

%  Supress all error messages from NetCDF.

  [ncopts]=mexcdf('setopts',0);

%  Define NetCDF parameters.

  [ncdouble]=mexcdf('parameter','nc_double');
  [ncfloat]=mexcdf('parameter','nc_float');
  vartyp=ncfloat;

%  Put NetCDF file into definition mode.

  [status]=mexcdf('ncredef',ncid);
  if (status == -1),
    error(['WRT_WAVE: ncrefdef - unable to put into define mode.'])
    return
  end

%  Inquire horizontal dimensions name at RHO-points.

  [Dnames,Dsizes]=nc_dim(fname);
  ndims=length(Dsizes);

  for n=1:ndims,
    name=deblank(Dnames(n,:));
    switch (name),  
      case 'xi_rho'
        did.xr=n;
      case 'eta_rho'
        did.er=n;
      case 'wave_time'
        did.time=n;
        define.Tdim=0;
    end,
  end,

%  Define time dimension.

  if (define.Tdim),
    [did.time]=mexcdf('ncdimdef',ncid,Vname.Tdim,Nrec);
    if (did.time == -1),
     error(['WRT_WAVE: ncvardef - unable to define dimension: ',Vname.Tdim]);
    end,
  end,

%  Define wind-induced wave time.

  if (define.Twave),
    Var.name  =Vname.Twave;
    Var.type  =ncdouble;
    Var.dimid =[did.time];
    Var.long  ='wind-induced wave time';
    Var.units ='modified Julian day';
    Var.offset=2440000;
    Var.field ='time, scalar, series';

    [varid,status]=nc_vdef(ncid,Var);
    clear Var
  end,

%  Define wind-induced wave amplitude.

  if (define.Awave),
    Var.name =Vname.Awave;
    Var.type =vartyp;
    if (grided),
      Var.dimid=[did.time did.er did.xr];
    else,
      Var.dimid=[did.time];
    end,
    Var.long ='wind-induced wave amplitude';
    Var.units='meter';
    Var.field='Awave, scalar, series';

    [varid,status]=nc_vdef(ncid,Var);
    clear Var
  end,

%  Define wind-induced wave direction.

  if (define.Awave),
    Var.name =Vname.Dwave;
    Var.type =vartyp;
    if (grided),
      Var.dimid=[did.time did.er did.xr];
    else,
      Var.dimid=[did.time];
    end,
    Var.long ='wind-induced wave direction';
    Var.units='degrees';
    Var.field='Dwave, scalar, series';

    [varid,status]=nc_vdef(ncid,Var);
    clear Var
  end,

%  Define wind-induced wave amplitude.

  if (define.Pwave),
    Var.name =Vname.Pwave;
    Var.type =vartyp;
    if (grided),
      Var.dimid=[did.time did.er did.xr];
    else,
      Var.dimid=[did.time];
    end,
    Var.long ='wind-induced wave period';
    Var.units='second';
    Var.field='Pwave, scalar, series';

    [varid,status]=nc_vdef(ncid,Var);
    clear Var
  end,

%  Leave definition mode and close NetCDF file.

  [status]=mexcdf('ncendef',ncid);
  if (status == -1),
    error(['WRT_WAVE: ncendef - unable to leave definition mode.']);
  end,

  [status]=mexcdf('ncclose',ncid);
  if (status == -1),
    error(['WRT_WAVE: ncclose - unable to close NetCDF file: ', fname]);
  end,

end,

%---------------------------------------------------------------------------
%  Write out wave data.
%---------------------------------------------------------------------------

status=nc_write(fname,Vname.Twave,wave.time);
status=nc_write(fname,Vname.Awave,wave.amp);
status=nc_write(fname,Vname.Dwave,wave.dir);
status=nc_write(fname,Vname.Pwave,wave.per);

return
