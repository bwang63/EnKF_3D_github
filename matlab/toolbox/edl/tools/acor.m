function [c,r]=acor(xzero,xdcay);

r=0:5:2*xzero;
r2=r.*r;
a=r2./(xzero*xzero);
b=-0.5.*r2./(xdcay*xdcay);

c=(1-a).*exp(b);

return
