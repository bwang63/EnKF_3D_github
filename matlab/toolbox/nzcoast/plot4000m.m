%
function a = plot4000m(str)
if ~exist('str'),str='--';,end
load c:\smcmatla\nzcoast\bathymet\b_04000.mat
plot(lon_4000,lat_4000,str)