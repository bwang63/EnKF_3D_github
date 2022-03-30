% Leo-15, Currents EOF's, Summer 1998.

IPLOT1=0;
IPLOT2=1;
IPLOT3=1;

order=10;
zsur=0;
zbot=-30;

% Read in Bob's eof file

load eof_leo.dat

% Extract EOF's from read in array.

eof1=eof_leo(1:20,:);
eof2=eof_leo(21:40,:);
eof3=eof_leo(41:60,:);

clear eof_leo

% Set indidual fields.  Convert velocity to m/s.  Padd out surface and
% bottom values.

f=-eof1(:,1); f=[zsur; f; zbot];  z(:,1)=f; clear f;
f=-eof2(:,1); f=[zsur; f; zbot];  z(:,2)=f; clear f;
f=-eof2(:,1); f=[zsur; f; zbot];  z(:,3)=f; clear f;

f=eof1(:,4)./100; f=[f(1); f; 0]; u(:,1)=f; clear f;
f=eof2(:,4)./100; f=[f(1); f; 0]; u(:,2)=f; clear f;
f=eof3(:,4)./100; f=[f(1); f; 0]; u(:,3)=f; clear f;

umean=eof1(:,6)./100; umean=[umean(1); umean; 0];

f=eof1(:,5)./100; f=[f(1); f; 0]; v(:,1)=f; clear f;
f=eof2(:,5)./100; f=[f(1); f; 0]; v(:,2)=f; clear f;
f=eof3(:,5)./100; f=[f(1); f; 0]; v(:,3)=f; clear f;

vmean=eof1(:,7)./100; vmean=[vmean(1); vmean; 0];

clear eof1 eof2 eof3

% Compute speed magnitude and direction.

mag=sqrt(u.*u + v.*v);
dir=atan2(u,v).*180./pi;

% Fit polynomial curve.

F=polyfit(z(:,1),u(:,1),order);
u_fit(:,1)=F';
u_val(:,1)=polyval(u_fit(:,1),z(:,1));

F=polyfit(z(:,2),u(:,2),order);
u_fit(:,2)=F';
u_val(:,2)=polyval(u_fit(:,2),z(:,2));

F=polyfit(z(:,3),u(:,3),order);
u_fit(:,3)=F';
u_val(:,3)=polyval(u_fit(:,3),z(:,3));

F=polyfit(z(:,1),v(:,1),order);
v_fit(:,1)=F';
v_val(:,1)=polyval(v_fit(:,1),z(:,1));

F=polyfit(z(:,2),v(:,2),order);
v_fit(:,2)=F';
v_val(:,2)=polyval(v_fit(:,2),z(:,2));

F=polyfit(z(:,3),v(:,3),order);
v_fit(:,3)=F';
v_val(:,3)=polyval(v_fit(:,3),z(:,3));

F=polyfit(z(:,1),mag(:,1),order);
mag_fit(:,1)=F';
mag_val(:,1)=polyval(mag_fit(:,1),z(:,1));

F=polyfit(z(:,2),mag(:,2),order);
mag_fit(:,2)=F';
mag_val(:,2)=polyval(mag_fit(:,2),z(:,2));

F=polyfit(z(:,3),mag(:,3),order);
mag_fit(:,3)=F';
mag_val(:,3)=polyval(mag_fit(:,3),z(:,3));

F=polyfit(z(:,1),dir(:,1),order);
dir_fit(:,1)=F';
dir_val(:,1)=polyval(dir_fit(:,1),z(:,1));

F=polyfit(z(:,2),dir(:,2),order);
dir_fit(:,2)=F';
dir_val(:,2)=polyval(dir_fit(:,2),z(:,2));

F=polyfit(z(:,3),dir(:,3),order);
dir_fit(:,3)=F';
dir_val(:,3)=polyval(dir_fit(:,3),z(:,3));

% Plot detailed data.

