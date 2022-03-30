
function pac_coast(varargin)

if nargin == 0
   color='k';
   varargin{1} = color;
end

load(which('rgrd_WorldCstLinePacific.mat'));
plot(lon+360,lat,varargin{:})
