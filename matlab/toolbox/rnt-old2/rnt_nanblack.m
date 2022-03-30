
function rnt_nanblack(iz,ix)
% function rnt_nanblack(x,z)
h_bottom =iz(:,1)';
x_coord  =ix(:,1)';
xr=x_coord;

x_coord = [x_coord , x_coord(end) , x_coord(1) ,               x_coord(1)];
h_bottom = [h_bottom , min(h_bottom(:))-10, min(h_bottom(:))-10, h_bottom(1) ];
fill(x_coord,h_bottom,'k')
