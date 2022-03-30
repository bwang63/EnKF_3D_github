function ncini=create_inifile(inifile,gridfile,parentfile,title,...
                              theta_s,theta_b,Tcline,N,time,clobber)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright (c) 2000 IRD                                          %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                 %
%                                                                 %
%  function ncini=create_inifile(inifile,gridfile,theta_s,...  %
%                  theta_b,Tcline,N,ttime,stime,utime,...         %
%                  cycle,clobber)                                 %
%                                                                 %
%                                                                 %
%   This function create the header of a Netcdf climatology       %
%   file.                                                         %
%                                                                 %
%                                                                 %
%   Input:                                                        %
%                                                                 %
%   inifile      Netcdf initial file name (character string).     %
%   gridfile     Netcdf grid file name (character string).        %
%   theta_s      S-coordinate surface control parameter.(Real)    % 
%   theta_b      S-coordinate bottom control parameter.(Real)     %
%   Tcline       Width (m) of surface or bottom boundary layer    %
%                where higher vertical resolution is required     %
%                during stretching.(Real)                         %
%   N            Number of vertical levels.(Integer)              %
%   time         Initial time.(Real)                              %
%   clobber      Switch to allow or not writing over an existing  %
%                file.(character string)                          %
%                                                                 %
%                                                                 %
%   Output                                                        %
%                                                                 %
%   ncini       Output netcdf object.                             %
%                                                                 %
%                                                                 %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp(' ')
disp(' ')
disp(['Creating the file : ',inifile])
disp(' ')
%
%  Read the grid file
%
ncgrid = netcdf(gridfile, 'nowrite');
theVar = ncgrid{'h'};
h = theVar(:);  
status=close(ncgrid);
[Mp,Lp]=size(h);
L=Lp-1;
M=Mp-1;
Np=N+1;
%
%  Create the initial file
%
type = 'INITIAL file' ; 
history = 'ROMS' ;
ncini = netcdf(inifile,clobber);
result = redef(ncini);
%
%  Create dimensions
%
ncini('xi_u') = L;
ncini('xi_v') = Lp;
ncini('xi_rho') = Lp;
ncini('eta_u') = Mp;
ncini('eta_v') = M;
ncini('eta_rho') = Mp;
ncini('s_rho') = N;
ncini('s_w') = Np;
ncini('tracer') = 2;
ncini('time') = 0;
ncini('one') = 1;
%
%  Create variables
%
ncini{'tstart'} = ncdouble('one') ;
ncini{'tend'} = ncdouble('one') ;
ncini{'theta_s'} = ncdouble('one') ;
ncini{'theta_b'} = ncdouble('one') ;
ncini{'Tcline'} = ncdouble('one') ;
ncini{'hc'} = ncdouble('one') ;
ncini{'sc_r'} = ncdouble('s_rho') ;
ncini{'Cs_r'} = ncdouble('s_rho') ;
ncini{'scrum_time'} = ncdouble('time') ;
ncini{'u'} = ncdouble('time','s_rho','eta_u','xi_u') ;
ncini{'v'} = ncdouble('time','s_rho','eta_v','xi_v') ;
ncini{'ubar'} = ncdouble('time','eta_u','xi_u') ;
ncini{'vbar'} = ncdouble('time','eta_v','xi_v') ;
ncini{'zeta'} = ncdouble('time','eta_rho','xi_rho') ;
ncini{'temp'} = ncdouble('time','s_rho','eta_rho','xi_rho') ;
ncini{'salt'} = ncdouble('time','s_rho','eta_rho','xi_rho') ;
%
%  Create attributes
%
ncini{'tstart'}.long_name = ncchar('start processing day');
ncini{'tstart'}.long_name = 'start processing day';
ncini{'tstart'}.units = ncchar('day');
ncini{'tstart'}.units = 'day';
%
ncini{'tend'}.long_name = ncchar('end processing day');
ncini{'tend'}.long_name = 'end processing day';
ncini{'tend'}.units = ncchar('day');
ncini{'tend'}.units = 'day';
%
ncini{'theta_s'}.long_name = ncchar('S-coordinate surface control parameter');
ncini{'theta_s'}.long_name = 'S-coordinate surface control parameter';
ncini{'theta_s'}.units = ncchar('nondimensional');
ncini{'theta_s'}.units = 'nondimensional';
%
ncini{'theta_b'}.long_name = ncchar('S-coordinate bottom control parameter');
ncini{'theta_b'}.long_name = 'S-coordinate bottom control parameter';
ncini{'theta_b'}.units = ncchar('nondimensional');
ncini{'theta_b'}.units = 'nondimensional';
%
ncini{'Tcline'}.long_name = ncchar('S-coordinate surface/bottom layer width');
ncini{'Tcline'}.long_name = 'S-coordinate surface/bottom layer width';
ncini{'Tcline'}.units = ncchar('meter');
ncini{'Tcline'}.units = 'meter';
%
ncini{'hc'}.long_name = ncchar('S-coordinate parameter, critical depth');
ncini{'hc'}.long_name = 'S-coordinate parameter, critical depth';
ncini{'hc'}.units = ncchar('meter');
ncini{'hc'}.units = 'meter';
%
ncini{'sc_r'}.long_name = ncchar('S-coordinate at RHO-points');
ncini{'sc_r'}.long_name = 'S-coordinate at RHO-points';
ncini{'sc_r'}.units = ncchar('nondimensional');
ncini{'sc_r'}.units = 'nondimensional';
ncini{'sc_r'}.valid_min = -1;
ncini{'sc_r'}.valid_max = 0;
ncini{'sc_r'}.field = ncchar('sc_r, scalar');
ncini{'sc_r'}.field = 'sc_r, scalar';
%
ncini{'Cs_r'}.long_name = ncchar('S-coordinate stretching curves at RHO-points');
ncini{'Cs_r'}.long_name = 'S-coordinate stretching curves at RHO-points';
ncini{'Cs_r'}.units = ncchar('nondimensional');
ncini{'Cs_r'}.units = 'nondimensional';
ncini{'Cs_r'}.valid_min = -1;
ncini{'Cs_r'}.valid_max = 0;
ncini{'Cs_r'}.field = ncchar('Cs_r, scalar');
ncini{'Cs_r'}.field = 'Cs_r, scalar';
%
ncini{'scrum_time'}.long_name = ncchar('time since initialization');
ncini{'scrum_time'}.long_name = 'time since initialization';
ncini{'scrum_time'}.units = ncchar('second');
ncini{'scrum_time'}.units = 'second';
ncini{'scrum_time'}.field = ncchar('time, scalar, series');
ncini{'scrum_time'}.field = 'time, scalar, series'  ;
%
ncini{'u'}.long_name = ncchar('u-momentum component');
ncini{'u'}.long_name = 'u-momentum component';
ncini{'u'}.units = ncchar('meter second-1');
ncini{'u'}.units = 'meter second-1';
ncini{'u'}.field = ncchar('u-velocity, scalar, series');
ncini{'u'}.field = 'u-velocity, scalar, series';
%
ncini{'v'}.long_name = ncchar('v-momentum component');
ncini{'v'}.long_name = 'v-momentum component';
ncini{'v'}.units = ncchar('meter second-1');
ncini{'v'}.units = 'meter second-1';
ncini{'v'}.field = ncchar('v-velocity, scalar, series');
ncini{'v'}.field = 'v-velocity, scalar, series';
%
ncini{'ubar'}.long_name = ncchar('vertically integrated u-momentum component');
ncini{'ubar'}.long_name = 'vertically integrated u-momentum component';
ncini{'ubar'}.units = ncchar('meter second-1');
ncini{'ubar'}.units = 'meter second-1';
ncini{'ubar'}.field = ncchar('ubar-velocity, scalar, series');
ncini{'ubar'}.field = 'ubar-velocity, scalar, series';
%
ncini{'vbar'}.long_name = ncchar('vertically integrated v-momentum component');
ncini{'vbar'}.long_name = 'vertically integrated v-momentum component';
ncini{'vbar'}.units = ncchar('meter second-1');
ncini{'vbar'}.units = 'meter second-1';
ncini{'vbar'}.field = ncchar('vbar-velocity, scalar, series');
ncini{'vbar'}.field = 'vbar-velocity, scalar, series';
%
ncini{'zeta'}.long_name = ncchar('free-surface');
ncini{'zeta'}.long_name = 'free-surface';
ncini{'zeta'}.units = ncchar('meter');
ncini{'zeta'}.units = 'meter';
ncini{'zeta'}.field = ncchar('free-surface, scalar, series');
ncini{'zeta'}.field = 'free-surface, scalar, series';
%
ncini{'temp'}.long_name = ncchar('potential temperature');
ncini{'temp'}.long_name = 'potential temperature';
ncini{'temp'}.units = ncchar('Celsius');
ncini{'temp'}.units = 'Celsius';
ncini{'temp'}.field = ncchar('temperature, scalar, series');
ncini{'temp'}.field = 'temperature, scalar, series';
%
ncini{'salt'}.long_name = ncchar('salinity');
ncini{'salt'}.long_name = 'salinity';
ncini{'salt'}.units = ncchar('PSU');
ncini{'salt'}.units = 'PSU';
ncini{'salt'}.field = ncchar('salinity, scalar, series');
ncini{'salt'}.field = 'salinity, scalar, series';
%
% Create global attributes
%
ncini.title = ncchar(title);
ncini.title = title;
ncini.date = ncchar(date);
ncini.date = date;
ncini.clim_file = ncchar(inifile);
ncini.clim_file = inifile;
ncini.grd_file = ncchar(gridfile);
ncini.grd_file = gridfile;
ncini.parent_file = ncchar(parentfile);
ncini.parent_file = parentfile;
ncini.type = ncchar(type);
ncini.type = type;
ncini.history = ncchar(history);
ncini.history = history;
%
% Leave define mode
%
result = endef(ncini);
%
% Compute S coordinates
%
ds=1.0/N;
hmin=min(min(h));
hc=min(hmin,Tcline);
lev=1:N;
sc=-1+(lev-0.5).*ds;
Ptheta=sinh(theta_s.*sc)./sinh(theta_s);
Rtheta=tanh(theta_s.*(sc+0.5))./(2*tanh(0.5*theta_s))-0.5;
Cs=(1-theta_b).*Ptheta+theta_b.*Rtheta;
%
% Write variables
%
theVar = ncini{'tstart'};
theVar(:) =  time/(24*3600); 
theVar = ncini{'tend'};
theVar(:) =  time/(24*3600); 
theVar = ncini{'theta_s'};
theVar(:) =  theta_s; 
theVar = ncini{'theta_b'};
theVar(:) =  theta_b; 
theVar = ncini{'Tcline'};
theVar(:) =  Tcline; 
theVar = ncini{'hc'};
theVar(:) =  hc; 
theVar = ncini{'sc_r'};
theVar(:) =  sc; 
theVar = ncini{'Cs_r'};
theVar(:) =  Cs; 
theVar = ncini{'scrum_time'};
theVar(1) =  time; 
theVar = ncini{'u'};
theVar(:) =  0; 
theVar = ncini{'v'};
theVar(:) =  0; 
theVar = ncini{'zeta'};
theVar(:) =  0; 
theVar = ncini{'ubar'};
theVar(:) =  0; 
theVar = ncini{'vbar'};
theVar(:) =  0; 
theVar = ncini{'temp'};
theVar(:) =  0; 
theVar = ncini{'salt'};
theVar(:) =  0; 
%
% Synchronize on disk
%
result = sync(ncini);
return


