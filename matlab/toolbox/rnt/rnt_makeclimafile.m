function rnt_makeclimafile(grd,climfile); 
%% ncdump('clim-levitus.nc')   %% Generated 07-Sep-2002 14:31:03
 
nc = netcdf(climfile, 'clobber');
if isempty(nc), return, end
 
%% Global attributes:
 
nc.type = ncchar('');
nc.title = ncchar('');
nc.out_file = ncchar('');
nc.grd_file = ncchar('');
nc.history = ncchar('');
 
%% Dimensions:
%% Dimensions:
nc('xi_rho') = grd.Lp;
nc('xi_u') = grd.L;
nc('xi_v') = grd.Lp;
nc('eta_rho') = grd.Mp;
nc('eta_u') = grd.Mp;
nc('eta_v') = grd.M;
nc('s_rho') = grd.N;
nc('s_w') = grd.N+1;
 
nc('tracer') = 2;
nc('tclm_time') = 12;
nc('sclm_time') = 12;
nc('ssh_time') = 12;
nc('uclm_time') = 12;
nc('vclm_time') = 12;
 
%% Variables and attributes:
 
nc{'job'} = nclong; %% 1 element.
nc{'job'}.long_name = ncchar('processing job type');
nc{'job'}.option_0 = ncchar('initial tracer fields, zero momentum');
nc{'job'}.option_1 = ncchar('tracer fields climatology');
 
nc{'vintrp'} = nclong; %% 1 element.
nc{'vintrp'}.long_name = ncchar('vertical interpolation switch');
nc{'vintrp'}.option_0 = ncchar('linear');
nc{'vintrp'}.option_1 = ncchar('cubic spline');
 
nc{'tstart'} = ncdouble; %% 1 element.
nc{'tstart'}.long_name = ncchar('start processing day');
nc{'tstart'}.units = ncchar('day');
 
nc{'tend'} = ncdouble; %% 1 element.
nc{'tend'}.long_name = ncchar('end processing day');
nc{'tend'}.units = ncchar('day');
 
nc{'theta_s'} = ncdouble; %% 1 element.
nc{'theta_s'}.long_name = ncchar('S-coordinate surface control parameter');
nc{'theta_s'}.units = ncchar('nondimensional');
 
nc{'theta_b'} = ncdouble; %% 1 element.
nc{'theta_b'}.long_name = ncchar('S-coordinate bottom control parameter');
nc{'theta_b'}.units = ncchar('nondimensional');
 
nc{'Tcline'} = ncdouble; %% 1 element.
nc{'Tcline'}.long_name = ncchar('S-coordinate surface/bottom layer width');
nc{'Tcline'}.units = ncchar('meter');
 
nc{'hc'} = ncdouble; %% 1 element.
nc{'hc'}.long_name = ncchar('S-coordinate parameter, critical depth');
nc{'hc'}.units = ncchar('meter');
 
nc{'sc_r'} = ncdouble('s_rho'); %% 20 elements.
nc{'sc_r'}.long_name = ncchar('S-coordinate at RHO-points');
nc{'sc_r'}.units = ncchar('nondimensional');
nc{'sc_r'}.valid_min = ncdouble(-1);
nc{'sc_r'}.valid_max = ncdouble(0);
nc{'sc_r'}.field = ncchar('sc_r, scalar');
 
nc{'sc_w'} = ncdouble('s_w'); %% 21 elements.
nc{'sc_w'}.long_name = ncchar('S-coordinate at W-points');
nc{'sc_w'}.units = ncchar('nondimensional');
nc{'sc_w'}.valid_min = ncdouble(-1);
nc{'sc_w'}.valid_max = ncdouble(0);
nc{'sc_w'}.field = ncchar('sc_w, scalar');
 
nc{'Cs_r'} = ncdouble('s_rho'); %% 20 elements.
nc{'Cs_r'}.long_name = ncchar('S-coordinate stretching curves at RHO-points');
nc{'Cs_r'}.units = ncchar('nondimensional');
nc{'Cs_r'}.valid_min = ncdouble(-1);
nc{'Cs_r'}.valid_max = ncdouble(0);
nc{'Cs_r'}.field = ncchar('Cs_r, scalar');
 
nc{'Cs_w'} = ncdouble('s_w'); %% 21 elements.
nc{'Cs_w'}.long_name = ncchar('S-coordinate stretching curves at W-points');
nc{'Cs_w'}.units = ncchar('nondimensional');
nc{'Cs_w'}.valid_min = ncdouble(-1);
nc{'Cs_w'}.valid_max = ncdouble(0);
nc{'Cs_w'}.field = ncchar('Cs_w, scalar');
 
