function rnt_plotcoast(grd)
% function rnt_plotcoast(grd)
% plot coast of grd file
%  RNT - edl@ucsd.edu

load(grd.cstfile);
plot(lon,lat,'k');
