% FUNCTION: Get_TSData()
% 
% USAGE:
%     [var, time, loc, depth] = get_tsdata('cdf_file', 'varname', station) ;
%     [var, time, loc]        = get_tsdata('cdf_file', 'varname', station) ;
%     [var, time]             = get_tsdata('cdf_file', 'varname', station) ;
% or
%     var = get_tsdata('cdf_file', 'varname', station) ;
% 
% DESCRIPTION:
% Get_tsdata() is used to extract time-series variables from 'tsepic' files,
% and it not only returns the time-series data but also (optionally) returns
% the time, grid location, and depth values for the data. 
% 
% There are 13 time-series variables stored in the 'tsepic' files.  No matter
% which variable names you use, get_tsdata() will return matrices of the
% appropriate dimension.  Some of these variables are just one-dimensional
% time-series.  They are:
% 
%     taux		Wind-stress along the x-axis...
%     tauy		Wind-stress along the y-axis...
%     elev		Sea surface elevation
%     heat_flux		Heat flux
% 
% Other variables are two-dimensional (depth & time).  These variables are:
% 
%     u			Current along the x-axis
%     v			Current along the y-axis
%     w			Current along the z-axis
%     conc		Tracer concentration
%     salt		Salinity
%     kh		Vertical Diffusivity
%     km		Vertical Viscosity
%     am		Horizontal Viscosity
%     temp		Temperature (degrees-Celsius)
% 
% You can make a quick plot of salinity with the following set of commands
% 
%     [salt, t, loc, depth] = get_tsdata('tsepic.cdf', 'salt', 1) ;
%     pcolor(t,depth,salt) 
%     shading 'flat'
%     colorbar 
% 
% If you now want to make a plot of temperature (from the same file), it is
% not necessary to use all four output variables...
% 
%     temp = get_tsdata('tsepic.cdf', 'temp', 1);
%     figure
%     pcolor(t,depth,temp)
%     shading 'flat'
%     colorbar
% 
% Author:  Randy Zagar  (zagar@chester.cms.udel.edu)
%


function [x, time, loc, depth] = get_tsdata(cdf_file, varname, station)

mexcdf('setopts', 0);

if  isstr(cdf_file)
    mexcdf('setopts', 0) ;
    ncid = mexcdf('open', cdf_file) ;
else
    ncid = cdf_file ;
end

[name, nstation] = mexcdf('diminq', ncid, 'stations');
[name, nsigma]   = mexcdf('diminq', ncid, 'sigma');
[name, nt]       = mexcdf('diminq', ncid, 'time');
[name, ndim]     = mexcdf('diminq', ncid, 'dim');

if  station > nstation
    errmsg = sprintf('    invalid station number (max==%d)\n', nstation);
    error( errmsg );
    return ;
end

if  isstr(varname)
    varid = mexcdf('varid', ncid, varname) ;
    if  varid == -1
	errmsg = sprintf('    invalid variable name \"%s\"\n', varname) ;
	error( errmsg );
	return ;
    end

%   [name, type, ndims, dim, natts, status] = mexcdf('VARINQ',ncid,varid)

    if  nargout >= 2
	[time, status] = mexcdf('VARGET', ncid, mexcdf('varid',ncid,'time'),  ...
		    [0], [nt], 1) ;
    end

    if  nargout >= 3
	[loc, status] = mexcdf('VARGET', ncid, mexcdf('varid',ncid,'loc'), ...
			[0,station-1], [2,1]) ;
	loc = loc';
    end

    if  nargout == 4
	[s, status] = mexcdf('VARGET', ncid, mexcdf('varid',ncid,'sigma'), ...
		    [0], [nsigma]) ;
	[d, status] = mexcdf('VARGET', ncid, mexcdf('varid',ncid,'depth'), ...
		    [station-1], [1]) ;
	depth = s * d ;
    end
		
    if strcmp(varname, 'taux')
	[x, status] = mexcdf('VARGET', ncid, varid, [0,0,0,0], [nt,1,1,1]) ;
	if  nargout == 4
	    depth = [] ;
	end
	if  nargout >= 3
	    loc = [] ;
	end
    elseif strcmp(varname, 'tauy')
	[x, status] = mexcdf('VARGET', ncid, varid, [0,0,0,0], [nt,1,1,1]) ;
	if  nargout == 4
	    depth = [] ;
	end
	if  nargout >= 3
	    loc = [] ;
	end
    elseif strcmp(varname, 'elev')
	[x, status] = mexcdf('VARGET', ncid, varid, [0,0,0,station-1], [nt,1,1,1]) ;
	if  nargout == 4
	    depth = 0 ;
	end
    elseif strcmp(varname, 'heat_flux')
	[x, status] = mexcdf('VARGET', ncid, varid, [0,0,0,station-1], [nt,1,1,1], 1) ;
	if  nargout == 4
	    depth = 0 ;
	end
    elseif strcmp(varname, 'u')
	[x, status] = mexcdf('VARGET', ncid, varid, [0,0,0,station-1], [nt,nsigma,1,1], 1) ;
    elseif strcmp(varname, 'v')
	[x, status] = mexcdf('VARGET', ncid, varid, [0,0,0,station-1], [nt,nsigma,1,1], 1) ;
    elseif strcmp(varname, 'w')
	[x, status] = mexcdf('VARGET', ncid, varid, [0,0,0,station-1], [nt,nsigma,1,1], 1) ;
    elseif strcmp(varname, 'conc')
	[x, status] = mexcdf('VARGET', ncid, varid, [0,0,0,station-1], [nt,nsigma,1,1], 1) ;
    elseif strcmp(varname, 'salt')
	[x, status] = mexcdf('VARGET', ncid, varid, [0,0,0,station-1], [nt,nsigma,1,1], 1) ;
    elseif strcmp(varname, 'kh')
	[x, status] = mexcdf('VARGET', ncid, varid, [0,0,0,station-1], [nt,nsigma,1,1], 1) ;
    elseif strcmp(varname, 'km')
	[x, status] = mexcdf('VARGET', ncid, varid, [0,0,0,station-1], [nt,nsigma,1,1], 1) ;
    elseif strcmp(varname, 'am')
	[x, status] = mexcdf('VARGET', ncid, varid, [0,0,0,station-1], [nt,nsigma,1,1], 1) ;
    elseif strcmp(varname, 'temp')
	[x, status] = mexcdf('VARGET', ncid, varid, [0,0,0,station-1], [nt,nsigma,1,1], 1) ;
    end

    depth = s * d ;
end

if  isstr(cdf_file)
    mexcdf('CLOSE', ncid);
end
