
function plcoast(cstfile, varargin)

if nargin == 1
   color='k';
   varargin{1} = color;
end

load(cstfile);
plot(lon,lat,varargin{:})
