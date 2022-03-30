function hanx = plot_niwa_eez(file,colors)
% hanx = plot_niwa_eez(file,colors)
%  
% file = 'eez' or 'charts'
% colors = a colormap
%
% I think this plots all the isobaths in the data set

nextplt_status = get(gca,'nextplot');

switch file
case 'charts'
   zlev = [0 10 20 30 50 100 200];
case 'eez'
   zlev = 250:250:10000;
   % zlev = [500 1000 2000 4000]; % liz map
otherwise
   error('file must be either charts or eez')
end

f = [data_public 'topo/' file];
load(f)

if nargin<2
   colors = jet(length(zlev));
end

for i=1:length(zlev)
   zp = zlev(i);
   in = find(z==zp | isnan(z)==1);
   han(i) = plot(lon(in),lat(in));
   set(gca,'nextplot','add')
   set(han(i),'color',colors(i,:));
end

set(gca,'nextplot',nextplt_status);

if nargout>0
   hanx = han;
end
