%
function a = plot250m(str)
if ~exist('str'),str='-';,end
load c:\smcmatla\nzcoast\bathymet\b_00000.mat
plot(lon_0,lat_0,str)