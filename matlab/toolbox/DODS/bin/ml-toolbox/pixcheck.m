function [index] = pixcheck(user_ranges, VarRange, NVar)

% PIXCHECK convert from geographic coordinates to row/column indices.
% part of the DODS Matlab GUI/Toolbox.
%
% USAGE: [INDICES] = PIXCHECK(RANGES, VARIABLE_RANGE, NVAR)

index = [nan nan];
if nargin < 3
  dodsmsg('Usage: [rows, columns] = pixcheck(ranges, variablerange, nvar)')
  return
end

% The user defines the region of interest from the outer edges
% convert to pixel-centered coords:
pixel_spacing = abs(diff(VarRange) / NVar);

% computed array indices from dataset range and user selection ranges.

if VarRange(1) < VarRange(2)
  pcc = VarRange + [1 -1]*(pixel_spacing/2);
  pcc = pcc(1);
% PCC 2/1/02 added 1 to each of the following two lines +1 ==> +2 and -1 ==> 0
% Map element number is one larger than the number of grid spacings.
  index(1) = floor((user_ranges(1) - pcc) / pixel_spacing) + 2;
  index(2) = ceil((user_ranges(2) - pcc) / pixel_spacing);
elseif VarRange(1) > VarRange(2)
  pcc = VarRange + [-1 1]*(pixel_spacing/2);
  pcc = pcc(1);
% PCC 2/1/02 added 1 to each of the following two lines +1 ==> +2 and -1 ==> 0
% Map element number is one larger than the number of grid spacings.
  index(1) = floor((pcc - user_ranges(2)) / pixel_spacing) + 2;
  index(2) = ceil((pcc - user_ranges(1)) / pixel_spacing);
else % the dataset is a single pixel in this direction
  index(1:2) = 1;
end

if any(user_ranges == VarRange(1))
  index(1) = 1;
end
if any(user_ranges == VarRange(2))
  index(2) = NVar;
end

% make sure indices do not go over dataset boundaries
if index(1) < 1, index(1) = 1; end
if index(1) == NVar+1, index(1) = NVar; end
if index(1) > NVar+1, index(1) = nan; end
if index(2) > NVar, index(2) = NVar; end
if index(2) == -1, index(2) = 1; end
if index(2) < -1, index(2) = nan; end
% added fix, 98/04/13 D.B.
% make sure indices are increasing
if index(1) > index(2), index(2) = index(1); end

if any(isnan(index))
%  dodsmsg('Pixcheck: The specified longitudes are out of dataset range')
  index = [nan nan];
end

return
