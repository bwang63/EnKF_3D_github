function han = plotm(varargin)
if nargin < 1
  plotopts={'k-'};
else
  plotopts = varargin;
end
nextplt_status = get(gca,'nextplot');
set(gca,'nextplot','add')

load([data_public 'nzcoast/bathymet/B_00500.MAT']);
a = plot(lon_500,lat_500,plotopts{:});

set(gca,'nextplot',nextplt_status);
if nargout > 0
  han = a;
end