if (IPLOT1),

  figure;
  plot(u(:,1),z(:,1),u(:,2),z(:,2),u(:,3),z(:,3));
  legend('EOF 1: 81.1%','EOF 2: 12.9%','EOF 3:  3.6%',0);
  grid on;
  title('Zonal Velocity EOF');
  xlabel('EOF amplitude  (m/s)');
  ylabel('Depth  (m)');

  figure;
  plot(v(:,1),z(:,1),v(:,2),z(:,2),v(:,3),z(:,3));
  legend('EOF 1: 81.1%','EOF 2: 12.9%','EOF 3:  3.6%',0);
  grid on;
  title('Meridional Velocity EOF');
  xlabel('EOF amplitude  (m/s)');
  ylabel('Depth  (m)');

  figure;
  plot(umean,z(:,1));
  grid on;
  title('Mean Zonal Velocity for all EOFs');
  xlabel('EOF amplitude  (m/s)');
  ylabel('Depth  (m)');

  figure;
  plot(vmean,z(:,1));
  legend('EOF 1: 81.1%','EOF 2: 12.9%','EOF 3:  3.6%',0);
  grid on;
  title('Mean Meridional Velocity for all EOF');
  xlabel('EOF amplitude  (m/s)');
  ylabel('Depth  (m)');

  figure;
  plot(mag(:,1),z(:,1),mag(:,2),z(:,2),mag(:,2),z(:,3));
  legend('EOF 1: 81.1%','EOF 2: 12.9%','EOF 3:  3.6%',0);
  grid on;
  title('EOF: Velocity Magnitude');
  xlabel('(m/s)');
  ylabel('Depth  (m)');

  figure;
  plot(dir(:,1),z(:,1),dir(:,2),z(:,2),dir(:,3),z(:,3));
  legend('EOF 1: 81.1%','EOF 2: 12.9%','EOF 3:  3.6%',0);
  grid on;
  title('EOF: Velocity Direction');
  xlabel('(degrees)');
  ylabel('Depth  (m)');

end,

% Plot fitted data.

if (IPLOT2),

  figure;
  plot(u(:,1),z(:,1),'b-',u_val(:,1),z(:,1),'+r');
  grid on;
  title(['Fitted Zonal Velocity, Norder = ',num2str(order)]);
  xlabel('(m/s)');
  ylabel('Depth  (m)');

  figure;
  plot(v(:,1),z(:,1),'b-',v_val(:,1),z(:,1),'+r');
  grid on;
  title(['Fitted Meridional Velocity, Norder = ',num2str(order)]);
  xlabel('(m/s)');
  ylabel('Depth  (m)');

  figure;
  plot(mag(:,1),z(:,1),'b-',mag_val(:,1),z(:,1),'+r');
  grid on;
  title(['Fitted Velocity Magnitude, Norder = ',num2str(order)]);
  xlabel('(m/s)');
  ylabel('Depth  (m)');

  figure;
  plot(dir(:,1),z(:,1),'b-',dir_val(:,1),z(:,1),'+r');
  grid on;
  title(['Fitted Velocity Direction, Norder = ',num2str(order)]);
  xlabel('(degrees)');
  ylabel('Depth  (m)');

end,

% Plot data for presentation data.

if (IPLOT3),

 figure;

 subplot(1,2,1)
 plot(u(:,1),z(:,1),u(:,2),z(:,2),u(:,3),z(:,3));
 legend('EOF 1: 81.1%','EOF 2: 12.9%','EOF 3:   3.6%',4);
 grid on;
 title('Zonal Velocity EOFs');
 xlabel('EOF amplitude  (m/s)');
 ylabel('Depth  (m)');

 subplot(1,2,2)
 plot(v(:,1),z(:,1),v(:,2),z(:,2),v(:,3),z(:,3));
 grid on;
 title('Meridional Velocity EOFs');
 xlabel('EOF amplitude  (m/s)');
 ylabel('Depth  (m)');

 print -dpsc eof.ps

 figure;

 subplot(1,2,1)
 plot(mag(:,1),z(:,1),'b-');
 grid on;
 title('EOF 1: Velocity Magnitude');
 xlabel('(m/s)');
 ylabel('Depth  (m)');

 subplot(1,2,2)
 plot(dir(:,1),z(:,1),'b-');
 grid on;
 title('EOF 1: Velocity Direction');
 xlabel('(degrees)');
 ylabel('Depth  (m)');

 print -dpsc -append eof.ps

 figure;

 zerr=-24:0.1:0;
 error=exp(zerr./2);

 subplot(1,2,1)
 plot(error,zerr,'r-');
 grid on;
 title('Extended Velocity Error Variance');
 set(gca,'Xlim',[-0.2 1.2]);
 xlabel('(nondimsional)');
 ylabel('Depth  (m)');

 print -dpsc -append eof.ps

end,