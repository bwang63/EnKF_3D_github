function [sst,lon,lat,sst_date,metadata,imagedata] = read_pfsst_hdf(file,ax)
% Read sea surface temperature data from JPL Pathfinder Project or 
% Multichannel SST (MCSST) hdf format data files
%
% [sst,lon,lat,sst_date,metadata,imagedata] = read_pfsst_hdf(file,ax)
%
% Inputs:
%    file = the hdf data file
%    ax (optional) = a lon/lat range vector (like axis uses) to define a
%       subregion of the global domain to extract 
%
% Outputs:
%    sst = the data (missing values are converted to NaN)
%    lon/lat = vectors of the coordinates
%    sst_date = string describing the central time of the data (in the
%       format used by the Matlab datenum/datestr functions)
%    metadata = the hdf file metadata describing all the data attributes
%       [the output of metadata = hdfinfo(file)]
%    imagedata = structure output
%       imagedata.sst = sst image data (int8)
%       imagedata.map = image colormap
%          The image can be displayed in Matlab with the command:
%          >> imshow(imagedata.sst,imagedata.map)
%
% GETTING THE DATA FILES -----------------------------------------
% MCSST data files may be obtained from:
%    http://podaac.jpl.nasa.gov/mcsst/mcsst_data.html
%
% Pathfinder data files may be obtained from:
%    http://podaac.jpl.nasa.gov/sst/sst_data.html
%    (Click "subset" to request a regional subset - registration is quick,
%    easy and free).
%
% ----------------------------------------------------------------
% JPL SST data reference:
% http://podaac.jpl.nasa.gov/pub/sea_surface_temperature/avhrr/pathfinder/
% doc/usr_gde4_0_toc.html
%
% This function requires the hdfinfo and hdfread functions provided by
% Chris Lawton of The Mathworks Inc. (to appear in a future release of
% Matlab). These are presently loaded from HDFMATLABPATH (see code below).
%
%
% BUGS:
%   There seems to be some variable behaviour when handling different
%   Pathfinder hdf files. This version works for regional susbsets of 9km
%   data requested from the podacc web site. 
%
%   Longitude/latitude are not calculated accurately and do not exactly 
%   coincide with the Pathfinder Equal Area bin centers. (See notes in the
%   code below - email me if you fix this).
%
%
% John Wilkin - j.wilkin@niwa.cri.nz
% $Id: read_pfsst_hdf.m,v 1.3 2001/09/15 02:26:05 wilkin Exp wilkin $

if ~exist('hdfinfo') ~=2
  % Chris Lawton's hdfread and hdfinfo
  HDFMATLABPATH = '/h1/wilkin/wilkin/matlab/hdf-matlab';
  addpath(HDFMATLABPATH,'-begin')
end

% Read the metadata from the hdf file
metadata = hdfinfo(file);

% Determine whether this is a Pathfinder SST or Multichannel SST file
% Pathfinder:
%    metadata.Attributes(1).Value == 'AVHRR Oceans Pathfinder Equal Angle '
% MCSST: 
%    metadata.Attributes(1).Value == 'MCSST Sea Surface Temperature '
%
% This information affects the processing of the longitude, date, and
% missing values
%
if ~isempty(findstr(metadata.Attributes(1).Value,'Pathfinder'))
  sst_type = 'Pathfinder';
elseif ~isempty(findstr(metadata.Attributes(1).Value,'MCSST'))
  sst_type = 'MCSST';
else
  sst_type = 'unknown';
end

% Extract the scale and offset [scale_factor and add_offset appear to
% be in these locations in all Pathfinder and MCSST hdf files.]
scale_factor = metadata.SDS(1).Attributes(1).Value;
add_offset = metadata.SDS(1).Attributes(3).Value;

% Read the raster image data from the hdf file
% FYI these values can be viewed easily with imshow(sst,map)
switch sst_type
  case 'Pathfinder'
    [sst,map] = imread(file);
  case 'MCSST'
    % ref=3 for interpolated SST (ref=2 is 8day average with gaps)
    ref = 3;
    [sst,map] = imread(file,ref);
end
if nargout > 5
  imagedata.sst = sst;
  imagedata.map = map;
end

