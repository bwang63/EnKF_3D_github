function bool = nc_isunlimitedvar ( ncfile, varname )
% NC_ISUNLIMITEDVAR:  determines if a variable has an unlimited dimension
%
% BOOL = NC_ISUNLIMITEDVAR ( NCFILE, VARNAME ) returns TRUE if the netCDF
% variable VARNAME in the netCDF file NCFILE has an unlimited dimension, 
% and FALSE otherwise.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% $Id: nc_isunlimitedvar.m 2413 2007-11-10 06:19:43Z johnevans007 $
% $LastChangedDate: 2007-11-10 01:19:43 -0500 (Sat, 10 Nov 2007) $
% $LastChangedRevision: 2413 $
% $LastChangedBy: johnevans007 $
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


snc_nargchk(2,2,nargin);
snc_nargoutchk(0,1,nargout);

try
    DataSet = nc_getvarinfo ( ncfile, varname );
catch
    e = lasterror;
    switch ( e.identifier )
        case { 'SNCTOOLS:NC_GETVARINFO:badVariableName', ...
               'SNCTOOLS:NC_VARGET:MEXNC:INQ_VARID' }
            bool = false;
            return
        otherwise
            error('SNCTOOLS:NC_ISUNLIMITEDVAR:unhandledCondition', e.message );
    end
end

bool = DataSet.Unlimited;

return;
