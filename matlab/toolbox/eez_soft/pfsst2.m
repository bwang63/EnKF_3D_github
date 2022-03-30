function [data,lon,lat,date_used] = pfsst2(limits,date_requested,varopt,...
	deci,data_dir,method)

% Retrieves a map of 10-day averaged estimates of NOAA/NASA Pathfinder SST
% closest to the date requested, within the lat/lon LIMITS requested.
%
% [data,lon,lat,date_used] = pfsst(limits,date_requested,varopt,deci,data_dir)
%---------------------------------------------------------------------
% LIMITS is a 4-element vector [lonmin lonmax latmin latmax]
%		as used by AXIS
%
% DATE_REQUESTED is a 6-element vector [year month day hr min sec]
%
% VAROPT can be:
%         'sst' to get the SST estimate (default)
%         'err' to get the expected error
%         'raw' to get the unprocessed Pathfinder best-SST
%
% DECI is equivalent to stride in a call to getnc : the factor by
%	which you want to dcimate the high resolution data (default = 1)
%
% DATA_DIR directory in which netcdf files reside (default exists)
%
% Outputs are matrices of DATA, LON, LAT, and the actual DATE_USED
% for the output data.
%
% This version reads the 10-day averaged data stored in netcdf files.
% The spatial resolution ~=0.114 degrees with lat/lon boundaries [90 200 -70 0]
% Optimally averaged Pathfinder data presently spans the time-period 
% [1987 2 14 0 0 0] to [1994 6 27 0 0 0]
%
% Produced : Alison Walker  & John Wilkin Sep-97
% 
%
% Oceans-EEZ project matlab tools are installed in:
% /home/eez_data/software/matlab 
%
% If this function fails when trying to execute function getnc, make sure
% the version 5 netcdf utilities are in your path.   They can be added
% interactively with the commands ...
% addpath /home/toolbox/local/netcdf_matlab5 -begin
% addpath /home/toolbox/local/netcdf_matlab5/nctype -begin
% addpath /home/toolbox/local/netcdf_matlab5/ncutility -begin
%
% The directory where the Pathfinder netcdf files are kept
%	driftwood:/rwx2/eez_data/sst/pathfinder_aus/

% CHECK INPUTS

if nargin < 6
  method = 'nearest';
end

if nargin < 5
  data_dir = '/home/eez_data/sst/pathfinder_aus/';
  if nargin < 4
    deci=1;
  end
end
if nargin >= 3
  if ~(strcmp(varopt,'sst') | strcmp(varopt,'err') | strcmp(varopt,'raw'))
    error(['varopt must be sst, error or raw.  It was: ' varopt])
  end
else
  varopt = 'sst'; % default is to get the sst estimate
end

reading_raw_data = strcmp(varopt,'raw');

if strcmp(varopt,'err')
  varopt = 'error'; % so we can read this variable name fomr the netcdf file
end

lonmn = limits(1);
lonmx = limits(2);
latmn = limits(3);
latmx = limits(4);

% delta_angle of data grid interval is 360/4096;
vlimits = [90+[0 1251*360/4096] [-796 -1]*360/4096];

if lonmn<vlimits(1) | lonmx>vlimits(2) | latmn<vlimits(3) | latmx>vlimits(4)
  bell;
  disp(['Requested lon/lat limits exceed valid range ' mat2str(vlimits)])
  disp('The output will not cover the full area requested')
end

% CHOOSE APPROPRIATE NETCDF FILE
date_requested = gregorian(julian(date_requested));
year_req = date_requested(1)-1900;
if reading_raw_data 
  file=([data_dir 'pfsstr' num2str(year_req)]);
else
  file=([data_dir 'pfsste' num2str(year_req)]);
end

% FIND LAT, LON AND TIME INDICES

lon = getnc(file,'lon');
lat = getnc(file,'lat');
time = getnc(file,'time');

index = find(lon>lonmn & lon<lonmx);
xW = min(index)-1;
xE = max(index)+1;
index = find(lat>latmn & lat<latmx);
yN = min(index)-1;
yS = max(index)+1;

if reading_raw_data 
  
  time_lag = julian(date_requested)-(time+julian([1985 1 1 0 0 0]));
  index = find(abs(time_lag)==min(abs(time_lag)));
  t = index(1); 
  date_used = time(t)+julian([1985 1 1 0 0 0]);
  varopt  ='sst';

  % RETRIEVE REQUESTED DATA FROM NETCDF FILES
  data = getnc(file,varopt,[t yN xW],[t yS xE],[1 deci deci],-1,-1);

