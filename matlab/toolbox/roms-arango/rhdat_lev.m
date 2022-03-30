function [F]=rhdat_lev(Hname);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright (c) 2001 Rutgers University.                               %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                      %
%  function [F]=rhdat_lev(Hname)                                       %
%                                                                      %
%  Reads an HDAT file containing Levitus Climatology.  The data        %
%  is loaded on global array to facilitate plotting.                   %
%                                                                      %
%  On Input:                                                           %
%                                                                      %
%     Hname      Input HDAT file name (string).                        %
%                                                                      %
%  On Output:                                                          %
%                                                                      %
%     F          Grided hydrography data (structure array):            %
%                  F.lon   => Longitude.                               %
%                  F.lat   => Latitude.                                %
%                  F.z     => Depth.                                   %
%                  F.temp  => Temperature.                             %
%                  F.salt  => Salinity.                                %
%                                                                      %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%  Read HDAT file.

[header,hinfo,htype,hdata]=rhydro(Hname);

%  Get Longitude and latitude.

lon=hinfo(:,4);
lat=hinfo(:,5);
nsta=max(size(lon));

%  Get number of vertical points for each station.

kpts=hinfo(:,2);

%-----------------------------------------------------------------------
%  Set-up grided arrays.
%-----------------------------------------------------------------------

%  Get grid spacing.

dx=min(find(abs(gradient(sort(lon)))) > 0);
dy=min(find(gradient(sort(lat))) > 0);
dx=0.25;
dy=0.25;

LonMin=min(lon); LonMax=max(lon);
LatMin=min(lat); LatMax=max(lat);

Im=1+(LonMax-LonMin)/dx;
Jm=1+(LatMax-LatMin)/dy;
Km=max(kpts);

% Initialize output arrays.

F.z=zeros([Im,Jm,Km])+NaN;
F.temp=zeros([Im,Jm,Km])+NaN;
F.salt=zeros([Im,Jm,Km])+NaN;

%  Load temperature and salinity data.

x=[LonMin:dx:LonMax];
y=[LatMin:dy:LatMax];

F.lon=repmat(x',[1 Jm]);
F.lat=repmat(y ,[Im 1]);

for n=1:nsta,
  i=1+fix((lon(n)-LonMin)/dx);
  j=1+fix((lat(n)-LatMin)/dy);
  k=fix(kpts(n));
  F.z(i,j,1:k)=squeeze(hdata(1,1:k,n));
  F.temp(i,j,1:k)=squeeze(hdata(2,1:k,n));
  F.salt(i,j,1:k)=squeeze(hdata(3,1:k,n));
end,

return
