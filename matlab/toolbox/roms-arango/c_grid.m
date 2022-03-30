function [status]=c_grid(Lp,Mp,Gname);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright (c) 2000 Rutgers University.                                    %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Hernan G. Arango %%%
%                                                                           %
% function [status]=c_grid(Im,Jm,Gname);                                    %
%                                                                           %
% This function creates or modifies a GRID NetCDF file.                     %
%                                                                           %
% On Input:                                                                 %
%                                                                           %
%    Lp          Number of RHO-points in the XI-direction.                  %
%    Mp          Number of RHO-points in the ETA-direction.                 %
%    Gname       GRID NetCDF file name.                                     %
%                                                                           %
% On Output:                                                                %
%                                                                           %
%    status      Error flag.                                                %
%                                                                           %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Check if GRID NetCDF already exist.

GOT_NCFILE=0;
[ncid]=mexcdf('ncopen',Gname,'nc_write');
disp(' ');
if (ncid ~= -1),
  GOT_NCFILE=1;
  disp(['Appending to existing GRID NetCDF file: ',Gname]);
else,
  disp(['Creating a new GRID NetCDF file: ',Gname]);
end,
disp(' ');

%----------------------------------------------------------------------------
%  Get some NetCDF parameters.
%----------------------------------------------------------------------------

[ncglobal]=mexcdf('parameter','nc_global');
[ncdouble]=mexcdf('parameter','nc_double');
[ncunlim]=mexcdf('parameter','nc_unlimited');
[ncfloat]=mexcdf('parameter','nc_float');
[ncchar]=mexcdf('parameter','nc_char');

%----------------------------------------------------------------------------
%  Inquire dimensions from a existing NeTCDF file.
%----------------------------------------------------------------------------

gotDim.xr   =0;  Dname.xr  ='xi_rho';    Dsize.xr  =Lp;
gotDim.xu   =0;  Dname.xu  ='xi_u';      Dsize.xu  =Lp-1;
gotDim.xv   =0;  Dname.xv  ='xi_v';      Dsize.xv  =Lp;
gotDim.xp   =0;  Dname.xp  ='xi_psi';    Dsize.xp  =Lp-1;
gotDim.yr   =0;  Dname.yr  ='eta_rho';   Dsize.yr  =Mp;
gotDim.yu   =0;  Dname.yu  ='eta_u';     Dsize.yu  =Mp;
gotDim.yv   =0;  Dname.yv  ='eta_v';     Dsize.yv  =Mp-1;
gotDim.yp   =0;  Dname.yp  ='eta_psi';   Dsize.yp  =Mp-1;
gotDim.bath =0;  Dname.bath='bath';      Dsize.bath=ncunlim;

if (GOT_NCFILE),

  [Dnames,Dsizes]=nc_dim(Gname);
  ndims=length(Dsizes);
  for n=1:ndims,
    name=deblank(Dnames(n,:));
    switch name
      case {Dname.xr}
        Dsize.xr=Dsizes(n);
        gotDim.xr=1;
        did.xr=n-1;
      case {Dname.xu}
        Dsize.xu=Dsizes(n);
        gotDim.xu=1;
        did.xu=n-1;
      case {Dname.xv}
        Dsize.xv=Dsizes(n);
        gotDim.xv=1;
        did.xv=n-1;
      case {Dname.xp}
        Dsize.xp=Dsizes(n);
        gotDim.xp=1;
        did.xp=n-1;
      case {Dname.yr}
        Dsize.yr=Dsizes(n);
        gotDim.yr=1;
        did.yr=n-1;
      case {Dname.yu}
        Dsize.yu=Dsizes(n);
        gotDim.yu=1;
        did.yu=n-1;
      case {Dname.yv}
        Dsize.yv=Dsizes(n);
        gotDim.yv=1;
        did.yv=n-1;
      case {Dname.yp}
        Dsize.yp=Dsizes(n);
        gotDim.yp=1;
        did.yp=n-1;
      case {Dname.bath}
        Dsize.bath=Dsizes(n);
        gotDim.bath=1;
        did.bath=n-1;
    end,
  end,
  if (gotDim.xr),
    if (~gotDim.xu), Dsize.xu=Dsize.xr-1; end,
    if (~gotDim.xv), Dsize.xv=Dsize.xr;   end,
    if (~gotDim.xp), Dsize.xp=Dsize.xr-1; end,
  end,
  if (gotDim.yr),
    if (~gotDim.yu), Dsize.yu=Dsize.yr;   end,
    if (~gotDim.yv), Dsize.yv=Dsize.yr-1; end,
    if (~gotDim.yp), Dsize.yp=Dsize.yr-1; end,
  end,
  if (~gotDim.bath), Dsize.bath=ncunlim; end,

