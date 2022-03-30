% (R)oms (N)umerical (T)oolbox
%
% FUNCTION [Ue, Ve, dE]=rnt_ekmanUV(taoX,taoY,grd);
%
% Compute Ekman Currents based on the wind stress vector
% with component taoX and taoY. 
% dE    returns the Ekman depth
% AV    is the vertical viscosity
% GRD   is the grid control array.
%
% RNT - E. Di Lorenzo (edl@ucsd.edu)

function [Ue, Ve, dE, U10, Vo,Ut,Vt]=rnt_ekmanUV(taoX,taoY,grd)

tao.x = rnt_2grid(taoX, 'u','p');
tao.y = rnt_2grid(taoY, 'v','p');
  
% drag coefficient
Cd = 2.6e-3;
% density of air
rhoAir = 1.25 ;
% density of water
rhoW   = 1025;

% modulus of wind stress
T = sqrt( (tao.x).^2 + (tao.y).^2 );
% T = rhoAir*Cd*U10^2
% compute Ekman depth from scaling arguments
U10=sqrt(T/(rhoAir*Cd));
deg2rad=1/180 *pi;
phi= deg2rad*rnt_2grid(grd.latr, 'r','p');
U10=10;
dE = 7.6./sqrt((sin(abs(phi))) ).*U10;
Vo = 0.0127./sqrt((sin(abs(phi))) ).*U10;
%Av=1.0e-1;
%dE=sqrt(2*pi^2*Av./grd.f);
%dE=rnt_2grid(dE,'r','p');

f=rnt_2grid(grd.f,'r','p');

Ut=1./f/rhoW.*tao.y;
Vt=-1./f/rhoW.*tao.x;

in =find (abs(grd.latr)< 10);
if length(in) > 0 ; warning(' -- lat found < 10 degree'); end

TAO = [tao.x(:)' ; tao.y(:)'];
Z = rnt_setdepth(0,grd);
Z = rnt_2grid(Z,'r','p');
Z(:)=0;

for zlev=1:size(Z,3)
  arg=pi/4 + Z(:,:,zlev)*pi./dE;
  cff = sqrt(2)*pi./[rhoW*dE.*f].*exp( Z(:,:,zlev) *pi ./dE);
  Ue(:,:,zlev) = cff .* ( [tao.x] .* sin(arg) + [tao.y] .* cos(arg) );
  Ve(:,:,zlev) = cff .* (-[tao.x] .* cos(arg) + [tao.y] .* sin(arg) );
end






return

% test data
grd=rnt_gridload('usw20');
ctl= rnt_timectl( {'usw20-forc.nc'}, 'sms_time' );
tao.x = rnt_loadvar(ctl,6,'sustr');
tao.y = rnt_loadvar(ctl,6,'svstr');

[Ue, Ve, dE]=rnt_ekmanUV(tao.x,tao.y,grd);

rnt_plcm(dE,grd);
