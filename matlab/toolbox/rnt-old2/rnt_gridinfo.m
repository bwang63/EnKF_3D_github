% (R)oms (N)umerical (T)oolbox
%
% FUNCTION grdinfo = rnt_gridinfo(gridid)
%
% Loads the grid configuration for gridid
% To add new grid please edit this file.
% just copy an existing one and modify for
% your needs. It is simple.
%
% If you editing this file after using
% the Grid-pak scripts use the content
% of variable "nameit" for gridid.
%
% Example: CalCOFI application
%
%    grdinfo = rnt_gridinfo('calc')
%
% RNT - E. Di Lorenzo (edl@ucsd.edu)

function gridindo=rnt_gridinfo(gridid)
  
% initialize to defaults
  gridindo.id      = gridid;
  gridindo.name    = '';
  gridindo.grdfile = '';
  gridindo.N       = 20;
  gridindo.thetas  = 5;
  gridindo.thetab  = 0.4;
  gridindo.tcline  = 200;
  gridindo.cstfile = which('rgrd_WorldCstLinePacific.mat');
  
  
  switch gridid
        
  case 'sd'
    gridindo.id      = gridid;
    gridindo.name    = 'SD 500 m';
    %gridindo.grdfile = '/d1/manu/SDM/sdm-grid.nc';
    gridindo.grdfile = '/d6/edl/ROMS-pak/sd-data/sd-grid.nc';
    gridindo.N       = 30;
    gridindo.thetas  = 5;
    gridindo.thetab  = 0.2;
    gridindo.tcline  = 200;
    gridindo.cstfile = '/d6/edl/ROMS-pak/sccoos-data/sccoos-coast.mat';

  case 'tutorial'
    gridindo.id      = gridid;
    gridindo.name    = 'Tutorial coast test';
    gridindo.grdfile = '/d6/edl/ROMS-pak/tutorial-data/tutorial-grid.nc';
    gridindo.grdfile = '/wd3/edl/4DVAR/SCB_test/sccoos-grid-CBd.nc';
    gridindo.N       = 30;
    gridindo.thetas  = 6;
    gridindo.thetab  = 0;

  case 'smb3'
    gridindo.id      = gridid;
    gridindo.name    = 'SMB 3 from Blaas';
    gridindo.grdfile = '/wd4/edl/SMB/grid_02_10.nc.3';
    gridindo.N       = 40;
    gridindo.thetas  = 5;
    gridindo.thetab  = 0;
    gridindo.tcline  = 200;
    gridindo.cstfile = '/d6/edl/ROMS-pak/sccoos-data/sccoos-coast.mat';    
    
  case 'front'
    gridindo.id      = gridid;
    gridindo.name    = 'Tutorial coast test';
    gridindo.grdfile = '/furhome/shcher/roms/front/roms_grd.nc';
    gridindo.N       = 20;
    gridindo.thetas  = 5;
    gridindo.thetab  = 1;
    gridindo.tcline  = 50;

  case 'd2'
    gridindo.id      = gridid;
    gridindo.name    = 'Double Gyre';
    gridindo.grdfile = '/wd3/edl/4DVAR/IOM/run-2D_gyre/FWD-roms2d_fwd.nc';
    gridindo.N       = 30;
    gridindo.thetas  = 1;
    gridindo.thetab  = 1;


  case 'jdf3'
    gridindo.id      = gridid;
    gridindo.name    = 'JDF 3 in Wash';
    gridindo.grdfile = '/d6/edl/ROMS-pak/jdf3-data/jdf3-grid.nc';
    gridindo.N       = 30;
    gridindo.thetas  = 6;
    gridindo.thetab  = 0.4;
    gridindo.cstfile = '/d6/edl/ROMS-pak/jdf2-data/coast.mat';


  case 'usw8'
    gridindo.id      = gridid;
    gridindo.name    = 'US West Coast 8 km';
    gridindo.grdfile = '/d6/edl/ROMS-pak/usw8-data/usw8-grid.nc';
    gridindo.N       = 32;
    gridindo.thetas  = 6.5;
    gridindo.thetab  = 0;

  case 'usw20'
    gridindo.id      = gridid;
    gridindo.name    = 'US West Coast 20 km';
    gridindo.grdfile = '/d6/edl/ROMS-pak/usw20-data/usw20-grid.nc';
    gridindo.N       = 20;
    gridindo.thetas  = 6.5;
    gridindo.thetab  = 0;
    gridindo.cstfile = '/d6/edl/ROMS-pak/Grid-pak/CoastlineWorldPacific.mat';    
    
  case 'usw8-old'
    gridindo.id      = gridid;
    gridindo.name    = 'US West Coast 8 km - old grid';
    gridindo.grdfile = '/d6/edl/ROMS-pak/usw8-data/usw8-grid.nc-old';
    gridindo.N       = 32;
    gridindo.thetas  = 6.5;
    gridindo.thetab  = 0;
        
  case 'carib'
    gridindo.id      = gridid;
    gridindo.name    = 'Caribbean Sea';
    gridindo.grdfile = '/home/users/julios/carib-data/carib-grid.nc';
    gridindo.N       = 20;
    gridindo.thetas  = 5;
    gridindo.thetab  = 0.4;
    
  case 'northsea'
    gridindo.id      = gridid;
    gridindo.name    = 'North Sea';
    gridindo.grdfile = '/wd3/edl/ROMS-pak/northsea-data/northsea-grid.nc';
    gridindo.N       = 25;
    gridindo.thetas  = 3;
    gridindo.thetab  = 0.4;
    gridindo.cstfile = '/d6/edl/ROMS-pak/matlib/rgrd/rgrd_CoastlineWorld.mat';
            
  case 'china25'
    gridindo.id      = gridid;
    gridindo.name    = 'East China Sea 25 km';
    gridindo.grdfile = '/roms1/roms/ROMS-pak/china25-data/china25-grid.nc';
    gridindo.N       = 20;
    gridindo.thetas  = 5;
    gridindo.thetab  = 0.4;
    gridindo.cstfile = '/d6/edl/ROMS-pak/Grid-pak/CoastlineWorldPacific.mat';

  case 'med'
    gridindo.id      = gridid;
    gridindo.name    = 'Mediterranean Sea';
    gridindo.grdfile = '/d1/manu/creta/data/med-grid.nc';
    gridindo.N       = 30;
    gridindo.thetas  = 5;
    gridindo.thetab  = 0.4;
    gridindo.tcline  = 20;
    gridindo.cstfile = '/d1/manu/creta/data/med_coastline.mat';
            
  case 'bl'
    gridindo.id      = gridid;
    gridindo.name    = 'Boundary layer problem';
    gridindo.grdfile = '/d6/edl/ROMS-pak/bl-data/bl-grid.nc';
    gridindo.N       = 20;
    gridindo.thetas  = 5;
    gridindo.thetab  = 0.0;
    gridindo.cstfile = '/d6/edl/ROMS-pak/Grid-pak/CoastlineWorldPacific.mat';
    
  case 'pacific'
    gridindo.id      = gridid;
    gridindo.name    = 'Pacific';
    gridindo.grdfile = '/wd3/edl/PACIFIC/pacific-alex/pacific_jpl_grd.nc';
    gridindo.N       = 20;
    gridindo.thetas  = 5;
    gridindo.thetab  = 0.0;
   
  case 'pacific-'
    gridindo.id      = gridid;
    gridindo.name    = 'Pacific';
    gridindo.grdfile = '/wd3/edl/PACIFIC/pacific-alex/pacific_jpl_grd-.nc';
    gridindo.N       = 20;
    gridindo.thetas  = 5;
    gridindo.thetab  = 0.0;
    
  case 'pacxav'
    gridindo.id      = gridid;
    gridindo.name    = 'Pacific';
    gridindo.grdfile = '/wd3/edl/PACIFIC/pacific-xav/pacific_jpl_grd_xa.nc';
    gridindo.N       = 30;
    gridindo.thetas  = 6;
    gridindo.thetab  = 0.0;

  case 'queen'
    gridindo.id      = gridid;
    gridindo.name    = 'Queen Island Application';
    gridindo.grdfile = '/d1/manu/foreman/data/queen-grid.nc';
    gridindo.N       = 20;
    gridindo.thetas  = 7;
    gridindo.thetab  = 0;
    gridindo.tcline  = 50;
    gridindo.cstfile = '/d1/manu/foreman/grid/ga8_COAST.mat';
    
  case 'jdf'
    gridindo.id      = gridid;
    gridindo.name    = 'JDF';
    gridindo.grdfile = '/d1/manu/foreman/data/jdf-grid.nc';
    
    gridindo.N       = 20;
    gridindo.thetas  = 7;
    gridindo.thetab  = 0;
    gridindo.tcline  = 50;
    gridindo.cstfile = '/d1/manu/foreman/grid/ga8_COAST.mat';
    
  case 'jdf2'
    gridindo.id      = gridid;
    gridindo.name    = 'JDF';
    gridindo.grdfile = '/d6/edl/ROMS-pak/jdf2-data/jdf2-grid.nc';
    
    gridindo.N       = 30;
    gridindo.thetas  = 7;
    gridindo.thetab  = 0.0;
    gridindo.tcline  = 50;
    gridindo.cstfile = '/d6/edl/ROMS-pak/jdf2-data/coast.mat';
    
  case 'jdf'
    gridindo.id      = gridid;
    gridindo.name    = 'JDF';
    gridindo.grdfile = '/d6/edl/ROMS-pak/jdf2-data/jdf2-grid.nc';
    
    gridindo.N       = 30;
    gridindo.thetas  = 7;
    gridindo.thetab  = 0.0;
    gridindo.tcline  = 50;
    gridindo.cstfile = '/d6/edl/ROMS-pak/jdf2-data/coast.mat';
    
    
  case 'goa8'
    gridindo.id      = gridid;
    gridindo.name    = 'Gulf of Alaska 8 km res.';
    gridindo.grdfile = '/d6/edl/ROMS-pak/goa8-data/goa8-grid.nc';
    gridindo.N       = 20;
    gridindo.thetas  = 7;
    gridindo.thetab  = 0;
    gridindo.tcline  = 10;
    gridindo.cstfile = '/d1/manu/foreman/grid/ga8_COAST.mat';
    
  case 'queen8'
    gridindo.id      = gridid;
    gridindo.name    = 'Queen Island Application 8 km res.';
    gridindo.grdfile = '/d1/manu/foreman/data/queen8-grid.nc';
    gridindo.N       = 20;
    gridindo.thetas  = 7;
    gridindo.thetab  = 0;
    gridindo.tcline  = 50;
    gridindo.cstfile = '/d1/manu/foreman/grid/ga8_COAST.mat';
    
  case 'queen8-t500'
    gridindo.id      = gridid;
    gridindo.name    = 'Queen Island Application 8 km res.';
    gridindo.grdfile = '/d1/manu/foreman/data/queen8-grid-t500.nc';
    gridindo.N       = 20;
    gridindo.thetas  = 7;
    gridindo.thetab  = 0;
    gridindo.tcline  = 50;
    gridindo.cstfile = '/d1/manu/foreman/grid/ga8_COAST.mat';
    
    
  case 'queen8-cape-flat'
    gridindo.id      = gridid;
    gridindo.name    = 'Queen Island Application 8 km res. cape flat';
    gridindo.grdfile = '/d1/manu/foreman/data/queen8-cape-flat-grid.nc';
    gridindo.N       = 20;
    gridindo.thetas  = 7;
    gridindo.thetab  = 0;
    gridindo.tcline  = 50;
    gridindo.cstfile = '/d1/manu/foreman/grid/ga8_COAST.mat';
    
    
  case 'queenBIG'
    gridindo.id      = gridid;
    gridindo.name    = 'Queen Island Application 20 km res.';
    gridindo.grdfile = '/d1/manu/foreman/data/queenBIG-grid.nc';
    gridindo.N       = 20;
    gridindo.thetas  = 7;
    gridindo.thetab  = 0;
    gridindo.tcline  = 50;
    gridindo.cstfile = '/d1/manu/foreman/grid/ga8_COAST.mat';

  case 'goa'
    gridindo.id      = gridid;
    gridindo.name    = 'Gulf of Alaska 7 km';    
    gridindo.grdfile = '/furhome/edl/goa-data/goa-grid.nc';
    gridindo.N       = 25;
    gridindo.thetas  = 6;
    gridindo.thetab  = 0.4;
    gridindo.tcline  = 50;
    gridindo.cstfile = '/d1/manu/foreman/grid/ga8_COAST.mat';
    
  case 'goa10'
    gridindo.id      = gridid;
    gridindo.name    = 'Gulf of Alaska 10 km';
    gridindo.grdfile = '/d1/manu/GOA/CGOA-3/goad10_grid.nc';
    gridindo.N       = 20;
    gridindo.thetas  = 5;
    gridindo.thetab  = 0.4;
    gridindo.tcline  = 200;
    
  case 'cgoa'
    gridindo.id      = gridid;
    gridindo.name    = 'Gulf of Alaska 3 km - Kate';
    gridindo.grdfile = '/d1/kate/CGOA_grid_3.nc';
    gridindo.N       = 30;
    gridindo.thetas  = 5;
    gridindo.thetab  = 0.4;
    gridindo.tcline  = 200;

  case 'goad'
    gridindo.id      = gridid;
    gridindo.name    = 'Gulf of Alaska Doug';
    gridindo.grdfile = '/d5/neilson/goa/lou/goa_grid_post.nc';
    gridindo.grdfile = '/d3/neilson/goa/goa_grid_smoothed_new.nc';
    gridindo.grdfile = '/ono5/neilson/neo_files/pre/roms_grid.nc';
    gridindo.N       = 20;
    gridindo.thetas  = 7;
    gridindo.thetab  = 0;
    gridindo.tcline  = 50;
    gridindo.cstfile = '/d1/manu/foreman/grid/ga8_COAST.mat';
    
  case 'goaft'
    gridindo.id      = gridid;
    gridindo.name    = 'Gulf of Alaska Doug';
    gridindo.grdfile = '/d1/manu/foreman/data/goaft-grid.nc';
    gridindo.N       = 20;
    gridindo.thetas  = 5;
    gridindo.thetab  = 0.4;
    gridindo.tcline  = 50;
    gridindo.cstfile = '/d1/manu/foreman/grid/ga8_COAST.mat';
    
  case 'goa8'
    gridindo.id      = gridid;
    gridindo.name    = 'Gulf of Alaska Doug';
    gridindo.grdfile = '/d1/manu/foreman/data/goa8-grid.nc';
    gridindo.N       = 25;
    gridindo.thetas  = 5;
    gridindo.thetab  = 0.4;
    gridindo.tcline  = 50;
    gridindo.cstfile = '/d1/manu/foreman/grid/ga8_COAST.mat';
        
  case 'dratio'
    gridindo.id      = gridid;
    gridindo.name    = 'Density ration problem';
    gridindo.grdfile = '/d6/edl/ROMS-pak/dratio-data/dratio-grid.nc';
    gridindo.N       = 20;
    gridindo.thetas  = 5;
    gridindo.thetab  = 0.0;
    
  case 'dratio10'
    gridindo.id      = gridid;
    gridindo.name    = 'Dratio';
    gridindo.grdfile = '/d6/edl/ROMS-pak/dratio-data/dratio10-grid.nc';
    gridindo.N       = 20;
    gridindo.thetas  = 5;
    gridindo.thetab  = 0.0;
    
  case 'dratio15'
    gridindo.id      = gridid;
    gridindo.name    = 'Dratio';
    gridindo.grdfile = '/d6/edl/ROMS-pak/dratio-data/dratio15-grid.nc';
    gridindo.N       = 20;
    gridindo.thetas  = 5;
    gridindo.thetab  = 0.0;        
    
  case 'tides'
    gridindo.id      = gridid;
    gridindo.name    = 'Tides analytical';
    gridindo.grdfile = '/hyd12/manu/FWD-RUN/TIDES/bumb-baro/roms_his.nc';
    gridindo.N       = 40;
    gridindo.thetas  = 1;
    gridindo.thetab  = 0.5;
    
  case 'uswest'
    gridindo.id      = gridid;
    gridindo.name    = 'USWEST Test';
    gridindo.grdfile = '/d6/edl/ROMS-pak/uswest-data/uswest-grid.nc';
    gridindo.N       = 20;
    gridindo.thetas  = 5;
    gridindo.thetab  = 0.4;
    
    
  case 'tidana'
    gridindo.id      = gridid;
    gridindo.name    = 'Tides analytical';
    gridindo.grdfile = '/d6/edl/ROMS-pak/tidana-data/tidana-grid.nc';
    gridindo.N       = 16;
    gridindo.thetas  = 5;
    gridindo.thetab  = 0.4;
           
    
  case 'eddy'
    gridindo.id      = gridid;
    gridindo.name    = 'Eddy test problem 0';
    gridindo.grdfile = '/d6/edl/ROMS-pak/eddy-data/eddy-grid.nc';
    gridindo.N       = 20;
    gridindo.thetas  = 5;
    gridindo.thetab  = 0.4;

  case 'eddy1'
    gridindo.id      = gridid;
    gridindo.name    = 'Eddy test problem 1';
    gridindo.grdfile = '/d6/edl/ROMS-pak/eddy1-data/eddy1-grid.nc';
    gridindo.N       = 20;
    gridindo.thetas  = 5;
    gridindo.thetab  = 0.4;
    
  case 'channel'
    gridindo.id      = gridid;
    gridindo.name    = 'Channel CW.';
    gridindo.grdfile = '/d6/edl/ROMS-pak/channel-data/channel-grid.nc';
    gridindo.N       = 20;
    gridindo.thetas  = 5;
    gridindo.thetab  = 0.4;
            
  case 'box'
    gridindo.id      = gridid;
    gridindo.name    = 'Box';
    gridindo.grdfile = '/d6/edl/ROMS-pak/box-data/box-grid.nc';
    gridindo.N       = 10;
    gridindo.thetas  = 5;
    gridindo.thetab  = 0.4;
    
  case 'box2'
    gridindo.id      = gridid;
    gridindo.name    = 'Box 2';
    gridindo.grdfile = '/d6/edl/ROMS-pak/box2-data/box2-grid.nc';
    gridindo.N       = 16;
    gridindo.thetas  = 3;
    gridindo.thetab  = 0;
    
  case 'ccs'
    gridindo.id      = gridid;
    gridindo.name    = 'CCS';
    gridindo.grdfile = '/d6/edl/ROMS-pak/ccs-data/ccs-grid.nc';
    gridindo.N       = 20;
    gridindo.thetas  = 5;
    gridindo.thetab  = 0.4;
    gridindo.cstfile = '/d6/edl/ROMS-pak/Grid-pak/CoastlineWorldPacific.mat';
    
  case 'natl'
    gridindo.id      = gridid;
    gridindo.name    = 'North Atlantic  ';
    gridindo.grdfile = '/d6/edl/ROMS-pak/natl-data/NATL_grid_1c.nc';
    gridindo.N       = 30;
    gridindo.thetas  = 5;
    gridindo.thetab  = 0.4;
    gridindo.tcline  = 200;
    gridindo.cstfile = '/d6/edl/ROMS-pak/Grid-pak/CoastlineWorld.mat';
    
  case 'gm'
    gridindo.id      = gridid;
    gridindo.name    = 'Gulf of Mexico  ';
    gridindo.grdfile = '/wd3/edl/d6/ROMS-pak/gm-data/gm-grid.nc';
    gridindo.N       = 30;
    gridindo.thetas  = 5;
    gridindo.thetab  = 0.4;
    gridindo.tcline  = 200;
    gridindo.cstfile = '/d6/edl/ROMS-pak/Grid-pak/CoastlineWorld.mat';
    
  case 'bengal'
    gridindo.id      = gridid;
    gridindo.name    = 'Bay of Bengal  ';
    gridindo.grdfile = '/d6/edl/ROMS-pak/bengal-data/bengal-grid.nc';
    gridindo.N       = 30;
    gridindo.thetas  = 7;
    gridindo.thetab  = 0.0;
    gridindo.tcline  = 200;
    gridindo.cstfile = '/d6/edl/ROMS-pak/Grid-pak/CoastlineWorldPacific.mat';
        
  case 'acc'
    gridindo.id      = gridid;
    gridindo.name    = 'Antartic Circ. Current - analytical grid';
    gridindo.grdfile = '/d6/edl/ROMS-pak/acc-data/acc-grid.nc';
    gridindo.N       = 14;
    gridindo.thetas  = 3;
    gridindo.thetab  = 1;
    
  case 'acc2'
    gridindo.id      = gridid;
    gridindo.name    = 'ACC analytical grid 10 km';
    gridindo.grdfile = '/d6/edl/ROMS-pak/acc-data/acc2-grid.nc';
    gridindo.N       = 14;
    gridindo.thetas  = 3;
    gridindo.thetab  = 1;
    
  case 'acc25'
    gridindo.id      = gridid;
    gridindo.name    = 'ACC analytical grid 15 km';
    gridindo.grdfile = '/d6/edl/ROMS-pak/acc-data/acc25-grid.nc';
    gridindo.N       = 14;
    gridindo.thetas  = 3;
    gridindo.thetab  = 1;

  case 'okh2'
    gridindo.id      = gridid;
    gridindo.name    = 'Sea of okh';
    gridindo.grdfile = '/d6/edl/ROMS-pak/okh-data/okh2-grid.nc';
    gridindo.N       = 20;
    gridindo.thetas  = 1;
    gridindo.thetab  = 0.5;

  case 'ok'
    gridindo.id      = gridid;
    gridindo.name    = 'okh';
    gridindo.grdfile = '/d6/edl/ROMS-pak/okh-data/ok-grid.nc';
    gridindo.N       = 10;
    gridindo.thetas  = 3;
    gridindo.thetab  = 1;
    
  case 'ok10'
    gridindo.id      = gridid;
    gridindo.name    = 'okh';
    gridindo.grdfile = '/home/shcher/roms/take2/ok10_grd.nc';
    gridindo.N       = 20;
    gridindo.thetas  = 5;
    gridindo.thetab  = 1;
    gridindo.Tcline  = 50;
    gridindo.cstfile = '/d6/edl/ROMS-pak/matlib/rgrd/rgrd_CoastlineWorld.mat';
    
  case 'hawaii'
    gridindo.id      = gridid;
    gridindo.name    = 'Hawaii';
    gridindo.grdfile = '/d6/edl/ROMS-pak/hawaii-data/hawaii-grid.nc';
    gridindo.N       = 20;
    gridindo.thetas  = 5;
    gridindo.thetab  = 0.4;
    gridindo.cstfile = '/d6/edl/ROMS-pak/Grid-pak/CoastlineWorldPacific.mat';
    
  case 'pacific-1'
    gridindo.id      = gridid;
    gridindo.name    = 'Pacific-1 - fulling around';
    gridindo.grdfile = '/d6/edl/ROMS-pak/pacific-data/pacific-grid.nc';
    gridindo.N       = 20;
    gridindo.thetas  = 5;
    gridindo.thetab  = 0.4;
    gridindo.cstfile = '/d6/edl/ROMS-pak/Grid-pak/CoastlineWorldPacific.mat';
        
  case 'creta'
    gridindo.id      = gridid;
    gridindo.name    = 'Creta';
    gridindo.grdfile = '/d1/manu/creta/data/creta-grid.nc';
    gridindo.N       = 30;
    gridindo.thetas  = 5;
    gridindo.thetab  = 0.4;
    gridindo.tcline  = 20;
    gridindo.cstfile = '/d1/manu/creta/data/creta_coastline.mat';
    
  case 'usw_1'
    gridindo.id      = gridid;
    gridindo.name    = 'usw15_z40 0 - UCLA grid';
    gridindo.grdfile = '/d6/edl/WORK/grid.nc.1';
    gridindo.N       = 30;
    gridindo.thetas  = 5;
    gridindo.thetab  = 0;
    gridindo.tcline  = 20;
    gridindo.cstfile = '/d1/manu/japan/grid/PacificCoast.mat';
    
    
  case 'japan'
    gridindo.id      = gridid;
    gridindo.name    = 'Japan sea';
    gridindo.grdfile = '/d1/manu/japan/data/japan-grid.nc';
    gridindo.N       = 30;
    gridindo.thetas  = 5;
    gridindo.thetab  = 0.4;
    gridindo.tcline  = 20;
    gridindo.cstfile = '/d1/manu/japan/grid/PacificCoast.mat';
    
  case 'japan1'
    gridindo.id      = gridid;
    gridindo.name    = 'Japan sea again';
    gridindo.grdfile = '/d1/manu/japan/data/japan1-grid.nc';
    gridindo.N       = 30;
    gridindo.thetas  = 5;
    gridindo.thetab  = 0.4;
    gridindo.tcline  = 20;
    gridindo.cstfile = '/d1/manu/japan/grid/PacificCoast.mat';
     


