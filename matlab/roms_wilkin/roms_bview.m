function [Data,han] = roms_bview(file,varname,time,bndy,grd,xcoord)
% $Id$
% [data,han] = roms_bview(file,var,time,bndy,grd,xcoord)
%
% file   = roms his/avg/rst etc nc file
% var    = variable to plot
% time   = time index into nc file
% bndy   = 'north','south','east','west'
% grd can be 
%       grd structure (from roms_get_grid)
%       grd_file name
%       [] (will attempt to get grid from roms file)
% xcoord = 'lon','lat', or 'dist' (default) to specify plot abscissa
%
% John Wilkin

if nargin < 5
  grd = [];
end
if nargin < 6
  xcoord = 'dist';
end

if isempty(grd)
  try
    grd = roms_get_grid(file,file);
  catch
    error([ 'Unable to generate grd structure from ' file])
  end
end

% trap case that varname was given with boundary included
nsew_check = findstr(varname,'_');
if ~isempty (nsew_check)
    bndy = varname((nsew_check+1):end);
else    
    varname = [varname '_' bndy];
end

% get appropriate z data for u, v or rho points
switch varname(1)
  case 'u'
    pos = '_u';
  case 'v'
    pos = '_v';
  otherwise
    pos = '_rho';
end
z = getfield(grd,[ 'z' pos(1:2)]);
lon = getfield(grd,[ 'lon' pos]);
lat = getfield(grd,[ 'lat' pos]);
m = getfield(grd,[ 'mask' pos]);

% choose z data for correct boundary
switch bndy(1)
  case 'w'
    z = z(:,:,1);
    lon = lon(:,1);
    lat = lat(:,1);
    m = m(:,1);
  case 'e'
    z = z(:,:,end);
    lon = lon(:,end);
    lat = lat(:,end);
    m = m(:,end);
  case 's'
    z = z(:,1,:);
    lon = lon(1,:);
    lat = lat(1,:);
    m = m(1,:);
  case 'n'
    z = z(:,end,:);
    lon = lon(end,:);
    lat = lat(end,:);
    m = m(end,:);
end
z = squeeze(z);
lon = lon(:);
lat = lat(:);
m = m(:);
m(find(m==0)) = NaN;

% compute approximate distance on sphere between lon/lat coordinate pairs
rearth = 6370.800; % km
dy = rearth*pi/180*diff(lat);
dx = rearth*pi/180*diff(lon).*cos(pi/180*0.5*(lat(2:end)+lat(1:end-1)));
dist = cumsum([0; sqrt(dx(:).^2+dy(:).^2)]);
% dist = cumsum([0; sw_dist(lat,lon,'km')]);

dist = repmat(dist',[size(z,1) 1]);
lon = repmat(lon',[size(z,1) 1]);
lat = repmat(lat',[size(z,1) 1]);
m = repmat(m',[size(z,1) 1]);

data = nc_varget(file,varname,[time-1 0 0],[1 -1 -1]);

% time information
dateformat = 1;
try
  [dnum,dstr] = roms_get_date(file,time,dateformat);
  tstr = [' - Date ' dstr];
catch
  warning([ 'Problem parsing date from file ' file ' for time index ' time]) 
end

if nargout > 0
  Data.var = data;
  Data.lon = lon;
  Data.lat = lat;
  Data.dist = dist;
  Data.mask = m;
  Data.z = z;
  Data.dnum = dnum;
end

% pcolor plot of the variable
titlestr = ...
  {['file: ' strrep_(file) ],...
  [upper(strrep_(varname)) tstr]};

switch xcoord
  case 'lon'
    hant = pcolorjw(lon,z,m.*data);
    xlabel('longitude')
  case 'lat'
    hant = pcolorjw(lat,z,m.*data);
    xlabel('latitude')
  otherwise
    hant = pcolorjw(dist,z,m.*data);
    xlabel('distance (m)')
end
title(titlestr)

if nargout > 1
  han = hant;
end
