% time_calc.m
[x y] = ginput(2)
d = earthdist(y(1),x(1),y(2),x(2))/1.8
t = d/12