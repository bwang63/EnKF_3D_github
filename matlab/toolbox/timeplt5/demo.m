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


disp('hit enter to continue')
pause

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


disp('hit enter to continue')
pause

% days
  start=[1990 1 1 0 0 0];    %Gregorian start [yyyy mm dd hh mi sc]
  stop=[1990 1 15 0 0 0];
  jd=[julian(start):1/6:julian(stop)];

% synthesize velocity data
  u=sin(.1*jd(:)*10).^2-.5;
  v=cos(.1*jd(:)*10);

% convention: store velocity time series as complex vector:
  w=u+i*v;

  h=timeplt(jd,[u v abs(w) w],[1 1 2 3]);
  title('Demo of TIMEPLT and STACKLBL:  Days')
 
% use STACKLBL to label each stack plot panel with title and units:

  stacklbl(h(1),'East + North velocity','m/s');
  stacklbl(h(2),'Speed','m/s');
  stacklbl(h(3),'Velocity Sticks','m/s');



disp('hit enter to continue')
pause

% hours
  start=[1990 1 1 0 0 0];    %Gregorian start [yyyy mm dd hh mi sc]
  stop=[1990 1 1 15 0 0];
  jd=[julian(start):1/100:julian(stop)];

% synthesize velocity data
  u=sin(.1*jd(:)*100).^2-.5;
  v=cos(.1*jd(:)*100);

% convention: store velocity time series as complex vector:
  w=u+i*v;

  h=timeplt(jd,[u v abs(w) w],[1 1 2 3]);
  title('Demo of TIMEPLT and STACKLBL:  Hours')
 
% use STACKLBL to label each stack plot panel with title and units:

  stacklbl(h(1),'East + North velocity','m/s');
  stacklbl(h(2),'Speed','m/s');
  stacklbl(h(3),'Velocity Sticks','m/s');




disp('hit enter to continue')
pause

% minutes
  start=[1990 12 31 23 38 0];    %Gregorian start [yyyy mm dd hh mi sc]
  stop=[1991 1 1 0 20 0];
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
