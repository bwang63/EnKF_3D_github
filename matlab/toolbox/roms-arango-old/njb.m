function [t,s]=njb(z);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright (c) 1996 Rutgers University.                                    %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                           %
% function [t,s]=njb(z)                                                     %
%                                                                           %
% This routine computes and plots a section of temperature and salinity.    %
% The temperature and salinity is computed with a 7th order polynomial      %
% derived from LEO-15 summer 1996 data set.                                 %
%                                                                           %
% On Input:                                                                 %
%                                                                           %
%    z_r       Depths (m) of RHO-points (matrix).                           %
%                                                                           %
% On Output:                                                                %
%                                                                           %
%    t         Temperature (C) section (matrix).                            %
%    s         Salinity (PSU) section (matrix).                             %
%                                                                           %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%----------------------------------------------------------------------------
% Set polynomial expansion coefficients for temperature.
%----------------------------------------------------------------------------

T0=2.049264257728403e+01;
T1=2.640850848793918e-01;
T2=2.751125328535212e-01;
T3=9.207489761648872e-02;
T4=1.449075725742839e-02;
T5=1.078215685912076e-03;
T6=3.240318053903974e-05;
T7=1.262826857690271e-07;

%----------------------------------------------------------------------------
% Set polynomial expansion coefficients for salinity.
%----------------------------------------------------------------------------

S0=3.066489149193135e+01;
S1=1.476725262946735e-01;
S2=1.126455760313399e-01;
S3=3.900923281871022e-02;
S4=6.939014937447098e-03;
S5=6.604436696792939e-04;
S6=3.191792361954220e-05;
S7=6.177352634409320e-07;

%----------------------------------------------------------------------------
% Compute and plot temperature and salinity sections.
%----------------------------------------------------------------------------

[im,km]=size(z);
x=zeros(size(z));
xsec=0:im-1;

for k=1:km,
  x(:,k)=xsec(:);
  for i=1:im,
    z1=z(i,k);
    if (z1 >= -15.0),
      t(i,k)=T0-z1*(T1+z1*(T2+z1*(T3+z1*(T4+z1*(T5+z1*(T6+T7*z1))))));
      s(i,k)=S0-z1*(S1+z1*(S2+z1*(S3+z1*(S4+z1*(S5+z1*(S6+S7*z1))))));
    else,
      t(i,k)=14.6+6.7*tanh(1.1*z1+15.9);
      s(i,k)=31.3-0.55*tanh(1.1*z1+15.9);
    end,
  end,
end,

pcolor(x,z,t); shading interp; colormap(cool(64)); colorbar;
xmax=max(max(x));
zmin=min(min(z));
set(gca,'xlim',[0 xmax],'ylim',[zmin 0]);
title('Temperature Section');
xlabel('(grid units)');
ylabel('depth  (m)');

return;

