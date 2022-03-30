function nestvar3d(np,nc,igrid_par,jgrid_par,...
                   igrid_child,jgrid_child,...
                   varname,tindex)
%
%  Interpole a 3D variable on a nested grid...
%
imin=min(min(igrid_par));
imax=max(max(igrid_par));
jmin=min(min(jgrid_par));
jmax=max(max(jgrid_par));

var_par=squeeze(np{varname}(tindex,jmin:jmax,imin:imax));
var_child=interp2(igrid_par,jgrid_par,var_par,igrid_child,jgrid_child,'cubic');
nc{varname}(tindex,:,:)=var_child;
return
