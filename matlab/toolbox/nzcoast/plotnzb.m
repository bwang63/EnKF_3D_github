function han = plotnzb(isobath,varargin)
% [han] = plotnzb(isobath,'plot options')
%
% plot an isobath from Steve Chiswell's (via N. Oien) isobath files 
%
% Inputs:
%   isobath (>0) is the desired isobath to plot 
%   'plot options' is any valid set of linetype,color,style etc. options
%    acceptable to the matlab plot command 
%
% Outputs
%   handle to plotted line
%
% This command adds the plot to the existing axes and preserves the
% 'nextplot' status of the current axes
%
% John Wilkin 
% March 16, 2000

if nargin < 1
  isobath = 0 ;
end
useisobath = round(isobath/250)*250;
useisobath = min(useisobath,10000);
if useisobath ~= isobath
  disp(['plotnzb doesn''t have data for ' int2str(isobath) ' m'])
  disp(['Plotting nearest depth contour: ' int2str(useisobath) ' m instead'])
end
iso_str = int2str(useisobath);
lon_str = ['lon_' iso_str];
lat_str = ['lat_' iso_str];
filestr = '00000';
filestr((6-length(int2str(useisobath))):5) = iso_str;

if nargin < 2
  plotopts={'k-'};
else
  plotopts = varargin;
end
nextplt_status = get(gca,'nextplot');
set(gca,'nextplot','add')

% load([data_public 'nzcoast/bathymet/B_' filestr '.MAT']);
load([data_public 'nzcoast/bathymet/B_' filestr]);
plotstr = ['a = plot(' lon_str ',' lat_str ',plotopts{:});'];
eval(plotstr)

set(gca,'nextplot',nextplt_status);
if nargout > 0
  han = a;
end


