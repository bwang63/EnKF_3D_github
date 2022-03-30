function w=wvelocity(u,v,pm,pn,Hz,z_w,z_r,wtype)

%====================================================================
% Compute absolute vertical velocity. It is comprised of two
% principal: the S-coordinate vertical velocity  w*pm*pn; the
% component due to (quasi-)horizontal motions along S=const
% isosurfaces, which have slopes (the component due to displacement
% of the free surface is neglected here).
%
% It should be noted that the S-coordinate vertical velocity (stored
% as "W") is to be interpreted as volume flux through the grid
% interface between two RHO-cells. Therefore it has to be divided by
% the area of the grid cell as seen from above (i.e. muptiplied by
% pm*pn) in order to convert it into the actual vertical velocity. 
%
%====================================================================
if nargin < 8,
  wtype='w';
end;
[Lu Mu N]=size(u);
[Lv Mv N]=size(v);
[Lr Mr]=size(pm);
ds=1/N; Nw=N+1;

%  compute S-coordinate vertical velocity,
%  w=[Hz/(m*n)]*omega,     [m^3/s]
%  diagnostically at horizontal RHO-points and vertical W-points.

pn3d=repmat(pn,[1 1 Nw]);
Huon(1:Lu,1:Mu,1:N)=ds.*(Hz(2:Lr,1:Mr,1:N)+Hz(1:Lr-1,1:Mr,1:N)).* ...
    u(1:Lu,1:Mu,1:N)./(pn3d(2:Lr,1:Mr,1:N)+pn3d(1:Lr-1,1:Mr,1:N));

pm3d=repmat(pm,[1 1 Nw]);
Hvom(1:Lv,1:Mv,1:N)=ds.*(Hz(1:Lr,2:Mr,1:N)+Hz(1:Lr,1:Mr-1,1:N)).* ...
    v(1:Lv,1:Mv,1:N)./(pm3d(1:Lr,2:Mr,1:N)+pm3d(1:Lr,1:Mr-1,1:N));

omega(1:Lr,1:Mr,1:Nw)=0;

for k=2:Nw;
  omega(2:Lr-1,2:Mr-1,k)=omega(2:Lr-1,2:Mr-1,k-1) ...
         -   ( Huon(2:Lu,2:Mu-1,k-1)-Huon(1:Lu-1,2:Mu-1,k-1) ...
              +Hvom(2:Lv-1,2:Mv,k-1)-Hvom(2:Lv-1,1:Mv-1,k-1));
end;
for k=Nw-1:-1:2;
  omega(2:Lr-1,2:Mr-1,k)=omega(2:Lr-1,2:Mr-1,k) ...
                                -omega(2:Lr-1,2:Mr-1,Nw).* ...
             (z_w(2:Lr-1,2:Mr-1,k)-z_w(2:Lr-1,2:Mr-1,1))./ ...
             (z_w(2:Lr-1,2:Mr-1,Nw)-z_w(2:Lr-1,2:Mr-1,1));
end;
omega(2:Lr-1,2:Mr-1,Nw)=0;
%  Compute omega [m/s]
%

omega=omega.*pm3d.*pn3d;


if (wtype=='w'),

%
% Compute contributions due to (quasi-)horizontal motions along
% S=const surfaces by multiplying horizontal velocity components
% by slopes S-coordinate surfaces:
%

wrk(1:Lr,1:Mr)=0;
vert(1:Lr,1:Mr,1:Nw)=0;
for k=2:Nw;
  wrk(2:Lr,2:Mr-1)=u(1:Lu,2:Mu-1,k-1).* ...
         (z_r(2:Lr,2:Mr-1,k-1)-z_r(1:Lr-1,2:Mr-1,k-1)).* ...
                    (pm(2:Lr,2:Mr-1)+pm(1:Lr-1,2:Mr-1));

  vert(2:Lr-1,2:Mr-1,k)=.25*(wrk(2:Lr-1,2:Mr-1)+wrk(3:Lr,2:Mr-1));

  wrk(2:Lr-1,2:Mr)=v(2:Lv-1,1:Mv,k-1).* ...
         (z_r(2:Lr-1,2:Mr,k-1)-z_r(2:Lr-1,1:Mr-1,k-1)).* ...
                     (pn(2:Lr-1,2:Mr)+pn(2:Lr-1,1:Mr-1));

  vert(2:Lr-1,2:Mr-1,k)=vert(2:Lr-1,2:Mr-1,k)+ ...
                        0.25*(wrk(2:Lr-1,2:Mr-1)+wrk(2:Lr-1,3:Mr));

end;
% After that compute the actual vertical velocity. Note that the 
% horizontal contributions "vert" are naturally defined at vertical
% RHO-levels. Cubic interpolation is used to shift them to W-levels.

w(1:Lr,1:Mr,1:Nw)=0;
w(2:Lr-1,2:Mr-1,2)=omega(2:Lr-1,2:Mr-1,2) ...
       +0.75*vert(2:Lr-1,2:Mr-1,2)+0.5*vert(2:Lr-1,2:Mr-1,3) ...
                                 -0.05*vert(2:Lr-1,2:Mr-1,4);
for k=3:Nw-2;
 w(2:Lr-1,2:Mr-1,k)=omega(2:Lr-1,2:Mr-1,k) ...
     +0.5625*(vert(2:Lr-1,2:Mr-1,k  )+vert(2:Lr-1,2:Mr-1,k+1)) ...
     -0.0625*(vert(2:Lr-1,2:Mr-1,k-1)+vert(2:Lr-1,2:Mr-1,k+2));
end;
w(2:Lr-1,2:Mr-1,Nw)=0;
w(2:Lr-1,2:Mr-1,Nw-1)=omega(2:Lr-1,2:Mr-1,Nw-1) ...
     +0.375*vert(2:Lr-1,2:Mr-1,N)+0.75*vert(2:Lr-1,2:Mr-1,N-1) ...
                                -0.125*vert(2:Lr-1,2:Mr-1,N-2);
else,

  w=omega;

end,   % wtype=='w'

%
%  Set lateral boundary conditions: gradient
%

w(1,2:Mr-1,1:Nw)=w(2,2:Mr-1,1:Nw);
w(Lr,2:Mr-1,1:Nw)=w(Lr-1,2:Mr-1,1:Nw);
w(1:Lr,1,1:Nw)=w(1:Lr,2,1:Nw);
w(1:Lr,Mr,1:Nw)=w(1:Lr,Mr-1,1:Nw);


return

