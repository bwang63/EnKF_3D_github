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
  
  if exist(gridid)== 2
     file = textread(gridid,'%s','delimiter','\n','whitespace','');
     for i=1:length(file)
       eval(file{i});
     end
%     feval(gridid);
%     load(gridid);
     return
  end
  
  
  switch gridid

  case 'ccs-20km'
    gridindo.id      = gridid;
    gridindo.name    = 'CCS 25 km';
    gridindo.grdfile = '/pldd/ilaria/CCS/ccs-20km-data/ccs-20km-grid.nc';
    gridindo.N       = 26;
    gridindo.thetas  = 6;
%    gridindo.hc  = 111.0827; 
%    gridindo.hmin =7;
    gridindo.thetab  = 0.4;
    gridindo.cstfile='/d6/edl/ROMS-pak/matlib/rgrd/rgrd_CCS_CstLine.mat';
        
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

  case 'wrd'
    gridindo.id      = gridid;
    gridindo.name    = 'World';
    gridindo.grdfile = '/sdb/home/vc/wrd-data/wrd-grid.nc';
    gridindo.N       = 10;
    gridindo.thetas  = 3;
    gridindo.thetab  = 0.4;
    gridindo.tcline  = 200;
    gridindo.tcline  = 50;

  case 'iom-test'
    gridindo.id      = gridid;
    gridindo.name    = 'iom-test';
    gridindo.grdfile = '/sdc/IOM/TestCASE/iom-test-grid.nc';
    gridindo.N       = 5;
    gridindo.thetas  = 3;
    gridindo.thetab  = 1.0;
    gridindo.tcline  = 200;
    gridindo.tcline  = 50;

  case 'iom-upw'
    gridindo.id      = gridid;
    gridindo.name    = 'iom-upw-up';
    gridindo.grdfile = '/drive/edl/IROMS/ncfiles-upw/upw-grid.nc';
    gridindo.N       = 10;
    gridindo.thetas  = 6;
    gridindo.thetab  = 0.4;
    gridindo.tcline  = 200;
    gridindo.tcline  = 50;






  case 'gb'
    gridindo.id      = gridid;
    gridindo.name    = 'Global';
    %gridindo.grdfile = '/d1/manu/SDM/sdm-grid.nc';
    gridindo.grdfile = '/web/gg023.nc';
    gridindo.N       = 30;
    gridindo.thetas  = 5;
    gridindo.thetab  = 0.2;
    gridindo.tcline  = 200;

  case 'tutorial'
    gridindo.id      = gridid;
    gridindo.name    = 'Tutorial coast test';
    gridindo.grdfile = '/d6/edl/ROMS-pak/tutorial-data/tutorial-grid.nc';
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

  case 'nawc'
    gridindo.id      = gridid;
    gridindo.name    = 'Double Gyre';
    gridindo.grdfile = '/d6/edl/ROMS-pak/nawc-data/nawc-grid.nc';
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

  case 'usw6'
    gridindo.id      = gridid;
    gridindo.name    = 'US West Coast 6 km';
    gridindo.grdfile = '/d6/edl/ROMS-pak/usw6-data/usw6-grid.nc';
    gridindo.N       = 30;
    gridindo.thetas  = 6.5;
    gridindo.thetab  = 0.4;
    gridindo.hc      = 40; %m
    gridindo.tcline  = 40; %m
    gridindo.cstfile = '/d6/edl/ROMS-pak/matlib/rgrd/rgrd_CCS_CstLine.mat';

  case 'bahia2'
    gridindo.id      = gridid;
    gridindo.name    = 'US West Coast 6 km';
    gridindo.grdfile = '/home/manu/aurelian/bahia2-grid.nc';
    gridindo.N       = 30;
    gridindo.thetas  = 6.5;
    gridindo.thetab  = 0.4;
    gridindo.hc      = 40; %m
    gridindo.tcline  = 40; %m
    gridindo.cstfile = '/home/manu/aurelian/coastfile.mat';

  case 'usw7'
    gridindo.id      = gridid;
    gridindo.name    = 'US West Coast 7 km';
    gridindo.grdfile = '/largehome/edl/ROMS-pak/usw7-data/usw7-grid.nc';
    gridindo.N       = 30;
    gridindo.thetas  = 6.5;
    gridindo.thetab  = 0.4;
    gridindo.hc      = 40; %m
    gridindo.tcline  = 40; %m
    gridindo.cstfile = '/d6/edl/ROMS-pak/matlib/rgrd/rgrd_CCS_CstLine.mat';

  case 'usw20'
    gridindo.id      = gridid;
    gridindo.name    = 'US West Coast 20 km';
    gridindo.grdfile = '/d6/edl/ROMS-pak/usw20-data/usw20-grid.nc';
    gridindo.N       = 20;
    gridindo.thetas  = 6.5;
    gridindo.thetab  = 0;
    gridindo.hc  = 84.2521;
    gridindo.cstfile = '/d6/edl/ROMS-pak/matlib/rgrd/rgrd_CCS_CstLine.mat';

 case 'so'
    gridindo.id      = gridid;
    gridindo.name    = 'Southern Ocean';
    gridindo.grdfile = '/d6/edl/ROMS-pak/so-data/so-grid.nc';
    gridindo.N       = 20;
    gridindo.thetas  = 6.5;
    gridindo.thetab  = 0;
    gridindo.hc  = 84.2521;
    gridindo.cstfile = '/d6/edl/ROMS-pak/matlib/rgrd/rgrd_CCS_CstLine.mat';
    
  case 'scb'
    gridindo.id      = gridid;
    gridindo.name    = 'SCB 7 km';
    gridindo.grdfile = '/d6/edl/ROMS-pak/scb-data/scb-grid.nc';
    gridindo.N       = 20;
    gridindo.thetas  = 6.5;
    gridindo.thetab  = 0;
    gridindo.hc  = 155.6225;
    gridindo.cstfile = '/sdb/edl/ROMS-pak/matlib/rgrd/rgrd_CCS_CstLine.mat';

  case 'scb20'
    gridindo.id      = gridid;
    gridindo.name    = 'SCB 20 km';
    gridindo.grdfile = '/sdb/edl/ROMS-pak/scb-data/scb20-grid.nc';
    gridindo.N       = 20;
    gridindo.thetas  = 6.5;
    gridindo.thetab  = 0;
    gridindo.hc  = 84.2521;
    gridindo.cstfile = '/sdb/edl/ROMS-pak/matlib/rgrd/rgrd_CCS_CstLine.mat';

  case 'scbANAL'
    gridindo.id      = gridid;
    gridindo.name    = 'SCB ANAL 20 km';
    gridindo.grdfile = '/drive/edl/IROMS/ncfiles-SCB20km/SCB_ANAL/scbANAL-grid.nc';
    gridindo.N       = 10;
    gridindo.thetas  = 5.0;
    gridindo.thetab  = 0.4;
    %gridindo.hc  = 84.2521;
    gridindo.cstfile = '/sdb/edl/ROMS-pak/matlib/rgrd/rgrd_CCS_CstLine.mat';

  case 'scb20_upw'
    gridindo.id      = gridid;
    gridindo.name    = 'SCB 20 km UPW-PERIODIC';
    gridindo.grdfile = '/sdd/CCS/SCB_ASSIM/SCB-UPW-PER/scb20_upw_grid.nc';
    gridindo.N       = 18;
    gridindo.thetas  = 5.0;
    gridindo.thetab  = 0.4;
    gridindo.hc  = 133.5977;
    gridindo.cstfile = '/sdb/edl/ROMS-pak/matlib/rgrd/rgrd_CCS_CstLine.mat';