end,

%----------------------------------------------------------------------------
%  Inquire Variables from a existing NeTCDF file.
%----------------------------------------------------------------------------

gotVar.spheric=0;  Vname.spheric='spherical';
gotVar.xl     =0;  Vname.xl     ='xl';
gotVar.el     =0;  Vname.el     ='el';

gotVar.angle  =0;  Vname.angle  ='angle';
gotVar.pm     =0;  Vname.pm     ='pm';
gotVar.pn     =0;  Vname.pn     ='pn';
gotVar.dndx   =0;  Vname.dndx   ='dndx';
gotVar.dmde   =0;  Vname.dmde   ='dmde';
gotVar.f      =0;  Vname.f      ='f';
gotVar.h      =0;  Vname.h      ='h';
gotVar.hraw   =0;  Vname.hraw   ='hraw';

gotVar.rx     =0;  Vname.rx     ='x_rho';
gotVar.ry     =0;  Vname.ry     ='y_rho';
gotVar.px     =0;  Vname.px     ='x_psi';
gotVar.py     =0;  Vname.py     ='y_psi';
gotVar.ux     =0;  Vname.ux     ='x_u';
gotVar.uy     =0;  Vname.uy     ='y_u';
gotVar.vx     =0;  Vname.vx     ='x_v';
gotVar.vy     =0;  Vname.vy     ='y_v';

gotVar.rlon   =0;  Vname.rlon   ='lon_rho';
gotVar.rlat   =0;  Vname.rlat   ='lat_rho';
gotVar.plon   =0;  Vname.plon   ='lon_psi';
gotVar.plat   =0;  Vname.plat   ='lat_psi';
gotVar.ulon   =0;  Vname.ulon   ='lon_u';
gotVar.ulat   =0;  Vname.ulat   ='lat_u';
gotVar.vlon   =0;  Vname.vlon   ='lon_v';
gotVar.vlat   =0;  Vname.vlat   ='lat_v';

gotVar.rmask  =0;  Vname.rmask  ='mask_rho';
gotVar.pmask  =0;  Vname.pmask  ='mask_psi';
gotVar.umask  =0;  Vname.umask  ='mask_u';
gotVar.vmask  =0;  Vname.vmask  ='mask_v';

if (GOT_NCFILE),

  [varnam,nvars]=nc_vname(Gname);
  for n=1:nvars,
    name=deblank(varnam(n,:));
    switch name
      case {Vname.spheric}
        gotVar.spheric=1;
      case {Vname.xl}
        gotVar.el=1;
      case {Vname.angle}
        gotVar.angle=1;
      case {Vname.pm}
        gotVar.pm=1;
      case {Vname.pn}
        gotVar.pn=1;
      case {Vname.dndx}
        gotVar.dndx=1;
      case {Vname.dmde}
        gotVar.dmde=1;
      case {Vname.f}
        gotVar.f=1;
      case {Vname.h}
        gotVar.h=1;
      case {Vname.hraw}
        gotVar.hraw=1;
      case {Vname.rx}
        gotVar.rx=1;
      case {Vname.ry}
        gotVar.ry=1;
      case {Vname.px}
        gotVar.px=1;
      case {Vname.py}
        gotVar.py=1;
      case {Vname.ux}
        gotVar.ux=1;
      case {Vname.uy}
        gotVar.uy=1;
      case {Vname.vx}
        gotVar.vx=1;
      case {Vname.vy}
        gotVar.vy=1;
      case {Vname.rlon}
        gotVar.rlon=1;
      case {Vname.rlat}
        gotVar.rlat=1;
      case {Vname.ulon}
        gotVar.ulon=1;
      case {Vname.ulat}
        gotVar.ulat=1;
      case {Vname.vlon}
        gotVar.vlon=1;
      case {Vname.vlat}
        gotVar.vlat=1;
      case {Vname.plon}
        gotVar.plon=1;
      case {Vname.plat}
        gotVar.plat=1;
      case {Vname.rmask}
        gotVar.rmask=1;
      case {Vname.umask}
        gotVar.umask=1;
      case {Vname.vmask}
        gotVar.vmask=1;
      case {Vname.pmask}
        gotVar.pmask=1;
    end,
  end,