else

  if strcmp(method,'nearest')
    
    time_lag = julian(date_requested)-(time+julian([1985 1 1 0 0 0]));
    index = find(abs(time_lag)==min(abs(time_lag)));
    t = index(1); % in case the date was exactly between two analysis dates
    date_used = time(t)+julian([1985 1 1 0 0 0]);
    
    if abs(time_lag(t)) >= 5.0001
      % date_requested isn't between 2 dates in file => at begin/end of year
      if time_lag(t)>0
	% end of year - read from next year's file
	file=([data_dir 'pfsste' num2str(year_req+1)]);
	time = getnc(file,'time');
	time_lag = julian(date_requested)-(time+julian([1985 1 1 0 0 0]));
	index = find(abs(time_lag)==min(abs(time_lag)));
	t = index(1); % in case the date was exactly between two analysis dates
	date_used = time(t)+julian([1985 1 1 0 0 0]);
	time_lag(t)
      end
      if time_lag(t)<0
	% start of year - read from last year's file
	file=([data_dir 'pfsste' num2str(year_req-1)]);
	time = getnc(file,'time');
	time_lag = julian(date_requested)-(time+julian([1985 1 1 0 0 0]));
	index = find(abs(time_lag)==min(abs(time_lag)));
	t = index(1); % in case the date was exactly between two analysis dates
	date_used = time(t)+julian([1985 1 1 0 0 0]);
	time_lag(t)
      end
    end
    
    % RETRIEVE REQUESTED DATA FROM NETCDF FILES
    data = getnc(file,varopt,[t yN xW],[t yS xE],[1 deci deci],-1,-1);

  else

    % interpolate in time to date_requested
    
    time_lag = julian(date_requested)-(time+julian([1985 1 1 0 0 0]));
    index = find(abs(time_lag)==min(abs(time_lag)));
    t = index(1);
    date_used = time(t)+julian([1985 1 1 0 0 0]);

    if time_lag(t)==0
      
      % then we don't need to interpolate
      % RETRIEVE REQUESTED DATA FROM NETCDF FILES
      data = getnc(file,varopt,[t yN xW],[t yS xE],[1 deci deci],-1,-1);

    else
    
      % We need to find the two sets of data that bracket date_requested
      % A quick and dirty way is is to find the nearest to dates +/- 5 days
      % from requested
    
      % shift forward 5 days
      
      keyboard

      date_requested = gregorian(julian(date_requested)+5);
      time_lag = julian(date_requested)-(time+julian([1985 1 1 0 0 0]));
      index = find(abs(time_lag)==min(abs(time_lag)));
      t = index(1);
      date_used = time(t)+julian([1985 1 1 0 0 0]);
      if abs(time_lag(t)) >= 5.0001
	% date_requested isn't between 2 dates in file => at begin/end of year
	if time_lag(t)>0
	  % end of year - read from next year's file
	  file=([data_dir 'pfsste' num2str(date_requested(1)+1)]);
	  time = getnc(file,'time');
	  time_lag = julian(date_requested)-(time+julian([1985 1 1 0 0 0]));
	  index = find(abs(time_lag)==min(abs(time_lag)));
	  t = index(1); % in case the date was exactly between two analysis dates
	  date_used = time(t)+julian([1985 1 1 0 0 0]);
	  time_lag(t)
	end
	if time_lag(t)<0
	  % start of year - read from last year's file
	  file=([data_dir 'pfsste' num2str(date_requested(1)-1)]);
	  time = getnc(file,'time');
	  time_lag = julian(date_requested)-(time+julian([1985 1 1 0 0 0]));
	  index = find(abs(time_lag)==min(abs(time_lag)));
	  t = index(1); % in case the date was exactly between two analysis dates
	  date_used = time(t)+julian([1985 1 1 0 0 0]);
	  time_lag(t)
	end
      end
      date_e = date_used;
      data_e = getnc(file,varopt,[t yN xW],[t yS xE],[1 deci deci],-1,-1);

      % shift back 5 days
      date_requested = gregorian(julian(date_requested)-10);
      time_lag = julian(date_requested)-(time+julian([1985 1 1 0 0 0]));
      index = find(abs(time_lag)==min(abs(time_lag)));
      t = index(1);    
      date_used = time(t)+julian([1985 1 1 0 0 0]);  
      if abs(time_lag(t)) >= 5.0001
	% date_requested isn't between 2 dates in file => at begin/end of year
	if time_lag(t)>0
	  % end of year - read from next year's file
	  % file=([data_dir 'pfsste' num2str(year_req+1)]);
	  file=([data_dir 'pfsste' num2str(date_requested(1)+1)]);
	  time = getnc(file,'time');
	  time_lag = julian(date_requested)-(time+julian([1985 1 1 0 0 0]));
	  index = find(abs(time_lag)==min(abs(time_lag)));
	  t = index(1); % in case the date was exactly between two analysis dates
	  date_used = time(t)+julian([1985 1 1 0 0 0]);
	  time_lag(t)
	end
	if time_lag(t)<0
	  % start of year - read from last year's file
	  file=([data_dir 'pfsste' num2str(date_requested(1)-1)]);
	  time = getnc(file,'time');
	  time_lag = julian(date_requested)-(time+julian([1985 1 1 0 0 0]));
	  index = find(abs(time_lag)==min(abs(time_lag)));
	  t = index(1); % in case the date was exactly between two analysis dates
	  date_used = time(t)+julian([1985 1 1 0 0 0]);
	  time_lag(t)
	end
      end
      date_b = date_used;
      data_b = getnc(file,varopt,[t yN xW],[t yS xE],[1 deci deci],-1,-1);

      % interpolate in time from date_b to date_e
      a = (julian(date_requested)+5-date_b)/10;
      data = (1-a)*data_b+a*data_e;
      date_used = 'interpolated';
      
    end
    
  end % method nearest
  
end

% retrieve lat/lon data
lat = lat(yN:deci:yS);
lon = lon(xW:deci:xE);

%subplot(121);pcolorjw(lon,lat,data_b);axisleeuwin
%subplot(122);pcolorjw(lon,lat,data_b-data_e);axisleeuwin

if reading_raw_data
   %data = data + 254;
   data(find(data<0)) = data(find(data<0))+254;
   data = .15*data - 3.0;
   data=change(data,'==',-3.,nan);
end

% flip so that lat index is increasing from south to north
lat = flipud(lat);
data = flipud(data);
