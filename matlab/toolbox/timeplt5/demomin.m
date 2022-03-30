
% minutes
  start=[1990 1 1 5 0 0];    %Gregorian start [yyyy mm dd hh mi sc]
  stop=[1990 1 1 5 20 0];
  jd=[julian(start):1/5000:julian(stop)];

% synthesize velocity data
  u=sin(.1*jd(:)*500).^2-.5;
  v=cos(.1*jd(:)*500);

% convention: store velocity time series as complex vector:
  w=u+i*v;

  h=timeplt(jd,[u v abs(w) w],[1 1 2 3]);
  title('Demo of TIMEPLT and STACKLBL:  Minutes')
 
% use STACKLBL to label each stack plot panel with title and units:

  stacklbl(h(1),'East + North velocity','m/s');
  stacklbl(h(2),'Speed','m/s');
  stacklbl(h(3),'Velocity Sticks','m/s');

