%
function a = plot2000m(str)
if ~exist('str'),str='--';,end
load c:\smcmatlab\nzcoast\bathymet\b_02000.mat
plot(lon_2000,lat_2000,str)