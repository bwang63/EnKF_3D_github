function c = cslice_capture( point, xinds, yinds )
% cslice_capture:  Does a netcdf file cell contain a particular point?
%  CSLICE_CAPTURE determines whether or not the cell from the netcdf file
%                 captures the point.  The cell is determined by its i and j
%                 indices, which correspond to the lower left hand corner. 
%
%                 This algorithm was grabbed out of the
%                 comp.graphics.algorithms FAQ.  Modified for matlab.
%
%    USAGE cslice_capture ( point, xinds, yinds )
%        point = point in xy space
%        xinds, yinds:  These index into the grid to form the cell
%                             we are checking to see whether it captures
%                             the point.
%    


global cslice_obj;

N = cslice_obj_index;


xgrid = cslice_obj{N}.xgrid;
ygrid = cslice_obj{N}.ygrid;

[m,n] = size(xgrid);


% error checking
if (~isempty( find( xinds<1 | xinds>m) ) )
  c = 0; return;
end
if (~isempty( find( yinds<1 | yinds>n) ))
  c = 0; return;
end
	

x = point(1); y = point(2);

xp = [ ...
	xgrid(xinds(1), yinds(1));
	xgrid(xinds(2), yinds(2));
	xgrid(xinds(3), yinds(3));
	xgrid(xinds(4), yinds(4)) ];
yp = [ ...
	ygrid(xinds(1), yinds(1));
	ygrid(xinds(2), yinds(2));
	ygrid(xinds(3), yinds(3));
	ygrid(xinds(4), yinds(4)) ];


c = 0;

j = 4;
for i = 1:4

  if ( ( (yp(i)<=y) & (y<yp(j)) ) | ( (yp(j)<=y) & (y<yp(i)) ) ) 
    if (x < (xp(j) - xp(i)) * (y - yp(i)) / (yp(j) - yp(i)) + xp(i) )
      c = ~c;
    end
  end
  
  j = i;
end


return;




 

