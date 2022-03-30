function [data,lon,lat,date_used] = getoiwastacsst(limits,date_requested,...
   varopt,deci,data_dir)
% Retrieves 10-day averaged SST closest to the date requested, within the 
% lat/lon LIMITS requested, from the 10-day OI of Leeuwin Current region
% WASTAC HRPT data.  The raw data comprises more passes than went into
% Alison Walker 5km 10day OI of ACRES/ERIN HRPT.
%
% [data,lon,lat,date_used] = getoiwastacsst(limits,date_requested,varopt,...
% deci,data_dir)
%---------------------------------------------------------------------
%
% Required:
%
%   LIMITS is a 4-element vector [lonmin lonmax latmin latmax]
%   as used by AXIS
%
%   DATE_REQUESTED is a 6-element vector [year month day hr min sec]
%   (actually, you can drop the hr:min:sec)
%
% Optional:
%
%   VAROPT can be:
%         'sst' to get the SST estimate (default)
%         'err' to get the expected error
%
%   DECI is equivalent to stride in a call to getnc : the factor by
%   which you want to dcimate the high resolution data (default = 1)
%
%   DATA_DIR directory in which netcdf files reside (default exists)
%
% Outputs:
%
%   DATA, and vectors of LON, LAT, and the actual DATE_USED
%   for the output data.
%
% This version reads the 10-day averaged data stored in netcdf files
% oi5k10dsst.nc and oi5k10dssterr.nc
%
% John Wilkin 25-NOV-1998 

% CHECK INPUTS

if nargin < 5
  data_dir = [data_public '/sst/'];
end
if nargin < 4
    deci=1;
end
if nargin > 2
  if ~strcmp(varopt,'sst')
    error(['varopt must be sst. It was: ' varopt])
  end
end
if nargin < 3
  varopt = 'sst'; % default is to get the sst estimate
end
if nargin < 2
  error('You must give lat/lon limits and date')
end
if length(date_requested)==3
  date_requested = [date_requested 0 0 0];
end

% DATA FILE TO US
file = [data_dir 'sst_leeuwin'];
if strcmp(varopt,'err') 
  file = [file 'err'];
  varopt = 'ssterr';
end
file = [file '.nc'];
if ~exist(file)
  bell;
  warning([file ' does not exist - can''t obtain SST'])
  return
end


% GET LAT, LON, TIME INDICES
lon = getnc(file,'lon');
lat = getnc(file,'lat');
time = timenc(file);

lonmn = limits(1);
lonmx = limits(2);
latmn = limits(3);
latmx = limits(4);

% FIND LAT, LON AND TIME INDICES

xi = range(findinrange(lon,limits(1:2)));
yj = range(findinrange(lat,limits(3:4)));

time_lag = julian(date_requested)-julian(time);
tk = find(abs(time_lag)==min(abs(time_lag)));
tk = tk(1); % in case the date was exactly between two analysis dates
date_used = time(tk,:);
time_lag = time_lag(tk);

if abs(time_lag) >= 5.0001
   bell;
   warning(['date_requested is out of range of the data file'])
   data = NaN;
   lon=[];
   lat=[];
   date_used=[];
   return
end

% RETRIEVE REQUESTED DATA FROM NETCDF FILES

data = getnc(file,varopt,[tk yj(1) xi(1)],[tk yj(2) xi(2)],...
       [1 deci deci],-1,-1);
lat = getnc(file,'lat',[yj(1)],[yj(2)],[deci],-1,-1);
lon = getnc(file,'lon',[xi(1)],[xi(2)],[deci],-1,-1);
