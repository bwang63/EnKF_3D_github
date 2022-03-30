function  [datamin_o, datamax_o] = get_lon_rng( ranges, lonmin_t, lonmax_t, datamin_i, datamax_i)
%
% This function will find those data sets that are out of range in longitude.
%
%  Input: ranges - the range selected in the browse window
%         (lonmin,lonmax) - the range of the data set.
%         datamin - 1 if the range selected is below the data set range
%         datamax - 1 if the range selected is above the data set range
% For simplicity I have set both datamax and datamin to either 0 if the
% data set falls in the selected range or 1 if out of the range.
%
%   lonmin,lonax
%
%       -180                        0                    180
%  1      |       xxxx                                    |
%  2      |                      xxxxxxxx                 |
%  3      |                                xxxxx          |
%  4      |xxxx                                       xxxx|
%  5      |xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx|
%
%   ranges
%
%       -180                        0                    180
%  A      |       xxxx                                    |
%  B      |                      xxxxxxxx                 |
%  C      |                                xxxxx          |
%  D      |xxxx                                       xxxx|
%  E      |xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx|
%
%
%  Special cases 
%
%      lonmax < lonmin      case 4 \   If both are true there is overlap.
%      ranges(1,2) < ranges(1,1)  case D /
%      abs(lonmax - lonmin) = 360     case 5 No other tests, always overlap.
%

if abs(lonmax_t - lonmin_t) > 359.999  % Case 5 - Dataset covers 360 degrees so always overlaps. 
  datamin_t = 0;
else
  if lonmax_t < lonmin_t        % Case 4 - Dataset wraps around 180
    if ranges(1,2) < ranges(1,1)  % Case D - Selected range wraps around 180
      datamin_t = 0;
    else
      if (ranges(1,1) > lonmax_t) & (ranges(1,2) < lonmin_t) 
        datamin_t = 1;
      else
        datamin_t = 0;
      end
    end
  else
    if ranges(1,2) < ranges(1,1)  % Case 1-3, D 
      if (ranges(1,2) < lonmin_t) & (ranges(1,1) > lonmax_t)
        datamin_t = 1;
      else
        datamin_t = 0;
      end
    else
      if (ranges(1,2) < lonmin_t) | (ranges(1,1) > lonmax_t) 
        datamin_t = 1;
      else
        datamin_t = 0;
      end
    end
  end
end
datamax_t = datamin_t;
datamin_o = datamin_i | datamin_t;
datamax_o = datamax_i | datamax_t;
 


