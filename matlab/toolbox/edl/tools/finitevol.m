%  This script show how to represent analytical profiles of temperature,
%  for instance, from the finite volume approach.

dz=5;

Zw=-200:dz:0;
Nw=length(Zw);

Zr=0.5.*(Zw(2:Nw)+Zw(1:Nw-1));
Nr=length(Zw);

Z0=-35;
Z1=-75;

a=6.5;
b=150;

%  Discrete profile.

T1 = 14 + 4 .* tanh((Zr-Z0)./a) + (Zr-Z1)/b;

%  Finite volume profile: integrate analytically at the finite volume
%  box defined by Zw and then divide by the box size.

T2 = 14 + 4 * a .* log( cosh((Zw(2:Nw  )-Z0)./a) ./ ...
                        cosh((Zw(1:Nw-1)-Z0)./a) ) ./ ...
                   (Zw(2:Nw)-Zw(1:Nw-1)) + ...
                   (0.5.*(Zw(2:Nw)+Zw(1:Nw-1)) - Z1) ./b;

figure;
plot(T1,Zr,'r',T2,Zr,'b',T2,Zr,'k+');
legend('discrete','finite volume',4);
xlabel('Temperature');
ylabel('Depth');
grid on;
print -dpsc profile.ps

figure;
plot(T1-T2,Zr,'r-+');
title('Discrete minus Finite Volume Profile')
xlabel('Temperature');
ylabel('Depth');
grid on;
print -dpsc -append profile.ps

