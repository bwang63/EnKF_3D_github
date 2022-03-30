function out_time = tconvert(timebase, in_time, start_time)

% a function to convert time, given as ELAPSED TIME FROM A 
% CERTAIN STARTING POINT (START_TIME) into decimal years.
%
% The units of the (input) elapsed time may be any of 
% 'seconds' 'minutes' 'hours' 'days' or 'months'.
%
% START_TIME is given as a decimal year or vector of 
% [YEAR YEARDAY HR MIN SEC]).
%
% USAGE:
% DECIMAL_TIME = TCONVERT(TIMEBASE, INPUT_TIME, START_TIME);

if nargin < 3
  disp('usage: out_time = tconvert(timebase, in_time, start_time)')
  return
end

% first convert the starting time
if all(size(start_time) == 1)
  % start time is an integer year or a decimal year.
  % no conversions art necessary.
else
  start_time = start_time(:)';
  % pad with zeros for any missing fields
  start_time = [start_time zeros(1,5 - length(start_time))];
  if isleap(start_time(1));
    lyr = 366;
  else
    lyr = 365;
  end
  if all(start_time == 0)
    start_time = 0;
  else
    start_time = start_time(1) + ...
	( (start_time(2)-1) + ...
	(start_time(3) + (start_time(4) + ...
	(start_time(5) / 60) / 60) / 24) ) / lyr;
  end
end

switch timebase
  case 'seconds'
    in_time = in_time/(24*60*60);
  case 'minutes'
    in_time = in_time/(24*60);
  case 'hours'
    in_time = in_time/24;
  case 'days'
  case 'months'
    lmo = [31 29 31 30 31 30 31 31 30 31 30 31];
    tmptime = in_time; in_time = [];
    % don't allow month '0'
    k = find(tmptime == 0);
    tmptime(k) = 1;
    
    % now find both valid and too large months
    k = find(tmptime >= 1 & tmptime <= 12);
    kk = find(tmptime > 12);
    iter = 0;
    while ~isempty(k) | ~isempty(kk)
      t = tmptime(k);
      if all(floor(tmptime) == tmptime)
	% these are integer months
	% put them in the middle
	t = cumsum(lmo(t)) - lmo(t)/2;
      else
	eday = cumsum([0 lmo]);
	fit = floor(t)+1;
	t = eday(fit) + (t+1 - fit).*lmo(fit);
      end
      if isleap(iter+start_time)
	lyr = 366;
      else
	lyr = 365;
      end
      % make in_time (in years) relative to start_time
      in_time = [in_time iter+t/lyr];
      tmptime = tmptime - 12;
      k = find(tmptime >= 1 & tmptime <= 12);
      kk = find(tmptime > 12);
      iter = iter+1;
    end
end

if ~strcmp(timebase, 'years') & ~strcmp(timebase, 'months')
  out_time = day2year(in_time, start_time);
  if all(start_time == 0)
    % PUT IN A FAKE YEAR FOR CLIMATOLOGIES!
    out_time = day2year(in_time, 1901);
    out_time = out_time - 1901;
  else
    out_time = day2year(in_time, start_time);
  end
else
  % if the data are already in years, simply add the
  % start time onto the input time.
  out_time = in_time+start_time;
end
return
