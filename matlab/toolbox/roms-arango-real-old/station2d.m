function [T,f]=station2d(fname,vname,ista);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright (c) 1997 Rutgers University.                                    %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                           %
% function [t,f]=station2d(fname,vname,ista);                               %
%                                                                           %
% This function reads in and plots the requested variable from the          %
% stations NetCDF.                                                          %
%                                                                           %
% On Input:                                                                 %
%                                                                           %
%    fname       NetCDF Stations file name (character string).              %
%    vname       NetCDF variable name to read (character string).           %
%    ista        Station index to process (integer).                        %
%                                                                           %
% On Output:                                                                %
%                                                                           %
%    T           time (vector).                                             %
%    f           Field (vector).                                            %
%                                                                           %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Get number of stations.

h=nc_read(fname,'h',0);
nsta=length(h);

if (ista < 1 | ista > nsta),
  disp(' ');
  disp([setstr(7),'*** Error:  STATION2D - illegal station index.',setstr(7)]);
  disp([setstr(7),'                        valid range:  1 <= ista <= ',...
        num2str(nsta),setstr(7)]);
  disp(' ');
  return
end,

%----------------------------------------------------------------------------
% Read in requested field.
%----------------------------------------------------------------------------

w=nc_read(fname,vname,0);
t=nc_read(fname,'scrum_time',0);
dstart=nc_read(fname,'dstart',0);
lon=nc_read(fname,'lon_rho',0);
lat=nc_read(fname,'lat_rho',0);

%----------------------------------------------------------------------------
% Extract station data to analize.
%----------------------------------------------------------------------------

if (vname == 'zeta'),
  f=w(ista,:);
  TITLE1=['Sea Surface Height (m), station = ', num2str(ista)];
  YLABEL=['SSH (m)'];
elseif (vname == 'ubar'),
  f=w(ista,:);
  TITLE1=['Barotropic U-velocity (m/s), station = ', num2str(ista)];
  YLABEL=['Ubar (m/s)'];
elseif (vname == 'vbar'),
  f=w(ista,:);
  TITLE1=['Barotropic V-velocity (m/s), station = ', num2str(ista)];
  YLABEL=['Vbar (m/s)'];
end,

T=(t./86400)-dstart;

%----------------------------------------------------------------------------
% Plot Data.
%----------------------------------------------------------------------------

TITLE2=['Depth = ', num2str(round(h(ista))), ' m,   ', ...
        'Lon = ', num2str(lon(ista)), ',   ', ...
        'Lat = ', num2str(lat(ista))];
XLABEL=['Time  (days)'];

figure(2);

subplot(3,1,1);
plot(T,f); set(gca,'xlim',[690 720]);
grid;
title(TITLE1); ylabel(YLABEL);

subplot(3,1,2)
plot(T,f);
grid; set(gca,'xlim',[715 720]);
title(TITLE2); ylabel(YLABEL);

subplot(3,1,3)
plot(T,f);
grid; set(gca,'xlim',[719 720]);
xlabel(XLABEL); ylabel(YLABEL);

figure(3);

subplot(3,1,1);
plot(T,f); set(gca,'xlim',[1410 1440]);
grid;
title(TITLE1); ylabel(YLABEL);

subplot(3,1,2)
plot(T,f);
grid; set(gca,'xlim',[1435 1440]);
title(TITLE2); ylabel(YLABEL);

subplot(3,1,3)
plot(T,f);
grid; set(gca,'xlim',[1439 1440]);
xlabel(XLABEL); ylabel(YLABEL);

figure(4);

subplot(3,1,1);
plot(T,f); set(gca,'xlim',[2130 2160]);
grid;
title(TITLE1); ylabel(YLABEL);

subplot(3,1,2)
plot(T,f);
grid; set(gca,'xlim',[2155 2160]);
title(TITLE2); ylabel(YLABEL);

subplot(3,1,3)
plot(T,f);
grid; set(gca,'xlim',[2159 2160]);
xlabel(XLABEL); ylabel(YLABEL);

return

