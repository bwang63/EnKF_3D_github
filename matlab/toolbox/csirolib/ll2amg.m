% Converts a vecotr of latitudes and longitudes to
% a vector of AMG x/y coordinates.
%
% INPUT:  lats  	    - Vector of latitude (degrees).
%         lons 	    - Vector of longitude (degrees).
%         amgzone    - AMG zone (1-60).
%
% OUTPUT: x	    - Vector of AMG X coordinates (metres).
%         y         - Vector of AMG Y coordinates (metres).
%
% Note: The latitudes/longitudes are on the AGD66 spheroid.
%
% Author:  Jason R. Waring
%          CSIRO Division of Marine Research
% Created: 20th February 1998
%
% USAGE: [x,y] = ll2amg(lats, lons, amgzone);
%
% $Id: ll2amg.m,v 1.2 1998/03/16 04:19:57 mansbrid Exp $

function [x,y] = amg2ll(lats,lons,amgzone)
% compute the constants.
cm = (amgzone*6 - 183) * pi/180.0;
k0 = 0.9996;
radius = 6378160.0;
flat=1/298.25;
feastings = 500000.0;
fnorthings = 10000000.0;
e2 = (2.0 * flat) - (flat * flat);
edash2 = e2/(1.0 - e2);
e4 = e2*e2;
e6 = e2*e2*e2;

% Convert lats/lons to radian equivalents.
lat = lats * pi / 180.0;
lon = lons * pi / 180.0;

% Compute the meridinal distance from the equator.
ms = (1.0 - e2/4.0 - (3.0/64.0)*e4 -(5.0/256.0)*e6) * lat;
ms = ms - ((3.0/8.0)*e2 + (3.0/32.0)*e4 + (45.0/1024.0)*e6) * sin(2.0*lat);
ms = ms + ((15.0/256.0)*e4 + (45.0/1024.0)*e6) * sin(4.0*lat);
ms = ms - (35.0/3072.0) * e6 * sin(6.0*lat);
M = radius * ms;
M0 = 0.0;	% merid dist at lat 0.

% Compute the X/Y coordinates using a Transverse Mercator projection.
coslat = cos(lat);
sinlat = sin(lat);
sinlat2 =sinlat.*sinlat;
coslat2 = coslat.*coslat;
tanlat = sinlat./coslat;
N = radius ./ sqrt(1 - e2 * sinlat .* sinlat);
T = tanlat .* tanlat;
T2 = T.*T;
C = edash2 .* coslat2;
C2 = C .* C;
A = (lon - cm).*coslat;
A2 = A.*A;
A3 = A2.*A;
A4 = A3.*A;
A5 = A4.*A;
A6 = A5.*A;

x = A + (1.0 - T + C) .* A3/6.0 + (5.0 - 18.0*T + T2 + 72.0 * C - 58.0 * edash2) .* A5/120.0;
x = x .* N * k0;
y = M - M0 + N .* tanlat .* (A2/2.0 + (5.0 - T + 9.0*C +4.0*C2) .* A4/24.0 + (61.0 - 58.0*T + T2 + 600.0*C - 330*edash2) .* A6/720.0);
y = y * k0;

% reduce to false origins.
x = x + feastings;
y = y + fnorthings;
