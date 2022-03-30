function whatcdf

%--------------------------------------------------------------------
%     Copyright (C) J. V. Mansbridge, CSIRO, january 24 1992
%     Revision $Revision: 1.3 $
%
% DESCRIPTION:
% whatcdf lists all of the netCDF files (including compressed ones) in
% the current directory.  It also lists all of the netcdf files in the
% common data set.

% Note 1) If run under unix the output the files are listed without
%         their .cdf or .nc suffices and in a clean layout (ls and sed
%         have been used). whatcdf still runs under a non-unix system but
%         the output is quick and dirty (using dir) and the suffices
%         have not been removed.
% Note 2) whatcdf is based on an old version which used to only work for
%         unixsystems.
% Note 3) The path for the common data set is found by a call to
%         pos_cds.
%
% INPUT:
% none
%
% OUTPUT:
% messages to the user's terminal
%
% EXAMPLE:
% Simply type whatcdf at the matlab prompt.
%
% CALLER:   general purpose
% CALLEE:   Unix ls, sed
%
% AUTHOR:   J. V. Mansbridge, CSIRO
%---------------------------------------------------------------------

%     Copyright (C), J.V. Mansbridge, 
%     Commonwealth Scientific and Industrial Research Organisation
%     Revision $Revision: 1.3 $
%     Author   $Author: mansbrid $
%     Date     $Date: 1997/06/11 04:53:39 $
%     RCSfile  $RCSfile: whatcdf.m,v $
% 
%--------------------------------------------------------------------

% Annoying message

fprintf('');
disp('%% whatcdf is no longer supported - use whatnc from now on %%')

if isunix == 1
  disp(' ')
  disp('-----  current directory netCDF files  -----')
  !ls -C *.cdf *.nc | sed -e 's/\.cdf/    /g' | sed -e 's/\.nc/   /g'
  disp(' ')
  disp('-----  current directory compressed netCDF files  -----')
  !ls -C *.cdf.Z *.nc.Z | sed -e 's/\.cdf\.Z/      /g' | sed -e 's/\.nc\.Z/     /g'
  disp(' ')
  disp('-----  common data set of netCDF files  -----')
  path_name = pos_cds;
  command = [ '!cd ' path_name '; ls -C *.cdf *.nc' ...
	' | sed -e ''s/\.cdf/    /g'''  ' | sed -e ''s/\.nc/   /g''' ];
  eval(command);
  disp(' ')
else
  disp(' ')
  disp('-----  current directory netCDF files  -----')
  dir *.nc
  dir *.cdf
  disp(' ')
  disp('-----  current directory compressed netCDF files  -----')
  dir *.nc.Z
  dir *.cdf.Z
  disp(' ')
  disp('-----  common data set of netCDF files  -----')
  path_name = pos_cds;
  command = [ 'dir ' path_name '*.nc' ];
  eval(command);
  command = [ 'dir ' path_name '*.cdf' ];
  eval(command);
  disp(' ')
end