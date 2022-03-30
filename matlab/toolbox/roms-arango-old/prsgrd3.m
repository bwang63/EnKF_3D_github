function [phix,upg]=prsgrd3(z,y,r,rhobar,g,rho0,f0)
% discrete pressure gradient term as used in SCRUM
% [phix,u]=prsgrd3(z,y,rhop,rhobar,g,rho0,f0)
global z_w

N = size(r,1);
L = size(r,2);
Lm = L-1;
Nm = N-1;
phix=zeros([N Lm]);

if nargin < 6
  f0=1.e-4;
end
if nargin < 5
  rho0=1000;
end
if nargin < 4
  g=9.808;
end

% rho-rhobar
rhop=0.25*g/rho0*(r-rhobar);

% calculate top-level pressure gradients

% tony's method
% phix(N,:)=((zeros(size(z(N,1:Lm)))-z_w(N,1:Lm))+ ...
% (zeros(size(z(N,2:L)))-z_w(N,2:L))).*(rhop(N,2:L)-rhop(N,1:Lm));

% zero pressure at top
%phix(N,:)=zeros(size(z(N,1:Lm)));

% scrum method 
phix(N,:)=2*((zeros(size(z(N,1:Lm)))-z(N,1:Lm))+ ...
             (zeros(size(z(N,2:L)))-z(N,2:L))).* ...
            (rhop(N,2:L)-rhop(N,1:Lm));


% calculate baroclinic pressure gradients

% standard jacobian
phix(1:Nm,:) = ...
  (z(2:N,2:L)   +z(2:N,1:Lm)   -z(1:Nm,2:L)   -z(1:Nm,1:Lm))...
.*(rhop(2:N,2:L)+rhop(1:Nm,2:L)-rhop(2:N,1:Lm)-rhop(1:Nm,1:Lm))...
- (z(2:N,2:L)   +z(1:Nm,2:L)   -z(2:N,1:Lm)   -z(1:Nm,1:Lm))...
.*(rhop(2:N,2:L)+rhop(2:N,1:Lm)-rhop(1:Nm,2:L)-rhop(1:Nm,1:Lm));

% weighted jacobian
wj = 1;
if wj 
  dummy1 = 0.25*...
    (z(1:Nm,2:L)-z(1:Nm,1:Lm)+z(2:N,2:L) -z(2:N,1:Lm))...
  .*(z(2:N,2:L) -z(1:Nm,2:L) -z(2:N,1:Lm)+z(1:Nm,1:Lm))...
  ./((z(2:N,2:L)-z(1:Nm,2:L)).*(z(2:N,1:Lm)-z(1:Nm,1:Lm)) );

  a2d = ...
  (    z(2:N,2:L) +z(2:N,1:Lm)   -z(1:Nm,2:L)   -z(1:Nm,1:Lm))...
  .*(rhop(2:N,2:L)-rhop(1:Nm,2:L)-rhop(2:N,1:Lm)+rhop(1:Nm,1:Lm))...
  -(   z(2:N,2:L) -z(1:Nm,2:L)   -z(2:N,1:Lm)   +z(1:Nm,1:Lm))...
  .*(rhop(2:N,2:L)+rhop(2:N,1:Lm)-rhop(1:Nm,2:L)-rhop(1:Nm,1:Lm));

  phix(1:Nm,:)=phix(1:Nm,:)+dummy1.*a2d;

end

% integrate ds
phix=flipud(cumsum(flipud(phix)));

if nargout == 2

  % compute u = phix/f
  dy = diff(y*1000);
  dy = dy(ones([N 1]),:);
  upg = -phix./(f0*dy);

end

