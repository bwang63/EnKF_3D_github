function LonVector = maplon(get_archive, get_dset_stride, lon)

if nargin < 3
  disp('Usage: maplon(archive, stride, longitudes)')
  return
end

if exist(get_archive) == 2
  eval(get_archive)
else
  dodsmsg(['Problem reading dataset metadata ' get_archive '.m'])
  return
end

% switch to pixel-centered latitudes
pixel_spacing(1) = abs(diff(LonRange) / Nlon);
pixel_spacing(2) = abs(diff(LatRange) / Nlat);

if LonRange(1) < LonRange(2)
  pixel_centered_lon = LonRange + [1 -1]*(pixel_spacing(1)/2);
  column(1) = floor((lon(1) - pixel_centered_lon(1)) / pixel_spacing(1)) + 1;
  column(2) = ceil((lon(2) - pixel_centered_lon(1)) / pixel_spacing(1)) - 1;
else
  pixel_centered_lon(1) = LonRange + [-1 1]*(pixel_spacing(1)/2);
  column(1) = floor((pixel_centered_lon(1) - lon(2)) / pixel_spacing(1)) + 1;
  column(2) = ceil((pixel_centered_lon(1) - lon(1)) / pixel_spacing(1)) - 1;
end

% Construct the longitude vector in case this is an array rather than a grid. 
LonSign = diff(LonRange) / abs(diff(LonRange));
LonVector = pixel_centered_lon(1)+LonSign*pixel_spacing(1)*...
    (column(1):get_dset_stride:column(2));
return
