% MATLAB/netcdf interface
%
% The following m-files were written and developed by Jim Mansbridge (C)
% CSIRO 1992-7.  They use the files in the netcdf toolbox, mexcdf and other
% mex-files created and maintained by Chuck Denham U.S. Geological
% Survey, Woods Hole, MA 02543 (cdenham@usgs.gov) 
%
%==========================================================================
% The following commands are available (use help for further
% information) and will be supported in the future.
%==========================================================================
%
% attnc         - imports attributes of a netCDF file
% getnc         - imports variables from a netCDF file
% inqnc         - interactive inquiry of netCDF file
% netcdf toolbox- direct calls to netcdf functions - use 'help netcdf'
%                   for a detailed description 
% timenc        - finds the time vector and the corresponding base date for a
%                   netcdf file that meets COARDS standards
% whatnc        - lists netCDF files in current directory
%
%==========================================================================
% The following commands are employed less often (use help for further
% information) and will be supported in the future.
%==========================================================================
%
% get_calendar_date - converts Julian day numbers to calendar dates
% get_day_of_week- gets the day of the week given the Julian day number
% get_julian_day - converts calendar dates to corresponding Julian day numbers
% parsetnc       - parses the COARDS string that specifies time units
% pos_cds        - returns the path to the common data set directory
%
%==========================================================================
% Three of the above routines (getnc, netcdf toolbox and timenc)
% will only work under matlab 5.  All of the above routines supercede
% the following (less powerful) routines which work under matlab 3.5, 4
% and 5.  The older  routines are only included for backwards compatibility:
%==========================================================================
%
% attcdf        - imports attributes of a netCDF file
% getcdf        - imports variables from a netCDF file
% get_time      - finds the time vector and the corresponding base date for a
%                    netcdf file that meets COARDS standards.
% inqcdf        - interactive inquiry of netCDF file
% mexcdf        - direct calls to netcdf functions - (matlab 4 experts only)
% whatcdf       - lists netCDF files in current directory
%
%==========================================================================
