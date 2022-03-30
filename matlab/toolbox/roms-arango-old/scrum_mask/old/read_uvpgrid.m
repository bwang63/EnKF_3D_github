function [xugrd,yugrd,xvgrd,yvgrd,xpgrd,ypgrd]=read_uvpgrid(gname);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright (c) 1996 Rutgers University.                                    %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                           %
% function [xugrd,yugrd,xvgrd,yvgrd,xpgrd,ypgrd]=read_uvpgrid(gname)        %
%                                                                           %
% This routine reads in domain grid at U-, V-, and PSI-points from GRID     %
% NetCDF file.                                                              %
%                                                                           %
% On Input:                                                                 %
%                                                                           %
%    gname       GRID NetCDF file name (character string).                  %
%                                                                           %
% On Output:                                                                %
%                                                                           %
%    xugrd       X-location of U-points (real matrix; meters or degrees).   %
%    xvgrd       X-location of V-points (real matrix; meters or degrees).   %
%    xpgrd       X-location of PSI-points (real matrix; meters or degrees). %
%    yugrd       Y-location of U-points (real matrix; meters or degrees).   %
%    yvgrd       Y-location of V-points (real matrix; meters or degrees).   %
%    ypgrd       Y-location of PSI-points (real matrix; meters or degrees). %
%                                                                           %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%----------------------------------------------------------------------------
%  Read in number RHO-points.
%----------------------------------------------------------------------------

[Dnames,Dsizes]=nc_dim(gname);
ndims=length(Dsizes);
for n=1:ndims,
  name=deblank(Dnames(n,:));
  switch name
    case 'xi_rho'
      Lp=Dsizes(n);
    case 'eta_rho'
      Mp=Dsizes(n);
  end,
end,

L=Lp-1;
M=Mp-1;

%----------------------------------------------------------------------------
%  Read in grid type switch: Spherical or Cartesian.
%----------------------------------------------------------------------------

spherical=nc_read(gname,'spherical');

%----------------------------------------------------------------------------
% Read in Spherical or Cartesian grid locations at U-points.
%----------------------------------------------------------------------------

if (spherical == 'T' | spherical == 't'),
  xname='lon_u';
  yname='lat_u';
else
  xname='x_u';
  yname='y_u';
end

xugrd=nc_read(gname,xname); xugrd=xugrd';
yugrd=nc_read(gname,yname); yugrd=yugrd';

%----------------------------------------------------------------------------
% Read in Spherical or Cartesian grid locations at V-points.
%----------------------------------------------------------------------------

if (spherical == 'T' | spherical == 't'),
  xname='lon_v';
  yname='lat_v';
else
  xname='x_v';
  yname='y_v';
end

xvgrd=nc_read(gname,xname); xvgrd=xvgrd';
yvgrd=nc_read(gname,yname); yvgrd=yvgrd';

%----------------------------------------------------------------------------
% Read in Spherical or Cartesian grid locations at PSI-points.
%----------------------------------------------------------------------------

if (spherical == 'T' | spherical == 't'),
  xname='lon_psi';
  yname='lat_psi';
else
  xname='x_psi';
  yname='y_psi';
end

xpgrd=nc_read(gname,xname); xpgrd=xpgrd';
ypgrd=nc_read(gname,yname); ypgrd=ypgrd';

return
