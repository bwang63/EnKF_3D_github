%          Ocean Modeling Vizualization Tools (OMVIZ)
%
%               Rich Signell (rsignell@usgs.gov)
%
%                   LIST OF ROUTINES
%
% Routines that extract data from ECOM, POM and SCRUM NetCDF model output
% 
%   kslice     - Get horizontal slice along constant k
%   islice     - Get vertical slice along constant i
%   jslice     - Get vertical slice along constant j
%   zslice     - Get horizontal slice at constant z (interpolates)
%   ksliceuv   - Get horizontal velocity slice along sigma level k
%   zsliceuv   - Get horizontal velocity slice at constant z (interpolates from levels)
%   depaveuv   - Get depth-averaged velocity 
%   ctotal     - Determine total and average amount of scalar in domain
% 
% Plotting data
%
%   pslice     - Color-shaded image with color legend
%   psliceuv   - Draws field of arrows on existing plot
%
% Routines that currently only work with ECOM or POM files
%
%   depave     - Get depth-averaged scalar field
%   ecomtau    - Get wind time series 
%   ecomelev   - Get elevation time series 
%   ecomts     - Get time series of scalar at specified (i,j) location 
%   ecomvel    - Get time series of velocity at specified (i,j) location 
%   ecomtime   - Get time base 
%   freshtot   - Get total freshwater in domain (given a reference salinity)
%   w100       - Calculate velocity 1 m off bottom, assuming law-of-the-wall between
%                   the lowest velocity estimate and the sea floor.