end,

%----------------------------------------------------------------------------
%  If applicable, create initial/climatology NetCDF file.
%----------------------------------------------------------------------------

if (~GOT_NCFILE),
  [ncid,status]=mexcdf('nccreate',Gname,'nc_write');
  if (ncid == -1),
    error(['C_GRID: nccreate - unable to create file: ', Gname]);
    return
  end,
end,

%----------------------------------------------------------------------------
%  If applicable, open GRID NetCDF file and put in definition mode.
%----------------------------------------------------------------------------

if (GOT_NCFILE),
  [ncid]=mexcdf('ncopen',Gname,'nc_write');
  if (ncid == -1),
    error(['C_GRID: ncopen - unable to open file: ', Gname]);
    return
  end,
  [status]=mexcdf('ncredef',ncid);
  if (status == -1),
    error(['C_GRID: ncredef - unable to put in definition mode file: ', ...
           Gname]);
    return
  end,
end,

%-----------------------------------------------------------------------
%  Create global attribute(s).
%-----------------------------------------------------------------------

if (~GOT_NCFILE),
  type='GRID file';
  lstr=max(size(type));
  [status]=mexcdf('ncattput',ncid,ncglobal,'type',ncchar,lstr,type);
  if (status == -1),
    error(['C_GRID: ncattput - unable to global attribure: type.']);
    return
  end,
  history=['GRID file using Matlab script: c_grid, ', date_stamp];
  lstr=max(size(history));
  [status]=mexcdf('ncattput',ncid,ncglobal,'history',ncchar,lstr,history);
  if (status == -1),
    error(['C_GRID: ncattput - unable to global attribure: history.']);
    return
  end,
end,

%----------------------------------------------------------------------------
%  If appropriate, define dimensions.
%----------------------------------------------------------------------------

if (~gotDim.xr),
  [did.xr]=mexcdf('ncdimdef',ncid,Dname.xr,Dsize.xr);
  if (did.xr == -1),
    error(['C_GRID: ncdimdef - unable to define dimension: ',Dname.xr]);
  end,
end,

if (~gotDim.xu),
  [did.xu]=mexcdf('ncdimdef',ncid,Dname.xu,Dsize.xu);
  if (did.xu == -1),
    error(['C_GRID: ncdimdef - unable to define dimension: ',Dname.xu]);
  end,
end,

if (~gotDim.xv),
  [did.xv]=mexcdf('ncdimdef',ncid,Dname.xv,Dsize.xv);
  if (did.xv == -1),
    error(['C_GRID: ncdimdef - unable to define dimension: ',Dname.xv]);
  end,
end,

if (~gotDim.xp),
  [did.xp]=mexcdf('ncdimdef',ncid,Dname.xp,Dsize.xp);
  if (did.xp == -1),
    error(['C_GRID: ncdimdef - unable to define dimension: ',Dname.xp]);
  end,
end,

if (~gotDim.yr),
  [did.yr]=mexcdf('ncdimdef',ncid,Dname.yr,Dsize.yr);
  if (did.yr == -1),
    error(['C_GRID: ncdimdef - unable to define dimension: ',Dname.yr]);
  end,
end,

if (~gotDim.yu),
  [did.yu]=mexcdf('ncdimdef',ncid,Dname.yu,Dsize.yu);
  if (did.yu == -1),
    error(['C_GRID: ncdimdef - unable to define dimension: ',Dname.yu]);
  end,
end,

if (~gotDim.yv),
  [did.yv]=mexcdf('ncdimdef',ncid,Dname.yv,Dsize.yv);
  if (did.yv == -1),
    error(['C_GRID: ncdimdef - unable to define dimension: ',Dname.yv]);
  end,
end,

if (~gotDim.yp),
  [did.yp]=mexcdf('ncdimdef',ncid,Dname.yp,Dsize.yp);
  if (did.yp == -1),
    error(['C_GRID: ncdimdef - unable to define dimension: ',Dname.yp]);
  end,
end,

