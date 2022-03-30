function h=psliceuv(x,y,w,isub,sca,color)
%
% PSLICEUV plots a horizontal matrix of 
%          velocity from ECOMSI using arrows
%
%  USAGE: h=psliceuv(x,y,w,isub,sca,color)
% x is array of x points
% y is array of y points 
% w is array of velocities
% isub is number to subsample
% sca is scale factor for arrows
% color is color for arrows
% 
% EXAMPLE:  psliceuv(x,y,w,3,20,'white');
%
if(~exist('isub')),
  isub=2;
end
if(~exist('sca')),
  sca=1e4;
end
if(~exist('color')),
  color='white';
end
[m,n]=size(w);
w=w([isub:isub:m],[isub:isub:n]);
x=x([isub:isub:m],[isub:isub:n]);
y=y([isub:isub:m],[isub:isub:n]);
ig=find(finite(w));
h=arrows(x(ig),y(ig),w(ig),sca,color);
