% DEMO demonstrates the use of TIMEPLT and STACKLBL.
%

% Call TIMEPLT specifying east and north velocity components
% in the bottom panel, vector magnitude in the middle panel and a vector 
% stick plot in the top panel.  Note: each stick plot must have it's own panel


%
% Demonstrate for each time catagory.

% years
  start=[1970 11 1 0 0 0];    %Gregorian start [yyyy mm dd hh mi sc]
  stop=[1996 2 1 0 0 0];
  jd=julian(start):100:julian(stop);

% synthesize velocity data
  u=sin(.1*jd(:)/100).^2-.5;
  v=cos(.1*jd(:)/100);

% convention: store velocity time series as complex vector:
  w=u+i*v;

  h=timeplt(jd,[u v abs(w) w],[1 1 2 3]);
  title('Demo of TIMEPLT and STACKLBL:  Years')
 
% use STACKLBL to label each stack plot panel with title and units:

  stacklbl(h(1),'East + North velocity','m/s');
  stacklbl(h(2),'Speed','m/s');
  stacklbl(h(3),'Velocity Sticks','m/s');


