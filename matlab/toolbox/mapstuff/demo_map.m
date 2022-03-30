% DEMO_MAP  Demonstrates map stuff: JOIN_CST, FILLSEG and MAPAX.
%
%    Usage:  demo_map
%
% Rich Signell (rsignell@usgs.gov)


%load Nantucket lon,lat coastline data extracted from World Vector Shoreline
load map.dat

% 
% form continuous coastline using JOIN_CST, and joining segments closer
% than 0.0001 degrees.

new=join_cst(map,.0001);

% draw original coast without nans
ind=find(~isnan(map(:,1)));
subplot(211);
plot(map(ind,1),map(ind,2));

% crude map projection: set aspect ratio to cos(lat_middle) ~ 0.74
%
set(gca,'asp',[nan .74]);
title('Turn this disjointed coastline with lousy labels....');

% fill in land using FILLSEG.  Draw cyan land with nearly black coast.

subplot(212);
fillseg(new,[0 1 1],[0 0 .1]);

set(gca,'asp',[nan .74]);

% nice lon labels every 5 minutes and lat every 3 minutes with no decimal places
% for minutes

mapax(5,0,3,0);

title('...into this filled coastline with nice lat/lon labels');
