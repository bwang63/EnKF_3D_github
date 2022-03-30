function [e,jd]=tselev(cdf);
% TSELEV reads elevation time series from TSEPIC.CDF style files
%
% USAGE:  [e,jd]=tselev(cdf);

[t]=mcvgt(cdf,'time');
nt=length(t);
%
[stations]=mcvgt(cdf,'stations');
nsta=length(stations);
corner=[0 0 0 0];
edges=[nt, 1, 1, nsta];
e=mcvgt(cdf,'elev',corner,edges);
%
base_date=zeros(1,6);
base_date(1:3)=mcagt(cdf,'global','base_date');
jd0=julian(base_date);
jd=jd0+t/(3600*24);
