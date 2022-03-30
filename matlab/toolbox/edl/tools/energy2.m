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
subplot(3,1,1);
plot(t,ke); set(gca,'xlim',[0 36],'XTick',[0:4:36]);
grid;
title('USwest grid 6: Years 0-3')
ylabel('KE (GigaWatts)')

subplot(3,1,2)
plot(t,ke);
grid; set(gca,'xlim',[36 72],'XTick',[36:4:72]);
title('Years 3-6')
ylabel('KE (GigaWatts)')

subplot(3,1,3)
plot(t,ke);
grid; set(gca,'xlim',[72 108],'XTick',[72:4:108]);
title('Years 6-9')
xlabel('Month')
ylabel('KE (GigaWatts)')

figure;
subplot(3,1,1);
plot(t,vol); set(gca,'xlim',[0 36],'XTick',[0:4:36]);
grid;
title('USwest grid 6: Years 0-3')
ylabel('Volume (m^3)')

subplot(3,1,2)
plot(t,vol);
grid; set(gca,'xlim',[36 72],'XTick',[36:4:72]);
title('Years 3-6')
ylabel('Volume (m^3)')

subplot(3,1,3)
plot(t,vol);
grid; set(gca,'xlim',[72 108],'XTick',[72:4:108]);
title('Years 6-9')
xlabel('Month')
ylabel('Volume (m^3)')

return


