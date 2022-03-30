%  This script computes the fraction of solar shortwave flux penetrating
%  to specified depth or thickness.


Jwtype=1;
lmd_r1 =[0.58 0.62 0.67 0.77 0.78];
lmd_mu1=[0.35 0.6 1.0 1.5 1.4];
lmd_mu2=[23.0 20.0 17.0 14.0 7.9];

Zw=-30:0.5:0;

N=length(Zw);
for k=1:N,
  dz(k)=Zw(N)-Zw(k);
end,

swdk=lmd_r1(Jwtype).*exp(-dz./lmd_mu1(Jwtype)) + ...
     (1.0-lmd_r1(Jwtype)).*exp(-dz./lmd_mu2(Jwtype));

figure

plot(swdk,Zw);
grid on;

