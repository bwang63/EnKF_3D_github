
function [ssh,ugeo,vgeo]=rnt_calcSSH(T,S,grd,varargin)
  

  if nargin > 3
    ZREF=varargin{1};
  else
    ZREF='bottom';
  end
  
  rho0=1025;
  rho_ref= (1025-1000);
  g=9.81;

% -----------------------------------------  
  
  [zr,zw,Hz]=rnt_setdepth(0,grd);
  for i=1:grd.N
   rho(:,:,i)=rnt_rho_eos(T(:,:,i),S(:,:,i),zr(:,:,i));
  end 
  rho2=rho;
  rho=rho.*repmat(grd.maskr,[1 1 grd.N]);
  zeta=grd.lonr*0;
  
  disp ('--    Computing GEOS ...');
  [ugeo,vgeo,rv,ru]=rnt_prsV2(zeta.*grd.maskr,rho,rho0,zr,zw,Hz,grd.f,grd);
  if strcmp(ZREF,'bottom');
    vref=vgeo(:,:,1);
    uref=ugeo(:,:,1);
  else
    zref=str2num(ZREF);
    vref=rnt_2z(vgeo,rnt_2grid(zr,'r','v'),-abs(zref));
    uref=rnt_2z(ugeo,rnt_2grid(zr,'r','u'),-abs(zref));
  end
  
  ugeo=ugeo - repmat(uref,[1 1 grd.N]);
  vgeo=vgeo - repmat(vref,[1 1 grd.N]);
  
  
  disp ('--    Filling NaN values')
  % fill nan values for vgeo
  in=find(isnan(grd.maskv));
  tmp=vgeo(:,:,end);
  ingood=find(~isnan(tmp));
  tmp(in)=0;
  inbad=find(isnan(tmp));
  pmapv=rnt_oapmap(grd.lonv(ingood),grd.latv(ingood), ingood, ...
     grd.lonv(inbad),grd.latv(inbad),10);
  
  for i=1:grd.N
    tmp=vgeo(:,:,i);
    tmp(in)=0;
    vrec=rnt_oa2d(grd.lonv(ingood),grd.latv(ingood), tmp(ingood), ...
       grd.lonv(inbad),grd.latv(inbad),3,3,pmapv,10);
    tmp(inbad)=vrec;
    vgeo(:,:,i)=tmp;
  end
  
  
  % fill nan values for ugeo
  in=find(isnan(grd.masku));
  tmp=ugeo(:,:,end);
  ingood=find(~isnan(tmp));
  tmp(in)=0;
  inbad=find(isnan(tmp));
  pmapu=rnt_oapmap(grd.lonu(ingood),grd.latu(ingood), ingood, ...
     grd.lonu(inbad),grd.latu(inbad),10);
  
  for i=1:grd.N
    tmp=ugeo(:,:,i);
    tmp(in)=0;
    vrec=rnt_oa2d(grd.lonu(ingood),grd.latu(ingood), tmp(ingood), ...
       grd.lonu(inbad),grd.latu(inbad),3,3,pmapu,10);
    tmp(inbad)=vrec;
    ugeo(:,:,i)=tmp;
  end
 
  
  
    
% now compute SSH
 
  if strcmp(ZREF,'bottom');
  %  zref=500;
    %disp('--    SSH ref. level is set to  500m');
  else
  %  zref=str2num(ZREF);
  end 
  zref=500;
  [zr,zw,Hz]=rnt_setdepth(0,grd);
  rho=rho2;
  press=rnt_prs(rho,zr, zw);
  zref=-500;
  press_ref=rnt_2z(press,zr,-abs(zref));
  rho_ref= (1025-1000);
  g=9.81;
  P = abs(rho_ref*zref*g);
  ssh = (- press_ref + P)/1025/g;
  ssh = ssh - mean( ssh(~isnan(ssh)));

  % fill nan values for ugeo
  in=find(isnan(grd.maskr));
  tmp=ssh;
  ingood=find(~isnan(tmp));
  tmp(in)=0;
  inbad=find(isnan(tmp));
  tmp2=rnt_oa2d(grd.lonr(ingood),grd.latr(ingood), tmp(ingood), ...
     grd.lonr(inbad),grd.latr(inbad),3,3);
  tmp(inbad)=tmp2;
  ssh=tmp;
  
  return
  
  
  
  ctlc = rnt_timectl( {'/d6/edl/ROMS-pak/usw20-data/usw20-clim.nc'},'tclm_time');
  T=rnt_loadvar(ctlc,10,'temp');
  S=rnt_loadvar(ctlc,10,'salt');
  V=rnt_loadvar(ctlc,10,'v');
  U=rnt_loadvar(ctlc,10,'u');
  [ssh,ugeo,vgeo]=rnt_calcSSH(T,S,grd,'bottom');
  
  
  %==========================================================
  % MANU's junk
  %==========================================================
  press=rnt_prs(rho,zr, zw);
  h=zr(:,:,1);
  Pb = press(:,:,1);
  P = abs(rho_ref*zr(:,:,1)*g);
  
  
  ssh = (- Pb + P)/1025/g./h;
  ssh = ssh - mean( ssh(~isnan(ssh)));
  
  
  
  
  
  [zr,zw,Hz]=rnt_setdepth(0,grd);
  rho=rnt_rho_eos(T,S,zr);
  press=rnt_prs(rho,zr, zw);
  
  [zr,zw,Hz]=rnt_setdepth(zeta,grd);
  rho=rnt_rho_eos(T,S,zr);
  press1=rnt_prs(rho,zr, zw);
  
  
  ssh=[press1-press]/1025/g; ssh=ssh(:,:,end);
  
  
  in=find(isnan(ssh));
  ssh(in)=0;
  [zr,zw,Hz]=rnt_setdepth(ssh,grd);
  rho0=1025;
  rho=rnt_rho_eos(T,S,zr);
  rho=rho.*repmat(grd.maskr,[1 1 grd.N]);
  [ugeo,vgeo,rv,ru]=rnt_prsgrd31(ssh.*grd.maskr,rho,rho0,zr,zw,Hz,grd.f,grd);
  
  
  
  [zr,zw,Hz]=rnt_setdepth(0,grd);
  rho=rnt_rho_eos(T,S,zr);
  press=rnt_prs(rho,zr, zw);
  zref=-500;
  press_ref=rnt_2z(press,zr,zref);
  rho_ref= (1025-1000);
  g=9.81;
  P = abs(rho_ref*zref*g)
  ssh = (- press_ref + P)/1025/g;
  ssh = ssh - mean( ssh(~isnan(ssh)));
  
  
  
  v_ref=rnt_2z(v,rnt_2grid(zr,'r','v'),-1000);
  
  p=vgeo(:,:,:)-repmat(vgeo(:,:,1),[1 1 grd.N]);;
  rnt_prsV2.m
  
  
  [zr,zw,Hz]=rnt_setdepth(zeta,grd);
  press1=rnt_prs(rho,zr, zw);
  rho0=1025;
  rho=rnt_rho_eos(T,S,zr);
  rho=rho.*repmat(grd.maskr,[1 1 grd.N]);
  
  
  [ugeo,vgeo,rv,ru]=rnt_prsgrd31(zeta.*grd.maskr,rho,rho0,zr,zw,Hz,grd.f,grd);

