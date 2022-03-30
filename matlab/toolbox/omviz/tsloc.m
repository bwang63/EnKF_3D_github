function []=tsloc(ecom_file,ts_file);
% TSLOC shows locations of time series stations on map of bathymetry
%  Usage  function []=tsloc(ecom_file,ts_file);
%       ecom_file='ecom3d.cdf'
%       ts_file='tsepic.cdf';
if(nargin<1),
  ecom_file='ecom3d.cdf';
  ts_file='tsepic.cdf';
end
[d,x,y]=kslice(ecom_file,'depth');
pslice(x,y,d);
loc=mcvgt(ts_file,'loc');
loc=loc.';
[m,n]=size(loc);
for i=1:m,
  text(x(loc(i,1),loc(i,2)),y(loc(i,1),loc(i,2)),int2str(i));
end
