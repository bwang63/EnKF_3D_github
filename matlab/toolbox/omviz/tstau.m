function [w,jd]=tstau(cdf);
% TSTAU Reads time series of wind from TSEPIC style files
%  this version assumes wind is a 1D variable (uniform wind over domain)
%
% USAGE: [w,jd]=tstau(cdf);
%
% Author: Rich Signell (rsignell@usgs.gov)
%

[t]=mcvgt(cdf,'time');
nt=length(t);
%
ncid=mexcdf('open',cdf);
[name,datatype,ndims,dim,natts, status] = mexcdf('VARINQ',ncid, 'taux');
mexcdf('close',ncid);
ndims=1;
if(ndims==1),
 u=mcvgt(cdf,'taux');
 v=mcvgt(cdf,'tauy');
 w=u+i*v;
 w=w.';
else 
 [stations]=mcvgt(cdf,'stations');
 nsta=length(stations);
 corner=[0 0 0 0];
 edges=[nt 1 1 nsta];
 u=mcvgt(cdf,'taux',corner,edges);
 v=mcvgt(cdf,'tauy',corner,edges);
 w=u+i*v;
end
%
base_date=zeros(1,6);
base_date(1:3)=mcagt(cdf,'global','base_date');
jd0=julian(base_date);
jd=jd0+t/3600/24;
