function [jj,ii]=sp2gc(cdf,x_sp,y_sp,iwater)
% SP2GC State Plane (or whatever coordinates the model 
%   uses) to Grid Coordinates
% 
%    Usage: [i,j]=sp2gc(cdf,x_sp,y_sp,[iwater])
%       where  cdf = netCDF 4D output file name 
%              (x_sp,y_sp) = location in map coordinates
%                   used by model
%              (i,j) =  closest grid location in grid cell
%                      coordinates
%               [include iwater=1 if you want only water points to 
%               be considered]
if(nargin==2),
 y_sp=x_sp(:,2);
 x_sp=x_sp(:,1);
end
if(nargin==3),
  iwater=0;
end
[d,x,y]=kslice(cdf,'depth');
%
dind=find(~isnan(d));
ii=zeros(size(x_sp));
jj=ii;
for i=1:length(x_sp);
 if(iwater),
   [index,dist]=nearxy(x(dind),y(dind),x_sp(i),y_sp(i)); 
   index=dind(index);
 else
   [index,dist]=nearxy(x(:),y(:),x_sp(i),y_sp(i)); 
 end
 [m,n]=size(x);
 ii(i)=floor((index-1)/m)+1;
 jj(i)=rem(index,m);
 if(jj(i)==0),jj(i)=m,end;
end
