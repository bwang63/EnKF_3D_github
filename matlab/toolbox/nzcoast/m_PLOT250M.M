%
function a = plot250m(str)
if ~exist('str'),str='--';,end
load c:\smcmatlab\nzcoast\bathymet\b_00250.mat
m_plot(lon_250,lat_250,str)