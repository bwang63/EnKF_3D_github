function [intyears] = dy2dat(tmp_times)

% DY2DAT    part of the DODS Matlab GUI.  Convert a decimal year
% (e.g., 1981.11134) to a [year yearday hour minute] representation,
% (e.g., [1981 41 15 20]).  Note that January first is yearday 1, not
% yearday 0.

% Deirdre Byrne, U Maine, 00/05/30

if nargin < 1
  return
end

pass_times = [];
for k = 1:length(tmp_times)
  year = floor(tmp_times(k));
  if isleap(year)
    decday = 1.0/366.0;
  else
    decday = 1.0/365.0;
  end
  yearday = (tmp_times(k) - year) / decday + 1; 
  hour = (yearday - floor(yearday)) * 24.0;
  yearday = floor(yearday);
  minute = floor((hour - floor(hour)) * 60.0);
  hour = floor(hour);
  pass_times(k,:) = [year, yearday, hour, minute]; 
end

if nargout == 1
  intyears = pass_times;
end
return
