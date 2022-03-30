function [jdate,u,v,ws,wd] = f_windCman(fname,theta,zone,daylight)
% - process & rotate CMAN (or NDBC) historical wind data
%
% USAGE: [jdate,u,v,ws,wd] = f_windCman('fname',theta,zone,daylight)
%
% fname    = name of CMAN historical data file
% theta    = angle to rotate to local isobath  (default = 0)
% zone     = time zone                         (default = 0)
% daylight = correct for Daylight Savings Time (default = 0)
%
% jdate = Julian date (optionally corrected for time zone & DST)
% u     = cross-shore wind component
% v     = alongshore wind component
% ws    = wind speed (m/s)
% wd    = wind direction

% ----- Notes: -----
% This function is used to process wind data from a CMAN historical
% data file downloaded from, for example:
% http://www.ndbc.noaa.gov/station_history.phtml?station=smkf1
%
% The format of these files is as follows, with 999 & 99.0 indicating
% missing values:
% YY MM DD hh WD   WSPD GST  WVHT  DPD   APD  MWD  BAR    ATMP  WTMP  DEWP  VIS
% 92 01 01 00 353 06.2 06.6 99.00 99.00 99.00 999 1019.2  20.0  24.1 999.0 99.0
%
% Wind direction is converted "From" to "To" and the coordinate system is
% optionally rotated clockwise by the angle THETA to aligh with local isobaths
% (i.e., the shoreline) to allow extraction of the cross-shore (u) and 
% alongshore (v) wind components.

% ----- Details: -----
% Adding an angle (theta) to the wind direction is equivalent to
% rotating a VECTOR counter-clockwise or rotating the COORDINATE SYSTEM
% clockwise.

% ----- References: -----
% with help from Cynthia Yeung<Cynthia.Yeung@noaa.gov>
% and news://comp.soft-sys.matlab

% ----- Author(s): -----
% by Dave Jones,<djones@rsmas.miami.edu> Dec-2002
% http://www.rsmas.miami.edu/personal/djones/
% ----------------- DISCLAIMER: -------------------
% This code is provided as is, with no guarantees
% and is only intended for non-commercial use.
% --------------------------------------------------

% 05-Dec-2002: added convert 2 digit yr to 4 digit; fixed documentation,
%              mark vs. remove missing data

% ----- Check input & set defaults: -----
if (nargin < 2), theta    = 0; end; % no rotation by default
if (nargin < 3), zone     = 0; end; % default no correction for time zone
if (nargin < 4), daylight = 0; end; % default no correction for DST

if (exist(fname,'file')==0)
	error(['File ' fname ' not found! Check path or filename.']);
end
% ---------------------------------------

% read in data file:
x = textread(fname,'','delimiter',' ','headerlines',1);

% Mark missing data:
null_wd = find(x(:,5)==999);  % wind speed missing
null_ws = find(x(:,6)==99.0); % wind direction missing
x(unique([null_wd' null_ws']'),5:6) = NaN;

% Parse data:
yy = x(:,1); % year
mm = x(:,2); % month
dd = x(:,3); % day
hh = x(:,4); % hour
wd = x(:,5); % direction wind is blowing from (North is 0 degrees)
ws = x(:,6); % average wind speed for 2 mins during each hour (m/s)
clear x;

% convert 2 digit years to 4 digits (1980 is pivot year):
yy(find((yy>=80) & (yy<100))) = yy(find((yy>=80) & (yy<100))) + 1900;
yy(find(yy<80)) = yy(find(yy<80)) + 2000;

% Julian date:
jdate = f_julian([yy mm dd hh],zone,daylight);

% Convert wind direction "From" to "To":
wd = wd + 180;
wd(find(wd>360)) = wd(find(wd>360)) - 360;

% Rotate vectors counter-clockwise 90 degrees, so North = 90 degrees,
% East = 0 degrees:
wd = wd + 90;
wd(find(wd>360)) = wd(find(wd>360)) - 360;

% Rotate coordinate system clockwise by theta:
if theta>0
	wd = wd - theta;
	wd(find(wd<0)) = wd(find(wd<0)) + 360;
end

% Cross-shore (u) and alongshore wind components (v):
[u,v] = f_vecUV(ws,wd);
