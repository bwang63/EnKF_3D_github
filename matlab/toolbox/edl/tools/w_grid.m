function [Grid,status]=w_grid(Grid);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright (c) 2000 Rutgers University.                                    %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Hernan G. Arango %%%
%                                                                           %
% function [Grid,status]=w_grid(Grid);                                      %
%                                                                           %
% This function writes variables to GRID NetCDF file.  It secondary         %
% variables are not found in structure array, they are computed from        %
% primary variables.                                                        %
%                                                                           %
% On Input:                                                                 %
%                                                                           %
%    Grid        Grid variables (structure array):                          %
%                  Grid.name     =>  NetCDF file name (string).             %
%                  Grid.spheric  =>  Spherical grid swith (T/F).            %
%                  Grid.xl       =>  basin length in XI (m).                %
%                  Grid.el       =>  basin length in ETA (m).               %
%                  Grid.angle    =>  Curvilinear rotation angle (radians).  %
%                  Grid.pm       =>  Curvilinear metric in XI (1/m).        %
%                  Grid.pn       =>  Curvilinear metric in ETA (1/m).       %
%                  Grid.dndx     =>  XI-derivative of "1/pn" (m).           %
%                  Grid.dmde     =>  ETA-derivative of  "1/pm" (m).         %
%                  Grid.f        =>  Coriolis parameter (1/s).              %
%                  Grid.hraw     =>  Working bathymetry (m).                %
%                  Grid.h        =>  Model bathymetry (m; positive).        %
%                  Grid.rx       =>  X-location of RHO-points (m).          %
%                  Grid.ry       =>  Y-location of RHO-points (m).          %
%                  Grid.px       =>  X-location of PSI-points (m).          %
%                  Grid.py       =>  Y-location of PSI-points (m).          %
%                  Grid.ux       =>  X-location of U-points (m).            %
%                  Grid.uy       =>  Y-location of U-points (m).            %
%                  Grid.vx       =>  X-location of V-points (m).            %
%                  Grid.vy       =>  Y-location of V-points (m).            %
%                  Grid.rlon     =>  Longitude of RHO-points (degree_east). %
%                  Grid.rlat     =>  Latitude of RHO-points (degree_north). %
%                  Grid.plon     =>  Longitude of PSI-points (degree_east). %
%                  Grid.plat     =>  Latitude of PSI-points (degree_north). %
%                  Grid.ulon     =>  Longitude of U-points (degree_east).   %
%                  Grid.ulat     =>  Latitude  of U-points (degree_north).  %
%                  Grid.vlon     =>  Longitude of V-points (degree_east).   %
%                  Grid.vlat     =>  Latitude  of V-points (degree_north).  %
%                  Grid.rmask    =>  Land/sea mask on RHO-points (0/1).     %
%                  Grid.pmask    =>  Land/sea mask on PSI-points (0/1).     %
%                  Grid.umask    =>  Land/sea mask on U-points (0/1).       %
%                  Grid.vmask    =>  Land/sea mask on U-points (0/1).       %
%                                                                           %
% On Output:                                                                %
%                                                                           %
%    Grid        Modified grid variables (if appropriate).                  %
%    status      Error flag.                                                %
%                                                                           %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%  Set internal spherical switch.

spherical=0;
if (isfield(Grid,'spheric')),
  if (Grid.spheric == 'T' | Grid.spheric == 't'),
    spherical=1;
  end,
end,
if (isfield(Grid,'name')),
  Gname=Grid.name;
  disp(['Writing grid variables into NetCDF file: ', Gname]);
  disp(' ');
else,
  error(['W_GRID - cannot found field "name" in Grid']);
  return
end,

%----------------------------------------------------------------------------
%  Inquire dimensions from a existing NeTCDF file.
%----------------------------------------------------------------------------

