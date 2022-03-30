function allmean(cdf1,cdf2,tind,tout);
%function allmean(cdf1,cdf2,tind,tout);
% compute average wind, salinity, temperature, velocity,
% time and elevation over 
%
% tind = time steps to average over in file cdf1
% tout = time step to write mean  in file cdf2
cmean(cdf1,cdf2,'salt',tind,tout);
cmean(cdf1,cdf2,'temp',tind,tout);
vmean(cdf1,cdf2,tind,tout);
emean(cdf1,cdf2,tind,tout);
taumean(cdf1,cdf2,tind,tout);
tmean(cdf1,cdf2,tind,tout);

