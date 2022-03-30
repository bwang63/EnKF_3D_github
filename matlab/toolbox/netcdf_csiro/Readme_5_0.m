% Copyright J. V. Mansbridge, CSIRO, january 30 1992
%      Revision $Revision: 1.2 $
%      Author   $Author: mansbrid $
%      Date     $Date: 2000/07/03 04:28:46 $
%      Source   ftp.marine.csiro.au/software/mansbrid/matlab_netcdf_5_0.tar.Z 
%               or ftp.marine.csiro.au/software/mansbrid/matlab_netcdf_5_0.p
% 
% DISCLAIMER
%   This software is provided "as is" without warranty of any kind.
% 
% DESCRIPTION
%   This software is a toolkit of MATLAB routines that enable some
% simple manipulation of netcdf files within matlab version 5.  The
% routines provide a simple (but limited) interface to Chuck Denham's
% (cdenham@nobska.er.usgs.gov) netcdf toolbox.  The main use for the
% routines is to read hyperslabs of data into matlab variables.
% 
% INSTALLATION
%   It is assumed that users have already installed one of Chuck
% Denham's (cdenham@nobska.er.usgs.gov) matlab/netcdf interfaces.  These
% can be found from the mexcdf homepage at
% 'http://crusty.er.usgs.gov/mexcdf.html'.  There are versions suitable
% for matlab 5, 4 and 3.5.
% 
% The installation of the m-files in this tarfile is easy.
% 
% 1) Simply untarring this file has put all of the required m-files in a
% single directory.
% 
% 2) Put the directory (called something like matlab-netcdf-5.0) into
% matlab's path - perhaps by using the 'path' command.  It is possible
% to store the m-files in the directory containing Chuck's files (this
% would usually be $TOOLBOX/local/netcdf).  The only trouble with this
% is that matlab will then see a conflict between the Contents.m file is
% this distribution and chuck's netcdf help file.
% 
% 3) Edit the m-file pos_cds.m; it returns the path to the common data
% set directory.  pos_cds.m is called by whatnc, inqnc and getnc and so
% any netcdf file in the common data set will be accessible to users
% without them needing to specify path names.
% 
% 4) You may edit the the function y_rescale.m although this is strongly
% advised against.  The function y_rescale determines whether getnc
% applies the attributes scale_factor and add_offset to relevant
% variables and attributes.  The default is that any variable will be
% automatically rescaled; if a variable has attributes valid_range,
% valid_min, valid_max or _FillValue then these will be automatically
% rescaled also.  This behaviour can be changed by editing y_rescale.m
% but you should be very cautious in doing so.  In particular, if the
% variable is rescaled and its attributes not, or vice versa, then the
% options to replace 'invalid' data will not work in the way expected in
% the netcdf standard.
% 
% 5) The system should now be ready to go.
% 
% 	Summary of functions
% 
% ==========================================================================
% The following commands are available (use help for further
% information) and will be supported in the future.
% 
% ==========================================================================
% attnc         - imports attributes of a netCDF file
% getnc         - imports variables from a netCDF file
% inqnc         - interactive inquiry of netCDF file
% netcdf toolbox- direct calls to netcdf functions - use 'help netcdf'
%                   for a detailed description 
% timenc        - finds the time vector and the corresponding base date for a
%                   netcdf file that meets COARDS standards
% whatnc        - lists netCDF files in current directory
% ==========================================================================
% 
% 	Documentation
% 
% There used to be a user manual in latex and postscript form.  I have
% not yet updated the manual and so have not put it in this distribution.
% 
% In fact it should not be necessary for an experienced matlab and
% netcdf user to read the manual at all.  Simply do a help on the 5
% m-files that would be commonly used - attnc, getnc, inqnc, timenc and
% whatnc.
% 
% 	Backwards compatibility issues
% 
% Earlier versions of these m-files had names like getcdf, whatcdf, etc
% and were used for matlab versions 3.5 and 4.2.  If you have a lot of
% legacy code that you don't wish to change then you should download and
% install matlab_netcdf_4x5.tar.Z or matlab_netcdf_4x5.p.  This runs under
% matlab 5 and mimics the older matlab/netcdf interface.
% 
% 	KNOWN BUGS:
% 
% None. Earlier versions of TIMENC only worked for times later than 1582
% (when the Gregorian calendar began). The present version also knows about
% the  Julian calenders; thus it is accurate back to the beginning of the
% year -4712.
% 
%          Jim Mansbridge (jim.mansbridge@marine.csiro.au)

help Readme_5_0
