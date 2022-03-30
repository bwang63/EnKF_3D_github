
gfile='/d15/arango/scrum/Damee/grid6/damee6_grid_b.nc';

h=nc_read(gfile,'h');
pm=nc_read(gfile,'pm');
pn=nc_read(gfile,'pn');
vmask=nc_read(gfile,'mask_v');

[L,M]=size(h);
Lm=L-1;
Mm=M-1;

%  Get variables for the northern boundary.

bh=0.5.*(h(:,M)+h(:,Mm));
bm=0.5.*(pm(:,M)+pm(:,Mm));
bn=0.5.*(pn(:,M)+pn(:,Mm));
mask=vmask(:,Mm);
mask=mask;

x(1)=0.0;
for i=2:L,
  x(i)=x(i-1)+0.001./bm(i);
end
x=x';

%  Compute Newfoundland Inflow function.

vinflow=0.05;
vsum=0.0;
hsum=0.0;
% xinflow=x(58);   % Damee #7
xinflow=x(96);

vref=vinflow*(0.5.*(1.0+tanh((650.0-(x-xinflow))./100.))).*mask;
vsum=sum(vref.*bh);
hsum=sum(bh.*mask);

v0=vsum/hsum;

%  Compute Newfoundland transport.

scale=1.0e-6;
vnorth=-(vinflow.*(0.5*(1.0+tanh((650.0-(x-xinflow))./100.0)))-v0).*mask;
vtrans=cumsum(vnorth.*bh./bm).*scale;

%  Plot.

figure(1);
plot(x,vtrans,'r'); hold
plot(x,cumsum(0.8.*vnorth.*bh./bm).*scale,'y');
plot(x,cumsum(0.7.*vnorth.*bh./bm).*scale,'g');
plot(x,cumsum(0.6.*vnorth.*bh./bm).*scale,'c');
plot(x,cumsum(0.5.*vnorth.*bh./bm).*scale,'b');
plot(x,cumsum(0.4.*vnorth.*bh./bm).*scale,'m');
plot(x,cumsum(0.3.*vnorth.*bh./bm).*scale,'r');
plot(x,cumsum(0.2.*vnorth.*bh./bm).*scale,'y');
plot(x,cumsum(0.1.*vnorth.*bh./bm).*scale,'g');

title('Newfoundland Transport, Damee #6');
xlabel('Grid (Km)');
ylabel('Sverdrups');

figure(2);
plot(x,vnorth,x,vnorth,'r+');
title('Vbar - Newfoundland Transport, Damee #6');
xlabel('Grid (Km)');
ylabel('m/s');

figure(3);
plot(x,scale.*vnorth.*bh./bm);
title('Transport Term: Vbar*h_v/pm_v, Damee #6');
xlabel('Grid (Km)');
ylabel('Sverdurps');

figure(4);
plot(x,-bh);
title('Northern Boundary Bathymetry, Damee #6');
xlabel('Grid (Km)');
ylabel('m');