gotDim.xr  =0;  Dname.xr  ='xi_rho';
gotDim.yr  =0;  Dname.yr  ='eta_rho';
gotDim.bath=0;  Dname.bath='bath';

[Dnames,Dsizes]=nc_dim(Gname);
ndims=length(Dsizes);
for n=1:ndims,
  name=deblank(Dnames(n,:));
  switch name
    case {Dname.xr}
      Lp=Dsizes(n);
    case {Dname.yr}
      Mp=Dsizes(n);
    case {Dname.bath}
      nbath=Dsizes(n);
  end,
end,

L=Lp-1;
M=Mp-1;

if (isfield(Grid,'pm')),
  [Im,Jm]=size(Grid.pm);
  if (Im ~= Lp),
    error(['W_GRID - inconsistent dimension: ',Dname.xr,' = ', ...
           num2str(Lp),'  ',num2str(Im)]);
    return
  end,
  if (Jm ~= Mp),
    error(['W_GRID - inconsistent dimension: ',Dname.yr,' = ', ...
           num2str(Mp),'  ',num2str(Jm)]);
    return
  end,
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

[varnam,nvars]=nc_vname(Gname);
for n=1:nvars,
  name=deblank(varnam(n,:));
  switch name
    case {Vname.spheric}
      gotVar.spheric=1;
    case {Vname.xl}
      gotVar.xl=1;
    case {Vname.el}
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

%----------------------------------------------------------------------------
%  If applicable, compute secondary variables and load them into Grid.
%----------------------------------------------------------------------------

% X- and Y- locations.

if (~isfield(Grid,'px') & isfield(Grid,'rx') & gotVar.px),
  Grid.px=0.25.*(Grid.rx(1:L,1:M ) + Grid.rx(2:Lp,1:M ) + ...
                 Grid.rx(1:L,2:Mp) + Grid.rx(2:Lp,2:Mp));
end,
if (~isfield(Grid,'py') & isfield(Grid,'ry') & gotVar.py),
  Grid.py=0.25.*(Grid.ry(1:L,1:M ) + Grid.ry(2:Lp,1:M ) + ...
                 Grid.ry(1:L,2:Mp) + Grid.ry(2:Lp,2:Mp));
end,

if (~isfield(Grid,'ux') & isfield(Grid,'rx') & gotVar.ux),
  Grid.ux=0.5.*(Grid.rx(1:L,1:Mp) + Grid.rx(2:Lp,1:Mp));
end,
if (~isfield(Grid,'uy') & isfield(Grid,'ry') & gotVar.uy),
  Grid.uy=0.5.*(Grid.ry(1:L,1:Mp) + Grid.ry(2:Lp,1:Mp));
end,

if (~isfield(Grid,'vx') & isfield(Grid,'rx') & gotVar.vx),
  Grid.vx=0.5.*(Grid.rx(1:Lp,1:M) + Grid.rx(1:Lp,2:Mp));
end,
if (~isfield(Grid,'vy') & isfield(Grid,'ry') & gotVar.vy),
  Grid.vy=0.5.*(Grid.ry(1:Lp,1:M) + Grid.ry(1:Lp,2:Mp));
end,

% Longitude and latitude.

