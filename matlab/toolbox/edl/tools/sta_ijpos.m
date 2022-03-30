function [Sgrid]=sta_ijpos(gname,slon,slat);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright (c) 2001 Rutgers University.                                    %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                           %
% function [Sgrid]=sta_ijpos(gname,slon,slat)                               %
%                                                                           %
% This function computes the (I,J) model grid locations from the station    %
% (lon,lat) positions.                                                      %
%                                                                           %
% On Input:                                                                 %
%                                                                           %
%    gname       NetCDF grid file name (character string).                  %
%    slon        Station's longitude.                                       %
%    slat        Station's latitude.                                        %
%                                                                           %
% On Ouput:                                                                 %
%                                                                           %
%    Sgrid       Station's (I,J) grid positions (structure array):          %
%                  Sgrid.I     =>  I-grid positions.                        %
%                  Sgrid.J     =>  J-grid positions.                        %
%                  Sgrid.Inear =>  Nearest fix(I) grid positions.           %
%                  Sgrid.Jnear =>  Nearest fix(J) grid positions.           %
%                  Sgrid.lon   =>  Nearest longitude.                       %
%                  Sgrid.lat   =>  Nearest latitude.                        %
%                  Sgrid.dist  =>  Distance from nearest point (km);        %
%                                                                           %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%----------------------------------------------------------------------------
% Read in grid longitude and latitude
%----------------------------------------------------------------------------

rlon=nc_read(gname,'lon_rho');
rlat=nc_read(gname,'lat_rho');
[Im,Jm]=size(rlon);

%----------------------------------------------------------------------------
% Compute (I,J) positions via interpolation.
%----------------------------------------------------------------------------

Igrid=repmat([1:1:Im]',[1 Jm]);
Jgrid=repmat([1:1:Jm] ,[Im 1]); 

Sgrid.I=griddata(rlon,rlat,Igrid,slon,slat);
Sgrid.J=griddata(rlon,rlat,Jgrid,slon,slat);

%----------------------------------------------------------------------------
% Find closest (I,J) point by computing geographical distance.
%----------------------------------------------------------------------------

Nsta=length(slon);

for n=1:Nsta,

  i(1)=fix(Sgrid.I(n));     j(1)=fix(Sgrid.J(n));
  i(2)=fix(Sgrid.I(n))+1;   j(2)=fix(Sgrid.J(n));
  i(3)=fix(Sgrid.I(n))+1;   j(3)=fix(Sgrid.J(n))+1;
  i(4)=fix(Sgrid.I(n));     j(4)=fix(Sgrid.J(n))+1;

  lon(1)=rlon(i(1),j(1));
  lon(2)=rlon(i(2),j(2));
  lon(3)=rlon(i(3),j(3));
  lon(4)=rlon(i(4),j(4));

  lat(1)=rlat(i(1),j(1));
  lat(2)=rlat(i(2),j(2));
  lat(3)=rlat(i(3),j(3));
  lat(4)=rlat(i(4),j(4));

  [d,b]=gcircle(slon(n),slat(n),lon,lat,0);
  [Sgrid.dist(n),kmin]=min(d);

  Sgrid.Inear(n)=i(kmin);
  Sgrid.Jnear(n)=j(kmin);

  Sgrid.lon(n)=lon(kmin);
  Sgrid.lat(n)=lat(kmin);

end,

return


