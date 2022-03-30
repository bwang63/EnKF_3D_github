function zn = mexrect ( z, np, n1, n2, n3, n4 )
% MEXRECT:  Conformal mapping from grid boundary to complex space rectangle.
%
% USAGE:  zn = mexrect ( z, np, n1, n2, n3, n4 );
%
% PARAMETERS:
%    z:
%        x and y coordinates of boundary of grid, complexified.
%    np:
%        number of points in z
%    n1, n2, n3, n4:
%        index of corner indicies in z
%    zn:
%        Result of mexrect iteration.  Should eventually be very close
%        to complex unit square.
%
%
