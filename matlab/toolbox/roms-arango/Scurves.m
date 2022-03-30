function [Grid]=Scurves(Grid);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright (c) 2000 Rutgers University.                                    %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Hernan G. Arango %%%
%                                                                           %
% function [Grid]=Scurves(Grid)                                             %
%                                                                           %
% This function computes parameters associated with the terrain-following,  %
% vertical coordinates: S-coordinates transformation.                       %
%                                                                           %
% On Input:                                                                 %
%                                                                           %
%    Grid        Grid information (structure array):                        %
%                  Grid.h        => bathymetry (m).                         %
%                  Grid.hc       => S-coordinate parameter, critical depth. %
%                  Grid.theta_s  => S-coordinate surface control parameter. %
%                  Grid.theta_b  => S-coordinate bottom control parameter.  %
%                  Grid.Tcline   => S-coordinate surface/bottom stretching  %
%                                   width (m).                              %
%                  Grid.N        => Number of vertical RHO-levels.          %
%                  Grid.ncgrid   => GRID NetCDF file name, if any.          %
%                                                                           %
% On Output:                                                                %
%                                                                           %
%    Grid        Appended Grid information (structure array):               %
%                  Grid.sc_r     => S-coordinate at RHO-points.             %
%                  Grid.sc_w     => S-coordinate at W-points.               %
%                  Grid.Cd_r     => S-coordinate stretching curves at       %
%                                   RHO-points.                             %
%                  Grid.Cd_w     => S-coordinate Stretching curves at       %
%                                   W-points.                               %
%                                                                           %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global IPRINT;
IPRINT=0;

%  If appropriate, get "hc" parameter.

if (~isfield(Grid,'hc')),
  if (isfield(Grid,'ncgrid')),
    Grid.h=nc_read(Grid.ncgrid,'h');
    Grid.hc=min(Grid.hc);
  else,
    error(['Scurves - cannot get parameter: hc']);
  end,
end,

%----------------------------------------------------------------------------
%  Set S-coordinates transformation variables.
%----------------------------------------------------------------------------

N=Grid.N;
hc=Grid.hc;
theta_s=Grid.theta_s;
theta_b=Grid.theta_b;
Tcline=Grid.Tcline;

ds=1.0/N;
cff1=1.0/sinh(theta_s);
cff2=0.5/tanh(0.5*theta_s);

sc_w(1)=-1.0;
Cd_w(1)=-1.0;

for k=1:N,
  sc_w(k+1)=ds*(k-N);
  Cd_w(k+1)=(1.0-theta_b)*cff1*sinh(theta_s*sc_w(k+1))+ ...
            theta_b*(cff2*tanh(theta_s*(sc_w(k+1)+0.5))-0.5);
  sc_r(k)=ds*((k-N)-0.5);
  Cd_r(k)=(1.0-theta_b)*cff1*sinh(theta_s*sc_r(k))+ ...
          theta_b*(cff2*tanh(theta_s*(sc_r(k)+0.5))-0.5);
end,

Grid.sc_r=sc_r;
Grid.sc_w=sc_w;
Grid.Cs_r=Cd_r;
Grid.Cs_w=Cd_w;

return



 