case 'scb20-assim'
    gridindo.id      = gridid;
    gridindo.name    = 'SCB 20 km';
    gridindo.grdfile = '/sdd/CCS/SCB_ASSIM/scb20-assim-grid.nc';
    gridindo.N       = 26;
    gridindo.thetas  = 6.0;
    gridindo.thetab  = 0;
%    gridindo.hc  = 84.2521;
    gridindo.cstfile = '/d6/edl/ROMS-pak/matlib/rgrd/rgrd_CCS_CstLine.mat';
  

case 'scb20-2'
    gridindo.id      = gridid;
    gridindo.name    = 'SCB 20 km';
    gridindo.grdfile = '/d6/edl/ROMS-pak/scb-data/scb20-grid.nc';
    gridindo.N       = 20;
    gridindo.thetas  = 5.0;
    gridindo.thetab  = 0.2;
    gridindo.hc  = 84.2521;
    gridindo.cstfile = '/d6/edl/ROMS-pak/matlib/rgrd/rgrd_CCS_CstLine.mat';



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
    gridindo.grdfile = '/sdb/edl/ROMS-pak/carib-data/carib-grid.nc';
    gridindo.N       = 20;
    gridindo.thetas  = 5;
    gridindo.thetab  = 0.4;

  case 'carib2'
    gridindo.id      = gridid;
    gridindo.name    = 'Caribbean Sea';
    gridindo.grdfile = '/sdb/edl/ROMS-pak/carib-data/carib2-grid.nc';
    gridindo.N       = 20;
    gridindo.thetas  = 5;
    gridindo.thetab  = 0.4;
    gridindo.cstfile ='/sdb/edl/ROMS-pak/carib-data/carib_coast.mat';

  case 'ias20'
    gridindo.id      = gridid;
    gridindo.name    = 'Intra-america-sea 20km';
    gridindo.grdfile = '/sdb/edl/ROMS-pak/ias20-data/ias20_grid.nc';
    gridindo.N       = 30;
    gridindo.thetas  = 5;
    gridindo.thetab  = 0.4;
