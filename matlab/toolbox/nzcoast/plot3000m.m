%
function a = plot3000m(str)
if ~exist('str'),str='--';,end
load c:\smcmatlab\nzcoast\bathymet\b_03000.mat
plot(lon_3000,lat_3000,str)