if (spherical),

  if (~isfield(Grid,'plon') & isfield(Grid,'rlon') & gotVar.plon),
    Grid.plon=0.25.*(Grid.rlon(1:L,1:M ) + Grid.rlon(2:Lp,1:M ) + ...
                     Grid.rlon(1:L,2:Mp) + Grid.rlon(2:Lp,2:Mp));
  end,
  if (~isfield(Grid,'plat') & isfield(Grid,'rlat') & gotVar.plat),
    Grid.plat=0.25.*(Grid.rlat(1:L,1:M ) + Grid.rlat(2:Lp,1:M ) + ...
                     Grid.rlat(1:L,2:Mp) + Grid.rlat(2:Lp,2:Mp));
  end,

  if (~isfield(Grid,'ulon') & isfield(Grid,'rlon') & gotVar.ulon),
    Grid.ulon=0.5.*(Grid.rlon(1:L,1:Mp) + Grid.rlon(2:Lp,1:Mp));
  end,
  if (~isfield(Grid,'ulat') & isfield(Grid,'rlat') & gotVar.ulat),
    Grid.ulat=0.5.*(Grid.rlat(1:L,1:Mp) + Grid.rlat(2:Lp,1:Mp));
  end,

  if (~isfield(Grid,'vlon') & isfield(Grid,'rlon') & gotVar.vlon),
    Grid.vlon=0.5.*(Grid.rlon(1:Lp,1:M) + Grid.rlon(1:Lp,2:Mp));
  end,
  if (~isfield(Grid,'vlat') & isfield(Grid,'rlat') & gotVar.vlat),
    Grid.vlat=0.5.*(Grid.rlat(1:Lp,1:M) + Grid.rlat(1:Lp,2:Mp));
  end,

end,

% Coriolis parameter.

if (spherical),
  if (~isfield(Grid,'f') & isfield(Grid,'rlat') & gotVar.f),
    omega=2*pi*366.25/(24*3600*365.25);
    deg2rad=pi/180;
    Grid.f=2.*omega.*sin(deg2rad.*Grid.rlat);
  end,
end,

% Land/Sea masking.

if (isfield(Grid,'rmask')),
  if (~isfield(Grid,'pmask') & gotV.pmask),
    Grid.pmask=Grid.rmask(1:L,1:M ) .* Grid.rmask(2:Lp,1:M ) .* ...
               Grid.rmask(1:L,2:Mp) .* Grid.rmask(2:Lp,2:Mp);
  end,
  if (~isfield(Grid,'umask') & gotV.umask),
    Grid.umask=Grid.rmask(1:L,1:Mp).*Grid.rmask(2:Lp,1:Mp);
  end,
  if (~isfield(Grid,'vmask') & gotV.vmask),
    Grid.umask=Grid.rmask(1:Lp,1:M).*Grid.rmask(1:Lp,2:Mp);
  end,
else,
  Grid.rmask=ones([Lp Mp]);
  Grid.pmask=ones([L  M ]);
  Grid.umask=ones([L  Mp]);
  Grid.vmask=ones([Lp M ]);
end,

%----------------------------------------------------------------------------
%  Write relevant variables.
%----------------------------------------------------------------------------

% Spherical switch.

if (isfield(Grid,'spheric') & gotVar.spheric),
  [status]=nc_write(Gname,Vname.spheric,Grid.spheric);
end,

% Basin lengths.

if (isfield(Grid,'xl') & gotVar.xl),
  [status]=nc_write(Gname,Vname.xl,Grid.xl);
end,
if (isfield(Grid,'el') & gotVar.el),
  [status]=nc_write(Gname,Vname.el,Grid.el);
end,

%  Curvilinear rotation angle on RHO-points.

if (isfield(Grid,'angle') & gotVar.angle),
  [status]=nc_write(Gname,Vname.angle,Grid.angle);
end,

%  Curvilinear coordinates metrics at RHO-points.

if (isfield(Grid,'pm') & gotVar.pm),
  [status]=nc_write(Gname,Vname.pm,Grid.pm);
end,
if (isfield(Grid,'pn') & gotVar.pn),
  [status]=nc_write(Gname,Vname.pn,Grid.pn);
end,

%  Curvilinear coordinates inverse metric derivative.

if (isfield(Grid,'dndx') & gotVar.dndx),
  [status]=nc_write(Gname,Vname.dndx,Grid.dndx);
end,
if (isfield(Grid,'dmde') & gotVar.dmde),
  [status]=nc_write(Gname,Vname.dmde,Grid.dmde);
end,

%  Coriolis Parameter at RHO-points.