%    gridindo.thetas  = 6.5;
%    gridindo.thetab  = 0;
%    gridindo.hc  = 19.999;
    gridindo.hc  = 20.;
    gridindo.cstfile ='/sdb/edl/ROMS-pak/ias20-data/ias_coast.mat';

  case 'ias10'
    gridindo.id      = gridid;
    gridindo.id      = '/sdc/dana/GoodTopo/grid.txt';
    gridindo.name    = 'Caribbean HIRES';
    %gridindo.grdfile = '/sdc/dana/GoodTopo/carib10km-grid.nc';
    gridindo.grdfile = '/drive/dana/IAS10/ias10-data/ias10-grid-new.nc';
    gridindo.N       = 30;
    gridindo.thetas  = 6;
    gridindo.thetab  = 0.4;
    gridindo.tcline  = 200;
    gridindo.cstfile = '/sdb/edl/ROMS-pak/ias20-data/ias_coast.mat';

  case 'ias10-manu'
    gridindo.id      = gridid;
    gridindo.name    = 'Caribbean HIRES Manu';
    gridindo.grdfile = '/drive/dana/IAS10/10km/ias10-manu-grid.nc';
    gridindo.N       = 30;
    gridindo.thetas  = 5;
    gridindo.thetab  = 0.4;
    gridindo.tcline  = 200;
    gridindo.cstfile = '/sdb/edl/ROMS-pak/ias20-data/ias_coast.mat';

  case 'ias10-manu-paleo'
    gridindo.id      = gridid;
    gridindo.name    = 'Caribbean HIRES Manu';
    gridindo.grdfile = '/drive/dana/IAS10/10km/ias10-manu-paleogrid.nc';
    gridindo.N       = 30;
    gridindo.thetas  = 5;
    gridindo.thetab  = 0.4;
    gridindo.tcline  = 200;
    gridindo.cstfile = '/sdb/edl/ROMS-pak/ias20-data/ias_coast.mat';



  case 'ias40-w4dvar'
    gridindo.id      = gridid;
    gridindo.name    = 'Intra-america-sea 40km';
    gridindo.grdfile = '/drive/powellb/interp/ias40_grid.nc';
    gridindo.N       = 30;
    gridindo.thetas  = 5;
    gridindo.thetab  = 0.4;
%    gridindo.thetas  = 6.5;
%    gridindo.thetab  = 0;
%    gridindo.hc  = 19.999;
    gridindo.hc  = 29.0857;
    gridindo.cstfile ='/sdb/edl/ROMS-pak/ias20-data/ias_coast.mat';

  case 'ias20-w4dvar'
    gridindo.id      = gridid;
    gridindo.name    = 'Intra-america-sea 40km';
    gridindo.grdfile = '/drive/powellb/interp/ias20_grid_new.nc';
    gridindo.N       = 30;
    gridindo.thetas  = 5;
    gridindo.thetab  = 0.4;
%    gridindo.thetas  = 6.5;
%    gridindo.thetab  = 0;
%    gridindo.hc  = 19.999;
    gridindo.hc  = 29.0857;
    gridindo.cstfile ='/sdb/edl/ROMS-pak/ias20-data/ias_coast.mat';

  case 'ias40'
    gridindo.id      = gridid;
    gridindo.name    = 'Intra-america-sea 40km';
    gridindo.grdfile = '/sdb/edl/ROMS-pak/ias20-data/ias40_grid.nc';
    gridindo.N       = 30;
    gridindo.thetas  = 5;
    gridindo.thetab  = 0.4;
%    gridindo.thetas  = 6.5;
%    gridindo.thetab  = 0;
%    gridindo.hc  = 19.999;
    gridindo.hc  = 29.0857;
    gridindo.cstfile ='/sdb/edl/ROMS-pak/ias20-data/ias_coast.mat';





  case 'ias40_b'
    gridindo.id      = gridid;
    gridindo.name    = 'Intra-america-sea 40km';
    gridindo.grdfile = '/drive/powellb/interp/ias40_grid.nc';
    gridindo.N       = 30;
    gridindo.thetas  = 5;
    gridindo.thetab  = 0.4;
    gridindo.hc  = 29.0857;
    gridindo.cstfile ='/sdb/edl/ROMS-pak/ias20-data/ias_coast.mat';

  case 'ias20_b'
    gridindo.id      = gridid;
    gridindo.name    = 'Intra-america-sea 20km';
    gridindo.grdfile = '/drive/powellb/interp/ias20_grid.nc';
    gridindo.N       = 30;
    gridindo.thetas  = 5;
    gridindo.thetab  = 0.4;
    gridindo.hc  = 29.0857;
    gridindo.cstfile ='/sdb/edl/ROMS-pak/ias20-data/ias_coast.mat';



  case 'ias20-paleo'
    gridindo.id      = gridid;
    gridindo.name    = 'Intra-america-sea 20km';
    gridindo.grdfile = '/sdb/edl/ROMS-pak/ias20-data/ias20_grid-paleo.nc';
    gridindo.N       = 30;
    gridindo.thetas  = 5;
    gridindo.thetab  = 0.4;
