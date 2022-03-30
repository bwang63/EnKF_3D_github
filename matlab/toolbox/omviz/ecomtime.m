function [jd]=ecomtime(cdf,ind)
% ECOMTIME Julian time data from POM.CDF or ECOM.CDF type file
% function [jd]=ecomtime(cdf,[ind])
%    cdf= ecom.cdf file name 
%
mexcdf('setopts',0);
ncid=mexcdf('open',cdf,'nowrite');
[nam,nt]=mexcdf('diminq',ncid,'time');
base_date=[0 0 0 0 0 0];
base_date(1:3)=mexcdf('attget',ncid,'global','base_date');
if(nargin==1),
   t=mexcdf('varget',ncid,'time',0,nt);
else
   t=mexcdf('varget1',ncid,'time',ind-1);
end
jd0=julian(base_date);
jd=jd0+t;
mexcdf('close',ncid);