nc{'tclm_time'} = ncdouble('tclm_time'); %% 12 elements.
nc{'tclm_time'}.long_name = ncchar('time for temperature climatology');
nc{'tclm_time'}.units = ncchar('day');
nc{'tclm_time'}.cycle_length = ncdouble(360);
nc{'tclm_time'}.field = ncchar('tclm_time, scalar, series  ');
 
nc{'sclm_time'} = ncdouble('sclm_time'); %% 12 elements.
nc{'sclm_time'}.long_name = ncchar('time for salinity climatology');
nc{'sclm_time'}.units = ncchar('day');
nc{'sclm_time'}.cycle_length = ncdouble(360);
nc{'sclm_time'}.field = ncchar('sclm_time, scalar, serie');
 
nc{'temp'} = ncdouble('tclm_time', 's_rho', 'eta_rho', 'xi_rho'); %% 2304000 elements.
nc{'temp'}.long_name = ncchar('potential temperature');
nc{'temp'}.units = ncchar('Celsius');
nc{'temp'}.field = ncchar('temperature, scalar, series');
nc{'temp'}.time = ncchar('tclm_time');
 
nc{'salt'} = ncdouble('sclm_time', 's_rho', 'eta_rho', 'xi_rho'); %% 2304000 elements.
nc{'salt'}.long_name = ncchar('salinity');
nc{'salt'}.units = ncchar('PSU');
nc{'salt'}.field = ncchar('salinity, scalar, series');
nc{'salt'}.time = ncchar('sclm_time');
 
nc{'ssh_time'} = ncdouble('ssh_time'); %% 12 elements.
nc{'ssh_time'}.long_name = ncchar('time for sea surface height');
nc{'ssh_time'}.units = ncchar('day');
nc{'ssh_time'}.cycle_length = ncdouble(360);
nc{'ssh_time'}.field = ncchar('ssh_time, scalar, series');
 
nc{'zeta'} = ncdouble('ssh_time', 'eta_rho', 'xi_rho'); %% 115200 elements.
nc{'zeta'}.long_name = ncchar('sea surface height');
nc{'zeta'}.units = ncchar('meter');
nc{'zeta'}.field = ncchar('SSH, scalar, series');
nc{'zeta'}.time = ncchar('ssh_time');
 
nc{'uclm_time'} = ncdouble('uclm_time'); %% 12 elements.
nc{'uclm_time'}.long_name = ncchar('time climatological u');
nc{'uclm_time'}.units = ncchar('day');
nc{'uclm_time'}.cycle_length = ncdouble(360);
nc{'uclm_time'}.field = ncchar('uclm_time, scalar, serie');
 
nc{'ubar'} = ncdouble('uclm_time', 'eta_u', 'xi_u'); %% 113760 elements.
nc{'ubar'}.long_name = ncchar('vertically integrated u-momentum component');
nc{'ubar'}.units = ncchar('meter second-1');
nc{'ubar'}.field = ncchar('ubar-velocity, scalar, serie');
nc{'ubar'}.time = ncchar('uclm_time');
 
nc{'vclm_time'} = ncdouble('vclm_time'); %% 12 elements.
nc{'vclm_time'}.long_name = ncchar('time climatological v');
nc{'vclm_time'}.units = ncchar('day');
nc{'vclm_time'}.cycle_length = ncdouble(360);
nc{'vclm_time'}.field = ncchar('vclm_time, scalar, serie');
 
nc{'vbar'} = ncdouble('vclm_time', 'eta_v', 'xi_v'); %% 114240 elements.
nc{'vbar'}.long_name = ncchar('vertically integrated v-momentum component');
nc{'vbar'}.units = ncchar('meter second-1');
nc{'vbar'}.field = ncchar('vbar-velocity, scalar, serie');
nc{'vbar'}.time = ncchar('vclm_time');
 
nc{'u'} = ncdouble('uclm_time', 's_rho', 'eta_u', 'xi_u'); %% 2275200 elements.
nc{'u'}.long_name = ncchar('u-momentum component');
nc{'u'}.units = ncchar('meter second-1');
nc{'u'}.field = ncchar('u-velocity, scalar, serie');
nc{'u'}.time = ncchar('uclm_time');
 
nc{'v'} = ncdouble('vclm_time', 's_rho', 'eta_v', 'xi_v'); %% 2284800 elements.
nc{'v'}.long_name = ncchar('v-momentum component');
nc{'v'}.units = ncchar('meter second-1');
nc{'v'}.field = ncchar('v-velocity, scalar, serie');
nc{'v'}.time = ncchar('vclm_time');
 
endef(nc)
close(nc)
