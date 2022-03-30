function [t,s]=rlev96(fname);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                      %
% function [t,s]=rlev96(fname);                                        %
%                                                                      %
%  Reads NCAR's file containing Levitus quater-degree climatology.     %
%                                                                      %
%  On Input:                                                           %
%                                                                      %
%     fname      input file name (string).                             %
%                                                                      %
%  On Output:                                                          %
%                                                                      %
%     t          temperature data.                                     %
%     s          salinity data.                                        %
%                                                                      %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%  Read HDAT file.

[header,hinfo,htype,z,temp,salt]=rhydro(fname);

%  Get Longitude and latitude.

lon=hinfo(:,4);
lat=hinfo(:,5);
nsta=max(size(lon));

%  Get number of vertical points for each station.

kpts=hinfo(:,2);

%  Initialize output arrays.

%t(1:360,1:180,1:33)=nan;

%  Load temperature and salinity data.

for n=1:nsta,
  i=fix(0.25*(lon(n)+360));
  j=fix(0.25*(lat(n)+90));
  k=fix(kpts(n));
  t(i,j,1:k)=temp(n,1:k);
  s(i,j,1:k)=salt(n,1:k);
end,

return
      
