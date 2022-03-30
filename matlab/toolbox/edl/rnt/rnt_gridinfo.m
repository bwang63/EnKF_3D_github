% (R)oms (N)umerical (T)oolbox
% 
% FUNCTION grdinfo = rnt_gridinfo(gridid)
%
% Loads the grid configuration for gridid
% To add new grid please edit this file.
%
% Example: CalCOFI application
%
%    grdinfo = rnt_gridinfo('calc')
%
% RNT - E. Di Lorenzo (edl@ucsd.edu)

function gridindo=rnt_gridinfo(gridid)

% initialize
       gridindo.id      = gridid;
       gridindo.name    = '';
       gridindo.grdfile = '';	 	 
	 gridindo.N       = 0;
       gridindo.thetas  = 0;  
       gridindo.thetab  = 0;  	 	 
       gridindo.tcline  = 0;
	 gridindo.cstfile = '';


    switch gridid
    case 'creta'
       gridindo.id      = gridid;
       gridindo.name    = 'Creta';
       gridindo.grdfile = '/d1/manu/creta/data/creta-grid.nc';	 	 
	 gridindo.N       = 30;
       gridindo.thetas  = 5;  
       gridindo.thetab  = 0.4;  	 	 
       gridindo.tcline  = 20;
	 gridindo.cstfile = '/d1/manu/creta/data/creta_coastline.mat';

    case 'japan'
       gridindo.id      = gridid;
       gridindo.name    = 'Japan';
       gridindo.grdfile = '/d1/manu/japan/data/japan-grid.nc';
         gridindo.N       = 30;
       gridindo.thetas  = 5;
       gridindo.thetab  = 0.4;
       gridindo.tcline  = 20;
         gridindo.cstfile = '/d1/manu/japan/grid/PacificCoast.mat';


    case 'nwp'
       gridindo.id      = gridid;
       gridindo.name    = 'North East Pacific';
       gridindo.grdfile = '/d1/manu/japan/data/nwp-grid.nc';
         gridindo.N       = 30;
       gridindo.thetas  = 5;
       gridindo.thetab  = 0.4;
       gridindo.tcline  = 20;
         gridindo.cstfile = '/d1/manu/japan/grid/PacificCoast.mat';


    case 'scb'
       gridindo.id      = gridid;
       gridindo.name    = 'CalCOFI TEST';
       gridindo.grdfile = '/d1/manu/sbchannel/seagrid/grid-bight.nc';
         gridindo.N       = 20;
       gridindo.thetas  = 7;
       gridindo.thetab  = 0;
       gridindo.tcline  = 200;
         gridindo.cstfile = '/d1/manu/foreman/grid/bigcoast.mat';


    case 'sdm'
       gridindo.id      = gridid;
       gridindo.name    = 'San Diego Modeling';
       gridindo.grdfile = '/d1/manu/SDM/sdm-grid.nc';
         gridindo.N       = 20;
       gridindo.thetas  = 7;
       gridindo.thetab  = 0;
       gridindo.tcline  = 200;
         gridindo.cstfile = '/d1/manu/foreman/grid/bigcoast.mat';



    case 'med'
       gridindo.id      = gridid;
       gridindo.name    = 'Mediterranean Sea';
       gridindo.grdfile = '/d1/manu/creta/data/med-grid.nc';
         gridindo.N       = 30;
       gridindo.thetas  = 5;
       gridindo.thetab  = 0.4;
       gridindo.tcline  = 20;
         gridindo.cstfile = '/d1/manu/creta/data/med_coastline.mat';

    
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

    case 'queen8'
       gridindo.id      = gridid;
       gridindo.name    = 'Queen Island Application 8 km res.';
       gridindo.grdfile = '/d1/manu/foreman/data/queen8-grid.nc';
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
       gridindo.grdfile = '/d1/manu/sbchannel/seagrid/Line90Grid.nc';
	 gridindo.N       = 20;
       gridindo.thetas  = 7;  
       gridindo.thetab  = 0;  	 	 
       gridindo.tcline  = 200;
	 gridindo.cstfile = '/d1/manu/foreman/grid/bigcoast.mat';

    case 'goa10'
       gridindo.id      = gridid;
       gridindo.name    = 'Gulf of Alaska 10 km';
       gridindo.grdfile = '/d1/manu/GOA/CGOA-3/goad10_grid.nc';
	 gridindo.N       = 20;
       gridindo.thetas  = 5;  
       gridindo.thetab  = 0.4;  	 	 
       gridindo.tcline  = 200;
	 
    case 'goa'
       gridindo.id      = gridid;
       gridindo.name    = 'Gulf of Alaska 3 km - Kate';
       gridindo.grdfile = '/d1/kate/CGOA_grid_3.nc';
	 gridindo.N       = 30;
       gridindo.thetas  = 5;  
       gridindo.thetab  = 0.4;  	 	 
       gridindo.tcline  = 200;
	 
    case 'calc'
       gridindo.id      = gridid;
       gridindo.name    = 'CalCOFI grid - Manu';
       gridindo.grdfile = '/d1/manu/matlib/rnt/grid-calcofi.nc';
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

