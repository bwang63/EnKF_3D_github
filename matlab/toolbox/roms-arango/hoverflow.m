function [y,h]=hoverflow();

y=0:1:200;

%  Set bottom topography.

hmin=200;
hmax=4000;
yc=100;
ydecay=20;

h=hmin+0.5*(hmax-hmin).*(1.0+tanh((y-yc)./ydecay));

return
