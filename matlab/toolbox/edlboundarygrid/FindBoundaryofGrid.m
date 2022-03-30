
function corners_data=FindBoundaryofGrid(grd)


corners.lon = [grd.lonr(1,end) grd.lonr(1,1) grd.lonr(end,1) grd.lonr(end,end)]';
corners.lat = [grd.latr(1,end) grd.latr(1,1) grd.latr(end,1) grd.latr(end,end)]';

corners_data = [corners.lon corners.lat ones([4 1])];
