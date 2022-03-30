function [type,coord] = what_type ( filename )
% WHAT_TYPE:  Determines type of cdf file for cslice.
%
% USAGE:  [type,coord] = what_type ( filename )    
%
% PARAMETERS:
%   type:  string denoting file type.
%   coord:  string denoting coordinate type, 'GEOGRAPHIC' (lon/lat)
%           or 'PROJECTED' (meters, km)
%
%   filename:  Name of file to visualize.
%

type = 'unknown';


[ncid, status] = ncmex ( 'open', filename, 'nowrite' );

%
% Assume that a SCRUM file will always contain the 'xi_rho' dimension.
% If we find it, assume that we've got a SCRUM file.
[dimid, rcode] = ncmex('dimid', ncid, 'xi_rho');
if ( dimid ~= -1 )
	type = 'SCRUM';
% If "lon_rho" and "lat_rho" are present, define coord as
%  'GEOGRAPHIC', otherwise, 'PROJECTED'
	[lon_rho_varid, rcode] = ncmex('VARID', ncid, 'lon_rho');
	[lat_rho_varid, rcode] = ncmex('VARID', ncid, 'lat_rho');
	if ( (lon_rho_varid >= 0) | (lat_rho_varid >= 0) )
     	 	coord='GEOGRAPHIC';
	else
		coord='PROJECTED';
	end
	return;
end

%
% Assume that an ECOM file will always contain the 'xpos' dimensions.
% If we find it, assume it is an ECOM file.
[dimid, rcode] = ncmex('dimid', ncid, 'xpos');
if ( dimid ~= -1 )
	type = 'ECOM';
% If "lon" and "lat" are present, define coord as
%  'GEOGRAPHIC', otherwise, 'PROJECTED'
  [lon_varid, rcode] = ncmex('VARID', ncid, 'lon');
  [lat_varid, rcode] = ncmex('VARID', ncid, 'lat');
  if ( (lon_varid >= 0) | (lat_varid >= 0) )
     coord='GEOGRAPHIC';
  else
     coord='PROJECTED';
  end 
	return;
end


ncmex ( 'close', ncid );

