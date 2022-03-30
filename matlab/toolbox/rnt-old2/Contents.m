% 
%     +++++++++++++++++++++++++++++++++++++++++++++++++
%     +                                               +
%     +   (R)oms (N)umerical (T)oolbox -  (by Manu)   +
%     +   Version 2.0  Jan 2004                       +
%     +                                               +
%     +++++++++++++++++++++++++++++++++++++++++++++++++
%
% Function list:
%                -- NUMERICS --
% rnt_gridinfo          - Add/Update your grid configurations (do 1st)
% rnt_gridload          - Loads grid variables
% rnt_setdepth          - Returns depths of sigma coordinates at rho points
% rnt_wvelocity         - Compute vertical  velocity w(x,y,s)
% rnt_2z                - Take field on SIGMA and interpolate to Z
%                         Need to make the mex file first.
% rnt_2s                - Take field on Z and interpolate to SIGMA   
%                         Need to make the mex file first.
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
% 
%               -- PLOTTING --
% rnt_pl_vec            - Plot velocity vectors (uses rnt_quiver.m)
%               -- DEVELOPPING --
% rnt_sectx.m, rnt_secty  - Extracto plot sections along x or y
% rnt_section.m           - Extract arbitrary section
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

% Contents.m $Revision: 2.0 $  $Date: 2004/01/19 02:12:17 $


% Contents.m              rnt_font.m              rnt_oat.m
% getMYframe.m            rnt_getbry_vals.m       rnt_oat_field.m
% nccdl.m                 rnt_getbry_vals_rev.m   rnt_pl_vec.m
% nccopy.m                rnt_getfilenames.m      rnt_plc.m
% nccopyvar.m             rnt_getfilenames_c.m    rnt_plc2.m
% ncsave.m                rnt_grid2gridN.m        rnt_plcm.m
% ncsave2.m               rnt_gridbox.m           rnt_plcm2.m
% pac_coast.m             rnt_gridboxm.m          rnt_plotcoast.m
% pcolorjw.m              rnt_gridinfo.m          rnt_prsV2.m
% rnt_2s.m                rnt_quiver.m
% rnt_2sigma.m            rnt_loadState.m         rnt_rho_eos.m
% rnt_2z.m                rnt_loadvar.m           rnt_rotate.m
% rnt_CreateIniFile.m     rnt_loadvar_seg.m       rnt_section.m
% rnt_GetState.m          rnt_loadvarsum.m        
% rnt_SaveState.m         rnt_makeano.m           
% rnt_barotropic.m        rnt_makebryfile.m       rnt_setdepth.m
% rnt_confill.m           rnt_makeclimafile.m     rnt_spice.m
% rnt_contourfill.m       rnt_makeinifile.m       rnt_timectl.m
% rnt_curl.m              rnt_movie.m             rnt_vertInt.m
% rnt_date.m              rnt_movie2.m            rnt_working.m
% rnt_fill.m              rnt_oa.m                rnt_wvelocity.m
% rnt_fill2.m             rnt_oa2d.m              rnt_wvelocity2.m
% rnt_fill3ab.m           rnt_oa3d.m              rvalue.m
% rnt_findbounds.m        rnt_oapmap.m            sq.m

