%
function a = plot200m(str)
if ~exist('str'),str='--';,end
load c:\smcmatlab\nzcoast\bathymet\b_0200.mat
plot(lon_200,lat_200,str)