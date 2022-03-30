function [p, lon, lat, bdepth, varargout] = ctdExtract(filename, varargin)

% ctdExtract  Read DPG CTD data from netCDF files
%
% [p, lon, lat, bdepth] = ctdExtract(filename)
% Given a list of CTD station files, 'filename', return the pressure, p,
% for the full range of pressures covered by the station files, the longitude, lon,
% the latitude, lat, and bottom depth, bdepth.
%
% [p, lon, lat, bdepth, p1, p2, ...] = ctdExtract(filename, 'p1, 'p2, ...)
% As above, but also return data p1, p2, ..., for CTD data types 'p1', 'p2',etc.
% 'p1', 'p2', etc. are strings with the following values (case insensitive):
% 'T'     - temperature
% 'S'     - salinity
% 'O'     - dissolved oxygen
% 'Dig_n' - where 'Dig_n' is the name of a digitizer channel (only first
%           unambiguous characters are required), 'Tr' for transmissometer.
%
% WARNING: n * m may be very large.
%
%   Derived from ctd_extract as written by:
%   Jeff Dunn  15/1/98  CSIRO Division of Marine Research
%   Modified for use as a function by Lindsay Pender 21/5/98 and again 5/11/99

if ~nargin | isempty(list)
  list = 'ctdnames.lis';
end
if nargin<2
   dig_str = [];
   dig = [];
end

fid = fopen(list,'r');
name_bin = fread(fid)';
fclose(fid);
crtns = find(name_bin==10);
names = setstr(name_bin);
numsta = length(crtns);
clear name_bin

%  Suppress tedious netCDF warnings
ncmex('setopts',0);

% Preallocate arrays here if possible

if ~numsta
  return;
end

start = 1;
maxPressIndex = 0;
kmax = ones(numsta, 1);

for ii=1:numsta
  fname = deblank(names(start:crtns(ii)-1));
  
  cdfid = ncmex('ncopen',['/home/dpg/export/ctd_arc/' fname '.cdf'],'nowrite');
  if cdfid<0
     error(['Cannot open ' fname])
  end
  [dimnam,nrecs] = ncmex('ncdiminq',cdfid,'number_of_data_records');
  kmax(ii) = nrecs;
  if nrecs > maxPressIndex
    maxPressIndex = nrecs;
    p = ncmex('varget',cdfid,'pressure',0,nrecs);
  end

  ncmex('ncclose',cdfid);
  
  start = crtns(ii)+1;
end

lat = ones(numsta, 1) * nan;
lon = ones(numsta, 1) * nan;
bdepth = ones(numsta, 1) * nan;
t = ones(numsta, maxPressIndex) * nan;
s = ones(numsta, maxPressIndex) * nan;
if ~isempty(dig_str)
   dig = ones(numsta, maxPressIndex) * nan;
end

start = 1;

for ii=1:numsta

  fname = deblank(names(start:crtns(ii)-1));
  
  cdfid = ncmex('ncopen',['/home/dpg/export/ctd_arc/' fname '.cdf'],'nowrite');
  
  % Because of loose use of ASCII fields in the global attributes, it is safer
  % to get cruise details from file names than from those attributes. 

  n1 = 8;

  sves = fname(1:1);
  scr_id = fname(3:6);

  lst = length(fname);
  sstn = fname(lst-2:lst);

  sdep = ncmex('ncattget', cdfid, 'global', 'Bottom_depth');

  % Get start time if available. I would prefer bottom time, but the date is
  % apparently for the start time, and I'm too lazy to do the testing and
  % correcting of the date to match the bottom time.

  stime = ncmex('ncattget', cdfid, 'global', 'Start_time');
  if isempty(deblank(stime))
    stime = ncmex('ncattget', cdfid, 'global', 'Bottom_time');
    if isempty(deblank(stime))
      stime = ncmex('ncattget', cdfid, 'global', 'End_time');
      if isempty(deblank(stime))
	stime = '    ';
      end
    end
  end
  
  sdate = ncmex('ncattget', cdfid, 'global', 'Date');

  % Get a lat lon, preferably from bottom position
  
  pos = ncmex('ncattget', cdfid, 'global', 'Bottom_position');
  if pos(9:9)~='N' & pos(9:9)~='S'
    pos = ncmex('ncattget', cdfid, 'global', 'Start_position');
    if pos(9:9)~='N' & pos(9:9)~='S'
      pos = ncmex('ncattget', cdfid, 'global', 'End_position');
    end
  end
  
  
  if sves=='f'
    ves_id = 1;
  elseif sves=='s'
    ves_id = 2;
  elseif sves=='a'
    ves_id = 3;
  else
    ves_id = -1;
  end
    
  cr_id = str2num(scr_id);
  stn = str2num(sstn);

  tim = str2num(stime(1:4));
  if tim ~= 0
    hr = floor(tim/100);
    minu = rem(tim,100);
    tim = ((hr*60)+minu)/1440;
  end
 
  % Convert date to days_since_1900, which involves the magic number below

  yday = str2num(sdate(13:15));
  yr   = str2num(sdate(8:11));
  jday = julian(yr-1,12,31) - 2415020.5;
  time = jday + yday + tim;

  latd = str2num(pos(1:2));
  latm = str2num(pos(4:8));
  if strcmp(pos(9:9),'S')
    lat(ii) = -(latd + latm/60);
  else
    lat(ii) = latd + latm/60;
  end

  lond = str2num(pos(11:13));
  lonm = str2num(pos(15:19));
  ew   = strcmp(pos(20:20),'W');
  lon(ii)  = lond + lonm/60. + ew*180;

  % After decoding bottom depth, check for failed conversion
  bdepth(ii) = sscanf(sdep,'%d');
  if isempty(bdepth(ii))
    bdepth(ii) = sscanf(sdep,'%*s %d');
    if isempty(bdepth(ii)) 
      bdepth(ii) = NaN;
    end
  end

  [dimnam,nrecs] = ncmex('ncdiminq',cdfid,'number_of_data_records');
  t(ii, 1:nrecs) = ncmex('varget',cdfid,'temperature',0,nrecs);  
  s(ii, 1:nrecs) = ncmex('varget',cdfid,'salinity',0,nrecs);  

  if ~isempty(dig_str)
     digl = ncmex('ncattget', cdfid, 'global', 'Dig_labels');
     diglw = word_chop(digl);
     for ll = 1:length(diglw)
	if strcmp(diglw{ll},dig_str)
	   dig(ii,1:nrecs) = ncmex('varget',cdfid,'digitiser_channels',...
		 [ll-1 0],[1 nrecs])';
	end
     end
  end
  
  ncmex('ncclose',cdfid);
  
  start = crtns(ii)+1;
end
  

% --------------- End of ctd_extract ----------------