function [f,x,y]=freshthick(cdf,tind,s0);
% function [f,x,y]=freshthick(cdf,tind,s0);
% finds the depth-integrated freshwater thickness
% relative to a reference salinity s0

[s,x,y]=depave(cdf,'salt',tind);
[d,x,y]=kslice(cdf,'depth');
fmean=(s0-s)/s0;
f=fmean.*d;
