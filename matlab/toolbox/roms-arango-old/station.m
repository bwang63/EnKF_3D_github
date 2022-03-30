function [T,f]=station(fname,vname,ista,month);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright (c) 1997 Rutgers University.                                    %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                           %
% function [T,f]=station(fname,vname,ista,month);                           %
%                                                                           %
% This function reads in and plots the requested variable from the          %
% stations NetCDF.                                                          %
%                                                                           %
% On Input:                                                                 %
%                                                                           %
%    fname       NetCDF Stations file name (character string).              %
%    vname       NetCDF variable name to read (character string).           %
%    ista        Station index to process (integer).                        %
%    month       Month record to plot (integer)                             %
%                                                                           %
% On Output:                                                                %
%                                                                           %
%    T           time (vector).                                             %
%    f           Field (vector).                                            %
%                                                                           %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% if not provided, set-up month to analyze and plot.

if (nargin < 4),
  month=24;
end

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
t=nc_read(fname,'ocean_time',0);
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

T=(t./86400);
T=T-fix(T(1)); T=T';

Tlast=T(length(T));
Tend=30*month;
if (Tend > Tlast), 
  Tend=fix(Tlast);
end,

fsize=length(f);
Tsize=length(T);
len=fsize;
len=min(fsize,Tsize);

%----------------------------------------------------------------------------
% Plot Data.
%----------------------------------------------------------------------------

TITLE2=['Depth = ', num2str(round(h(ista))), ' m,   ', ...
        'Lon = ', num2str(lon(ista)), ',   ', ...
        'Lat = ', num2str(lat(ista))];
XLABEL=['Time  (days)'];

figure(2);

subplot(3,1,1);
plot(T(1:len),f(1:len));
set(gca,'xlim',[max(0,Tend-30) Tend]);
grid;
title(TITLE1); ylabel(YLABEL);

subplot(3,1,2)
plot(T(1:len),f(1:len));
grid;
set(gca,'xlim',[Tend-5 Tend]);
title(TITLE2); ylabel(YLABEL);

subplot(3,1,3)
plot(T(1:len),f(1:len));
grid;
set(gca,'xlim',[Tend-1 Tend]);
xlabel(XLABEL); ylabel(YLABEL);

return