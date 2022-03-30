function zr=zlev(theta_s,theta_b,Tcline,h,N)
%
%  compute the vertical levels at rho points
%
[Mp,Lp]=size(h);
ds=1.0/N;
hmin=min(min(h));
hmax=max(max(h));
hc=min(hmin,Tcline);
lev=1:N;
sc=-1+(lev-0.5).*ds;
Ptheta=sinh(theta_s.*sc)./sinh(theta_s);
Rtheta=tanh(theta_s.*(sc+0.5))./(2*tanh(0.5*theta_s))-0.5;
Cs=(1-theta_b).*Ptheta+theta_b.*Rtheta;
Cd_r=(1-theta_b).*cosh(theta_s.*sc)./sinh(theta_s)+ ...
     theta_b./tanh(0.5*theta_s)./(2.*(cosh(theta_s.*(sc+0.5))).^2);
Cd_r=Cd_r.*theta_s;
zeta=zeros(Mp,Lp);
zr=zeros(N,Mp,Lp);
for k=1:N,
  zr(k,:,:)=zeta.*(1+sc(k))+hc.*sc(k)+(h-hc).*Cs(k);
end,
