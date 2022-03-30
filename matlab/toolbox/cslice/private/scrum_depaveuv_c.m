function [wmean,x,y]=scrum_depaveuv(cdfin,tind,bounds)
% ECOM_DEPAVEUV computes the depth-averaged value of velocity at
%        a given time step of a SCRUM model run.
%
%  Usage:  [wmean,x,y]=scrum_depaveuv(cdf,[tstep],[bounds])
%
%  where:  cdf = ecomsi.cdf run
%          tstep = time step (default = 1)
%          bounds = [imin imax jmin jmax] limits
%                   (default = [1 nx 1 ny])
%
%          wmean = depth-averaged velocity
%          x = x locations of the returned array wmean
%          y = y locations of the returned array wmean
%
%  Example 1:  [wmean,x,y]=scrum_depaveuv('scrum.cdf');
%
%       computes the depth-averaged velocity at the 1st time step
%       over the entire domain.
%
%  Example 2:  [wmean,x,y]=scrum_depaveuv('scrum.cdf',10);
%
%       computes the depth-averaged velocity at the 10th time step
%       over the entire domain.
%
%  Example 3:  [wmean,x,y]=scrum_depaveuv('scrum.cdf',10,[10 30 30 50]);
%
%       computes the depth-averaged velocity at the 10th time step
%       in the subdomain defined by i=10:30 and j=30:50.
%
%  

if(nargin==1),
  tind=1;
end

ncid=mexcdf('open',cdfin,'nowrite');
if(ncid==-1),
  disp(['file ' cdf ' not found'])
  return
end


%
% Acquire the grid.
%
% If "lon_rho" and "lat_rho" are present, grab them.
% Otherwise, get "x_rho" and "y_rho".
[lon_rho_varid, rcode] = ncmex('VARID', ncid, 'lon_rho');
[lat_rho_varid, rcode] = ncmex('VARID', ncid, 'lat_rho');
if ( (lon_rho_varid >= 0) | (lat_rho_varid >= 0) )
    x=ncmex('varget',ncid,'lon_rho',[0 0],[-1 -1]);
    y=ncmex('varget',ncid,'lat_rho',[0 0],[-1 -1]);
else
    x=ncmex('varget',ncid,'x_rho',[0 0],[-1 -1]);
    y=ncmex('varget',ncid,'y_rho',[0 0],[-1 -1]);
end

x_rho = x;
y_rho = y;

[eta_rho_length, xi_rho_length] = size(x_rho);
eta_u_length = eta_rho_length;
eta_v_length = eta_rho_length-1;
xi_u_length = xi_rho_length-1;
xi_v_length = xi_rho_length;
eta_psi_length = eta_rho_length-1;
xi_psi_length = xi_rho_length-1;


%
% construct the grids at the psi points.
xtemp = (x_rho(:,1:(xi_rho_length-1)) + x_rho(:,2:xi_rho_length))/2;
x = (xtemp(1:(eta_rho_length-1),:)  + xtemp(2:eta_rho_length,:))/2;
ytemp = (y_rho(:,1:(xi_rho_length-1)) + y_rho(:,2:xi_rho_length))/2;
y = (ytemp(1:(eta_rho_length-1),:)  + ytemp(2:eta_rho_length,:))/2;



%
% Get ubar and vbar.
[u_bar, status] = ncmex ( 'varget', ncid, 'ubar', [tind-1 0 0], [1 -1 -1] );
if ( status == -1 )
	fprintf ( 'scrum_depaveuv:  could not get ubar in %s.', cdf );
	return;
end
[v_bar, status] = ncmex ( 'varget', ncid, 'vbar', [tind-1 0 0], [1 -1 -1] );
if ( status == -1 )
	fprintf ( 'scrum_depaveuv:  could not get vbar in %s.', cdf );
	return;
end

%
% If there is a mask_rho, we will want to use it later.
[mask_rho_varid, status] = ncmex ( 'varid', ncid, 'mask_rho' );
if ( status ~= -1 )
	[mask_rho, status] = ncmex ( 'varget', ncid, 'mask_rho', [0 0], [-1 -1] );
	if ( status == -1 )
		fprintf ( 'scrum_zsliceuv:  could not get ''mask_rho'' in %s.', cdf );
		return;
	end
end


ncmex ( 'close', ncid );

%
% Average the velocities onto the psi points.
[r,c] = size(u_bar);
u_bar = (u_bar(:,1:c-1) + u_bar(:,2:c))/2;
[r,c] = size(v_bar);
v_bar = (v_bar(1:r-1,:) + v_bar(2:r,:))/2;


%
% Use complex numbers.
wmean = u_bar + sqrt(-1) * v_bar;


%
% Cut out the requested part.
[nx,ny] = size(wmean);
if ( nargin < 3 )
    x1 = 1;
    y1 = 1;
    x2 = nx;
    y2 = ny;
else
    if (min(bounds(:))<=0)
	disp('out of bounds');
	return;
    end
    if (length(bounds)~=4)
	disp('out of bounds');
	return;
    end
    if (bounds(2) >= nx )
	disp('out of bounds');
	return;
    end
    if (bounds(4) >= ny )
	disp('out of bounds');
	return;
    end

    x1 = bounds(1);
    x2 = bounds(2);
    y1 = bounds(3);
    y2 = bounds(4);

end

%
% apply the rotation
%
% Since the "angle" variable is not always present, we
% need to construct it.  In the scrum files, it is apparently
% always in degrees.  Don't bother with degrees here.
angle = zeros(size(x));



[r,c] = size(x);
j = [2:c-1];
for i = 2:r-1
    angle(i,j) = atan2(y(i+1,j)-y(i-1,j), x(i+1,j)-x(i-1,j));
end

% don't apply the rotation angle here, because 
% john does it in cslice
% wmean=wmean.*exp(sqrt(-1)*angle);


wmean = wmean(x1:x2,y1:y2);
x = x(x1:x2,y1:y2);
y = y(x1:x2,y1:y2);

%
% Mask out the land.
% Since we average the u and v across cells, the appropriate mask
% dimension is that of "mask_psi".  I don't want to take the chance
% that it may not be present in the file, so I compute it from 
% mask_rho.
[umask,vmask,pmask]=uvp_masks ( mask_rho );
mask_inds = find ( pmask == 0 );
wmean(mask_inds) = NaN * ones(size(mask_inds));


return;
