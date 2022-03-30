function [slon,elon] = splitrequest(LonRange, get_ranges)

% SPLITREQUEST determines if a user request actually spans a data "seam".
% and separates longitudes into appropriate spans accordingly.
% 
% USAGE [start_lon, end_lon] = splitrequest(archive,ranges)

if nargin < 2
  dodsmsg('Usage: [start_lon, end_lon] = splitrequest(LonRange, ranges)')
  return
end

slon = []; elon = [];
LL = LonRange(1);
RL = LonRange(2);
LonDirection = 1;
if LL > RL % Data goes from east to west in the data set. Swap LL and RL.
  temp = LonRange(1);
  LL = LonRange(2);
  RL = temp;
  LonDirection = -1;
end
slon = get_ranges(1,1);
elon = get_ranges(1,2);
if elon < slon 
  slon = slon - 360.0;
end
% Make sure that the west end of the range is to the 
% east of the west end of the data set.
if slon < LL
  temp = (1 + floor((LL - slon) / 360.0)) * 360;
  slon = slon + temp;
  elon = elon + temp;
end
if abs(get_ranges(1,1) - get_ranges(1,2)) >= 360
  if LL < RL
    slon = LL;
    elon = RL;
  else
    slon = RL;
    elon = LL;
  end
else % this is still incorrect if the constraints match up! dab 98/04/14
  % Now examine the east end of the data set.
  if slon < RL
    if elon <= RL
    else
      if (elon-360) > LL
	%   Set up to make A SECOND CALL for the same URL
	elon(2) = elon - 360;
	elon(1) = RL;
	slon(2) = LL;
      else
	elon = RL;
      end
    end
  else
    slon = slon - 360;
    elon = elon - 360;
    if elon <= LL
      dodsmsg('Splitrequest: Longitude range does not overlap the data set.')
      slon = [];
      elon = [];
      return
    else
      slon = LL;
      % East end of range east of west end of data set, 
      %now check it against east end.
      if elon > RL
	elon = RL;
      end	      
    end
  end
end
