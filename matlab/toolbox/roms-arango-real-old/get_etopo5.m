function [topo,lon,lat] = get_etopo5 (file,lonmin,lonmax,latmin,latmax);
%
%-------------------------------------------------------------------------------
%|                                                                             |
%| function [topo,lon,lat] = get_etopo5 (file,lonmin,lonmax,latmin,latmax);    |
%|                                                                             |
%| This function reads in topography and positions from a netCDF ETOPO5 file.  |
%|                                                                             |
%| Input:                                                                      |
%|                                                                             |
%|    file.....Name of ETOPO5 netCDF file.                                     |
%|    lonmin...Minimum longitude to extract.                                   |
%|    lonmax...Maximum longitude to extract.                                   |
%|    latmin...Minimum latitude to extract.                                    |
%|    latmax...Maximum latitude to extract.                                    |
%|                                                                             |
%| Output:                                                                     |
%|                                                                             |
%|    topo.....Extracted topography.  (matrix)                                 |
%|    lon......Extracted longitudes.  (vector)                                 |
%|    lat......Extracted latitudes.  (vector)                                  |
%-------------------------------------------------------------------------------

%-------------------------------------------------------------------------------
% Convert lat/lon's into indices.
%-------------------------------------------------------------------------------

x = rem (latmin, 90);
jmin = round((x+90)*12);

x = rem (latmax, 90);
jmax = round((x+90)*12);

x = rem (lonmin, 360);
if (x<0), x=x+360; end;
imin = round(x*12);

x = rem (lonmax, 360);
if (x<0), x=x+360; end;
imax = round(x*12);

di = imax - imin + 1;
dj = jmax - jmin + 1;

%-------------------------------------------------------------------------------
% Initialize netCDF parameters.
%-------------------------------------------------------------------------------

status = mexcdf ('setopts',0);
nc_nowrite = mexcdf ('parameter','nc_nowrite');

%-------------------------------------------------------------------------------
% Open netCDF file.
%-------------------------------------------------------------------------------

ncid = mexcdf ('ncopen',file,nc_nowrite);
if (ncid < 0),
   disp([setstr(7),'***Error:  GET_ETOPO5 - unable to open file:',setstr(7)]);
   disp([setstr(7),'           ',setstr(34),file,setstr(34),setstr(7)]);
   return
end;

%-------------------------------------------------------------------------------
% Read topography, longitude and latitude.
%-------------------------------------------------------------------------------

varid = mexcdf ('ncvarid',ncid,'topo');
if (varid < 0),
   disp([setstr(7),'***Error:  GET_ETOPO5 - unable to find variable ', ...
                      setstr(34),'topo',setstr(34),' in file:',setstr(7)]);
   disp([setstr(7),'           ',setstr(34),file,setstr(34),setstr(7)]);
   return
end;
[topo, status] = mexcdf ('ncvarget',ncid,varid,[jmin imin],[dj di]);
if (varid < 0),
   disp([setstr(7),'***Error:  GET_ETOPO5 - unable to read variable ', ...
                      setstr(34),'topo',setstr(34),' in file:',setstr(7)]);
   disp([setstr(7),'           ',setstr(34),file,setstr(34),setstr(7)]);
   return
end;
topo = topo';

varid = mexcdf ('ncvarid',ncid,'topo_lon');
if (varid < 0),
   disp([setstr(7),'***Error:  GET_ETOPO5 - unable to find variable ', ...
                      setstr(34),'topo_lon',setstr(34),' in file:',setstr(7)]);
   disp([setstr(7),'           ',setstr(34),file,setstr(34),setstr(7)]);
   return
end;
[lon, status] = mexcdf ('ncvarget',ncid,varid,imin,di);
if (varid < 0),
   disp([setstr(7),'***Error:  GET_ETOPO5 - unable to read variable ', ...
                      setstr(34),'topo_lon',setstr(34),' in file:',setstr(7)]);
   disp([setstr(7),'           ',setstr(34),file,setstr(34),setstr(7)]);
   return
end;

varid = mexcdf ('ncvarid',ncid,'topo_lat');
if (varid < 0),
   disp([setstr(7),'***Error:  GET_ETOPO5 - unable to find variable ', ...
                      setstr(34),'topo_lat',setstr(34),' in file:',setstr(7)]);
   disp([setstr(7),'           ',setstr(34),file,setstr(34),setstr(7)]);
   return
end;
[lat, status] = mexcdf ('ncvarget',ncid,varid,jmin,dj);
if (varid < 0),
   disp([setstr(7),'***Error:  GET_ETOPO5 - unable to read variable ', ...
                      setstr(34),'topo_lat',setstr(34),' in file:',setstr(7)]);
   disp([setstr(7),'           ',setstr(34),file,setstr(34),setstr(7)]);
   return
end;

%-------------------------------------------------------------------------------
% Close netCDF file.
%-------------------------------------------------------------------------------

status = mexcdf ('ncclose',ncid);
if (status < 0),
   disp([setstr(7),'***Error:  GET_ETOPO5 - unable to close file:',setstr(7)]);
   disp([setstr(7),'           ',setstr(34),file,setstr(34),setstr(7)]);
   return
end;
