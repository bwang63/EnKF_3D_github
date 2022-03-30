function [Dnum,Dstr] = roms_get_date(file,tindex,dateformat,timevarname)
% $Id$
% [dnum,dstr] = roms_get_date(file,tindex,dateformat,timevarname)
%
% Read ocean_time value from FILE for time index TINDEX and try to parse
% this into a Matlab datenum value.  TINDEX starts at 1.
%
% If TINDEX=-1, get all times in the FILE
%
% If a 3rd input is given, interpret this as a format option to datestr and 
% convert the datenum value into a string with this format. If the
% dateformat < 0 the string returned will simply be "day ...."
%
% John Wilkin
% Uses snctools and function parsetnc

if nargin < 2
  tindex = -1;
end

if nargin < 3
  dateformat = 0;
end

if nargin < 4
  timevarname = 'ocean_time';
end

if tindex == -1
  % get all times
  ocean_time  = nc_varget(file,timevarname,0,-1);
else
  ocean_time  = nc_varget(file,timevarname,0,-1);
  ocean_time  = ocean_time(tindex);
  % ocean_time  = nc_varget(file,timevarname,tindex-1,1);
end
tunits = nc_attget(file,timevarname,'units');

switch tunits(1:3)
  case 'day'
    fac = 1;
  case 'hou'
    fac = 1/24;
  case 'sec'
    fac = 1/86400;
  otherwise
    warning('Not sure what time units are. Cannot interpret tunits:')
    disp(tunits)
    disp('Making no time units assumption. Returning ocean_time from file')
    fac = 0;
end

% convert to days
if fac == 0
  dnum = ocean_time;
  if nargout > 1
    dstr = [num2str(ocean_time) ' ' tunits];
  end
else
  try 
    % in case can't parse tunits string
    dnum = datenum(parsetnc(tunits)) + ocean_time*fac;
    if dateformat < 0
      for i=1:length(dnum)
        dstr(i,:) = ['day ' num2str(fac*ocean_time(i),'%8.2f')];
      end
    else
      dstr = datestr(dnum,dateformat);
    end
  catch
    warning('Problem parsing tunits string to get base date')
    dnum = ocean_time*fac;
      dstr = ['Day ' num2str(dnum)];
  end
end
if nargout == 0
  disp(dstr)
else
  Dnum = dnum;
  Dstr = dstr;
end
