function tsdiagram(S,T,P,sigma,marker,axislim);
% tsdiagram  Plots a temperature vs. salinity diagram
%            with selected density contours.
% =============================================================================
% tsdiagram  Version 2.0 8-Septermber-1998
%
% Usage: 
%   tsdiagram(S,T) draws several randomly chosen contours and assumes
%   Pressure = 0.            
%
%   tsdiagram(S,T,P) draws several randomly chosen contours.            
%
%   tsdiagram(S,T,P,sigma) draws contours lines of density anomaly
%
%   SIGMA (kg/m^3) at pressure P (dbars), given a range of
%
%   salinity (ppt) and temperature (deg C) in the 2-element vectors
%
%   S,T.  The freezing point (if visible) will be indicated. If sigma
%   is set to -1 no contours will be drawn. The user can input sigma
%   as a scalar (in which case the specified number of contours will be
%   drawn) or as a vector (in which case the contours will be drawn for
%   the specified isopycnals).
%
%   tsdiagram(S,T,P,sigma,marker) Set marker to specified symbol and color. If
%   not specified then default to green dot '.g'.
%
%   tsdiagram(S,T,P,sigma,marker,axislim) axislim is a vector to set the limits
%   for the x and y axes [lower_limit_s upper_limit_s lower_limit_t upper_limit_t].
%
% Description:
%   Function produces a 2-D T-S plot with various options for choosing
%   isopycnals, markers and axis limits.
%
% Input:
%   S = salinity [psu]
%   T = temperature [deg C]
%   P = pressure [db]
%   sigma = density [kg/m^3]
%   marker = string indicating color and style of marker to be plotted
%   axislim = vector indicating desired axis limits [smin smax tmin tmax]
%
% Output:
%   n/a
%
% Author:
%   Blair Greenan
%   Bedford Institute of Oceanography
%   September 8, 1998
%   Matlab 5.2.1
%   greenanb@mar.dfo-mpo.gc.ca
%
% Notes: 
%   RP (WHOI) 9/Dec/91
%
%             7/Nov/92 Changed for Matlab 4.0
%
%             14/Mar/94 Made P optional.
%
%   Blair Greenan (BIO) 27AUG98 
%     Version 2.0: Previous version did not actually take in
%     T,S data. It simply set up a T-S plot with isopynals drawn
%     on which you could overlay your T-S data by using "hold on".
%     This version takes in T-S data and sets up the plot based on
%     the min/max values of T and S and then plots the data. To
%     added data from another dataset use "hold on" and plot it.
%
% =============================================================================
%

% Set up function based on number of input arguments given

if (nargin<2),

   error('tsdiagram: Not enough calling parameters');

elseif (nargin==2),

   P=0;

   sigma=5;
   marker='.g';
   minS=floor(min(S))

   maxS=ceil(max(S))

   minT=floor(min(T))

   maxT=ceil(max(T))

elseif (nargin==3),

   sigma=5;

   marker='.g';
   minS=floor(min(S));

   maxS=ceil(max(S));

   minT=floor(min(T));

   maxT=ceil(max(T));

elseif (nargin==4),

   marker='.g';
   minS=floor(min(S));

   maxS=ceil(max(S));

   minT=floor(min(T));

   maxT=ceil(max(T));

elseif (nargin==5),

   minS=floor(min(S));

   maxS=ceil(max(S));

   minT=floor(min(T));

   maxT=ceil(max(T));

elseif (nargin==6),

   minS=axislim(1);

   maxS=axislim(2);

   minT=axislim(3);

   maxT=axislim(4);

end;

%

% Convert to columns to be on the safe side

sigma=sigma(:);

%

% If sigma ~= -1 then do isopycnal contours, otherwise skip
if (sigma ~= -1)
   % grid points for contouring

   Sg=minS+[0:30]/30*(maxS-minS);

   Tg=minT+[0:30]'/30*(maxT-minT);

   %

   % Use seawater state equation to return specific volume
   % anomaly SV (m^3/kg*1e-8) and the density anomaly SG (kg/m^3) 

   [SV,SG]=swstate(ones(size(Tg))*Sg,Tg*ones(size(Sg)),P(1));

   %

   % clear axis
   cla;

   % plot isopycnal contours

   [CS,H]=contour(Sg,Tg,SG,sigma,':g');
   % attach labels to contours
   
   % new style Matlab contour labelling ... I don't like it in this case so
   % clabel(CS,H)
   
   if (max(size(sigma))==1) 
      clabel(CS);
   else
      clabel(CS,sigma);
   end;

end
% set plot to "square"
axis('square');
% set axis limits
axis([minS maxS minT maxT]);

% place labels on axes
xlabel('Salinity (psu)');

ylabel('Temperature ({\circ}C)');

%

%plot freezing temp.

freezeT=swfreezetemp([minS maxS],P(1));

line([minS maxS],freezeT,'LineStyle','--');

%

% Label with pressure, then return to other axes

%text(S(1),T(2), ...

%[' Pressure = ' int2str(P(1)) ' dbars'],'horiz','left','Vert','top');

%
% plot data
hold on;
plot(S,T,marker)

