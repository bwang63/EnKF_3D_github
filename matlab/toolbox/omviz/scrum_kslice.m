function [u,x,y]=scrum_kslice(cdf,var,time,layer)
%SCRUM_KSLICE:  returns horizontal slice at particular layer.
%
% Horizontal slice is at specified s_rho layer at given time-step for a
% SCRUM file.
%
% This function can also be used to read in 2D and 3D fields such as
% bathymetry and heat_flux.  The coordinates of u are returned as x and y.
%
% USAGE: [u,x,y]=scrum_kslice(cdf,var,[time],[layer])
%
% where 
%   cdf:  file name for netCDf file (e.g. 'scrum_c.nc')
%   var:  the variable to select (eg. 'salt' for salinity)
%   time:  time step 
%   layer:  in the NetCDF file, s_rho is dimensioned as [0 ... s_rho_length-1].
%           The layer variables which are a function of s_rho run from -1 to 0,
%           which is reversed from ECOM.  In order to have conformity, we will 
%           have the parameter 'layer' be 1-based, and have layer 1 correspond 
%           to the top layer instead of the bottom.
%
%    
%       Examples: 
%
%          [s,x,y]=scrum_kslice('scrum_c.nc','salt',2,3);
%              returns the salinity field from the 3rd sigma level
%              at the 2nd time step.
%
%          [elev,x,y]=scrum_kslice('scrum_c.nc','zeta',4);
%              returns the elevation field from the 4th time step
%
%          [depth,x,y]=scrum_kslice('scrum_c.nc','h');
%              returns the depth field
%
if (nargin<2 | nargin>4),
  help scrum_kslice; return
end

% turn off warnings from NetCDf
mexcdf('setopts',0);

%
% open existing file
ncid=mexcdf('open',cdf,'nowrite');
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


[xi_rho_length, eta_rho_length] = size(x);


%
% Determine which variables make up the grid.
% This assumes that the variable being asked for is
% defined something like this.
%
% salt ( time, depth, ydimension, xdimension );
%
% The x dimension must be last, and the y dimension must
% be second to last.
[varid, rcode] = ncmex('VARID', ncid, var);
[dud, dud, ndims, vardims, dud, status] = ncmex('varinq', ncid, varid);

y_dimid = vardims(ndims-1);
x_dimid = vardims(ndims);

[dud, y_length, status] = ncmex('diminq', ncid, y_dimid);
[dud, x_length, status] = ncmex('diminq', ncid, x_dimid);

%
% if the lengths of the x and y dimensions do not match up with
% the eta_rho and xi_rho lengths, then we must have something
% that depends upon eta_u, xi_v, or similar.  Adjust the grid
% accordingly.
if ( x_length == (xi_rho_length-1) )
    x = (x(1:xi_rho_length-1,:) + x(2:xi_rho_length,:))/2;
    y = (y(1:xi_rho_length-1,:) + y(2:xi_rho_length,:))/2;
end
if ( y_length == (eta_rho_length-1) )
    x = (x(:,1:eta_rho_length-1) + x(:,2:eta_rho_length))/2;
    y = (y(:,1:eta_rho_length-1) + y(:,2:eta_rho_length))/2;
end




%
% allow for using kslice on 2D, 3D and 4D variables
switch ( nargin )

    %
    % 2D variable, such as bathymetry (h)
    case 2
        [u,ierr]=ncmex('varget',ncid,var,[0 0],[-1 -1]);

    %
    % 3D 
    case 3
        [u,ierr]=ncmex('varget',ncid,var,[(time-1) 0 0],[1 -1 -1]);

    %
    % 4D
    case 4
        [s_rho_dimid, status] = ncmex ( 'dimid', ncid, 's_rho' );
        [dud, s_rho_length, status] = ncmex ( 'diminq', ncid, s_rho_dimid );
        [u,ierr]=ncmex('varget',ncid,var,[(time-1) (s_rho_length-layer) 0 0],[1 1 -1 -1]);

end

    

%
% If the appropriate mask is present, use it to mask out the land.
% Find the correct mask by comparing the dimension ids of the 
% variable in question and that of each mask variable.
mask_vars = ['mask_rho'; 'mask_u  '; 'mask_v  '; 'mask_psi' ];
for ind = 1:4
    mask_var = deblank(mask_vars(ind,:));

    [mask_varid, status] = ncmex ( 'varid', ncid, mask_var );
    if ( mask_varid ~= -1 )
        [dud, dud, ndims, mask_dimids, dud, status] = ncmex('varinq', ncid, mask_varid);

        if ( ~isempty(find(vardims==mask_dimids(1))) & ~isempty(find(vardims==mask_dimids(2))) )
            [mask, status] = ncmex ( 'varget', ncid, mask_var, [0 0], [-1 -1] );
            land = find(mask==0);
            u(land) = u(land)*NaN;
        end

    end

end

ncmex('close',ncid);