%    gridindo.thetas  = 6.5;
%    gridindo.thetab  = 0;
    gridindo.hc  = 19.999;
    gridindo.cstfile ='/sdb/edl/ROMS-pak/ias20-data/ias_coast.mat';

 case 'ias10-no'
    gridindo.id      = gridid;
    gridindo.name    = 'Intra-america-sea 9km';
    gridindo.grdfile = '/sdb/edl/ROMS-pak/ias20-data/ias10-grid.nc';
    gridindo.N       = 30;
    gridindo.thetas  = 5;
    gridindo.thetab  = 0.4;
%    gridindo.thetas  = 6.5;
%    gridindo.thetab  = 0;
%    gridindo.hc  = 19.999;
    gridindo.cstfile ='/sdb/edl/ROMS-pak/ias20-data/ias_coast.mat';

  case 'ias_natl_ex'
    gridindo.id      = gridid;
    gridindo.name    = 'North Atlantic  IAS extract';
    gridindo.grdfile = '/sdb/edl/ROMS-pak/ias20-data/ias_natl_ex_grid.nc';
    gridindo.N       = 30;
    gridindo.thetas  = 5;
    gridindo.thetab  = 0.4;
    gridindo.tcline  = 200;
    gridindo.hc  = 20;
    gridindo.cstfile ='/sdb/edl/ROMS-pak/ias20-data/ias_coast.mat';


  case 'yuclow'
    gridindo.id      = gridid; 
    gridindo.name    = 'Caribbean Sea';
    gridindo.grdfile = '/sdb/edl/ROMS-pak/carib-data/yuclow-grid.nc';
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
    gridindo.grdfile = '/d6/edl/ROMS-pak/china-data/china-grid.nc';
    gridindo.N       = 20;
    gridindo.thetas  = 5;
    gridindo.thetab  = 0.4;
    gridindo.cstfile = '/d6/edl/ROMS-pak/Grid-pak/CoastlineWorldPacific.mat';

  case 'med'
    gridindo.id      = gridid;
    gridindo.name    = 'Mediterranean Sea';
    gridindo.grdfile = '/drive/edl/Mediterraneo/med-data/med-grid.nc';
    gridindo.N       = 30;
    gridindo.thetas  = 5;
    gridindo.thetab  = 0.4;
    gridindo.tcline  = 20;
    gridindo.cstfile = which('rgrd_medcoast.mat');

  case 'med8km'
    gridindo.id      = gridid;
    gridindo.name    = 'Mediterranean Sea';
    gridindo.grdfile = '/drive/edl/Mediterraneo/med-data/med8km-grid.nc';
    gridindo.N       = 30;
    gridindo.thetas  = 5;
    gridindo.thetab  = 0.4;
    gridindo.tcline  = 20;
    gridindo.cstfile = which('rgrd_medcoast.mat');

  case 'npacific'
    gridindo.id      = gridid;
    gridindo.name    = 'North Pacific';
    gridindo.grdfile = '/neo/GFD_Class/gfd_root/roms-examples/npacific/input/npacific-grid.nc';
    gridindo.N       = 30;
    gridindo.thetas  = 5;
    gridindo.hc  = 30;
    gridindo.thetab  = 0.4;

  case 'med_tmp'
    gridindo.id      = gridid;
    gridindo.name    = 'Mediterranean Sea';
    gridindo.grdfile = '/drive/edl/Mediterraneo/med-data/med_tmp-grid.nc';
    gridindo.N       = 30;
    gridindo.thetas  = 5;
    gridindo.thetab  = 0.4;
    gridindo.tcline  = 20;

            
  case 'bl'
    gridindo.id      = gridid;
    gridindo.name    = 'Boundary layer problem';
    gridindo.grdfile = '/d6/edl/ROMS-pak/bl-data/bl-grid.nc';
    gridindo.N       = 20;
    gridindo.thetas  = 5;
    gridindo.thetab  = 0.0;
    gridindo.cstfile = '/d6/edl/ROMS-pak/Grid-pak/CoastlineWorldPacific.mat';
    
  case 'pac25'
    gridindo.id      = gridid;
    gridindo.name    = 'Pacific';
    gridindo.grdfile = '/sdb/edl/ROMS-pak/pac25-data/pac25-grid.nc';
    gridindo.N       = 40;
    gridindo.thetas  = 6;
    gridindo.hc  = 50;
    gridindo.thetab  = 0.0;

  case 'usw25'
    gridindo.id      = gridid;
    gridindo.name    = 'Pacific 25 extract for CCS';
    gridindo.grdfile = '/sdb/edl/ROMS-pak/usw18-data/usw25-grid.nc';
    gridindo.N       = 26;
    gridindo.thetas  = 6;
    gridindo.hc  = 50; 
    gridindo.thetab  = 0.0;
    gridindo.cstfile='/d6/edl/ROMS-pak/matlib/rgrd/rgrd_CCS_CstLine.mat';

  case 'wc05a'
    gridindo.id      = gridid;
    gridindo.name    = 'Pacific 25 extract for CCS';
    gridindo.grdfile = '/pldb/edl/ROMS-pak/usw20-data/wc05a_grd.nc';
    gridindo.N       = 42;
    gridindo.thetas  = 5;
    gridindo.hc  = 10; 
    gridindo.thetab  = 0.4;
    gridindo.cstfile='/d6/edl/ROMS-pak/matlib/rgrd/rgrd_CCS_CstLine.mat';

 case 'usw25-2'
    gridindo.id      = gridid;
    gridindo.name    = 'Pacific 25 extract for CCS';
    gridindo.grdfile = '/pldb/edl/ROMS-pak/usw18-data/usw25-grid-2.nc';
    gridindo.N       = 26;
    gridindo.thetas  = 6;
    gridindo.hc  = 30; 
    gridindo.thetab  = 0.0;
    gridindo.cstfile='/d6/edl/ROMS-pak/matlib/rgrd/rgrd_CCS_CstLine.mat';



  case 'indian'
    gridindo.id      = gridid;
    gridindo.name    = 'Indian Ocean';
    gridindo.grdfile = '/sdb/home/dp/indian-data/indian-grid.nc';
    gridindo.N       = 20;
    gridindo.thetas  = 6;
    gridindo.thetab  = 0.0;

  case 'indiansc'
    gridindo.id      = gridid;
    gridindo.name    = 'Indian Ocean';
    gridindo.grdfile = '/sdb/home/dp/indian-data/indian-grid_noSC.nc';
    gridindo.N       = 20;
    gridindo.thetas  = 6;
    gridindo.thetab  = 0.0;
   
 case 'bengal'
    gridindo.id      = gridid;
    gridindo.name    = 'Bay of Bengal';
    gridindo.grdfile = '/drive/edl/INDIAN/bengal-data/bengal-grid.nc';
    gridindo.N       = 20;
    gridindo.thetas  = 6;
    gridindo.thetab  = 0.0;

