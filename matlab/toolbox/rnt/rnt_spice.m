function spice = rnt_spice(potemp,salt)
% evaluates "spice" for specified potential temperature and salinity
% which are contained in the input variables "potemp" and "salt"
%
% note that potential temperature is available through the ferret
%      function THETA_FO(salt,temp,p,pref)
%
% example:
%         potemp = [5,5,5,5]
%         salt = [25,30,35,40]
%       go spice
%       list spice returns -8.044, -3.618, 0.418, 4.047
%
  b00=0          ;   b01=0.77442    ;   b02=-0.00585;
  b03=-9.84E-4   ;   b04=-2.06E-4;
  b10=5.1655E-2  ;   b11=2.034E-3   ;   b12=-2.742E-4;
  b13=-8.5E-6    ;   b14=1.36E-5;
  b20=6.64783E-3 ;   b21=-2.4681E-4 ;   b22=-1.428E-5;
  b23=3.337E-5   ;   b24=7.894E-6;
  b30=-5.4023E-5 ;   b31=7.326E-6   ;   b32=7.0036E-6;
  b33=-3.0412E-6 ;   b34=-1.0853E-6;
  b40=3.949E-7   ;   b41=03.029E-8  ;   b42=-3.8209E-7;
  b43=1.0012E-7  ;   b44=4.7133E-8;
  b50=-6.36E-10  ;   b51=-1.309E-9  ;   b52=6.048E-9;
  b53=-1.1409E-9 ;   b54=-6.676E-10;
  dsalt=salt-35;
  sp0=b00+dsalt.*(b01+dsalt.*(b02+dsalt.*(b03+b04.*dsalt)));
  sp1=b10+dsalt.*(b11+dsalt.*(b12+dsalt.*(b13+b14.*dsalt)));
  sp2=b20+dsalt.*(b21+dsalt.*(b22+dsalt.*(b23+b24.*dsalt)));
  sp3=b30+dsalt.*(b31+dsalt.*(b32+dsalt.*(b33+b34.*dsalt)));
  sp4=b40+dsalt.*(b41+dsalt.*(b42+dsalt.*(b43+b44.*dsalt)));
  sp5=b50+dsalt.*(b51+dsalt.*(b52+dsalt.*(b53+b54.*dsalt)));
 
spice=sp0+potemp.*(sp1+potemp.*(sp2+potemp.*(sp3+potemp.*(sp4+potemp.*sp5))));

return
for i=1:12
potemp=rnt_loadvar(ctl,i,'temp');
salt=rnt_loadvar(ctl,i,'salt');
zeta=rnt_loadvar(ctl,i,'zeta');
spice = rnt_spice(potemp,salt);
zr=rnt_setdepth(zeta,grd);
rho=rnt_rho_eos(potemp,salt,zr);
sigma_layers=[26:0.5:30];
spice_iso(:,:,:,i)=rnt_2sigma(spice,-rho,-[sigma_layers]);
i
end



