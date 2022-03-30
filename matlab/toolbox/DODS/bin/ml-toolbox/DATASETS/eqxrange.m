function [aW,aE,dW,dE,latminindx,latmaxindx]= ...
           eqxrange(minlon,maxlon,minlat,maxlat,CanOrbFile)
%
% eqxrange 
% finds the range of the longitude of the ascending nodes that cross the
% latitude-longitude box, using the canonical orbit.
%             and
% finds the indices of the minimum and maximum latitude row numbers
% that cross the latitude range, for the ascending and descending
%    orbits:
%
%   e.g.:      latminindx: [250  1072]  latmaxindx: [260 1082],
%
%  NOTE:  ON THE DESCENDING ORBIT:
%           the minimum index latminindx corresponds to the maximum latitude
%           the maximum index latmaxindx corresponds to the minimum latitude!
%
% means that wvc_rows from  250-260  cross the latitude range on ascent, and
%            wvc_rows from 1072-1082 cross the range on descent.
%
% usage:
%         [aW,aE,dW,dE,latminindx,latmaxindx]= ...
%                      eqxrange(lonmin,lonmax,latmin,latmax)
%
% where lonmin,lonmax,latmin,latmax refer to the lat,lon limits, and
%       aW,aE,dW,dE correspond to the West and Eastern limits of
%                   the longitude of the ascending node
%                   for ascending (a) and descending (d) passes in
%                   a given orbit.
% notes on the Canonical Orbit:
%      LON_L,LAT_L refer to the left-most-crosstrack position, as viewed
%                                in the direction of satellite motion.
%      LON_NADIR,LAT_NADIR refer to the center track position.
%
%      LON_R,LAT-R refer to the right-most-crosstrack position, as viewed
%                                in the direction of satellite motion.
%
%      CO_eqX1 is the East Longitude of the equator crossing of the 
%           Canonical Orbit, going NORTH.
%
%      CO_eqX2 is the East Longitude of the equator crossing of the
%           Canonical Orbit, going SOUTH. (Note that the earth rotates
%           while the satellite is moving.)
%        
%      LD_AD is the difference.  For a pro-grade orbit,the difference
%           will be <180 degrees.  For a retro-grade orbit, the difference
%           will be >180 degrees.
%
% begun 1 march 2000 by paul hemenway

% see my notes of 29 feb 2000 for derivations.
%

lonmin=minlon; lonmax=maxlon;
latmax=maxlat;latmin=minlat;
latminindx=zeros(1:2);
latmaxindx=zeros(1:2);

global LON_L LAT_L LON_R LAT_R LD_AD CO_eqX1 CO_eqX2

if (lonmax<lonmin)
   fprintf('lonmax is less than lonmin\n')
   fprintf ('I will assume you want to go across the Greenwich Meridian.\n')
end

if (latmax<latmin)
   fprintf('latmax is less than latmin\n')
   fprintf('I will assume you want them reversed.\n')
   templat=latmax;
   latmax=latmin;
   latmin=templat;
   clear templat
end

%load the canonical orbit

if ~exist('LON_L')|~exist('LAT_L')|~exist('LAT_NADIR')|~exist('LON_NADIR')| ...
   ~exist('LON_R')|~exist('LAT_R')|~exist('LD_AD')|~exist('CO_eqX1')| ...
   ~exist('CO_eqX2')
     eval(CanOrbFile) 
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   DO THE ASCENDING ORBIT
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

ascendend=floor(numswathrows/2);
descendstart=ascendend + 1;
descendend=numswathrows;

ascnd=[1:ascendend];

% SOUTHERN-WESTERN CORNER (remember that the satellite is retrograde:

% What is the index of the scan of the southern swath edge at the lower
%          latitude limit?
[SL,idx] = sort(abs(LAT_R(ascnd) - latmin));

latminindx(1)=idx(1);

% the INDEX of the corner is idx(1)

dellon=CO_eqX1 - LON_R(idx(1));

LAN_MIN=lonmin+dellon;

aW=LAN_MIN;

% % % % % % % % % % % % % % % % % % % % % % % % %

% NORTH-EAST CORNER:

% What is the index of the scan of the northern swath edge at the upper
%          latitude limit?
[SL,idx] = sort(abs(LAT_L(ascnd) - latmax));

latmaxindx(1)=idx(1);

% the INDEX of the corner is idx(1)

dellon=CO_eqX1 - LON_L(idx(1));

LAN_MAX=lonmax+dellon;

aE=LAN_MAX;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   DO THE DESCENDING ORBIT
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

descnd = [descendstart:descendend];

% NORTH-WESTERN CORNER (remember that the satellite is retrograde:

% What is the index of the scan of the northern swath edge at the upper
%          latitude limit?
[SL,idx] = sort(abs(LAT_L(descnd) - latmax));

latminindx(2)=idx(1) + ascendend;

corner_index=idx(1) + ascendend;

% the INDEX of the corner is idx(1) + ascendend (we're on the descending path)

dellon=CO_eqX1 - LON_L(corner_index);

LAN_MIN=lonmin+dellon;

dW=LAN_MIN;

% % % % % % % % % % % % % % % % % % % % % % % % % % % % % %

% SOUTH_EAST CORNER

% What is the index of the scan of the southern swath edge at the lower
%          latitude limit?
[SL,idx] = sort(abs(LAT_R(descnd) - latmin));

latmaxindx(2)=idx(1) + ascendend;

corner_index=idx(1) + ascendend;

% the INDEX of the corner is idx(1) + ascendend

dellon=CO_eqX1 - LON_R(corner_index);

LAN_MAX=lonmax+dellon;

dE=LAN_MAX;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% if either range is greater than 360 degrees, set the range
%  to 360 degrees
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if (aE-aW)>360|(dE-dW)>360
   aE = 359.999999;
   aW = 0;
   dE = 359.999999;
   dW = 0;
end

while aW<0
  aW=aW+360;
  aE=aE+360;
end
while dW<0
  dW=dW+360;
  aW=aW+360;
end




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  initial version written by Paul Hemenway
%  Copyright 2000 by the University of Rhode Island
%  see the acompanying detailed copyright notice
%  >>help dodsqscopyright
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

