function [interpolated_z,interpolated_u] = cslice_interp ( nz, np, xind, yind, sigma );
% CSLICE_INTERP:  Interpolates value at a point from surrounding cell
% corners.  This function interpolates the value of the variable 'var' at
% the point np.  The interpolation is done by averaging the values of the
% surrounding corner points of the cell.
%
% The variable must be a function of x, y, z and time: (e.g. salinity) 
%
% USAGE cslice_interp ( nz, np, cell, sigma);
%        nz = number of values to retrieve along z direction
%        np = point at which to interpolate
%        sigma = depths at which to take the data
%
% Written by John Evans
% jevans@usgs.gov
% 10/19/95
% 

global cslice_obj;

N = cslice_obj_index;

ncid = cslice_obj{N}.ncid;
var = cslice_obj{N}.variable;
time_index = cslice_obj{N}.time_step;
xgrid = cslice_obj{N}.hx;
ygrid = cslice_obj{N}.hy;


i = cell(1); j = cell(2);


xp = [ ...
    xgrid( xind(1), yind(1) );
    xgrid( xind(2), yind(2) );
    xgrid( xind(3), yind(3) );
    xgrid( xind(4), yind(4) ) ];
yp = [ ...
    ygrid( xind(1), yind(1) );
    ygrid( xind(2), yind(2) );
    ygrid( xind(3), yind(3) );
    ygrid( xind(4), yind(4) ) ];


% Get the data values at the grid nodes of this particular cell.
zsize = length(sigma);
corner1 = squeeze( ...
    ncmex('varget',ncid,var,[time_index-1 0 yind(1)-1 xind(1)-1],[1 zsize 1 1]));
corner2 = squeeze( ...
    ncmex('varget',ncid,var,[time_index-1 0 yind(2)-1 xind(2)-1],[1 zsize 1 1]));
corner3 = squeeze( ...
    ncmex('varget',ncid,var,[time_index-1 0 yind(3)-1 xind(3)-1],[1 zsize 1 1]));
corner4 = squeeze( ...
    ncmex('varget',ncid,var,[time_index-1 0 yind(4)-1 xind(4)-1],[1 zsize 1 1]));
corner_data = [corner1 corner2 corner3 corner4];

        
        
             
% Now get the depth values.
corner_depths = [cslice_obj{N}.bathymetry( xind(1), yind(1))...
         cslice_obj{N}.bathymetry( xind(2), yind(2)) ...
         cslice_obj{N}.bathymetry( xind(3), yind(3)) ...
         cslice_obj{N}.bathymetry( xind(4), yind(4)) ];



% Compute the weights for the corner points.  Order is Southwest, Southeast,
% Northeast, Northwest.  The weighting scheme is in terms of inverse
% distance from the interpolated point.  Uncomment the first weights
% assignment to make it a simple average.
weights = [ sqrt((xp(1) - np(1))^2 + (yp(1) - np(2))^2); ...
            sqrt((xp(2) - np(1))^2 + (yp(2) - np(2))^2); ...
            sqrt((xp(3) - np(1))^2 + (yp(3) - np(2))^2); ...
            sqrt((xp(4) - np(1))^2 + (yp(4) - np(2))^2) ];
% weights = [0.25; 0.25; 0.25; 0.25];

% Guard against occasion where np falls square on a grid point.
is_zero = find(weights==0);
if (length(is_zero) ~= 0)
  weights = zeros(size(weights));
  weights(is_zero) = 1.0;
end


% check for NaNs in the depths vector.  If there are any, NaN out the
% respective weight.
ind = find(isnan(corner_depths));
weights(ind) = NaN * weights(ind);

%
% The closer a point is, the MORE it should contribute, so invert the
% distance.  Then normalize.  Then convert the NaNs back into 0s, as
% otherwise a single NaN will make the entire interpolated u and z
% into NaNs
weights = 1./weights;
nonan_weights = weights;
indnan = find(isnan(nonan_weights));
nonan_weights(indnan) = zeros(size(indnan));

%
% nansum was a call to the stats toolbox.  bad, bad, bad
%weights = weights / nansum(weights);
sum_weights = sum(nonan_weights);
if (sum_weights == 0)
    sum_weights = NaN;
end
weights = weights / sum_weights;
weights(ind) = zeros(size(weights(ind)));
corner_depths(ind) = zeros(size(corner_depths(ind)));


%
% If all of the weights are zero, then set the answer to NaN.
if ( length(ind) == 4 )
  interpolated_u = NaN * ones(size(sigma));
  interpolated_z = NaN * ones(size(sigma));
%elseif (sum(weights) ~= 0.0)
else
  interpolated_u = corner_data * weights;

  switch ( cslice_obj{N}.type )
    case 'ECOM'
          interpolated_z = (corner_depths * weights) * sigma;
    case 'SCRUM'

        %
        % get the information needed to compute depth
        % z = zeta * (1 + s) + hc*s + (h - hc)*C(s)
        corner_zeta = ...
	    [ ncmex('varget1', ncid, 'zeta', [time_index yind(1) xind(1)] ) ...
              ncmex('varget1', ncid, 'zeta', [time_index yind(2) xind(2)] ) ...
              ncmex('varget1', ncid, 'zeta', [time_index yind(3) xind(3)] ) ...
              ncmex('varget1', ncid, 'zeta', [time_index yind(4) xind(4)] ) ];

        s = sigma(:);
        h = corner_depths*weights;
        zeta = corner_zeta * weights;
        [hc, status] = ncmex ( 'varget1', cslice_obj{N}.ncid, 'hc', [0]);
        [Cs_r, status] = ncmex ( 'varget', ncid, 'Cs_r', [0], [-1] );
        Cs_r = Cs_r(:);
        interpolated_z = zeta*(1+s) + hc*s + (h-hc)*Cs_r;
        %interpolated_z = flipud(interpolated_z);

  end

end

interpolated_u = interpolated_u(:);
interpolated_z = interpolated_z(:);

       
