%
% SCRUM Land/Sea Mask Utility
% ===========================
%
% This utility is a graphical User interface enabling the User to easily
% create and modify a land mask for SCRUM.  This utility call the MEXCDF
% utilities for reading and writing to NetCDF files. 
%
% Driver:
%
%   scrum_mask   - Processes SCRUM Land/Sea mask data.
%
% Input/Output:
%
%   read_mask    - Reads in Land/Sea mask data from GRID NetCDF file.
%   write_mask   - Writes out Land/Sea mask data into GRID NetCDF file.
%   rcoastline   - Reads in coastline data file.
%
% Land/Sea mask:
%
%   set_mask     - Sets Land/Sea mask data on RHO-points.
%   uvp_masks    - Computes the Land/Sea mask data on U-, V-, and PSI-points.
%
% Graphic Interface:
%
%   mask_uifn    - Initializes and controls graphic buttons.
%   get_hand     - Gets handles to buttons from figure's UserData matrix.
%   get_states   - Gets state flags from figure's UserData matrix.
%   put_states   - Puts new state flag values into figure's UserData matrix.
%   radchk       - Maintains mutual exclusivity of grouped radio buttons.
%
% Orthogonal Grid Coordinate Manipulation:
%
%   ijgrid       - Finds closest (I,J) grid index to a point (XP,YP).
%   prange       - Defines closed polygon and finds if (XP,YP) is inside.
%   inside       - Finds if (XP,YP) is inside of defined polygon.
%
% Miscellaneous:
%
%   pltmask      - Plots Land/Sea mask.
%   read_uvpgrid - Reads in positions on U-, V-, and PSI-points.
%   draw_cst     - Draws coastlines. 
%   date_stamp   - Current date/time stamp.
%   day_code     - Determines numerical value for day of week from date.
%