case 'indo-pac'
    gridindo.id      = gridid;
    gridindo.name    = 'Indo-pacific';
    gridindo.grdfile = '/sdb/edl/ROMS-pak/indo-pac-data/indo-pac-grid.nc';
    gridindo.N       = 20;
    gridindo.thetas  = 6;
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

  case 'goap'
    gridindo.id      = gridid;
    gridindo.name    = 'GOA nested in Pacific';
    gridindo.grdfile = '/sdb/edl/ROMS-pak/goap-data/goap-grid.nc';
    gridindo.N       = 30;
    gridindo.thetas  = 6;
    gridindo.thetab  = 0.0;

  case 'haida'
    gridindo.id      = gridid;
    gridindo.name    = 'Haida nested in GOAP';
    gridindo.grdfile = '/neo/GOAP/haida-data/haida-grid.nc';
    gridindo.N       = 30;
    gridindo.thetas  = 6;
    gridindo.thetab  = 0.0;


  case 'goap2'
    gridindo.id      = gridid;
    gridindo.name    = 'GOA nested in Pacific';
    gridindo.grdfile = '/sdb/edl/ROMS-pak/goap-data/goap-grid.nc';
    gridindo.N       = 20;
    gridindo.thetas  = 6;
    gridindo.thetab  = 0.0;
 


  case 'nepd'
    gridindo.id      = gridid;
    gridindo.name    = 'NEPD-GOA-CCS grid';
    gridindo.grdfile = '/drive/edl/NEPD/nepd-data/nepd-grid.nc';
    gridindo.N       = 30;
    gridindo.thetas  = 5;
    gridindo.thetab  = 0.4;

  case 'nepd10'
    gridindo.id      = gridid;
    gridindo.name    = 'NEPD-GOA-CCS 10 KM grid';
    gridindo.grdfile = '/drive/edl/NEPD/nepd-data/nepd10-grid.nc';
    gridindo.N       = 30;
    gridindo.thetas  = 5;
    gridindo.thetab  = 0.4;


  case 'npac2'
    gridindo.id      = gridid;
    gridindo.name    = 'North Pacific 1/8 degree';
    gridindo.grdfile = '/drive/edl/NPAC/npac2-data/npac2-grid.nc';
    gridindo.N       = 42;
    gridindo.thetas  = 5;
    gridindo.thetab  = 0.4;


  case 'nep10'
    gridindo.id      = gridid;
    gridindo.name    = 'NEP 10 km new';
    gridindo.grdfile = '/neo/pascal/CCS/ccs10-data/nep10-grid.nc';
    gridindo.N       = 42;
    gridindo.thetas  = 5;
    gridindo.thetab  = 0.4;
    gridinfo.Tcline  = 50;
    gridinfo.hc      = 30;

  case 'np6'
    gridindo.id      = gridid;
    gridindo.name    = 'North Pacifci';
    gridindo.grdfile = '/neo/hyodae/roms-NP6-grid.nc';
    gridindo.N       = 30;
    gridindo.thetas  = 5;
    gridindo.thetab  = 0.4;
    gridinfo.Tcline  = 50;
    gridinfo.hc      = 10;

  case 'goan10'
    gridindo.id      = gridid;
    gridindo.name    = 'GOAN subextract of NEP 10 km ';
    gridindo.grdfile = '/neo/amm/GOAN10/ncdata/goan10-grid.nc';
    gridindo.N       = 42;
    gridindo.thetas  = 5;
    gridindo.thetab  = 0.4;
    gridinfo.Tcline  = 50;
    gridinfo.hc      = 30;

  case 'east-goa10'
    gridindo.id      = gridid;
    gridindo.name    = 'EAST-GOA subextract of NEP 10 km ';
    gridindo.grdfile = '/neo/vc/ncdata/east-goa10-grid.nc';
    gridindo.N       = 42;
    gridindo.thetas  = 5;
    gridindo.thetab  = 0.4;
    gridinfo.Tcline  = 50;
    gridinfo.hc      = 30;


  case 'ccs10'
    gridindo.id      = gridid;
    gridindo.name    = 'CCS extract of NEP 10 km new';
    gridindo.grdfile = '/neo/pascal/CCS/ccs10-data/ccs10-grid.nc';
    gridindo.N       = 42;
    gridindo.thetas  = 5;
    gridindo.thetab  = 0.4;
    gridinfo.Tcline  = 50;
    gridinfo.hc      = 30;


  case 'nepd-ccs'
    gridindo.id      = gridid;
    gridindo.name    = 'NEPD-CCS grid';
    gridindo.grdfile = '/drive/edl/NEPD/nepd-data/nepd-ccs-grid.nc';
    gridindo.N       = 30;
    gridindo.thetas  = 5;
    gridindo.thetab  = 0.4;

  case 'goa_east'
    gridindo.id      = gridid;
    gridindo.name    = 'GOA-CCS grid';
    gridindo.grdfile = '/sdb/home/vc/Vinz/goa_east-grid.nc';
    gridindo.N       = 30;
    gridindo.thetas  = 5;
    gridindo.thetab  = 0.4;



  case 'nepd2x'
    gridindo.id      = gridid;
    gridindo.name    = 'CCS grid';
    gridindo.grdfile = '/drive/edl/NEPD/nepd-data/nepd2x/nepd2x-grid.nc';
    gridindo.N       = 30;
    gridindo.thetas  = 5;
    gridindo.thetab  = 0.4;


  case 'alg'
    gridindo.id      = gridid;
    gridindo.name    = 'Algerian Coast ';
    gridindo.grdfile = '/drive/annalisa/alg/data/alg2_grd.nc';
    gridindo.N       = 20;
    gridindo.thetas  = 7;
    gridindo.thetab  = 0;

  case 'goap80'
    gridindo.id      = gridid;
    gridindo.name    = 'GOA nested in Pacific';
    gridindo.grdfile = '/sdd/VC/RUN_MODEL/Files/goap80-grid.nc';
    gridindo.N       = 30;
    gridindo.thetas  = 6;
    gridindo.thetab  = 0.0;

  case 'goap50'
    gridindo.id      = gridid;
    gridindo.name    = 'GOA nested in Pacific';
    gridindo.grdfile = '/sdd/VC/RUN_MODEL/Files/goap50-grid.nc';
    gridindo.N       = 30;
    gridindo.thetas  = 6;
    gridindo.thetab  = 0.0;





 case 'goap11'
    gridindo.id      = gridid;
    gridindo.name    = 'GOA nested in Pacific';
    gridindo.grdfile = '/sdd/VC/RUN_MODEL/Files/goap11-grid.nc';
    gridindo.N       = 30;
    gridindo.thetas  = 6;
    gridindo.thetab  = 0.0;



  case 'goan'
    gridindo.id      = gridid;
    gridindo.name    = 'GOA nested in Pacific';
    gridindo.grdfile = '/sdb/home/vc/GOA/goan-grid.nc';
    gridindo.N       = 30;
    gridindo.thetas  = 6;
    gridindo.thetab  = 0.4;
    gridindo.hc      = 100;

  case 'goan2'
    gridindo.id      = gridid;
    gridindo.name    = 'GOA nested in Pacific';
    gridindo.grdfile = '/sdb/home/vc/GOA/goan2-grid.nc';
    gridindo.N       = 30;
    gridindo.thetas  = 6;
    gridindo.thetab  = 0.4;
    gridindo.hc      = 100;

  case 'goantry'
    gridindo.id      = gridid;
    gridindo.name    = 'GOA nested in Pacific';
    gridindo.grdfile = '/sdb/home/vc/GOA/goantry-grid.nc';
    gridindo.N       = 20;
    gridindo.thetas  = 0.01;
    gridindo.thetab  = 1;
    gridindo.hc      = 100;



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
    gridindo.grdfile = '/sdb/edl/foreman/data/queen8-grid.nc';
    gridindo.N       = 20;
    gridindo.thetas  = 7;
    gridindo.thetab  = 0;
    gridindo.tcline  = 50;
    gridindo.cstfile = '/sdb/edl/foreman/grid/ga8_COAST.mat';
    
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
    gridindo.grdfile = '/wd3/edl/GOA/goa-grid.nc';
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
    gridindo.grdfile = '/sdb/edl/foreman/data/goaft-grid.nc';
    gridindo.N       = 20;
    gridindo.thetas  = 5;
    gridindo.thetab  = 0.4;
    gridindo.tcline  = 50;
    gridindo.cstfile = '/d1/manu/foreman/grid/ga8_COAST.mat';

  case 'test_goa'
    gridindo.id      = gridid;
    gridindo.name    = 'Gulf of Alaska Doug';
    gridindo.grdfile = '/sdd/VC/RUN_MODEL/Files/test_goa.nc';
    gridindo.N       = 20;
    gridindo.thetas  = 5;
    gridindo.thetab  = 0.4;
    gridindo.tcline  = 50;
    gridindo.cstfile = '/d1/manu/foreman/grid/ga8_COAST.mat';

  case 'goa80'
    gridindo.id      = gridid;
    gridindo.name    = 'Gulf of Alaska 80 km';
    gridindo.grdfile = '/sdd/VC/RUN_MODEL/Files/goa80-grid.nc';
    gridindo.N       = 20;
    gridindo.thetas  = 5;
    gridindo.thetab  = 0.4;
    gridindo.tcline  = 50;
    gridindo.cstfile = '/d1/manu/foreman/grid/ga8_COAST.mat';

  case 'goa50'
    gridindo.id      = gridid;
    gridindo.name    = 'Gulf of Alaska 50 km';
    gridindo.grdfile = '/sdd/VC/RUN_MODEL/Files/goa50-grid.nc';
    gridindo.N       = 20;
    gridindo.thetas  = 5;
    gridindo.thetab  = 0.4;
    gridindo.tcline  = 50;
    gridindo.cstfile = '/d1/manu/foreman/grid/ga8_COAST.mat';


 case 'goa_open'
    gridindo.id      = gridid;
    gridindo.name    = 'Gulf of Alaska Doug';
    gridindo.grdfile = '/sdd/VC/RUN_MODEL/Files/goa_open.nc';
    gridindo.N       = 20;
    gridindo.thetas  = 5;
    gridindo.thetab  = 0.4;
    gridindo.tcline  = 50;
    gridindo.cstfile = '/d1/manu/foreman/grid/ga8_COAST.mat';

 case 'alaska'
    gridindo.id      = gridid;
    gridindo.name    = 'Gulf of Alaska';
    gridindo.grdfile = '/sdd/VC/RUN_MODEL/Files/alaska-grid.nc';
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

  case 'floridaST'
    gridindo.id      = gridid;
    gridindo.name    = 'Florida Str.  ';
    gridindo.grdfile = '/sdb/wd3/edl/ROMS-pak/floridaST-data/floridaST-grid.nc';
    gridindo.N       = 30;
    gridindo.thetas  = 5;
    gridindo.thetab  = 0.4;
    gridindo.tcline  = 200;
    gridindo.cstfile = '/d6/edl/ROMS-pak/Grid-pak/CoastlineWorld.mat';
    
  case 'gm'
    gridindo.id      = gridid;
    gridindo.name    = 'Gulf of Mexico  ';
    gridindo.grdfile = '/sdb/edl/ROMS-pak/gm-data/gm-grid.nc';
    gridindo.N       = 30;
    gridindo.thetas  = 5;
    gridindo.thetab  = 0.4;
    gridindo.tcline  = 200;
    gridindo.cstfile = '/d6/edl/ROMS-pak/Grid-pak/CoastlineWorld.mat';
    
  case 'bengal-old'
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

