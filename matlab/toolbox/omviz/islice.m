function [u,y,z]=islice(cdf,var,time,iindex,jrange)
% ISLICE:  returns horizontal slice at particular layer.
%
% The variable must be 4D.  Works on either ECOM or SCRUM files.
%
% USAGE: 
% >> [u,y,z]=islice(cdf,var,time,iindex,[jrange])
%      u = the selected variable
%      y = distance in *km* (assuming y units in netCDF file are in meters)
%      z = depth in m
%      iindex = I index along which slice is taken
%      jrange = jmin and jmax indices along slice (optional).  If this
%           argument is not supplied the default takes all the J indices
%           except for the first and last, which are always "land" cells.
%
%
% see also JSLICE, KSLICE, ZSLICE, ZSLICEUV, KSLICEUV
%
if ( nargin<4 | nargin>5),
  help kslice; return
end

% turn off warnings from NetCDf
ncmex('setopts',0);

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
	ncmex ( 'close', ncid );
	switch ( nargin )
		case 4
			[u,y,z] = scrum_islice ( cdf, var, time, iindex );
		case 5
			[u,y,z] = scrum_islice ( cdf, var, time, iindex, jrange );
	end
	return;
end

%
% Assume that an ECOM file will always contain the 'xpos' dimensions.
% If we find it, assume it is an ECOM file.
[dimid, rcode] = ncmex('dimid', ncid, 'xpos');
if ( dimid ~= -1 )
	ncmex ( 'close', ncid );
	switch ( nargin )
		case 4
			[u,y,z] = ecom_islice ( cdf, var, time, iindex );
		case 5
			[u,y,z] = ecom_islice ( cdf, var, time, iindex, jrange );
	end
	return;
end


%
% If we get this far, then neither file was recognizable.
fprintf ( 'I can''t make sense out of %s???\n\n', cdf );
help islice;
return;
