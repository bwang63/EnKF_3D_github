function LatVector = maplat(get_archive, get_dset_stride, lat)

if nargin < 3
  disp('Usage: maplat(archive, stride, latitudes)')
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

% compute array rows from latitudes and latrange
if LatRange(1) < LatRange(2)
  pixel_centered_lat = LatRange + [1 -1] * (pixel_spacing(2)/2);
  row(1) = ceil((lat(1) - pixel_centered_lat(1)) / pixel_spacing(2));
  row(2) = floor((lat(2) - pixel_centered_lat(1)) / pixel_spacing(2));
else
  pixel_centered_lat = LatRange + [-1 1] * (pixel_spacing(2)/2);
  row(1) = ceil((pixel_centered_lat(1) - lat(2)) / pixel_spacing(2));
  row(2) = floor((pixel_centered_lat(1) - lat(1)) / pixel_spacing(2));
end

if row(1) <0, row(1) = 0; end
if row(2) > Nlat, row(2) = Nlat; end
% added fix, 98/04/13 D.B.
if row(1) > row(2), row(2) = row(1); end
  
% Construct the latitude vector
LatSign = diff(LatRange) / abs(diff(LatRange));
LatVector = pixel_centered_lat(1)+LatSign*pixel_spacing(2)*...
    (row(1):get_dset_stride:row(2));
return