if (isfield(Grid,'f') & gotVar.f),
  [status]=nc_write(Gname,Vname.f,Grid.f);
end,

%  Raw bathymetry at RHO-points.

if (isfield(Grid,'hraw') & gotVar.hraw & nbath == 0),
  [status]=nc_write(Gname,Vname.hraw,Grid.hraw,nbath+1);
end,

%  Model bathymetry at RHO-points.

if (isfield(Grid,'h') & gotVar.h),
  [status]=nc_write(Gname,Vname.h,Grid.h);
end,

%  Cartesian locations of RHO-points.

if (isfield(Grid,'rx') & gotVar.rx),
  [status]=nc_write(Gname,Vname.rx,Grid.rx);
end,
if (isfield(Grid,'ry') & gotVar.ry),
  [status]=nc_write(Gname,Vname.ry,Grid.ry);
end,

%  Cartesian locations of PSI-points.

if (isfield(Grid,'px') & gotVar.px),
  [status]=nc_write(Gname,Vname.px,Grid.px);
end,
if (isfield(Grid,'py') & gotVar.py),
  [status]=nc_write(Gname,Vname.py,Grid.py);
end,

%  Cartesian locations of U-points.

if (isfield(Grid,'ux') & gotVar.ux),
  [status]=nc_write(Gname,Vname.ux,Grid.ux);
end,
if (isfield(Grid,'uy') & gotVar.uy),
  [status]=nc_write(Gname,Vname.uy,Grid.uy);
end,

%  Cartesian locations of V-points.

if (isfield(Grid,'vx') & gotVar.vx),
  [status]=nc_write(Gname,Vname.vx,Grid.vx);
end,
if (isfield(Grid,'vy') & gotVar.vy),
  [status]=nc_write(Gname,Vname.vy,Grid.vy);
end,

%  Longitude/latitude of RHO-points.

if (isfield(Grid,'rlon') & gotVar.rlon),
  [status]=nc_write(Gname,Vname.rlon,Grid.rlon);
end,
if (isfield(Grid,'rlat') & gotVar.rlat),
  [status]=nc_write(Gname,Vname.rlat,Grid.rlat);
end,

%  Longitude/latitude of PSI-points.

if (isfield(Grid,'plon') & gotVar.plon),
  [status]=nc_write(Gname,Vname.plon,Grid.plon);
end,
if (isfield(Grid,'plat') & gotVar.plat),
  [status]=nc_write(Gname,Vname.plat,Grid.plat);
end,

%  Longitude/latitude of U-points.

if (isfield(Grid,'ulon') & gotVar.ulon),
  [status]=nc_write(Gname,Vname.ulon,Grid.ulon);
end,
if (isfield(Grid,'ulat') & gotVar.ulat),
  [status]=nc_write(Gname,Vname.ulat,Grid.ulat);
end,

%  Longitude/latitude of V-points.

if (isfield(Grid,'vlon') & gotVar.vlon),
  [status]=nc_write(Gname,Vname.vlon,Grid.vlon);
end,
if (isfield(Grid,'vlat') & gotVar.vlat),
  [status]=nc_write(Gname,Vname.vlat,Grid.vlat);
end,

%  Land/sea mask on RHO-points.

if (isfield(Grid,'rmask') & gotVar.rmask),
  [status]=nc_write(Gname,Vname.rmask,Grid.rmask);
end,

%  Land/sea mask on PSI-points.

if (isfield(Grid,'pmask') & gotVar.pmask),
  [status]=nc_write(Gname,Vname.pmask,Grid.pmask);
end,

%  Land/sea mask on U-points.

if (isfield(Grid,'umask') & gotVar.umask),
  [status]=nc_write(Gname,Vname.umask,Grid.umask);
end,

%  Land/sea mask on V-points.

if (isfield(Grid,'vmask') & gotVar.vmask),
  [status]=nc_write(Gname,Vname.vmask,Grid.vmask);
end,

return
