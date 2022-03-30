function [got,Vname,status]=c_ncdx(Xname,Hname,Gname,Istr,Iend,Jstr,Jend);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright (c) 1999 Rutgers University.                                    %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                           %
% [got,Vname,status]=c_ncdx(Xname,Hname,Gname,Istr,Iend,Jstr,Jend).         %
%                                                                           %
% This function creates IBM DX NetCDF file.                                 %
%                                                                           %
% On Input:                                                                 %
%                                                                           %
%    Xname       DX NetCDF file name to create (string).                    %
%    Hname       History NetCDF file name (string).                         %
%    Gname       GRID NetCDF file name (string).                            %
%    Istr        Starting I-index to process.                               %
%    Iend        Ending I-index to process                                  %
%    Jstr        Starting J-index to process.                               %
%    Jend        Ending J-index to process                                  %
%                                                                           %
% On Output:                                                                %
%                                                                           %
%    got         Switches indicating defined variables.                     %
%    Vname       Names of defined variables.                                %
%    status      Error flag.                                                %
%                                                                           %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global IPRINT

IPRINT=0;

%-----------------------------------------------------------------------
%  Get some NetCDF parameters.
%-----------------------------------------------------------------------

[ncglobal]=mexcdf('parameter','nc_global');
[ncdouble]=mexcdf('parameter','nc_double');
[ncunlim]=mexcdf('parameter','nc_unlimited');
[ncfloat]=mexcdf('parameter','nc_float');
[ncchar]=mexcdf('parameter','nc_char');

% Set floating-point variables type.

vartyp=ncfloat;

%-----------------------------------------------------------------------
%  Inquire dimensions.
%-----------------------------------------------------------------------

[Dnames,Dsizes]=nc_dim(Hname);

ndims=length(Dsizes);
for n=1:ndims,
  name=deblank(Dnames(n,:));
  switch name
    case 'xi_rho'
      Dsize.xr=Dsizes(n);
      Dname.xr='xi_rho';
    case 'eta_rho'
      Dsize.er=Dsizes(n);
      Dname.er='eta_rho';
    case 's_rho'
      Dsize.sr=Dsizes(n);
      Dname.sr='s_rho';
    case 's_w'
      Dsize.sw=Dsizes(n);
      Dname.sw='s_w';
    case 'tracer'
      Dsize.trc=Dsizes(n);
      Dname.trc='tracer';
  end,
end,
Dname.a2='axis2';
Dname.a3='axis3';

% Set dimension for visulaization file.

if (nargin > 3),
 Nr=Dsize.sr;
 Nw=Dsize.sw;
 Lr=Iend-Istr+1;
 Mr=Jend-Jstr+1;
 Isr=Istr+1;
 Ier=Iend+1;
 Jsr=Jstr+1;
 Jer=Jend+1;
else,
 Nr=Dsize.sr;
 Nw=Dsize.sw;
 Lr=Dsize.xr-1;
 Mr=Dsize.er-1;
 Isr=1;
 Ier=Lr;
 Jsr=1;
 Jer=Mr;
end, 

%-----------------------------------------------------------------------
%  Inquire variables.
%-----------------------------------------------------------------------

got.mask=0;
got.angle=0;
got.zeta=0;
got.ubar=0;
got.vbar=0;
got.u=0;
got.v=0;
got.w=0;
got.omega=0;
got.temp=0;
got.salt=0;
got.rho=0;
got.Hsbl=0;
got.AKv=0;
got.AKt=0;
got.AKs=0;

[varnam,nvars]=nc_vname(Hname);

