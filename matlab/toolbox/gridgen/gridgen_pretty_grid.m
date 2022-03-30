function gridgen_pretty_grid()

global grid_obj;

a = figure ( 'Position', [10 10 600 400], ...
             'Name', sprintf ( '%s', grid_obj.scrum_file ), ...
	     'NumberTitle', 'Off' ); 


%
% Plot the coastline in the projected coordinate system.
[projected_coastx, projected_coasty] = ...
    m_ll2xy ( grid_obj.coastline_longitude, grid_obj.coastline_latitude );
h = plot(projected_coastx, projected_coasty);
set(h,'color','k','linewidth',2);

hold on


%
% Plot the bathymetry.
[projected_x, projected_y] = m_ll2xy ( grid_obj.lon_rho, grid_obj.lat_rho );
depth = grid_obj.grid_bathymetry;
bathy_max = max(depth(:));
ind = find(depth==-99999);
depth(ind) = NaN*ones(size(ind));
pslice(projected_x,projected_y,-depth,[-bathy_max 0]);

hold on

%
% Plot the grid.
h = plot( projected_x, projected_y, projected_x', projected_y' );
set(h,'color','k');

%
% Put the coastline back on top.
h = plot(projected_coastx, projected_coasty);
set(h,'color',[0 0.5 0.5],'linewidth',2);

xmax = max(projected_coastx);   
xmin = min(projected_coastx);
ymax = max(projected_coasty);   
ymin = min(projected_coasty);
xdiff = xmax-xmin;
ydiff = ymax-ymin;
set ( gca,'xlim', [xmin-0.1*xdiff xmax+0.1*xdiff] );
set ( gca,'ylim', [ymin-0.1*ydiff ymax+0.1*ydiff] );

%cmap = flipud(jet(200));
%colormap(cmap(100:200,:));


return;

