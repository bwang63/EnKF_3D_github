function [u,x,y]=zslice(cdf,var,timestep,zdepth)
%ZSLICE:  Returns horizontal slice from SCRUM or ECOM Netcdf file.
%
% This is a wrapper m-file that determines whether the input file is of
% type SCRUM or ECOM.  Depending on the result, it calls "ecom_zslice" or
% "scrum_zslice".
%
% USAGE: [u,x,y]=zslice(cdf,var,time,zdepth)
%    cdf:  name of SCRUM or ECOM NetCDF file.
%    var:  name of variable.
%    time:  time index, must be zero-based
%    zdepth:  depth in meters (e.g -10.)
%
% see also ZSLICEUV, 
% hint: use PSLICE to plot the results of ZSLICE 

if ( nargin ~= 4 )
	help zslice;
	return;
end

ncid = ncmex('open', cdf, 'nowrite');
if ( ncid == -1 )
	fprintf ( 'Could not open %s.\n', cdf );
	return;
end

%
% Assume that a SCRUM file will always contain the 'xi_rho' dimension.
% If we find it, assume that we've got a SCRUM file.
[dimid, rcode] = ncmex('dimid', ncid, 'xi_rho');
if ( dimid ~= -1 )
	[u,x,y]=scrum_zslice(cdf,var,timestep,zdepth);
	ncmex ( 'close', ncid );
	return;
end

%
% Assume that an ECOM file will always contain the 'xpos' dimensions.
% If we find it, assume it is an ECOM file.
[dimid, rcode] = ncmex('dimid', ncid, 'xpos');
if ( dimid ~= -1 )
	[u,x,y]=ecom_zslice(cdf,var,timestep,zdepth);
	%u = u';
	%x = x';
	%y = y';
	ncmex ( 'close', ncid );
	return;
end


%
% If we get this far, then neither file was recognizable.
fprintf ( 'I can''t make sense out of %s???\n', cdf );
help zslice;
return;