if (~gotDim.bath),
  [did.bath]=mexcdf('ncdimdef',ncid,Dname.bath,Dsize.bath);
  if (did.bath == -1),
    error(['C_GRID: ncdimdef - unable to define dimension: ',Dname.bath]);
  end,
end,

%----------------------------------------------------------------------------
%  If appropriate, define variables.
%----------------------------------------------------------------------------

% Define spherical switch.

if (~gotVar.spheric),
  Var.name =Vname.spheric;
  Var.type =ncchar;
  Var.dimid=[];
  Var.long ='grid type logical switch';
  Var.opt_T='spherical';
  Var.opt_F='Cartesian';
  [varid,status]=nc_vdef(ncid,Var);
  clear Var
end,

% Define basin length.

if (~gotVar.xl),
  Var.name =Vname.xl;
  Var.type =ncdouble;
  Var.dimid=[];
  Var.long ='basin length in the XI-direction';
  Var.units='meter';
  [varid,status]=nc_vdef(ncid,Var);
  clear Var
end,
if (~gotVar.el),
  Var.name =Vname.el;
  Var.type =ncdouble;
  Var.dimid=[];
  Var.long ='basin length in the ETA-direction';
  Var.units='meter';
  [varid,status]=nc_vdef(ncid,Var);
  clear Var
end,

%  Curvilinear rotation angle on RHO-points.

if (~gotVar.angle),
  Var.name =Vname.angle;
  Var.type =ncdouble;
  Var.dimid=[did.yr did.xr];
  Var.long ='angle between XI-axis and EAST';
  Var.units='radians';
  Var.field=[Vname.angle,', scalar'];
  [varid,status]=nc_vdef(ncid,Var);
  clear Var
end,

%  Curvilinear coordinates metrics at RHO-points.

if (~gotVar.pm),
  Var.name =Vname.pm;
  Var.type =ncdouble;
  Var.dimid=[did.yr did.xr];
  Var.long ='curvilinear coordinate metric in XI';
  Var.units='meter-1';
  Var.field=[Vname.pm,', scalar'];
  [varid,status]=nc_vdef(ncid,Var);
  clear Var
end,
if (~gotVar.pn),
  Var.name =Vname.pn;
  Var.type =ncdouble;
  Var.dimid=[did.yr did.xr];
  Var.long ='curvilinear coordinate metric in ETA';
  Var.units='meter-1';
  Var.field=[Vname.pn,', scalar'];
  [varid,status]=nc_vdef(ncid,Var);
  clear Var
end,

%  Curvilinear coordinates inverse metric derivative.

if (~gotVar.dndx),
  Var.name =Vname.dndx;
  Var.type =ncdouble;
  Var.dimid=[did.yr did.xr];
  Var.long ='XI-derivative of inverse metric factor pn';
  Var.units='meter';
  Var.field=[Vname.dndx,', scalar'];
  [varid,status]=nc_vdef(ncid,Var);
  clear Var
end,
if (~gotVar.dmde),
  Var.name =Vname.dmde;
  Var.type =ncdouble;
  Var.dimid=[did.yr did.xr];
  Var.long ='ETA-derivative of inverse metric factor pm';
  Var.units='meter';
  Var.field=[Vname.dmde,', scalar'];
  [varid,status]=nc_vdef(ncid,Var);
  clear Var
end,

%  Coriolis Parameter at RHO-points.

if (~gotVar.f),
  Var.name =Vname.f;
  Var.type =ncdouble;
  Var.dimid=[did.yr did.xr];
  Var.long ='Coriolis parameter at RHO-points';
  Var.units='second-1';
  Var.field=[Vname.f,', scalar'];
  [varid,status]=nc_vdef(ncid,Var);
  clear Var
end,

%  Raw bathymetry at RHO-points.

if (~gotVar.hraw),
  Var.name =Vname.hraw;
  Var.type =ncdouble;
  Var.dimid=[did.bath did.yr did.xr];
  Var.long ='Working bathymetry at RHO-points';
  Var.units='meter';
  Var.field=[Vname.hraw,', scalar'];
  [varid,status]=nc_vdef(ncid,Var);
  clear Var
end,

%  Model bathymetry at RHO-points.