for n=1:nvars,
  name=deblank(varnam(n,:));
  switch name
    case 'mask_rho'
      got.mask=1;
      Vname.mask=name;
    case 'angle'
      got.angle=1;
      Vname.angle=name;
    case 'zeta'
      got.zeta=1;
      Vname.zeta=name;
    case 'ubar'
      got.ubar=1;
      Vname.ubar=name;
    case 'vbar'
      got.vbar=1;
      Vname.vbar=name;
    case 'u'
      got.u=1;
      Vname.u=name;
    case 'v'
      got.v=1;
      Vname.v=name;
    case 'w'
      got.w=1;
      Vname.w=name;
    case 'omega'
      got.omega=1;
      Vname.omega=name;
    case 'temp'
      got.temp=1;
      Vname.temp=name;
    case 'salt'
      got.salt=1;
      Vname.salt=name;
    case 'rho'
      got.rho=1;
      Vname.rho=name;
    case 'hbl'
      got.Hsbl=1;
      Vname.Hsbl=name;
    case 'AKv'
      got.AKv=1;
      Vname.AKv=name;
    case 'AKt'
      got.AKt=1;
      Vname.AKt=name;
    case 'AKs'
      got.AKs=1;
      Vname.AKs=name;
  end,
end,

got.v2d=got.ubar & got.vbar;
got.v3d=got.u & got.v & got.w;

Vname.rg2='r_grid2';
Vname.rg3='r_grid3';
Vname.wg3='w_grid3';
Vname.bath='h';
Vname.rlon='lon_rho';
Vname.rlat='lat_rho';
Vname.time='ocean_time';
Vname.v2d='ubar';
Vname.v3d='u';

%-----------------------------------------------------------------------
%  Create DX Visualization NetCDF file.
%-----------------------------------------------------------------------

[ncid,status]=mexcdf('nccreate',Xname,'nc_write');
if (ncid == -1),
  error(['NC_DXPOS: ncopen - unable to create file: ', Xname]);
  return
end,

%-----------------------------------------------------------------------
%  Define output file dimensions.
%-----------------------------------------------------------------------

[did.xr]=mexcdf('ncdimdef',ncid,Dname.xr,Lr);
if (did.xr == -1),
  error(['D_NCDX: ncdimdef - unable to define dimension: ',Dname.xr]);
end,

[did.er]=mexcdf('ncdimdef',ncid,Dname.er,Mr);
if (did.er == -1),
  error(['D_NCDX: ncdimdef - unable to define dimension: ',Dname.er]);
end,

[did.sr]=mexcdf('ncdimdef',ncid,Dname.sr,Nr);
if (did.sr == -1),
  error(['D_NCDX: ncdimdef - unable to define dimension: ',Dname.sr]);
end,

[did.sw]=mexcdf('ncdimdef',ncid,Dname.sw,Nw);
if (did.sw == -1),
  error(['D_NCDX: ncdimdef - unable to define dimension: ',Dname.sw]);
end,

[did.a2]=mexcdf('ncdimdef',ncid,Dname.a2,2);
if (did.a2 == -1),
  error(['D_NCDX: ncdimdef - unable to define dimension: ',Dname.a2]);
end,

[did.a3]=mexcdf('ncdimdef',ncid,Dname.a3,3);
if (did.a2 == -1),
  error(['D_NCDX: ncdimdef - unable to define dimension: ',Dname.a3]);
end,

[did.time]=mexcdf('ncdimdef',ncid,'time',ncunlim);
if (did.a2 == -1),
  error(['D_NCDX: ncdimdef - unable to define dimension: time']);
end,

%----------------------------------------------------------------------------
%  Create global attribute(s).
%----------------------------------------------------------------------------

type='DX Visualization file';

lstr=max(size(type));
[status]=mexcdf('ncattput',ncid,ncglobal,'type',ncchar,lstr,type);
if (status == -1),
  error(['D_NCDX: ncattput - unable to global attribure: history.']);
  return
end

history=['Visualization file ', date_stamp];

lstr=max(size(history));
[status]=mexcdf('ncattput',ncid,ncglobal,'history',ncchar,lstr,history);
if (status == -1),
  error(['D_NCDX: ncattput - unable to global attribure: history.']);
  return
end

%----------------------------------------------------------------------------
%  Define positions variables.
%----------------------------------------------------------------------------

% Define spherical switch.

Var.name ='spherical';
Var.type =ncchar;
Var.dimid=[];
Var.long ='grid type logical switch';
Var.opt_T='spherical';
Var.opt_F='Cartesian';

