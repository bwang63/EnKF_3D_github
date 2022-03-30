%
function a = plot2500m(str)
if ~exist('str'),str='--';,end
load c:\smcmatlab\nzcoast\bathymet\b_02500.mat
plot(lon_2500,lat_2500,str)