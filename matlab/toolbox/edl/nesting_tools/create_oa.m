function  result=create_oa(oaname,parentname,grdname,title,zout,time)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% 	Create an empty netcdf OA file
%       oaname: name of the OA file
%       grdname: name of the grid file
%       title: title in the netcdf file  
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

nc=netcdf(grdname);
Lp=length(nc('xi_rho'));
Mp=length(nc('eta_rho'));
result=close(nc);

nw = netcdf(oaname, 'clobber');
result = redef(nw);

%
%  Create dimensions
%
nw('lon_rho') = Lp;
nw('lat_rho') = Mp;
nw('level') = length(zout);
nw('one') = 1;
nw('four') = 4;
nw('time') = 0;
%
%  Create variables and attributes
%

nw{'refine_coef'} = ncint('one');
nw{'refine_coef'}.long_name = ncchar('Grid refinment coefficient');
nw{'refine_coef'}.long_name = 'Grid refinment coefficient';

nw{'grd_pos'} = ncint('four');
nw{'grd_pos'}.long_name = ncchar('Subgrid location in the parent grid: psi corner points (imin imax jmin jmax)');
nw{'grd_pos'}.long_name = 'Subgrid location in the parent grid: psi corner points (imin imax jmin jmax)';

nw{'zout'} = ncdouble('level');
nw{'zout'}.long_name = ncchar('depths at center of the grid vertical boxes');
nw{'zout'}.long_name = 'depths at center of the grid vertical boxes';
nw{'zout'}.units = ncchar('meter');
nw{'zout'}.units = 'meter';

nw{'lon_rho'} = ncdouble('lat_rho', 'lon_rho');
nw{'lon_rho'}.long_name = ncchar('longitude of RHO-points');
nw{'lon_rho'}.long_name = 'longitude of RHO-points';
nw{'lon_rho'}.units = ncchar('degree_east');
nw{'lon_rho'}.units = 'degree_east';

nw{'lat_rho'} = ncdouble('lat_rho', 'lon_rho');
nw{'lat_rho'}.long_name = ncchar('latitude of RHO-points');
nw{'lat_rho'}.long_name = 'latitude of RHO-points';
nw{'lat_rho'}.units = ncchar('degree_north');
nw{'lat_rho'}.units = 'degree_north';

nw{'mask_rho'} = ncdouble('lat_rho', 'lon_rho');
nw{'mask_rho'}.long_name = ncchar('mask on RHO-points');
nw{'mask_rho'}.long_name = 'mask on RHO-points';
nw{'mask_rho'}.option_0 = ncchar('land');
nw{'mask_rho'}.option_0 = 'land';
nw{'mask_rho'}.option_1 = ncchar('water');
nw{'mask_rho'}.option_1 = 'water';

nw{'time'} = ncdouble('time');
nw{'time'}.long_name = ncchar('estimate time');
nw{'time'}.long_name = 'estimate time';
nw{'time'}.units = ncchar('modified Julian day');
nw{'time'}.units = 'modified Julian day';
nw{'time'}.add_offset = 2440000.;

nw{'temp'} = ncdouble('time','level','lat_rho', 'lon_rho');
nw{'temp'}.long_name = ncchar('potential temperature');
nw{'temp'}.long_name = 'potential temperature';
nw{'temp'}.units = ncchar('Celsius');
nw{'temp'}.units = 'Celsius';
nw{'temp'}.field = ncchar('temperature, scalar, series');
nw{'temp'}.field = 'temperature, scalar, series';

nw{'salt'} = ncdouble('time','level','lat_rho', 'lon_rho');
nw{'salt'}.long_name = ncchar('salinity');
nw{'salt'}.long_name = 'salinity';
nw{'salt'}.units = ncchar('PSU');
nw{'salt'}.units = 'PSU';
nw{'salt'}.field = ncchar('salinity, scalar, series');
nw{'salt'}.field = 'salinity, scalar, series';

result = endef(nw);

%
% Create global attributes
%

nw.title = ncchar(title);
nw.title = title;
nw.date = ncchar(date);
nw.date = date;
nw.grd_file = ncchar(grdname);
nw.grd_file = grdname;
nw.parent_file = ncchar(parentname);
nw.parent_file = parentname;

%
% Wite zout and time
%

nw{'zout'}(:) = zout;
nw{'time'}(1) = time;

result = close(nw);
