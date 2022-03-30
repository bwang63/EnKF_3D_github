function bool = nc_isvar ( ncfile, varname )
% NC_ISVAR:  determines if a variable is present in a netCDF file
%
% BOOL = NC_ISVAR(NCFILE,VARNAME) returns true if the variable VARNAME is 
% present in the netCDF file NCFILE.  Otherwise false is returned.
%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% $Id: nc_isvar.m 2450 2007-11-28 21:35:07Z johnevans007 $
% $LastChangedDate: 2007-11-28 16:35:07 -0500 (Wed, 28 Nov 2007) $
% $LastChangedRevision: 2450 $
% $LastChangedBy: johnevans007 $
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

snc_nargchk(2,2,nargin);
snc_nargoutchk(1,1,nargout);

%
% Both inputs must be character
if nargin ~= 2
	snc_error ( 'SNCTOOLS:NC_ISVAR:badInput', 'must have two inputs' );
end
if ~ischar(ncfile)
	snc_error ( 'SNCTOOLS:NC_ISVAR:badInput', 'first argument must be character.' );
end
if ~ischar(varname)
	snc_error ( 'SNCTOOLS:NC_ISVAR:badInput', 'second argument must be character.' );
end



%
% Do we use java instead of mexnc?
use_java = getpref ( 'SNCTOOLS', 'USE_JAVA', false );
if use_java 
	bool = nc_isvar_java ( ncfile, varname );
else
	bool = nc_isvar_mexnc ( ncfile, varname );
end

return








function bool = nc_isvar_mexnc ( ncfile, varname )

[ncid,status] = mexnc('open',ncfile, nc_nowrite_mode );
if status ~= 0
	ncerr = mexnc ( 'STRERROR', status );
	snc_error ( 'SNCTOOLS:NC_ISVAR:MEXNC:OPEN', ncerr );
end


[varid,status] = mexnc('INQ_VARID',ncid,varname);
if ( status ~= 0 )
	bool = false;
elseif varid >= 0
	bool = true;
else
	snc_error ( 'SNCTOOLS:NC_ISVAR:unknownResult', ...
	        'Unknown result, INQ_VARID succeeded, but returned a negative varid.  That should not happen.' );
end

mexnc('close',ncid);
return









function bool = nc_isvar_java ( ncfile, varname )
% assume false until we know otherwise
bool = false;

import ucar.nc2.dods.*     % import opendap reader classes
import ucar.nc2.*          % have to import this (NetcdfFile) as well for local reads
                           % Now that's just brilliant.  


%
% Try it as a local file.  If not a local file, try as
% via HTTP, then as dods
if exist(ncfile,'file')
	jncid = NetcdfFile.open(ncfile);
else
	try 
		jncid = NetcdfFile.open ( ncfile )
	catch
		try
			jncid = DODSNetcdfFile(ncfile);
		catch
			msg = sprintf ( 'Could not open ''%s'' as either a local file, a regular URL, or as a DODS URL.' );
			error ( 'SNCTOOLS:nc_varget_java:fileOpenFailure', msg );
		end
	end
end




jvarid = jncid.findVariable(varname);

%
% Did we find anything?
if ~isempty(jvarid)
	bool = true;
end

close(jncid);

return

