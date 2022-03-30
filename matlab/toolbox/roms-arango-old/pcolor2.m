function pcolor2(x,y,z,cmin,cmax)

%  Manipulate input matrix to set desired color scale.

[Im,Jm]=size(z);

Z=z;
ind=find(Z<cmin);
if (~isempty(ind)), Z(ind)=cmin; end,
ind=find(Z>cmax);
if (~isempty(ind)), Z(ind)=cmax; end,

Z(Im+1,1:Jm+1,:)=NaN;
Z(1:Im+1,Jm+1,:)=NaN;
Z(Im+1,Jm  ,:)=cmin;
Z(Im+1,Jm+1,:)=cmax;

X=x;
X(Im+1,1:Jm+1)=Inf;
X(1:Im+1,Jm+1)=Inf;

Y=y;
Y(Im+1,1:Jm+1)=Inf;
Y(1:Im+1,Jm+1)=Inf;

pcolor(X,Y,Z);

return
