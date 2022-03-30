function [t,ub,vb,u,v]=seamount(fname);
 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright (c) 1996 Rutgers University.                                    %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                           %
% function [t,ub,bv,u,v]=seamount(fname)                                    %
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
%     ub       Maximum barotropic U-velocity (m/s; vector)                  %
%     vb       Maximum barotropic V-velocity (m/s; vector)                  %
%     u        Maximum total U-velocity (m/s; vector)                       %
%     v        Maximum total V-velocity (m/s; vector)                       %
%                                                                           %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%----------------------------------------------------------------------------
%  Read in maximum velocity data.
%----------------------------------------------------------------------------

fid=fopen(fname,'r');
if (fid < 0),
  error(['Cannot open ' cstfile '.'])
end

[f count]=fscanf(fid,'%g %g %g %g %g',[5 inf]);
t =f(1:5:count);
ub=f(2:5:count);
vb=f(3:5:count);
u =f(4:5:count);
v =f(5:5:count);

%----------------------------------------------------------------------------
%  Draw maximum velocity magnitudes.
%----------------------------------------------------------------------------

vmag=sqrt(u.*u + v.*v);
vbmag=sqrt(ub.*ub + vb.*vb);
semilogy(t,vmag,'r',t,vbmag,'c');
set(gca,'ylim',[1e-5 10]);
xlabel('day');
ylabel('m/s');
title('Seamount - Pressure Gradient Test');

return