switch sst_type
  
  case 'Pathfinder'    
    % scan the attributes list because these entries because these entries
    % from one hdf file to another      
    attriblist = metadata.Attributes(1).Name;
    for k=2:size(metadata.Attributes,2)
      attriblist = strvcat(attriblist, metadata.Attributes(k).Name);
    end
end

% Date
if nargout > 3
  switch sst_type
    
    case 'Pathfinder'
      try
	% This works for 9km regional subsets
	k = strmatch('Data start time',attriblist);
	date_start = metadata.Attributes(k).Value;
	k = strmatch('Data end time',attriblist);
	date_end   = metadata.Attributes(k).Value;	
	sst_date   = datestr(0.5*(datenum(date_start)+datenum(date_end)));
      catch
        % The format of these attributes is variable so trap any problem and
	% keep going
        warning(lasterr)
	sst_date = [];
      end
        
    case 'MCSST'
      try
        start_year = double(metadata.Attributes(11).Value);
	end_year   = double(metadata.Attributes(12).Value);
	start_day  = double(metadata.Attributes(13).Value);
	end_day    = double(metadata.Attributes(14).Value);
	sst_date   = datestr(0.5*(datenum(start_year,1,start_day)+...
	    datenum(end_year,1,end_day)));      
      catch
        warning(lasterr)
	sst_date = [];
      end      
    
    otherwise
      sst_date = 'unknown';
  end      
end

% lon/lat coordinates
% Pathfinder documentation says ...
% longitude=(i-1)*dx.+x1
% latitude=y1-(j-1)*dx

switch sst_type
  
  case 'MCSST'
    
    nlat = size(sst,1);
    dlat = 180/nlat;
    nlon = size(sst,2);
    dlon = 360/nlon;
    lat = (90-(0:nlat-1)*dlat)-dlat/2;
    lon = (0:nlon-1)*dlon-180+dlon/2;

  case 'Pathfinder'
    
    % Handle regional subsetting - we can't use the total number of 
    % points to determine the resolution (9km, 18km etc)
    k = strmatch('Minimum Longitude',attriblist);
    lon_min = double(metadata.Attributes(k).Value);
    k = strmatch('Maximum Longitude',attriblist);
    lon_max = double(metadata.Attributes(k).Value);
    if lon_max < 0
      lon_max = lon_max+360;
    end    
    lon = linspace(lon_min,lon_max,size(sst,2));

    k = strmatch('Minimum Latitude',attriblist);
    lat_min = double(metadata.Attributes(k).Value);
    k = strmatch('Maximum Latitude',attriblist);
    lat_max = double(metadata.Attributes(k).Value);   
    lat = linspace(lat_max,lat_min,size(sst,1));
	
    % There can be a small lon/lat error here because the min/max
    % values given in the hdf file do not fall exactly on the bin centers used
    % by the Pathfinder processing. The error is less than the bin
    % spacing. I can't think of any easy way to fix this because the hdf
    % attributes don't document the lon spacing or the nominal resolution
    % (9km, 18km etc).
   
end

% flip lat and sst
sst = flipud(sst);
lat = fliplr(lat);

switch sst_type
  case 'Pathfinder'
    
    % Shift lon to 0->360 instead of -180->180. I prefer it this way

    % This shift was necessary when first testing the global Pathfinder
    % datasets, but using the regional subsets the dateline shift issue goes
    % away so tihs step is disabled
    if 0
      movedateline = [min(find(lon>0)):length(lon) 1:max(find(lon<0))];
      sst = sst(:,movedateline);
      lon = lon(movedateline);
      lon(lon<0) = lon(lon<0)+360;
      if nargout > 5
	imagedata.sst = imagedata.sst(:,movedateline);
      end
    end
    
  case 'MCSST'
    lon = lon+180;
end

if nargin > 1
  % obtain requested subregion
  I = find(lon>=ax(1)&lon<=ax(2));
  J = find(lat>=ax(3)&lat<=ax(4));
  sst = sst(J,I);
  lon = lon(I);
  lat = lat(J);
end

% convert image data to temperature
sst = add_offset+scale_factor*double(sst);

switch sst_type
  case 'Pathfinder'
    missing = find(sst==add_offset);
    sst(missing) = NaN;
  case 'MCSST'
    missing = find(sst==add_offset);
    sst(missing) = NaN;
    missing = find(sst==add_offset+scale_factor*255);
    sst(missing) = NaN;
end
