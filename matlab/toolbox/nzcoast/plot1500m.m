%
function a = plot1500m(str)
if ~exist('str'),str='--';,end
load c:\smcmatlab\nzcoast\bathymet\b_01500.mat
plot(lon_1500,lat_1500,str)