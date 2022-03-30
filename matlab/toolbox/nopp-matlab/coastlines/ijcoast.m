function [C]=ijcoast(Gname,Cname);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright (c) 2001 Rutgers University.                               %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                      %
% function [C]=ijcoast(Gname,Cname)                                    %
%                                                                      %
% This script converts coastline data to GRID indices for a particular %
% application.  This will used in the Land/Sea masking tools.          %
%                                                                      %
% On Input:                                                            %
%                                                                      %
%    Gname       NetCDF file name (character string).                  %
%    Cname       Coastline file name (character string).               %
%                                                                      %
% On Output:                                                           %
%                                                                      %
%    C           Coastline indices (structure array):                  %
%                  C.grid  => Grid file name.                          %
%                  C.coast => Coastline file name.                     %
%                  C.Llon  => Extracted left-corner longitude.         %
%                  C.Rlon  => Extracted right-corner longitude.        %
%                  C.Blat  => Extracted bottom-corner latitude.        %
%                  C.Tlat  => Extracted top-corner latitude.           %
%                  C.lon   => Coastline longitudes.                    %
%                  C.lat   => Coastline latitudes.                     %
%                  C.Icst  => Coastline I-grid coordinates.            %
%                  C.Jcst  => Coastline J-grid coordinates.            %
%                                                                      %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

EXTRACT=0;
method='linear';

C.grid=Gname;
C.coast=Cname;

%-----------------------------------------------------------------------
% Read in grid coordinates at rho-points.
%-----------------------------------------------------------------------

rlon=nc_read(Gname,'lon_rho');
rlat=nc_read(Gname,'lat_rho');

[Im,Jm]=size(rlon);

%-----------------------------------------------------------------------
% Read in coastline data.
%-----------------------------------------------------------------------

%[Clon,Clat]=rcoastline(Cname);
load(Cname);
Clon=lon;
Clat=lat;

%-----------------------------------------------------------------------
% Extract need coasline data.
%-----------------------------------------------------------------------

if (EXTRACT),

  dx=5*abs(mean(mean(gradient(rlon))));
  dy=5*abs(mean(mean(gradient(rlat))));

  C.Llon=min(min(rlon));  C.Llon=C.Llon-dx;
  C.Rlon=max(max(rlon));  C.Rlon=C.Rlon+dx;
  C.Blat=min(min(rlat));  C.Blat=C.Blat-dy;
  C.Tlat=max(max(rlat));  C.Tlat=C.Tlat+dy;

  ind=find(Clon > C.Rlon | Clon < C.Llon | Clat > C.Tlat | Clat < C.Blat);
  clon=Clon;
  clat=Clat;
  if (~isempty(ind)),
    clon(ind)=[];
    clat(ind)=[];
  end,

  C.lon=[NaN; clon; NaN];
  C.lat=[NaN; clat; NaN];

else,

  clon=Clon;
  clat=Clat;

  C.lon=clon;
  C.lat=clat;

end,

clear Clon Clat clon clat

%-----------------------------------------------------------------------
% Interpolate coastline to grid units.
%-----------------------------------------------------------------------

[y,x]=meshgrid(1:Jm,1:Im);

C.Icst=griddata(rlon,rlat,x,C.lon,C.lat,method);
C.Jcst=griddata(rlon,rlat,y,C.lon,C.lat,method);

%-----------------------------------------------------------------------
%  Save sctructure array into a "mat" file
%-----------------------------------------------------------------------

save coast_mask C

return
