function [dy]=tide(t,y);

a=2.0*pi/12.4;

dy = [y(1); -0.05 - 0.25.*sin(a.*t)];

return
