function hanx = plot_niwa_eez(zlev,colors,file)
%  hanx = plot_niwa_eez(file,colors,zlev)
%
% file = 'eez' or 'charts'
% colors = a colormap
% zlev = desired isobath (the nearest is plotted)

nextplt_status = get(gca,'nextplot');

if nargin < 3;
  file = 'eez';
end

if nargin < 2
   colors = jet(length(zlev));
end

switch file
  case 'charts'
   zlev = [0 10 20 30 50 100 200];
  case 'eez'
   zlev = 250:250:10000;
  otherwise
   error('file must be either charts or eez')
end

f = [data_public 'topo/' file];
load(f)

for i=1:length(zlev)
  keyboard
   zp = zlev(i);
   in = find(z==zp | isnan(z)==1);
   han = plot(lon(in),lat(in));
   set(gca,'nextplot','add')
   set(han,'color',colors(i,:));
   hans(i) = han;
end

set(gca,'nextplot',nextplt_status);

if nargout>0
   hanx = hans;
end
