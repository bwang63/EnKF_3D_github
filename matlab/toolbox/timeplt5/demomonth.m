% months

  start=[1990 1 1 0 0 0];    %Gregorian start [yyyy mm dd hh mi sc]
  stop=[1991 4 1 0 0 0];
  jd=julian(start):10:julian(stop);

% synthesize velocity data
  u=sin(.1*jd(:)/10).^2-.5;
  v=cos(.1*jd(:)/10);

% convention: store velocity time series as complex vector:
  w=u+i*v;

  h=timeplt(jd,[u v abs(w) w],[1 1 2 3]);
  title('Demo of TIMEPLT and STACKLBL:  Months')
 
% use STACKLBL to label each stack plot panel with title and units:

  stacklbl(h(1),'East + North velocity','m/s');
  stacklbl(h(2),'Speed','m/s');
  stacklbl(h(3),'Velocity Sticks','m/s');
