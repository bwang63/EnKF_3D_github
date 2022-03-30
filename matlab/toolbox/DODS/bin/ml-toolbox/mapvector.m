function Vector = mapvector(ranges, stride, VectorRange, N, mapname)

if nargin < 4
  disp('Usage: mapvector(ranges, stride, VectorRange, VectorLength)')
  return
end

if nargin == 5
  disp([ 'Using simulated values for ' mapname '.'])
end

% switch to pixel-centered latitudes
pixel_spacing = abs(diff(VectorRange) / N);

% clip user selection ranges to dataset extent
if ranges(1) < min(VectorRange)
  ranges(1) = min(VectorRange);
end
if ranges(1) > max(VectorRange)
  ranges(1) = max(VectorRange);
end
if ranges(2) < min(VectorRange)
  ranges(2) = min(VectorRange);
end
if ranges(2) > max(VectorRange)
  ranges(2) = max(VectorRange);
end

if VectorRange(1) < VectorRange(2)
  pix_centered_range = VectorRange + [1 -1]*(pixel_spacing/2);
  inx(1) = floor((ranges(1) - pix_centered_range(1)) / pixel_spacing) + 1;
  inx(2) = ceil((ranges(2) - pix_centered_range(1)) / pixel_spacing) - 1;
elseif VectorRange(1) > VectorRange(2)
  pix_centered_range = VectorRange + [-1 1]*(pixel_spacing/2);
  inx(1) = floor((pix_centered_range(1) - ranges(2)) / pixel_spacing) + 1;
  inx(2) = ceil((pix_centered_range(1) - ranges(1)) / pixel_spacing) - 1;
else
  % there is only one pixel in this range
  Vector = VectorRange(1);
  return
end

% Construct the longitude vector in case this is an array rather than a grid. 
Sign = diff(VectorRange) / abs(diff(VectorRange));
Vector = pix_centered_range(1)+Sign*pixel_spacing*...
    (inx(1):stride:inx(2));
return
