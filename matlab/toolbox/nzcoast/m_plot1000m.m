%
function a = plot1000m(str)
if ~exist('str'),str='--';,end
load c:\smcmatlab\nzcoast\bathymet\b_01000.mat
m_plot(lon_1000,lat_1000,str)