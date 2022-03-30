function [t,ke,pe,vol]=energy(fname);
 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright (c) 1996 Rutgers University.                                    %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                           %
% function [t,ke,pe,vol]=energy(fname)                                      %
%                                                                           %
% This function reads and plots seamount pressure gradient errors.          %
%                                                                           %
%  On Input:                                                                %
%                                                                           %
%     fname    Maximum velocity ASCII file name (string).                   %
%                                                                           %
%  On Output:                                                               %
%                                                                           %
%     t        Time (days; vector).                                         %
%     ke       Kinetic energy (gigaWatts; vector).                          %
%     pe       Potential energy (gigaWatts; vector).                        %
%     vol      Basin volume (m^3; vector).                                  %
%                                                                           %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%----------------------------------------------------------------------------
%  Read in energy data.
%----------------------------------------------------------------------------
 
fid=fopen(fname,'r');
if (fid < 0),
  error(['Cannot open ' fname '.'])
end
 
[f count]=fscanf(fid,'%g %g %g %g',[4 inf]);
t=f(1:4:count);
ke=f(2:4:count);
pe=f(3:4:count);
vol=f(4:4:count);

%----------------------------------------------------------------------------
%  Plot data.
%----------------------------------------------------------------------------

t=t./30;
t=t-fix(t(1));

figure;
plot(t,ke);
xlabel('Time  (Month)');
ylabel('Kinetic Energy (gigaWatts)');

figure;
plot(t,pe);
xlabel('Time  (Month)');
ylabel('Potential Energy (gigaWatts)');

figure;
plot(t,vol);
xlabel('Time  (Month)');
ylabel('Volume (m^3)');

return


