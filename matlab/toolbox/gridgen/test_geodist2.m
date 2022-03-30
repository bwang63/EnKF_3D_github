fig3 = figure ( 'name', 'Geographic Coordinates' );
plot(min_lon, min_lat, 'r*' );
hold on
plot(grid_obj.coastline_longitude, grid_obj.coastline_latitude);
h = plot(lon_rho, lat_rho, lon_rho', lat_rho' );
set(h,'color','k');
h = plot(min_lon_grid, min_lat_grid,'ro');
set(h,'markersize',15);
h = plot(min_lon_grid, min_lat_grid,'ro');
ind = [1:20:length(xbathy)];
plot(lon_bathy(ind),lat_bathy(ind),'g*');


fig4 = figure ( 'name', 'Meter Coordinates' );
plot(0,0, 'r*' );
hold on
plot(coast_in_meters_x, coast_in_meters_y);
h = plot(x,y,x',y');
set(h,'color','k');
h = plot(grid_offset_x, grid_offset_y,'ro');
set(h,'markersize',15);
h = plot(grid_offset_x, grid_offset_y,'ro');
plot(mxbathy(ind),mybathy(ind),'g*');



