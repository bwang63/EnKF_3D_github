function [u,dist,x,y,z] =get_cross_slice (pt1, pt2)
% GET_CROSS_SLICE:  Interpolates data values from pt1 to pt2.
%
% USAGE:  [u,d,x,y,z] = get_cross_slice ( point1, point2 );
% where
%    u:  holds interpolated values
%   d:  distances of interpolated values along line of slice
%   x,y,z:  spatial coordinates of data
%   point1, point2:  coords of endpoints of slice line
%
% Written by John Evans
% jevans@usgs.gov
% 5/3/96
% 





global cslice_obj;

N = cslice_obj_index;


%
% Reset the map projection.
x = cslice_obj{N}.hx;
y = cslice_obj{N}.hy;
switch ( cslice_obj{N}.map_projection )

    case 'none'

    case 'lambert conformal conic'
	lat_extents = [gmin(y(:)) gmax(y(:))];
	lon_extents = [gmin(x(:)) gmax(x(:))];
	m_proj ( 'lambert conformal conic', ...
		 'lat', lat_extents, ...
		 'lon', lon_extents );

    case 'mercator'
	m_proj ( 'mercator' );

    case 'stereographic'
	m_proj ( 'stereographic' );

end


%
% Get the grid dimensions.
switch ( cslice_obj{N}.type )
    case 'ECOM'
        [name, nz]=ncmex('diminq',cslice_obj{N}.ncid,'zpos');
    case 'SCRUM'
        [name, nz]=ncmex('diminq',cslice_obj{N}.ncid,'s_rho');
end
[ni,nj] = size(cslice_obj{N}.hx);

if ( strcmp(cslice_obj{N}.map_projection,'none') )
    xgrid = cslice_obj{N}.hx; 
    ygrid = cslice_obj{N}.hy;
else
    [xgrid,ygrid] = m_ll2xy(cslice_obj{N}.hx,cslice_obj{N}.hy);
end

cslice_obj{N}.xgrid = xgrid;
cslice_obj{N}.ygrid = ygrid;



res = cslice_obj{N}.resolution;


%
% Initial the values.
%
x = zeros(res,1);
y = zeros(res,1);


%
% Get the s values, we'll call them sigma.
switch ( cslice_obj{N}.type )
    case 'ECOM'
        %
        % The z values are 'interpolated' halfway between the sigma levels.
        sigma = ncmex( 'varget', cslice_obj{N}.ncid, 'sigma', 0, nz, 1 );
        sigma = (sigma(1:nz-1) + sigma(2:nz))/2.0;

    case 'SCRUM'
        sigma = ncmex ( 'varget', cslice_obj{N}.ncid, 'sc_r', 0, [-1] );

end

u = zeros(length(sigma),res);
z = zeros(length(sigma),res);

%
% Find points at which to interpolate.
% Each point is determined by the equation 
%    point = (1-alpha)*pt1 + alpha*pt2
% where alpha is a parameter ranging between 0 and 1.
%
for i = 1:res

    alpha = (i-1)/(res-1);
    current_point = (1-alpha)*pt1 + alpha*pt2;


    %
    % Find the nearest point.  If the point is actually inside
    % the grid, interpolate the data from the nearest four points.
    % Otherwise, return no data.
    %

    dist = sqrt ( (xgrid-current_point(1)).^2 ...
                + (ygrid-current_point(2)).^2 );
    index = find(dist==min(min(dist)));
    yind = floor((index-1)/ni) + 1;
    xind = index - (yind-1)*ni;




    % Determine the individual neighbor cells from the closest point.
    % A cell is determined by the indices corresponding
    % to its bottom left point.  The center of the search block is the southwest
    %        corner of the northeast block.
    % 
    %        X-----------------X------------------X
    %        |                 |                  |
    %        |                 |                  |
    %        |       quad2     |        quad1     |
    %        |                 |                  |
    %        |                 |                  |
    %        X----------closest point-------------X
    %        |                 |                  |
    %        |                 |                  |
    %        |       quad3     |        quad4     |
    %        |                 |                  |
    %        |                 |                  |
    %        X-----------------X------------------X

    %
    % Setup row and column indices for surrounding cells.
    quad1_yind = [yind yind+1 yind+1 yind]; quad1_xind = [xind xind xind+1 xind+1];
    quad2_yind = [yind-1 yind yind yind-1]; quad2_xind = [xind xind xind+1 xind+1];
    quad3_yind = [yind-1 yind yind yind-1]; quad3_xind = [xind-1 xind-1 xind xind];
    quad4_yind = [yind yind+1 yind+1 yind]; quad4_xind = [xind-1 xind-1 xind xind];


    %
    % capture x and y values
    %
    x(i) = current_point(1);  
    y(i) = current_point(2);
  

    % Look to see if quadrant 1 cell captures the next point.  If not, check
    % quadrant 2, quadrant 3, quadrant 4.  If any do, interpolate from that cell,
    % and move on to the next point.  If none do, set values to NaN
    if ( cslice_capture(current_point, quad1_xind, quad1_yind) )
      [z(:,i),u(:,i)] = cslice_interp ( nz, current_point, quad1_xind, quad1_yind, sigma);
    elseif ( cslice_capture ( current_point, quad2_xind, quad2_yind ) )
      [z(:,i),u(:,i)] = cslice_interp ( nz, current_point, quad2_xind, quad2_yind, sigma);
    elseif ( cslice_capture ( current_point, quad3_xind, quad3_yind ) )
      [z(:,i),u(:,i)] = cslice_interp ( nz, current_point, quad3_xind, quad3_yind, sigma);
    elseif ( cslice_capture ( current_point, quad4_xind, quad4_yind) )
      [z(:,i),u(:,i)] = cslice_interp ( nz, current_point, quad4_xind, quad4_yind, sigma);

    %
    % Why did I have these 0 instead of NaN??
    else
        z(:,i) = NaN * ones(size(z(:,i)));
        u(:,i) = NaN * ones(size(u(:,i)));

    end
    

end
  
u = u * cslice_obj{N}.scale_factor + cslice_obj{N}.add_offset;
  
% Compute the distance vector.  Done with a trick.  Since the points are
% all equidistant, all we really need to do is find the distance of the
% first two points, then multiply this by a vector [0 1 2... res-1]
dist  = [0:1:res-1] * sqrt((x(2) - x(1))^2 + (y(2) - y(1))^2);
[m,n]=size(u);
dist = ones(m,1) * dist;

% rps. 10-13-99  John Evans had the following chuck of code to interpolate
%  the xslice values in the vertical, but there isn't any good reason that
%  I can think of to do this -- we should just give back the sigma level values
%  along the slice.  So I put in a switch ("zinterp") and set it to zero
%  to turn this off.  If you really *want* to interpolate in the vertical
%  using the same "resolution" as in the horizontal, set "zinterp"=1,
zinterp=0;
if (zinterp),
  %  Now interpolate in the depth direction.
  [m,n] = size(u);
  uu = zeros(res,res);
  ddist = ones(res,res);
  zz = zeros(res,res);
  for i = 1:n
    zz(:,i) = [z(1,i):((z(m,i)-z(1,i))/(res-1)):z(m,i)]';
    uu(:,i) = cslice_linterp(z(:,i),u(:,i),zz(:,i));
    ddist(:,i) = dist(1,i) * ddist(:,i);
  end
  u = uu;
  dist = ddist;
  z = zz;
end

return;