[varid,status]=nc_vdef(ncid,Var);
clear Var

% Define S-coordinate parameters.

Var.name ='hc';
Var.long ='S-coordinate parameter, critical depth';
Var.dimid=[];
Var.type =ncdouble;
Var.units='meter';

[varid,status]=nc_vdef(ncid,Var);
clear Var

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

% Define 2D positions at RHO-points.

Var.name =Vname.rg2;
Var.type =ncdouble;
Var.dimid=[did.er did.xr did.a2];
Var.long ='2D grid positions at RHO-points';
Var.units='meter';
Var.field='r_grid2, vector';
Var.pos  =Vname.rg2;

[varid,status]=nc_vdef(ncid,Var);
clear Var

% Define 3D positions at RHO-points.

Var.name =Vname.rg3;
Var.type =ncdouble;
Var.dimid=[did.sr did.er did.xr did.a3];
Var.long ='3D grid positions at RHO-points';
Var.units='meter';
Var.field='r_grid3, vector';
Var.pos  =Vname.rg3;

[varid,status]=nc_vdef(ncid,Var);
clear Var

% Define 3D positions at W-points.

Var.name =Vname.wg3;
Var.type =ncdouble;
Var.dimid=[did.sw did.er did.xr did.a3];
Var.long ='3D grid positions at W-points';
Var.units='meter';
Var.field='w_grid3, vector';
Var.pos  =Vname.rg3;

[varid,status]=nc_vdef(ncid,Var);
clear Var

% Define bathymetry.

Var.name =Vname.bath;
Var.type =vartyp;
Var.dimid=[did.er did.xr];
Var.long ='bathymetry at RHO-points';
Var.units='meter';
Var.field='bath, scalar';
Var.pos  =Vname.rg2;

[varid,status]=nc_vdef(ncid,Var);
clear Var

% Define Longitude grid.

Var.name =Vname.rlon;
Var.type =vartyp;
Var.dimid=[did.er did.xr];
Var.long ='longitude of RHO-points';
Var.units='degree_east';
Var.field='lon_rho, scalar';
Var.pos  =Vname.rg2;

[varid,status]=nc_vdef(ncid,Var);
clear Var

% Define Latitude grid.

Var.name =Vname.rlat;
Var.type =vartyp;
Var.dimid=[did.er did.xr];
Var.long ='latitude of RHO-points';
Var.units='degree_north';
Var.field='lat_rho, scalar';
Var.pos  =Vname.rg2;

[varid,status]=nc_vdef(ncid,Var);
clear Var

% Define Land/Sea Masking.

if (got.mask),
  Var.name =Vname.mask;
  Var.type =vartyp;
  Var.dimid=[did.er did.xr];
  Var.long ='mask on RHO-points';
  Var.opt_0='land';
  Var.opt_1='water';
  Var.field='mask, scalar';
  Var.pos  =Vname.rg2;

  [varid,status]=nc_vdef(ncid,Var);
  clear Var
end,

% Define rotation angle.

if (got.angle),
  Var.name =Vname.angle;
  Var.type =vartyp;
  Var.dimid=[did.er did.xr];
  Var.long ='angle between XI-axis and EAST';
  Var.units='radians';
  Var.field='angle, scalar';
  Var.pos  =Vname.rg2;

  [varid,status]=nc_vdef(ncid,Var);
  clear Var
end,

%----------------------------------------------------------------------------
%  Define variables.
%----------------------------------------------------------------------------

%  Define time.

Var.name =Vname.time;
Var.type =ncdouble;
Var.dimid=[did.time];
Var.long ='time since initialization';
Var.units='second';
Var.field='time, scalar, series';

[varid,status]=nc_vdef(ncid,Var);
clear Var

%  Define free-surface.

if (got.zeta),
  Var.name =Vname.zeta;
  Var.type =vartyp;
  Var.dimid=[did.time did.er did.xr];
  Var.long ='free-surface';
  Var.units='meter';
  Var.field='free-surface, scalar, series';
  Var.pos  =Vname.rg2;

  [varid,status]=nc_vdef(ncid,Var);
  clear Var
