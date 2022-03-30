% Access routines for Oceans-EEZ data products
%
%   Contents of /home/eez_data/software/matlab
%   ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% - - -  CSIRO Climatology of Australian Regional Seas access scripts
% getchunk:   extract a 3D chunk of a property map
% get_clim_casts:  extract property from CARS for given locations, depths, and
%             optionally days-of-year.
% getmap:     extract a 2D horizontal slice of a given climatology
% getsection: (SUPERCEDED for most purposes by get_clim_casts) 
%             extract vertical profiles at arbitrary geographic positions
%             
% blankbelow: set a flag so that any of the above scripts overwrite any
%             data below the ocean bottom with NaNs.
% eezgrid:    create the lat/long grids on which the CARS is based.
% atday:      evaluated extracted mean and harmonics at given day of year.
% atdaypos:   evaluated extracted mean and harmonics at given positions and 
%             day of year.
% time2doy    days since start of 1900 to day_of_year   
% time2greg   days since start of 1900 to gregorian time
%
% - - -  Pathfinder SST
% pfsst:  Retrieves a map of Pathfinder SST for a given region and date.
%
% - - -  CSIRO CTD archive access 
% ctd_extract: skeleton script to be adapted by users to extract CSIRO CTDs
% ctd_select:  GUI menu to select from CSIRO CTD station list
%
% - - - Standard Level cast access functions
% getNODC:    Matlab5 access to WOA94 casts
% getNODC_var:   Matlab4 access to WOA94 casts
% getCSIRO:   Access to CSIRO standard level casts
%
% - - -  Background functions (not for users to invoke directly)
% For ctd_select:  ctd_sel_util.m, dispsel_util.m
%
% See ./private/Contents.m for others
