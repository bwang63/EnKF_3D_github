function [x,y,d,xi,yi]=plotsta(ecomcdf,tscdf,iplot);
% PLOTSTA Plots time series output locations on map
% and numbers the stations 
%function [x,y,d,xi,yi]=plotsta(ecomcdf,tscdf,iplot);
[d,x,y]=kslice(ecomcdf,'depth');
loc=mcvgt(tscdf,'loc');
loc=loc.';  %columnize
[m,n]=size(loc);
for i=1:m;
  xi(i)=x(loc(i,1),loc(i,2));
  yi(i)=y(loc(i,1),loc(i,2));
end
if nargin==3,
  pslice(x,y,d);
  line(xi,yi,'linestyle','none','color','black',...
   'marker','.','markersize',20);
  line(xi,yi,'linestyle','none','color','white',...
   'marker','.','markersize',14);
  for i=1:m;
    text(xi(i),yi(i),int2str(i),'color','white');
  end 
end
