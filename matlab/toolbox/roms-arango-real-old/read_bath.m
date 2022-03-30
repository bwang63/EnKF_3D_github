function [spherical,x,y,bath]=read_bath(gname);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright (c) 1996 Rutgers University.                                    %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                           %
% function [spherical,x,y,bath]=read_bath(gname)                            %
%                                                                           %
% This routine reads in domain grid and bathymetry from GRID NetCDF file.   %
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
%    bath        bathymetry at RHO-points (real matrix; meters).            %
%                                                                           %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Open GRIDS NetCDF file.

[ncid]=mexcdf('ncopen',gname,'nc_nowrite');
if (ncid == -1),
  error(['READ_BATH: ncopen - unable to open file: ' gname])
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
    error(['READ_BATH: ncdiminq - error while reading dimension: xi_rho.'])
  end
end

[dimid]=mexcdf('ncdimid',ncid,'eta_rho');
if (dimid > 0),
  [dimnam,Mp,status]=mexcdf('ncdiminq',ncid,dimid);
  if (status == -1),
    error(['READ_BATH: ncdiminq - error while reading dimension: eta_rho.'])
  end
end

%----------------------------------------------------------------------------
%  Read in grid type switch: Spherical or Cartesian.
%----------------------------------------------------------------------------

[varid]=mexcdf('ncvarid',ncid,'spherical');
if (varid > 0),
  [spherical,status]=mexcdf('ncvarget1',ncid,varid,[0]);
  if (status == -1),
    error(['READ_BATH: ncvarget1 - error while reading: spherical.'])
  end
else
 error(['READ_BATH: ncvarid - cannot find variable: meandx.'])
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

[varid]=mexcdf('ncvarid',ncid,xname);
if (varid > 0),
  [x,status]=mexcdf('ncvarget',ncid,varid,[0 0],[Mp Lp]);
  if (status == -1),
    error(['READ_BATH: ncvarget - error while reading: ',xname])
  end
  x=x';
else
  error(['READ_BATH: ncvarid - cannot find variable: ',xname])
end

[varid]=mexcdf('ncvarid',ncid,yname);
if (varid > 0),
  [y,status]=mexcdf('ncvarget',ncid,varid,[0 0],[Mp Lp]);
  if (status == -1),
    error(['READ_BATH: ncvarget - error while reading: ',yname])
  end
  y=y';
else
  error(['READ_BATH: ncvarid - cannot find variable: ',yname])
end

%----------------------------------------------------------------------------
% Read in bathymetry (meters) at RHO-points.
%----------------------------------------------------------------------------

[varid]=mexcdf('ncvarid',ncid,'h');
if (varid > 0),
  [bath,status]=mexcdf('ncvarget',ncid,varid,[0 0],[Mp Lp]);
  if (status == -1),
    error(['READ_BATH: ncvarget - error while reading: h.'])
  end
  bath=bath';
else
 error(['READ_BATH: ncvarid - cannot find variable: h.'])
end

%----------------------------------------------------------------------------
% Close GRID NetCDF file.
%----------------------------------------------------------------------------

[status]=mexcdf('ncclose',ncid);
if (status == -1),
  error(['READ_BATH: ncclose - unable to close NetCDF file.'])
end

return
