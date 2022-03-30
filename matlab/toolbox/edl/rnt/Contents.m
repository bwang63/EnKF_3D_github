% 
%     +++++++++++++++++++++++++++++++++++++++++++++++++
%     +                                               +
%     +   (R)oms (N)umerical (T)oolbox -  (by Manu)   +
%     +   Version 1.1  Mar 2001                       +
%     +                                               +
%     +++++++++++++++++++++++++++++++++++++++++++++++++
%
% Function list:
%                -- NUMERICS --
% rnt_sigma_config      - Update/ change SIGMA coordinate config (do 1st)
% rnt_gridload          - Loads grid variables
% rnt_setdepth          - Returns depths of sigma coordinates at rho points
% rnt_wvelocity        - Compute vertical  velocity w(x,y,s)
% rnt_2z                - Take field on SIGMA and interpolate to Z
%                          Need to make the mex file first.
% rnt_2s                - Take field on Z and interpolate to SIGMA   
%                          Need to make the mex file first.
% rnt_2grid             - Shift a variable from one grid to another
% rnt_curl              - Compute curl of vector (u,v) on model grid psi-points
% rnt_barotropic        - Compute barotropic u v
% rnt_prsgrd31		- Compute pressure gradient term and geostrophic vel.
%                         WEIGHTED/STANDARD jacobian form (old ROMS)
%                -- MANIPULATION --
%                  in netdf files of ROMS variables
% rnt_timectl           - Make controll array to recall any variable
%                         in 1 or more netcdf model file at the same
%                         time without always telling in which
%                         netcdf file to look into. See help for
%                         this. understanding the concept behind the 
%                         creation of the CTL array is fundamental, easy
%                         and usefull to take full advantage of this
%                         rnt toolbox when dealing with climatology runs
%                         outputs which can be 30-50 nc files which
%                         contain same variable but at different times.
% rnt_date              - Compute dates (day,month,year, etc)
%                         Use this routine to convert from CDC date types
%                         into actual dates, and others...
% rnt_stats             - Make statistics of selected fields (Mean, Variance ..)
% rnt_loadvar           - Load model field (from 1 netcdf file OR composite 
%                         netcdf file.
% rnt_loadvarsum        - Same as loadvar.m but makes summation over time
%                         index.
%               -- PLOTTING --
% rnt_pl_vec            - Plot velocity vectors (uses rnt_quiver.m)
%               -- DEVELOPPING --
% rnt_pl_sect           - Extract and plot section array
% rnt_zetacalc.m        - Calculate zeta ???
% rnt_plot              - Plotting package
% 
%
%                                   -  RNT team developers  -
%                                Emanuele Di Lorenzo (edl@ucsd.edu)
%                                Scripps Inst. of Oceanography
%                                University of California, San Diego
%
%

% Contents.m $Revision: 1.1 $  $Date: 2001/04/23 02:12:17 $




