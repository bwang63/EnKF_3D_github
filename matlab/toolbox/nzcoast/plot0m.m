function han = plotm(varargin)
if nargin < 1
  plotopts={'k-'};
else
  plotopts = varargin;
end
nextplt_status = get(gca,'nextplot');
set(gca,'nextplot','add')

load([data_public 'nzcoast/bathymet/B_00000.MAT']);
a = plot(lon_0,lat_0,plotopts{:});

set(gca,'nextplot',nextplt_status);
if nargout > 0
  han = a;
end


