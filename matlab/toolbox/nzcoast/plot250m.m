function han = plotm(varargin)
if nargin < 1
  plotopts={'k-'};
else
  plotopts = varargin;
end
nextplt_status = get(gca,'nextplot');
set(gca,'nextplot','add')

load([data_public 'nzcoast/bathymet/B_00250.MAT']);
a = plot(lon_250,lat_250,plotopts{:});

set(gca,'nextplot',nextplt_status);
if nargout > 0
  han = a;
end