if (~gotVar.h),
  Var.name =Vname.h;
  Var.type =ncdouble;
  Var.dimid=[did.yr did.xr];
  Var.long ='model bathymetry at RHO-points';
  Var.units='meter';
  Var.field=[Vname.h,', scalar'];
  [varid,status]=nc_vdef(ncid,Var);
  clear Var
end,

%  Cartesian locations of RHO-points.

if (~gotVar.rx),
  Var.name =Vname.rx;
  Var.type =ncdouble;
  Var.dimid=[did.yr did.xr];
  Var.long ='X-location of RHO-points';
  Var.units='meter';
  Var.field=[Vname.rx,', scalar'];
  [varid,status]=nc_vdef(ncid,Var);
  clear Var
end,
if (~gotVar.ry),
  Var.name =Vname.ry;
  Var.type =ncdouble;
  Var.dimid=[did.yr did.xr];
  Var.long ='Y-location of RHO-points';
  Var.units='meter';
  Var.field=[Vname.ry,', scalar'];
  [varid,status]=nc_vdef(ncid,Var);
  clear Var
end,

%  Cartesian locations of PSI-points.

if (~gotVar.px),
  Var.name =Vname.px;
  Var.type =ncdouble;
  Var.dimid=[did.yp did.xp];
  Var.long ='X-location of PSI-points';
  Var.units='meter';
  Var.field=[Vname.px,', scalar'];
  [varid,status]=nc_vdef(ncid,Var);
  clear Var
end,
if (~gotVar.py),
  Var.name =Vname.py;
  Var.type =ncdouble;
  Var.dimid=[did.yp did.xp];
  Var.long ='Y-location of PSI-points';
  Var.units='meter';
  Var.field=[Vname.py,', scalar'];
  [varid,status]=nc_vdef(ncid,Var);
  clear Var
end,

%  Cartesian locations of U-points.

if (~gotVar.ux),
  Var.name =Vname.ux;
  Var.type =ncdouble;
  Var.dimid=[did.yu did.xu];
  Var.long ='X-location of U-points';
  Var.units='meter';
  Var.field=[Vname.ux,', scalar'];
  [varid,status]=nc_vdef(ncid,Var);
  clear Var
end,
if (~gotVar.uy),
  Var.name =Vname.uy;
  Var.type =ncdouble;
  Var.dimid=[did.yu did.xu];
  Var.long ='Y-location of U-points';
  Var.units='meter';
  Var.field=[Vname.uy,', scalar'];
  [varid,status]=nc_vdef(ncid,Var);
  clear Var
end,

%  Cartesian locations of V-points.

if (~gotVar.vx),
  Var.name =Vname.vx;
  Var.type =ncdouble;
  Var.dimid=[did.yv did.xv];
  Var.long ='X-location of V-points';
  Var.units='meter';
  Var.field=[Vname.vx,', scalar'];
  [varid,status]=nc_vdef(ncid,Var);
  clear Var
end,
if (~gotVar.vy),
  Var.name =Vname.vy;
  Var.type =ncdouble;
  Var.dimid=[did.yv did.xv];
  Var.long ='Y-location of V-points';
  Var.units='meter';
  Var.field=[Vname.vy,', scalar'];
  [varid,status]=nc_vdef(ncid,Var);
  clear Var
end,

%  Longitude/latitude of RHO-points.

if (~gotVar.rlon),
  Var.name =Vname.rlon;
  Var.type =ncdouble;
  Var.dimid=[did.yr did.xr];
  Var.long ='longitude of RHO-points';
  Var.units='degree_east';
  Var.field=[Vname.rlon,', scalar'];
  [varid,status]=nc_vdef(ncid,Var);
  clear Var
end,
if (~gotVar.rlat),
  Var.name =Vname.rlat;
  Var.type =ncdouble;
  Var.dimid=[did.yr did.xr];
  Var.long ='latitute of RHO-points';
  Var.units='degree_north';
  Var.field=[Vname.rlat,', scalar'];
  [varid,status]=nc_vdef(ncid,Var);
  clear Var
end,

%  Longitude/latitude of PSI-points.

if (~gotVar.plon),
  Var.name =Vname.plon;
  Var.type =ncdouble;
  Var.dimid=[did.yp did.xp];
  Var.long ='longitude of PSI-points';
  Var.units='degree_east';
  Var.field=[Vname.plon,', scalar'];
  [varid,status]=nc_vdef(ncid,Var);
  clear Var
