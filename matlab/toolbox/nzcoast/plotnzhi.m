%
function a = plot250m(str)
if ~exist('str'),str='-';,end
addpath bathymet
load B_00000.MAT
plot(lon_0,lat_0,str)