case 'acc-channel'
    gridindo.id      = gridid;
    gridindo.name    = 'Antartic Circ. Current - analytical channel grid';
    gridindo.grdfile = '/sdc/raf/ACC/run/ACC_gridinfo.nc';
%    gridindo.grdfile = '/sdc/raf/ACC/run/ACC-his.nc';
    gridindo.N       = 36;
    gridindo.thetas  = 5;
    gridindo.thetab  = 0.4;
      
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

    
  case 'scb-ch'
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
    gridindo.cstfile = '/sdb/manu/foreman/grid/bigcoast.mat';

  case 'line90_flat'
    gridindo.id      = gridid;
    gridindo.name    = 'CalCOFI obs. grid';
    gridindo.grdfile = '/drive/edl/NEPD/biology/line90_flat-grid.nc';
    gridindo.N       = 30;
    gridindo.thetas  = 6;
    gridindo.thetab  = 0.4;
    gridindo.tcline  = 50;
    gridindo.cstfile = '/sdb/manu/foreman/grid/bigcoast.mat';
        
  case 'calc'
    gridindo.id      = gridid;
    gridindo.name    = 'CalCOFI grid - Manu';
    gridindo.grdfile = which('grid-calcofi.nc');
    gridindo.N       = 20;
    gridindo.thetas  = 5;
    gridindo.thetab  = 0.4;
    gridindo.tcline  = 200;
    gridindo.cstfile = '/sdb/edl/foreman/grid/bigcoast.mat';
    
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
    gridindo.grdfile = '/d6/edl/ROMS-pak/sccoos-data/grids/sccoos-grid.nc';
    gridindo.N       = 30;
    gridindo.thetas  = 5;
    gridindo.thetab  = 0.2;
    gridindo.tcline  = 200;
    gridindo.cstfile = '/d6/edl/ROMS-pak/sccoos-data/grids/sccoos-coast.mat';
    
  case 'sccoos1'
    gridindo.id      = gridid;
    gridindo.name    = 'SCCOOS 2.5 km';
    gridindo.grdfile = '/d6/edl/ROMS-pak/sccoos-data/grids/sccoos-grid.nc.1';
    gridindo.N       = 30;
    gridindo.thetas  = 5;
    gridindo.thetab  = 0.2;
    gridindo.tcline  = 200;
    gridindo.cstfile = '/d6/edl/ROMS-pak/sccoos-data/grids/sccoos-coast.mat';
    
  case 'sccoos2'
    gridindo.id      = gridid;
    gridindo.name    = 'SCCOOS 600 m';
    gridindo.grdfile = '/d6/edl/ROMS-pak/sccoos-data/grids/sccoos-grid.nc.2';
    gridindo.N       = 30;
    gridindo.thetas  = 5;
    gridindo.thetab  = 0.2;
    gridindo.tcline  = 200;
    gridindo.cstfile = '/d6/edl/ROMS-pak/sccoos-data/grids/sccoos-coast.mat';

    case 'sccoos1-low'
    gridindo.id      = gridid;
    gridindo.name    = 'SCCOOS 2.5 km';
    gridindo.grdfile ='/d6/edl/ROMS-pak/sccoos-data/grids/lowres/sccoos-grid.nc.1.lo';
    gridindo.N       = 30;
    gridindo.thetas  = 5;
    gridindo.thetab  = 0.2;
    gridindo.tcline  = 200;
    gridindo.cstfile = '/d6/edl/ROMS-pak/sccoos-data/grids/sccoos-coast.mat';
    
  case 'sccoos2-low'
    gridindo.id      = gridid;
    gridindo.name    = 'SCCOOS 600 m';
    gridindo.grdfile = '/d6/edl/ROMS-pak/sccoos-data/grids/lowres/sccoos-grid.nc.2.lo';
    gridindo.N       = 30;
    gridindo.thetas  = 5;
    gridindo.thetab  = 0.2;
    gridindo.tcline  = 200;
    gridindo.cstfile = '/d6/edl/ROMS-pak/sccoos-data/grids/sccoos-coast.mat';


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
    
 case 'sdroms'
    gridindo.id      = gridid;
    gridindo.name    = 'SDROMS 600 m';
    gridindo.grdfile = '/d6/edl/ROMS-pak/sccoos-data/grids/sdroms-grid.nc';
    gridindo.N       = 30;
    gridindo.thetas  = 3;
    gridindo.thetab  = 0.2;
    gridindo.tcline  = 100;
    gridindo.cstfile = '/d6/edl/ROMS-pak/sccoos-data/grids/sdcoast.mat';

 case 'scroms'
    gridindo.id      = gridid;
    gridindo.name    = 'SCROMS ';
    gridindo.grdfile = '/d6/edl/ROMS-pak/sccoos-data/grids/scroms-grid.nc';
    gridindo.N       = 30;
    gridindo.thetas  = 3;
    gridindo.thetab  = 0.2;
    gridindo.tcline  = 100;
    gridindo.cstfile = '/d6/edl/ROMS-pak/sccoos-data/grids/socal_coast.mat';

         
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

