function var_child = nestvar4d(np,nc,igrid_par,jgrid_par,...
      igrid_child,jgrid_child,...
      varname,zindex,tindex)
%
%  Interpolate a 4D variable on a nested grid
%
imin=min(min(igrid_par));
imax=max(max(igrid_par));
jmin=min(min(jgrid_par));
jmax=max(max(jgrid_par));

var_par=squeeze(np{varname}(tindex,zindex,jmin:jmax,imin:imax));
switch varname
  case 'u'
    mask = np{'mask_u'}(:);
  case 'v'
    mask = np{'mask_v'}(:);
  otherwise
    mask = np{'mask_rho'}(:);
end
land = find(mask==0);
if ~isempty(land)
  mask(land) = NaN;
end

% var_par=nozero(igrid_par,jgrid_par,var_par);
var_child=interp2(igrid_par,jgrid_par,var_par.*mask,igrid_child,jgrid_child,'cubic');

nans = find(isnan(var_child)==1);
if ~isempty(nans)
  tmp = interp2(igrid_par,jgrid_par,var_par.*mask,igrid_child,jgrid_child,'linear');
  var_child(nans) = tmp(nans);
end
nans = find(isnan(var_child)==1);
if ~isempty(nans)
  tmp = interp2(igrid_par,jgrid_par,var_par.*mask,igrid_child,jgrid_child,'nearest');
  var_child(nans) = tmp(nans);
end
nans = find(isnan(var_child)==1);
if ~isempty(nans)
  warning([ 'There are NaNs in ' varname])
end

% this is done to maintain compatability with Manu's usage which
% writes the result directly into the netcd file
if nargout > 0
  % Wilkin  
else
  % EDL
  nc{varname}(tindex,zindex,:,:)=var_child;
end
