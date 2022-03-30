%  This matlab script can be used to create the GRID NetCDF file used by
%  SCRUM and ROMS.  This is driver script sets-up all the GRID variables.
%  USERS can use this as a prototype for their application.  This script
%  uses "c_grid" to define variables and "w_grid" to write variables.
%
%  NOTICE that all variables are loaded to structure array "Grid" for
%  easy processing: (fields marked with an * can be computed internally
%                    in "w_grid", if appropriate).
%
%    Grid.name     =>  NetCDF file name (string).
%    Grid.spheric  =>  Spherical grid swith (T/F).
%    Grid.xl       =>  Basin length in XI (m).
%    Grid.el       =>  Basin length in ETA (m).
%    Grid.angle    =>  Curvilinear rotation angle (radians).
%    Grid.pm       =>  Curvilinear coordinate metric in XI (1/m).
%    Grid.pn       =>  Curvilinear coordinate metric in ETA (1/m).
%    Grid.dndx     =>  XI-derivative of inverse metric factor "pn" (m).
%    Grid.dmde     =>  ETA-derivative of inverse metric factor "pm" (m).
%  * Grid.f        =>  Coriolis parameter at RHO-points (1/s).
%    Grid.hraw     =>  Working bathymetry at RHO-points (m).
%    Grid.h        =>  Model bathymetry at RHO-points (m; positive).
%    Grid.rx       =>  X-location of RHO-points (m).
%    Grid.ry       =>  Y-location of RHO-points (m).
%  * Grid.px       =>  X-location of PSI-points (m).
%  * Grid.py       =>  Y-location of PSI-points (m).
%  * Grid.ux       =>  X-location of U-points (m).
%  * Grid.uy       =>  Y-location of U-points (m).
%  * Grid.vx       =>  X-location of V-points (m).
%  * Grid.vy       =>  Y-location of V-points (m).
%    Grid.rlon     =>  Longitude of RHO-points (degree_east).
%    Grid.rlat     =>  Latitude  of RHO-points (degree_north).
%  * Grid.plon     =>  Longitude of PSI-points (degree_east).
%  * Grid.plat     =>  Latitude  of PSI-points (degree_north).
%  * Grid.ulon     =>  Longitude of U-points (degree_east).
%  * Grid.ulat     =>  Latitude  of U-points (degree_north).
%  * Grid.vlon     =>  Longitude of V-points (degree_east).
%  * Grid.vlat     =>  Latitude  of V-points (degree_north).
%    Grid.rmask    =>  Land/sea mask on RHO-points (0/1).
%  * Grid.pmask    =>  Land/sea mask on PSI-points (0/1).
%  * Grid.umask    =>  Land/sea mask on U-points (0/1).
%  * Grid.vmask    =>  Land/sea mask on U-points (0/1).

%----------------------------------------------------------------------------
%  Star User's Application section.  This is just a prototype.
%----------------------------------------------------------------------------

%  Set GRID filename.

Gname='grid.nc';
Grid.name=Gname;

%  Set GRID parameters.

Grid.spheric='T';    % Spherical grid switch (T/F).
Lp=120;              % Number of points in the XI-direction.
Mp=120;              % Number of points in the ETA-direction.
dx=1000;             % Grid spacing (m) in the XI-direction.
dy=1000;             % Grid spacing (m) in the ETA-direction.
rot_angle=-35;       % Rotation angle (degrees).
deg2rad=pi/180;      % Degrees to radians.

%  Read in or set-up bathymetry.  For example:
%
%  h=load('my_bath.dat'); [Lp,Mp]=size(h);

h=zeros([Lp Mp]);
Grid.hraw=h;
Grid.h=h;

%  Set grid metrics and Cartesian coordinates at RHO-points.

rot_angle=rot_angle*deg2rad;

Grid.angle=ones(size(h)).*rot_angle;
Grid.pm   =ones(size(h))./dx;
Grid.pn   =ones(size(h))./dy;
Grid.pndx =zeros(size(h));
Grid.pmde =zeros(size(h));

x=[0:dx:(Lp-1)*dx]; x=x'; Grid.rx=x(:,ones([1 Mp])); clear x
y=[0:dy:(Mp-1)*dy]; Grid.ry=y(ones([1 Lp]),:); clear y

Grid.xl=max(max(x));
Grid.el=max(max(y));

%  Read in or set-up Longitude and Latitude.  For example:
%
%  lon=load('my_lon.dat');
%  lat=load('my_lat.dat');

lon=-ones(size(h)).*78;
lat=ones(size(h)).*38;

Grid.rlon=lon;
Grid.rlat=lat;

%  Compute Coriolis parameter (1/s).

omega=2*pi*366.25/(24*3600*365.25);
Grid.f=2.*omega.*sin(deg2rad.*Grid.rlat);

%----------------------------------------------------------------------------
%  Create a new file or append new variables to existing GRID NetCDF file.
%----------------------------------------------------------------------------

[Lp,Mp]=size(Grid.h);
[status]=c_grid(Lp,Mp,Gname);

%----------------------------------------------------------------------------
%  Write GRID variables.
%----------------------------------------------------------------------------

[Grid,status]=w_grid(Grid);
