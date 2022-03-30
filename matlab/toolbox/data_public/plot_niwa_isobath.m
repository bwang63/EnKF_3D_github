function [han,lonlats] = plot_niwa_isobath(zlev,varargin)
% [han,lonlats] = plot_niwa_isobath(zlev,color);
%
% Plot the isobaths zlev from the NIWA depth data files
% Valid values are [0 10 20 30 50 100 200 250:250:10000]
%
% Outputs: 
%     han = handles of the plotted lines
%     lonlats = depth and coords for each isobath (structure)

nextplt_status = get(gca,'nextplot');

set(gca,'nextplot','add')

for i=1:length(zlev)
   if zlev(i)<=200
     file = 'charts';
   else
     file = 'eez';
   end
   f = [data_public 'topo/' file];
   tmp = load(f);
   z = tmp.z;
   lon = tmp.lon;
   lat = tmp.lat;
   zp = zlev(i);
   in = find(z==zp | isnan(z)==1);
   hanx(i) = plot(lon(in),lat(in),varargin{:});
   if nargout > 1
     dep{i} = zp;
     lll{i} = [lon(in) lat(in)];
   end   
end

set(gca,'nextplot',nextplt_status);

if nargout > 0
   han = hanx;
   if nargout > 1
     lonlats.depth = dep;
     lonlats.coords = lll;
   end   
end