end,

%  Define 2D momentum.

if (got.v2d),
  Var.name =Vname.v2d;
  Var.type =vartyp;
  Var.dimid=[did.time did.er did.xr did.a2];
  Var.long ='vertically integrated momentum';
  Var.units='meter second-1';
  Var.field='ubar-velocity, vector, series';
  Var.pos  =Vname.rg2;

  [varid,status]=nc_vdef(ncid,Var);
  clear Var
end,

%  Define 3D momentum.

if (got.v3d),
  Var.name =Vname.v3d;
  Var.type =vartyp;
  Var.dimid=[did.time did.sr did.er did.xr did.a3];
  Var.long ='3D-momentum';
  Var.units='meter second-1';
  Var.field='u-velocity, vector, series';
  Var.pos  =Vname.rg3;

  [varid,status]=nc_vdef(ncid,Var);
  clear Var
end,

%  Define temperature.

if (got.temp),
  Var.name =Vname.temp;
  Var.type =vartyp;
  Var.dimid=[did.time did.sr did.er did.xr];
  Var.long ='potential temperature';
  Var.units='Celsius';
  Var.field='temperature, scalar, series';
  Var.pos  =Vname.rg3;

  [varid,status]=nc_vdef(ncid,Var);
  clear Var
end,

%  Define salinity.

if (got.salt),
  Var.name =Vname.salt;
  Var.type =vartyp;
  Var.dimid=[did.time did.sr did.er did.xr];
  Var.long ='salinity';
  Var.units='PSU';
  Var.field='salinity, scalar, series';
  Var.pos  =Vname.rg3;

  [varid,status]=nc_vdef(ncid,Var);
  clear Var
end,

%  Define density anomaly.

if (got.rho),
  Var.name =Vname.rho;
  Var.type =vartyp;
  Var.dimid=[did.time did.sr did.er did.xr];
  Var.long ='density anomaly';
  Var.units='kilogram meter-3';
  Var.field='density, scalar, series';
  Var.pos  =Vname.rg3;

  [varid,status]=nc_vdef(ncid,Var);
  clear Var
end,

%  Define vertical viscosity.

if (got.AKv),
  Var.name =Vname.AKv;
  Var.type =vartyp;
  Var.dimid=[did.time did.sw did.er did.xr];
  Var.long ='vertical viscosity coefficient';
  Var.units='meter2 second-1';
  Var.field='AKv, scalar, series';
  Var.pos  =Vname.wg3;

  [varid,status]=nc_vdef(ncid,Var);
  clear Var
end,

%  Define vertical diffusion of temperature.

if (got.AKt),
  Var.name =Vname.AKt;
  Var.type =vartyp;
  Var.dimid=[did.time did.sw did.er did.xr];
  Var.long ='temperature vertical diffusion coefficient';
  Var.units='meter2 second-1';
  Var.field='AKt, scalar, series';
  Var.pos  =Vname.wg3;

  [varid,status]=nc_vdef(ncid,Var);
  clear Var
end,

%  Define vertical diffusion of salinity.

if (got.AKs),
  Var.name =Vname.AKs;
  Var.type =vartyp;
  Var.dimid=[did.time did.sw did.er did.xr];
  Var.long ='salinity vertical diffusion coefficient';
  Var.units='meter2 second-1';
  Var.field='AKs, scalar, series';
  Var.pos  =Vname.wg3;

  [varid,status]=nc_vdef(ncid,Var);
  clear Var
end,

%  Define surface boundary layer.

if (got.Hsbl),
  Var.name =Vname.Hsbl;
  Var.type =vartyp;
  Var.dimid=[did.time did.er did.xr];
  Var.long ='depth of surface boundary layer';
  Var.units='meter';
  Var.field='Hsbl, scalar, series';
  Var.pos  =Vname.rg2;

  [varid,status]=nc_vdef(ncid,Var);
  clear Var
end,

