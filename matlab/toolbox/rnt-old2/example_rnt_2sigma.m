
% all is in x,y,z,t

file='/home/capet/Roms/NCfiles/Pacific/pac2calcofi_avg.nc';
file='/home/capet/Roms/NCfiles/Pacific/paclev2calcofi_avg.nc';
ctl=rnt_timectl({file},'time');

calc=ieh_LoadClima1949_1969;
temp=rnt_loadvar(ctl,7,'temp');
salt=rnt_loadvar(ctl,7,'salt');

grd=rnt_gridload('calc');

temp=calc.tempc(:,:,:,3);
salt=calc.saltc(:,:,:,3);

rnt_plcm(temp(:,:,1),grd);

zr=rnt_setdepth(0,grd);

z=-[     0
    10
    20
    30
    50
    75
   100
   125
   150
   200
   250
   300
   400
   500];

[I,J,K,T]=size(temp);
zr=perm(repmat(z,[ 1 J I]));

rho = rnt_rho_eos(temp,salt,zr);

isopyc=rnt_2sigma(zr,rho,[26.4]);



