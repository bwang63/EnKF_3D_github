function varlist = roms_varlist(option)
% $Id$
switch option
  case 'physics'  
    varlist = {'temp','salt','u','v','ubar','vbar','zeta'};
  case 'physics2d'
    varlist = {'ubar','vbar','zeta'};
  case 'physics3d'
    varlist = {'temp','salt','u','v'};
   case 'mixing3d'
    varlist = {'AKv','AKt','AKs'};
  case 's-param'
    varlist = {'theta_s','theta_b','Tcline','hc'};
  case 's-coord'
    varlist = {'s_rho','s_w','Cs_r','Cs_w'};
  case 'grid'
    varlist = {'h','f','pm','pn','angle','lon_rho','lat_rho',...
      'lon_u','lat_u','lon_v','lat_v','lon_psi','lat_psi',...
      'mask_rho','mask_u','mask_v','mask_psi'};
end
