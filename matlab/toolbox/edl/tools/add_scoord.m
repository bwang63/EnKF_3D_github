function [status]=add_scoord(Sname,Fname);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright (c) 1999 Rutgers University.                                    %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                           %
% function [status]=add_scoord(Sname,Fname);                                %
%                                                                           %
% This script adds/modifies the S-coordinate parameters of an existing      %
% NetCDF file.                                                              %
%                                                                           %
% On Input:                                                                 %
%                                                                           %
%    Sname       NetCDF file name having desired S-coordinate parameters    %
%                  (character string).                                      %
%    Fname       NetCDF file name to modify (character string).             %
%                                                                           %
% Calls:   MEXCDF (Interface to NetCDF library using Matlab).               %
%          nc_write                                                         %
%                                                                           %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%  Open output NetCDF file.

[ncid]=mexcdf('ncopen',Fname,'nc_write');
if (ncid == -1),
  error(['ADD_SCOORD: ncopen - unable to open file: ', Fname])
  return
end

%  Supress all error messages from NetCDF.

[ncopts]=mexcdf('setopts',0);

%  Define NetCDF parameters.

[ncglobal]=mexcdf('parameter','nc_global');
[ncdouble]=mexcdf('parameter','nc_double');
[ncfloat]=mexcdf('parameter','nc_float');
[ncchar]=mexcdf('parameter','nc_char');

%-----------------------------------------------------------------------
%  Inquire files dimensions.
%-----------------------------------------------------------------------

[Sdnames,Sdsizes]=nc_dim(Sname);

ndims=length(Sdsizes);
for n=1:ndims,
  name=deblank(Sdnames(n,:));
  switch (name),
    case 's_rho',
      dsiz.sr=Sdsizes(n);
      dnam.sr=name;
    case 's_w',
      dsiz.sw=Sdsizes(n);
      dnam.sw=name;
  end,
end,

[Fdnames,Fdsizes]=nc_dim(Fname);

got.sr=0;
got.sw=0;
ndims=length(Fdsizes);
for n=1:ndims,
  name=deblank(Fdnames(n,:));
  switch (name),
    case 's_rho',
      got.sr=1;
      did.sr=n-1;
      if (Fdsizes(n) ~= dsiz.sr),
        error(['ADD_SCOORD: inconsistent size of dimension: ', name])
        return
      end,
    case 's_w',
      got.sw=1;
      did.sw=n;
      if (Fdsizes(n) ~= dsiz.sw),
        error(['ADD_SCOORD: inconsistent size of dimension: ', name])
        return
      end,
  end,
end,

%-----------------------------------------------------------------------
%  Inquire S-coordinate parameter variables.
%-----------------------------------------------------------------------

[vname,nvars]=nc_vname(Fname);

define.hc=1;
define.spherical=1;
define.scr=1;
define.scw=1;
define.Csr=1;
define.Csw=1;

for n=1:nvars,
  name=deblank(vname(n,:));
  switch (name),
    case 'hc'
      define.hc=0;
    case 'spherical'
      define.spherical=0;
    case 'sc_r'
      define.scr=0;
    case 'sc_w'
      define.scw=0;
    case 'Cs_r'
      define.Csr=0;
    case 'Cs_w'
      define.Csw=0;
  end,
end,

%-----------------------------------------------------------------------
%  Define S-coordinate variables.
%-----------------------------------------------------------------------

defmode=(define.hc  | define.spherical | define.scr | define.scw | ...
         define.Csr | define.Csw);

if (defmode),

%  Put NetCDF file into definition mode.

  [status]=mexcdf('ncredef',ncid);
  if (status == -1),
    error(['ADD_SCOORD: ncrefdef - unable to put into define mode.'])
    return
  end

%  Define "s_rho" dimension.

  if (~got.sr),
    [did.sr]=mexcdf('ncdimdef',ncid,dnam.sr,dsiz.sr);
    if (did.sr == -1),
      error(['ADD_SCOORD: ncvardef - unable to define dimension: ',dnam.sr]);
    end,
  end,