%----------------------------------------------------------------------------
%  Leave definition mode.
%----------------------------------------------------------------------------

[status]=mexcdf('ncendef',ncid);
if (status == -1),
  error(['D_NCDX: ncendef - unable to leave definition mode.'])
end

%----------------------------------------------------------------------------
%  Close NetCDF file.
%----------------------------------------------------------------------------

[status]=mexcdf('ncclose',ncid);
if (status == -1),
  error(['D_NCDX: ncclose - unable to close NetCDF file: ', Xname])
end

%----------------------------------------------------------------------------
%  Write grid information data.
%----------------------------------------------------------------------------

% Write out spherical switch.

[status]=nc_write(Xname,'spherical','T');

% Write out 2D positions at RHO-points.

Finp=nc_read(Gname,'x_rho');
X2d=Finp(Isr:Ier,Jsr:Jer);
Finp=nc_read(Gname,'y_rho');
Y2d=Finp(Isr:Ier,Jsr:Jer);

grid2(1,:,:)=X2d;
grid2(2,:,:)=Y2d;

[status]=nc_write(Xname,Vname.rg2,grid2);
clear grid2

% Write out S-coordinate parameters.

hc=nc_read(Hname,'hc');
[status]=nc_write(Xname,'hc',hc);

Finp=nc_read(Hname,'sc_r');
[status]=nc_write(Xname,'sc_r',Finp);

Finp=nc_read(Hname,'Cs_r');
[status]=nc_write(Xname,'Cs_r',Finp);

Finp=nc_read(Hname,'sc_w');
[status]=nc_write(Xname,'sc_w',Finp);

Finp=nc_read(Hname,'Cs_w');
[status]=nc_write(Xname,'Cs_w',Finp);

% Write out 3D positions at RHO-points.

X3d=repmat(X2d,[1 1 Nr]);
Y3d=repmat(Y2d,[1 1 Nr]);
Finp=depths(Hname,Gname,1,0,0);
Fout=Finp(Isr:Ier,Jsr:Jer,:);

grid3(1,:,:,:)=X3d;
grid3(2,:,:,:)=Y3d;
grid3(3,:,:,:)=Fout;

[status]=nc_write(Xname,Vname.rg3,grid3);
clear grid3 X3d Y3d

% Write 3D positions at W-points.

X3d=repmat(X2d,[1 1 Nw]);
Y3d=repmat(Y2d,[1 1 Nw]);
Finp=depths(Hname,Gname,5,0,0);
if (Nw == Nr),
  Fout=Finp(Isr:Ier,Jsr:Jer,2:Nr+1);
else,
  Fout=Finp(Isr:Ier,Jsr:Jer,:);
end,

grid3(1,:,:,:)=X3d;
grid3(2,:,:,:)=Y3d;
grid3(3,:,:,:)=Fout;

[status]=nc_write(Xname,Vname.wg3,grid3);
clear grid3 X3d Y3d

% Write out bathymetry.

Finp=nc_read(Gname,Vname.bath);
Fout=Finp(Isr:Ier,Jsr:Jer);
[status]=nc_write(Xname,Vname.bath,Fout);

% Write out longitude grid.

Finp=nc_read(Gname,Vname.rlon);
Fout=Finp(Isr:Ier,Jsr:Jer);
[status]=nc_write(Xname,Vname.rlon,Fout);

% Write out latitude grid.

Finp=nc_read(Gname,Vname.rlat);
Fout=Finp(Isr:Ier,Jsr:Jer);
[status]=nc_write(Xname,Vname.rlat,Fout);

% Write out Land/Sea mask.

if (got.mask),
  Finp=nc_read(Gname,Vname.mask);
  Fout=Finp(Isr:Ier,Jsr:Jer);
  [status]=nc_write(Xname,Vname.mask,Fout);
end,

% Write out curvilinear angle.

if (got.angle),
  Finp=nc_read(Gname,Vname.angle);
  Fout=Finp(Isr:Ier,Jsr:Jer);
  [status]=nc_write(Xname,Vname.angle,Fout);
end,

return
