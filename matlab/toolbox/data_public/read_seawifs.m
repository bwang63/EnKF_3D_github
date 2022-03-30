function [chla,lon,lat,date,metadata,params] = read_seawifs(file,ax,rescale)
% Read SeaWiFS level3 gridded chlorophyll data from hdf files
% [chla,lon,lat,date,metadata,params] = read_seawifs(file,ax,rescale)
%
% Inputs:
%    file = SeaWiFS hdf file
%    ax (optional) = lon/lat limits vector (as used by axis)
%       ifempty get all data in the file
%    rescale value determines whether the data returned is rescaled
%       = 'log' (default) result is the log(chla) data as in the file
%       = 'lin' data is rescaled to true chl-a concentration units
%
% Outputs:
%    chla = log(chlorophyll-a) 
%    lon/lat = vectors of the coordinates
%    date = central time of the data (string in datenum/datestr format)
%    metadata = the hdf file metadata describing all the data attributes
%       [the output of metadata = hdfinfo(file)]
%    params = vector of [Base Slope Intercept] used to convert data to chl-a
%       Value = Base.^((Slope*l3m_data)+Intercept)
%
% PLOTTING ------------------------------------------------------
% The data is best plotted in default log(chl-a) units, e.g.:
%  Plotting log chl-a values
%   [chla,lon,lat,date,metadata,p] = read_seawifs(file,ax,'log');
%   pcolor(lon,lat,chla);shading flat
%   han = colorbar;
%   ytickvals = [0.05 .1 .2 .5 1 2 5 10 20 50];
%   set(han,'ytick',(log10(ytickvals)-p(3))/p(2))
%   yticklabels = num2str((10.^(get(han,'ytick')*p(2)+p(3)))',3);
%   set(han,'yticklabels',yticklabels)
%
% GETTING THE DATA FILES -----------------------------------------
% SeaWiFS data are available to authorized users at:
%    http://daac.gsfc.nasa.gov/data/dataset/SEAWIFS
%
% John Wilkin - Oct 2000
% $Id: read_seawifs.m,v 1.4 2001/10/03 21:42:54 wilkin Exp wilkin $

if ~exist('hdfinfo') ~=2
  % Chris Lawton's hdfread and hdfinfo
  HDFMATLABPATH = '/home/wilkin/matlab/hdf-matlab'
  addpath(HDFMATLABPATH,'-begin')
end

if nargin==0
  help(mfilename)
  % My seawifs access account
  disp(['  wilkin@imcs.rutgers.edu/9eaxifs'])
  return
end

% the data
data = hdfread(file,'l3m_data');

% the coordinates
nlat = size(data,1);
dlat = 180/nlat;
nlon = size(data,2);
dlon = 360/nlon;
lat  = (90-(0:nlat-1)*dlat)-dlat/2;
lon  = (0:nlon-1)*dlon-180+dlon/2;

if nargin > 1
  if ~isempty(ax)
    % obtain requested subregion
    I = find(lon>=ax(1)&lon<=ax(2));
    J = find(lat>=ax(3)&lat<=ax(4));
    data = data(J,I);
    lon = lon(I);
    lat = lat(J);
  end
end

metadata  = hdfinfo(file);

% date
start_year = double(metadata.Attributes(21).Value);
end_year   = double(metadata.Attributes(23).Value);
start_day  = double(metadata.Attributes(22).Value);
end_day    = double(metadata.Attributes(24).Value);
date       = datestr(0.5*(datenum(start_year,1,start_day)+...
    datenum(end_year,1,end_day)));      

% Base**((Slope*l3m_data) + Intercept) = Parameter value 
Base      = double(metadata.Attributes(55).Value);
Slope     = double(metadata.Attributes(56).Value);
Intercept = double(metadata.Attributes(57).Value);
params    = [Base Slope Intercept];

if nargin < 3
  rescale = 'log';
end

% return data with default (log) scaling, or convert to true chl-a
% concentration 

data = double(data);
missing = find(data==255);
data(missing) = NaN;

switch rescale
  
  case 'lin'
    
    chla  = Base.^(Slope*double(data)+Intercept);
    
  otherwise

    % no nothing
    chla = double(data);
    eqn = ['chla = ' int2str(Base) '.^(' num2str(Slope) ...
	  '*chla+(' num2str(Intercept) '))'];
    disp(['Convert to chl-a concentration values with:'])
    disp(eqn)

end