end,
if (~gotVar.plat),
  Var.name =Vname.plat;
  Var.type =ncdouble;
  Var.dimid=[did.yp did.xp];
  Var.long ='latitute of PSI-points';
  Var.units='degree_north';
  Var.field=[Vname.plat,', scalar'];
  [varid,status]=nc_vdef(ncid,Var);
  clear Var
end,

%  Longitude/latitude of U-points.

if (~gotVar.ulon),
  Var.name =Vname.ulon;
  Var.type =ncdouble;
  Var.dimid=[did.yu did.xu];
  Var.long ='longitude of U-points';
  Var.units='degree_east';
  Var.field=[Vname.ulon,', scalar'];
  [varid,status]=nc_vdef(ncid,Var);
  clear Var
end,
if (~gotVar.ulat),
  Var.name =Vname.ulat;
  Var.type =ncdouble;
  Var.dimid=[did.yu did.xu];
  Var.long ='latitute of U-points';
  Var.units='degree_north';
  Var.field=[Vname.ulat,', scalar'];
  [varid,status]=nc_vdef(ncid,Var);
  clear Var
end,

%  Longitude/latitude of V-points.

if (~gotVar.vlon),
  Var.name =Vname.vlon;
  Var.type =ncdouble;
  Var.dimid=[did.yv did.xv];
  Var.long ='longitude of V-points';
  Var.units='degree_east';
  Var.field=[Vname.vlon,', scalar'];
  [varid,status]=nc_vdef(ncid,Var);
  clear Var
end,
if (~gotVar.vlat),
  Var.name =Vname.vlat;
  Var.type =ncdouble;
  Var.dimid=[did.yv did.xv];
  Var.long ='latitute of V-points';
  Var.units='degree_north';
  Var.field=[Vname.vlat,', scalar'];
  [varid,status]=nc_vdef(ncid,Var);
  clear Var
end,

%  Land/sea mask on RHO-points.

if (~gotVar.rmask),
  Var.name =Vname.rmask;
  Var.type =ncdouble;
  Var.dimid=[did.yr did.xr];
  Var.long ='mask on RHO-points';
  Var.opt_0='land';
  Var.opt_1='water';
  Var.fill=1;
  Var.units='nondimensional';
  Var.field=[Vname.rmask,', scalar'];
  [varid,status]=nc_vdef(ncid,Var);
  clear Var
end,

%  Land/sea mask on PSI-points.

if (~gotVar.pmask),
  Var.name =Vname.pmask;
  Var.type =ncdouble;
  Var.dimid=[did.yp did.xp];
  Var.long ='mask on PSI-points';
  Var.opt_0='land';
  Var.opt_1='water';
  Var.fill=1;
  Var.units='nondimensional';
  Var.field=[Vname.pmask,', scalar'];
  [varid,status]=nc_vdef(ncid,Var);
  clear Var
end,

%  Land/sea mask on U-points.

if (~gotVar.umask),
  Var.name =Vname.umask;
  Var.type =ncdouble;
  Var.dimid=[did.yu did.xu];
  Var.long ='mask on U-points';
  Var.opt_0='land';
  Var.opt_1='water';
  Var.fill=1;
  Var.units='nondimensional';
  Var.field=[Vname.umask,', scalar'];
  [varid,status]=nc_vdef(ncid,Var);
  clear Var
end,

%  Land/sea mask on V-points.

if (~gotVar.vmask),
  Var.name =Vname.vmask;
  Var.type =ncdouble;
  Var.dimid=[did.yv did.xv];
  Var.long ='mask on V-points';
  Var.opt_0='land';
  Var.opt_1='water';
  Var.fill=1;
  Var.units='nondimensional';
  Var.field=[Vname.vmask,', scalar'];
  [varid,status]=nc_vdef(ncid,Var);
  clear Var
end,


%----------------------------------------------------------------------------
%  Leave definition mode and close NetCDF file.
%----------------------------------------------------------------------------

[status]=mexcdf('ncendef',ncid);
if (status == -1),
  error(['C_GRID: ncendef - unable to leave definition mode.']);
  return
end,

[status]=mexcdf('ncclose',ncid);
if (status == -1),
  error(['C_GRID: ncclose - unable to close GRID NetCDF file: ', Gname]);
  return
end,

return

