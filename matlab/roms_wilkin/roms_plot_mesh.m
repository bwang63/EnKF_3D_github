function h = roms_plot_mesh(g,n,c,cgrid)
% $Id$
% han = roms_plot_mesh(grd,decimation_factor,color,cgridposition)
%
% Plot a mesh showing a ROMS grid over an existing plot
% cgridposition can be 'rho', 'psi', 'edge'/'boundary'

% get plot state
nextplotstatewas = get(gca,'nextplot');

% hold whatever is already plotted
set(gca,'nextplot','add')

if nargin < 2
  n=5;
end
if nargin < 3
  c = 0.7*[1 1 1];
end
if nargin < 4
  cgrid = 'psi';
end

switch cgrid(1)
  case 'r'
    han1=plot(g.lon_rho(1:n:end,1:n:end),g.lat_rho(1:n:end,1:n:end),'w-');
    han2=plot(g.lon_rho(1:n:end,1:n:end)',g.lat_rho(1:n:end,1:n:end)','w-');
    han = [han1; han2];
  case 'p'
    han1=plot(g.lon_psi(1:n:end,1:n:end),g.lat_psi(1:n:end,1:n:end),'w-');
    han2=plot(g.lon_psi(1:n:end,1:n:end)',g.lat_psi(1:n:end,1:n:end)','w-');
    han = [han1; han2];
  otherwise
    han1=plot(g.lon_psi(1:end,1),g.lat_psi(1:end,1),'w-');
    han2=plot(g.lon_psi(1:end,end),g.lat_psi(1:end,end),'w-');
    han3=plot(g.lon_psi(1,1:end),g.lat_psi(1,1:end),'w-');
    han4=plot(g.lon_psi(end,1:end),g.lat_psi(end,1:end),'w-');
    han = [han1; han2; han3; han4];
end

set(han,'linew',0.5,'color',c);

if nargout>0
  h = han;
end

% restore nextplotstate to what it was
set(gca,'nextplot',nextplotstatewas);
