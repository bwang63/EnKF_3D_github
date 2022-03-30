% get_earthdist.m
function d = get_earthdist;
[x y] = ginput(2)
d = earthdist(y(1),x(1),y(2),x(2));