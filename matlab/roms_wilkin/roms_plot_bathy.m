function han = roms_plot_bathy(grd,cmap,clev,var);
% $Id$
% han = roms_plot_bathy(grd,cmap,clev,var);
% 
% defaults:
%    clev = [100 250 500 1000:1000:4000];
%    cmap = zebra(2,64);
%    var = 'h' (if var='r' r-value is plotted)

if ischar(grd)
  grd_file = grd;
  grd = get_roms_grid(grd_file);
else
  grd_file = ' ';
end

if nargin < 2
  colormap(zebra(2,64))
else
  if isempty('cmap')
    colormap(zebra(2,64))
  else
    colormap(cmap)
  end
end

if nargin < 3
  clev = [100 250 500 1000:1000:4000];
else
  if isempty('clev')
    lev = [100 250 500 1000:1000:4000];
  end
end

if nargin < 4
  var = 'h';
end

switch var
   case 'h'
      pcolorjw(grd.lon_rho,grd.lat_rho,grd.h.*grd.mask_rho_nan)
   case 'r'
      pcolorjw(grd.lon_rho,grd.lat_rho,rvalue(grd.h).*grd.mask_rho_nan)
end

caxis([0 max(clev)])
hold on
[cs,hanc] = contour(grd.lon_rho,grd.lat_rho,grd.h.*grd.mask_rho_nan,clev);
set(hanc,'edgecolor','k')
amerc
grid on
set(gca,'tickdir','out')
titlestr{1} = ['Model bathymetry ' strrep(grd_file,'_','\_')];
if strcmp(var,'r')
    titlestr{2} = 'r-value';
end
title(titlestr,'fontsize',16)
colorbar('h')

if nargout > 0
  han = hanc;
end

