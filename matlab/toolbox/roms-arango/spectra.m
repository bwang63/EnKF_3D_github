function [f,y,p,T,k]=spectra(fname,vname,ista,N);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright (c) 1997 Rutgers University.                                    %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                           %
% function [f,y,p,q]=spectra(fname,vname,ista,N)                            %
%                                                                           %
% This function reads in the requested variable from the stations NetCDF    %
% and then computes and plots the  power spectral density  of the signal    %
% buried in a noisy time domain signal.  It first  computes the discrete    %
% fast Fourier transform and then its power spectral density.               %
%                                                                           %
% On Input:                                                                 %
%                                                                           %
%    fname       NetCDF Stations file name (character string).              %
%    vname       NetCDF variable name to read (character string).           %
%    ista        Station index to process (integer).                        %
%    N           Optional, Number of time records to analize (integer).     %
%                If the length the record is less than N, the data is       %
%                padded with zeros to length N. If it is greater than N,    %
%                the sequence is truncated.                                 %
%                                                                           %
% On Output:                                                                %
%                                                                           %
%    f           Field (vector, matrix, or array).                          %
%    y           Discrete fast Fourier transform (vector).                  %
%    p           Power Spectral density (vector).                           %
%    T           Period (vector).                                           %
%    k           Wave number (vector).                                      %
%                                                                           %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Get number of stations.

h=nc_read(fname,'h',0);
nsta=length(h);

if (ista < 1 | ista > nsta),
  disp(' ');
  disp([setstr(7),'*** Error:  SPECTRA - illegal station index.',setstr(7)]);
  disp([setstr(7),'                      valid range:  1 <= ista <= ',...
        num2str(nsta),setstr(7)]);
  disp(' ');
  return
end,

%----------------------------------------------------------------------------
% Read in requested field.
%----------------------------------------------------------------------------

w=nc_read(fname,vname,0);
t=nc_read(fname,'scrum_time',0);
lon=nc_read(fname,'lon_rho',0);
lat=nc_read(fname,'lat_rho',0);

% Determine length of the fast Fourier transform. If not given, use the
% length of the record.

if (nargin < 4),
  N=length(t);
end,

%----------------------------------------------------------------------------
% Extract station data to analize.
%----------------------------------------------------------------------------

if (vname == 'zeta'),
  f=w(ista,:);
  TITLE1=['Sea Surface Height (m), station = ', num2str(ista)];
  YLABEL=['Spectral Density (m2/cycle/hour)'];
elseif (vname == 'ubar'),
  f=w(ista,:);
  TITLE1=['Barotropic U-velocity (m/s), station = ', num2str(ista)];
  YLABEL=['Spectral Density (m2/s2/cycle/hour)'];
elseif (vname == 'vbar'),
  f=w(ista,:);
  TITLE1=['Barotropic V-velocity (m/s), station = ', num2str(ista)];
  YLABEL=['Spectral Density (m2/s2/cycle/hour)'];
end,

%----------------------------------------------------------------------------
% Compute fast Fourier transform and power spectral density.
%----------------------------------------------------------------------------

y=fft(f,N);
p=y.*conj(y)./N;

%----------------------------------------------------------------------------
% Set-up period (T=1/f) axis. Since there is symmetry only take the first
% N/2 elements.  Convert period to (cycles/hour).
%----------------------------------------------------------------------------

Nhalf=fix(N/2);
dt=t(2)-t(1);
q=(0:Nhalf-1)./N;
q=3600.*q./dt;
T(1)=0.00001;
T(2:Nhalf)=1./q(2:Nhalf);
k=2.*pi.*q./(sqrt(9.808*h(ista)));

%----------------------------------------------------------------------------
% Plot frequency vs power spectral density.
%----------------------------------------------------------------------------

TITLE2=['DT = ', num2str(dt), ' sec,   ', ...
        'Depth = ', num2str(round(h(ista))), ' m,   ', ...
        'Lon = ', num2str(lon(ista)), ',   ', ...
        'Lat = ', num2str(lat(ista))];
XLABEL1=['Period  (hours)'];
XLABEL2=['Wave Number'];

subplot(2,1,1);
semilogy(T(2:Nhalf),p(2:Nhalf),'k-');
grid; set(gca,'xlim',[0 2]);
title(TITLE1); xlabel(XLABEL1); ylabel(YLABEL);

subplot(2,1,2)
semilogy(k,p(1:Nhalf),'k-');
grid; set(gca,'xlim',[0 0.1]);
title(TITLE2); xlabel(XLABEL2); ylabel(YLABEL);

return