%  Define "s_w" dimension.

  if (~got.sw),
    [did.sw]=mexcdf('ncdimdef',ncid,dnam.sw,dsiz.sw);
    if (did.sw == -1),
      error(['ADD_SCOORD: ncvardef - unable to define dimension: ',dnam.sw]);
    end,
  end,

% Define spherical switch.

  if (define.spherical),
    Var.name ='spherical';
    Var.type =ncchar;
    Var.dimid=[];
    Var.long ='grid type logical switch';
    Var.opt_T='spherical';
    Var.opt_F='Cartesian';
    [varid,status]=nc_vdef(ncid,Var);
    clear Var
  end,

%  Define critical depth.

  if (define.hc),
    Var.name ='hc';
    Var.long ='S-coordinate parameter, critical depth';
    Var.dimid=[];
    Var.type =ncdouble;
    Var.units='meter';
    [varid,status]=nc_vdef(ncid,Var);
    clear Var
  end,

%  Define S-coordinate at RHO-points.

  if (define.scr),
    Var.name ='sc_r';
    Var.long ='S-coordinate at RHO-points';
    Var.dimid=[did.sr];
    Var.type =ncdouble;
    Var.units='nondimensional';
    Var.min  =-1;
    Var.max  =0;
    Var.field='sc_r, scalar';
    [varid,status]=nc_vdef(ncid,Var);
    clear Var
  end,

%  Define S-coordinate at W-points.

  if (define.scw),
    Var.name ='sc_w';
    Var.long ='S-coordinate at W-points';
    Var.dimid=[did.sw];
    Var.type =ncdouble;
    Var.units='nondimensional';
    Var.min  =-1;
    Var.max  =0;
    Var.field='sc_w, scalar';
    [varid,status]=nc_vdef(ncid,Var);
    clear Var
  end,

%  Define S-coordinate stretching curves at RHO-points.

  if (define.Csr)
    Var.name ='Cs_r';
    Var.long ='S-coordinate stretching curves at RHO-points';
    Var.dimid=[did.sr];
    Var.type =ncdouble;
    Var.units='nondimensional';
    Var.min  =-1;
    Var.max  =0;
    Var.field='Cs_r, scalar';
    [varid,status]=nc_vdef(ncid,Var);
    clear Var
  end,

%  Define S-coordinate stretching curves at W-points.

  if (define.Csw),
    Var.name ='Cs_w';
    Var.long ='S-coordinate stretching curves at W-points';
    Var.dimid=[did.sw];
    Var.type =ncdouble;
    Var.units='nondimensional';
    Var.min  =-1;
    Var.max  =0;
    Var.field='Cs_w, scalar';
    [varid,status]=nc_vdef(ncid,Var);
    clear Var
  end,

%  Leave definition mode.

  [status]=mexcdf('ncendef',ncid);
  if (status == -1),
    error(['ADD_SCOORD: ncendef - unable to leave definition mode.']);
    return
  end,

%  Close NetCDF file.

  [status]=mexcdf('ncclose',ncid);
  if (status == -1),
    error(['ADD_SCOORD: ncclose - unable to close NetCDF file: ', Fname]);
    return
  end,

end,

%----------------------------------------------------------------------------
%  Write S-coordinate variables.
%----------------------------------------------------------------------------

spherical=nc_read(Sname,'spherical');
[status]=nc_write(Fname,'spherical',spherical);

hc=nc_read(Sname,'hc');
[status]=nc_write(Fname,'hc',hc);

Finp=nc_read(Sname,'sc_r');
[status]=nc_write(Fname,'sc_r',Finp);

Finp=nc_read(Sname,'Cs_r');
[status]=nc_write(Fname,'Cs_r',Finp);

Finp=nc_read(Sname,'sc_w');
[status]=nc_write(Fname,'sc_w',Finp);

Finp=nc_read(Sname,'Cs_w');
[status]=nc_write(Fname,'Cs_w',Finp);

return

