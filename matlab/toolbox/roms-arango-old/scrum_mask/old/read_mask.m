function [spherical,x,y,bath,rmask]=read_mask(gname);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright (c) 1996 Rutgers University.                                    %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                           %
% function [spherical,x,y,bath,rmask]=read_mask(gname)                      %
%                                                                           %
% This routine reads in domain grid, bathymetry, and Land/Sea mask at       %
% from GRID NetCDF file.                                                    %
%                                                                           %
% On Input:                                                                 %
%                                                                           %
%    gname       GRID NetCDF file name (character string).                  %
%                                                                           %
% On Output:                                                                %
%                                                                           %
%    spherical   grid type switch (character):                              %
%                spherical=T, spherical grid set-up.                        %
%                spherical=F, Cartesian grid set-up.                        %
%    x           X-location of RHO-points (real matrix; meters or degrees). %
%    y           Y-location of RHO-points (real matrix; meters or degrees). %
%    bath        raw bathymetry at RHO-points (real matrix; meters).        %
%    rmask       Land/Sea mask on RHO-points (real matrix):                 %
%                rmask=0 land, rmask=1 Sea.                                 %
%                                                                           %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Open GRIDS NetCDF file.

[ncid]=mexcdf('ncopen',gname,'nc_nowrite');
if (ncid == -1),
  error(['READ_MASK: ncopen - unable to open file: ' gname])
  return
end

% Supress all error messages from NetCDF.

[status]=mexcdf('setopts',0);

%----------------------------------------------------------------------------
%  Read in number RHO-points.
%----------------------------------------------------------------------------

[dimid]=mexcdf('ncdimid',ncid,'xi_rho');
if (dimid > 0),
  [dimnam,Lp,status]=mexcdf('ncdiminq',ncid,dimid);
  if (status == -1),
    error(['READ_MASK: ncdiminq - error while reading dimension: xi_rho.'])
  end
end

[dimid]=mexcdf('ncdimid',ncid,'eta_rho');
if (dimid > 0),
  [dimnam,Mp,status]=mexcdf('ncdiminq',ncid,dimid);
  if (status == -1),
    error(['READ_MASK: ncdiminq - error while reading dimension: eta_rho.'])
  end
end

%----------------------------------------------------------------------------
%  Read in grid type switch: Spherical or Cartesian.
%----------------------------------------------------------------------------

[varid]=mexcdf('ncvarid',ncid,'spherical');
if (varid > 0),
  [spherical,status]=mexcdf('ncvarget1',ncid,varid,[0]);
  if (status == -1),
    error(['READ_MASK: ncvarget1 - error while reading: spherical.'])
  end
else
 error(['READ_MASK: ncvarid - cannot find variable: meandx.'])
end

%----------------------------------------------------------------------------
% Read in Spherical or Cartesian grid locations at RHO-points.
%----------------------------------------------------------------------------

if (spherical == 'T' | spherical == 't'),
  xname='lon_rho';
  yname='lat_rho';
else
  xname='x_rho';
  yname='y_rho';
end

x=nc_read(gname,xname); x=x';
y=nc_read(gname,yname); y=y';

%----------------------------------------------------------------------------
% Read in raw bathymetry (meters) at RHO-points.
%----------------------------------------------------------------------------

bath=nc_read(gname,'hraw',1); bath=bath';

%----------------------------------------------------------------------------
% Read in Land/Sea mask on RHO-points, if any.
%----------------------------------------------------------------------------

[varid]=mexcdf('ncvarid',ncid,'mask_rho');
if (varid > 0),
  rmask=nc_read(gname,'mask_rho');
else
  rmask=ones(size(bath'));
end
rmask=rmask';

%----------------------------------------------------------------------------
% Close GRID NetCDF file.
%----------------------------------------------------------------------------

[status]=mexcdf('ncclose',ncid);
if (status == -1),
  error(['READ_MASK: ncclose - unable to close NetCDF file.'])
end

return