% begining of nested grids.
    
  case 'scb'
    gridindo.id      = gridid;
    gridindo.name    = 'CalCOFI TEST';
    gridindo.grdfile = '/d1/manu/sbchannel/seagrid/grid-bight.nc';
    gridindo.N       = 20;
    gridindo.thetas  = 7;
    gridindo.thetab  = 0;
    gridindo.tcline  = 200;
    gridindo.cstfile = '/d1/manu/foreman/grid/bigcoast.mat';
    
    
  case 'sdb2.5'
    gridindo.id      = gridid;
    gridindo.name    = 'SDB grid 2.5 km - Manu';
    gridindo.grdfile = '/d6/edl/ROMS-pak/sdb-data/sdb2.5-grid.nc';
    gridindo.N       = 30;
    gridindo.thetas  = 5;
    gridindo.thetab  = 0.4;
    gridindo.tcline  = 200;
    gridindo.cstfile = '/d1/manu/SDM/Coast1_250.mat';
    
  case 'sdb600'
    gridindo.id      = gridid;
    gridindo.name    = 'SDB grid 600 m- Manu';
    gridindo.grdfile = '/d6/edl/ROMS-pak/sdb-data/sdbay600-grid.nc';
    gridindo.N       = 30;
    gridindo.thetas  = 5;
    gridindo.thetab  = 0.4;
    gridindo.tcline  = 200;
    gridindo.cstfile = '/d1/manu/SDM/Coast1_250.mat';
    
  case 'bay'
    gridindo.id      = gridid;
    gridindo.name    = 'SDB grid - Manu';
    gridindo.grdfile = '/d6/edl/ROMS-pak/sdb-data/bay-grid.nc';
    gridindo.N       = 30;
    gridindo.thetas  = 5;
    gridindo.thetab  = 0.4;
    gridindo.tcline  = 200;
    gridindo.cstfile = '/d1/manu/SDM/Coast1_250.mat';
    
    
  case 'sdb-'
    gridindo.id      = gridid;
    gridindo.name    = 'San Diego Modeling';
    gridindo.grdfile = '/d1/manu/SDM/sdb-grid.nc';
    gridindo.N       = 20;
    gridindo.thetas  = 7;
    gridindo.thetab  = 0;
    gridindo.tcline  = 200;
    gridindo.cstfile = '/d1/manu/SDM/Coast1_250.mat';
    
  case 'sdb-2'
    gridindo.id      = gridid;
    gridindo.name    = 'San Diego Modeling';
    gridindo.grdfile = '/d1/manu/SDM/sdb2-grid.nc';
    gridindo.N       = 20;
    gridindo.thetas  = 7;
    gridindo.thetab  = 0;
    gridindo.tcline  = 200;
    gridindo.cstfile = '/d1/manu/SDM/Coast1_250.mat';                  
    
  case 'calx'
    gridindo.id      = gridid;
    gridindo.name    = 'CalCOFI TEST';
    gridindo.grdfile = '/d1/manu/foreman/data/calx-grid.nc';
    gridindo.N       = 20;
    gridindo.thetas  = 7;
    gridindo.thetab  = 0;
    gridindo.tcline  = 200;
    gridindo.cstfile = '/d1/manu/foreman/grid/bigcoast.mat';
    
  case 'ucla'
    gridindo.id      = gridid;
    gridindo.name    = 'US West Coast - UCLA';
    gridindo.grdfile = '/d2/emanuele/roms-data/USwest_pat/grid.nc';
    gridindo.N       = 20;
    gridindo.thetas  = 7;
    gridindo.thetab  = 0;
    gridindo.tcline  = 200;
    
  case 'line90'
    gridindo.id      = gridid;
    gridindo.name    = 'CalCOFI obs. grid';
    gridindo.grdfile = which('Line90Grid.nc');
    gridindo.N       = 20;
    gridindo.thetas  = 7;
    gridindo.thetab  = 0;
    gridindo.tcline  = 200;
    gridindo.cstfile = '/d1/manu/foreman/grid/bigcoast.mat';
        
  case 'calc'
    gridindo.id      = gridid;
    gridindo.name    = 'CalCOFI grid - Manu';
    gridindo.grdfile = which('grid-calcofi.nc');
    gridindo.N       = 20;
    gridindo.thetas  = 5;
    gridindo.thetab  = 0.4;
    gridindo.tcline  = 200;
    gridindo.cstfile = '/d1/manu/foreman/grid/bigcoast.mat';
    
  case 'calc7'
    gridindo.id      = gridid;
    gridindo.name    = 'CalCOFI grid (more surface res.) - Manu';
    gridindo.grdfile = '/d1/manu/matlib/rnt/grid-calcofi.nc';
    gridindo.N       = 20;
    gridindo.thetas  = 7;
    gridindo.thetab  = 0;
    gridindo.tcline  = 200;
    gridindo.cstfile = '/d1/manu/foreman/grid/bigcoast.mat';
    gridindo.hc = 43;
    
    % Embedded grids
    
  case 'sd0'
    gridindo.id      = gridid;
    gridindo.name    = 'San Diego Modeling 0';
    %gridindo.grdfile = '/d1/manu/SDM/sdm-grid.nc';
    gridindo.grdfile = '/d6/edl/AMR-data/DATA/sd_grid.nc';
    gridindo.N       = 40;
    gridindo.thetas  = 5;
    gridindo.thetab  = 0;
    gridindo.tcline  = 200;
    gridindo.cstfile = '/d1/manu/foreman/grid/bigcoast.mat';
    
  case 'sd1'
    gridindo.id      = gridid;
    gridindo.name    = 'San Diego Modeling 1';
    %gridindo.grdfile = '/d1/manu/SDM/sdm-grid.nc';
    gridindo.grdfile = '/d6/edl/AMR-data/DATA/sd_grid.nc.1';
    gridindo.N       = 40;
    gridindo.thetas  = 5;
    gridindo.thetab  = 0;
    gridindo.tcline  = 200;
    gridindo.cstfile = '/d1/manu/foreman/grid/bigcoast.mat';
    
  case 'sd2'
    gridindo.id      = gridid;
    gridindo.name    = 'San Diego Modeling 2';
    %gridindo.grdfile = '/d1/manu/SDM/sdm-grid.nc';
    gridindo.grdfile = '/d6/edl/AMR-data/DATA/sd_grid.nc.2';
    gridindo.N       = 40;
    gridindo.thetas  = 5;
    gridindo.thetab  = 0;
    gridindo.tcline  = 200;
    gridindo.cstfile = '/d1/manu/SDM/Coast1_250.mat';
    
  case 'sd3'
    gridindo.id      = gridid;
    gridindo.name    = 'San Diego Modeling 3';
    %gridindo.grdfile = '/d1/manu/SDM/sdm-grid.nc';
    gridindo.grdfile = '/d6/edl/AMR-data/DATA/sd_grid.nc.3';
    gridindo.N       = 40;
    gridindo.thetas  = 5;
    gridindo.thetab  = 0;
    gridindo.tcline  = 200;
    gridindo.cstfile = '/d1/manu/SDM/Coast1_250.mat';
    
    % SCCOOS grids
    
  case 'sccoos'
    gridindo.id      = gridid;
    gridindo.name    = 'SCCOOS base grid';
    %gridindo.grdfile = '/d1/manu/SDM/sdm-grid.nc';
    gridindo.grdfile = '/d6/edl/ROMS-pak/sccoos-data/sccoos-grid.nc';
    gridindo.N       = 30;
    gridindo.thetas  = 5;
    gridindo.thetab  = 0.2;
    gridindo.tcline  = 200;
    gridindo.cstfile = '/d6/edl/ROMS-pak/sccoos-data/sccoos-coast.mat';
    
  case 'sccoos1'
    gridindo.id      = gridid;
    gridindo.name    = 'SCCOOS 2.5 km';
    %gridindo.grdfile = '/d1/manu/SDM/sdm-grid.nc';
    gridindo.grdfile = '/d6/edl/ROMS-pak/sccoos-data/sccoos-grid.nc.1';
    gridindo.N       = 30;
    gridindo.thetas  = 5;
    gridindo.thetab  = 0.2;
    gridindo.tcline  = 200;
    gridindo.cstfile = '/d6/edl/ROMS-pak/sccoos-data/sccoos-coast.mat';
    
  case 'sccoos2'
    gridindo.id      = gridid;
    gridindo.name    = 'SCCOOS 2.5 km';
    %gridindo.grdfile = '/d1/manu/SDM/sdm-grid.nc';
    gridindo.grdfile = '/d6/edl/SCCOOS/sccoos-grid.nc.2';
    gridindo.N       = 30;
    gridindo.thetas  = 5;
    gridindo.thetab  = 0.2;
    gridindo.tcline  = 200;
    gridindo.cstfile = '/d6/edl/ROMS-pak/sccoos-data/sccoos-coast.mat';
    
  case 'sccoos2-'
    gridindo.id      = gridid;
    gridindo.name    = 'SCCOOS 2.5 km';
    %gridindo.grdfile = '/d1/manu/SDM/sdm-grid.nc';
    gridindo.grdfile = '/d6/edl/ROMS-pak/sccoos-data/sccoos-grid.nc.2';
    gridindo.N       = 30;
    gridindo.thetas  = 5;
    gridindo.thetab  = 0.2;
    gridindo.tcline  = 200;
    gridindo.cstfile = '/d6/edl/ROMS-pak/sccoos-data/sccoos-coast.mat';

  case 'sccoos1-orig'
    gridindo.id      = gridid;
    gridindo.name    = 'SCCOOS 2.5 km';
    %gridindo.grdfile = '/d1/manu/SDM/sdm-grid.nc';
    gridindo.grdfile = '/d6/edl/ROMS-pak/sccoos-data/refine4/sccoos-grid.nc.1-original';
    gridindo.N       = 30;
    gridindo.thetas  = 5;
    gridindo.thetab  = 0.2;
    gridindo.tcline  = 200;
    gridindo.cstfile = '/d6/edl/ROMS-pak/sccoos-data/sccoos-coast.mat';
    
    
  case 'sccs-tidal'
    gridindo.id      = gridid;
    gridindo.name    = 'SCCOOS 2.5 km';
    gridindo.grdfile = '/d6/edl/ROMS-pak/sccs-tidal-data/sccs-tidal-grid.nc';
    gridindo.N       = 2;
    gridindo.thetas  = 5;
    gridindo.thetab  = 0.2;
    gridindo.tcline  = 200;
    gridindo.cstfile = '/d6/edl/ROMS-pak/sccoos-data/sccoos-coast.mat';
    
  case 'sccs-tidal1'
    gridindo.id      = gridid;
    gridindo.name    = 'SCCOOS 2.5 km';
    gridindo.grdfile = '/d6/edl/ROMS-pak/sccs-tidal-data/sccs-tidal1-grid.nc';
    gridindo.N       = 2;
    gridindo.thetas  = 5;
    gridindo.thetab  = 0.2;
    gridindo.tcline  = 200;
    gridindo.cstfile = '/d6/edl/ROMS-pak/sccoos-data/sccoos-coast.mat';
    
    
  case 'smb'
    gridindo.id      = gridid;
    gridindo.name    = 'SMB ';
    gridindo.grdfile = '/d6/edl/ROMS-pak/MEINTE/SMB/usw15_z40_grid.nc';
    gridindo.N       = 40;
    gridindo.thetas  = 7;
    gridindo.thetab  = 0.0;
    gridindo.tcline  = 200;
    gridindo.cstfile = '/d6/edl/ROMS-pak/sccoos-data/sccoos-coast.mat';
    
  case 'smb1'
    gridindo.id      = gridid;
    gridindo.name    = 'SMB  ';
    gridindo.grdfile = '/d6/edl/ROMS-pak/MEINTE/SMB/usw15_z40_grid.nc.1';
    gridindo.N       = 40;
    gridindo.thetas  = 7;
    gridindo.thetab  = 0.0;
    gridindo.tcline  = 200;
    gridindo.cstfile = '/d6/edl/ROMS-pak/sccoos-data/sccoos-coast.mat';
    
  case 'smb2'
    gridindo.id      = gridid;
    gridindo.name    = 'SMB  ';
    gridindo.grdfile = '/d6/edl/ROMS-pak/MEINTE/SMB/usw15_z40_grid.nc.2';
    gridindo.N       = 40;
    gridindo.thetas  = 7;
    gridindo.thetab  = 0.0;
    gridindo.tcline  = 200;
    gridindo.cstfile = '/d6/edl/ROMS-pak/sccoos-data/sccoos-coast.mat';
    
  case 'smb3'
    gridindo.id      = gridid;
    gridindo.name    = 'SMB  ';
    gridindo.grdfile = '/d6/edl/ROMS-pak/MEINTE/SMB/usw15_z40_grid.nc.3';
    gridindo.N       = 40;
    gridindo.thetas  = 7;
    gridindo.thetab  = 0.0;
    gridindo.tcline  = 200;
    gridindo.cstfile = '/d6/edl/ROMS-pak/sccoos-data/sccoos-coast.mat';
    
    
    
    
  otherwise
    gridindo.id      = gridid;
    gridindo.name    = 'null';
    gridindo.grdfile = '/dev/null';
    gridindo.N       = 0;
    gridindo.thetas  = 0;
    gridindo.thetab  = 0;
    gridindo.tcline  = 0;
    disp([' RNT_GRIDINFO - ',gridid,' not configured']);
  end

