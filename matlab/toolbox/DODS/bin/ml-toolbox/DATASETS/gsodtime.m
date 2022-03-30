function [timestr,servers,tmptimes,urlinfolist] = gsodtime(str,getarchive,...
                  getranges,getmode,getvars,urlinfolist,varargin)

%
%
%

% The preceding empty line is important
% $Log: gsodtime.m,v $
% Revision 1.1  2000/09/19 20:50:42  kwoklin
% First toolbox internal release.   klee
%

% $Id: gsodtime.m,v 1.1 2000/09/19 20:50:42 kwoklin Exp $
% klee

% initialization
timestr = [];  servers = []; tmptimes = [];  

if exist(getarchive) == 2   
  eval(getarchive)
else
  dodsmsg('Metadata not found!')
  return
end

% Names
varname = urlinfolist(1).var_name;
timevarname = varname(8:17,:);
yearName = deblank(timevarname(1,:));
monthName = deblank(timevarname(2,:));
dayName = deblank(timevarname(3,:));
hrName = deblank(timevarname(7,:));
minName = deblank(timevarname(8,:));
otherTName = deblank(timevarname(10,:));
dref = DataTime;

if strcmp(str, 'url')
  % start and end times 
  beginTime = max(TimeRange(1), getranges(4,1));
  lastTime = min(TimeRange(2), getranges(4,2));
  startTime = num2str(year2day(beginTime,dref),9);
  endTime = num2str(year2day(lastTime,dref),9);

  % starttoend
  starttoend = 0;
  if (getranges(4,1) <= TimeRange(1) & getranges(4,2) >= TimeRange(2))
    starttoend = 1;
  end

  % servers
  baseservers = [];
  baseservers = [urlinfolist.server_info];

  % construct timestr and servers
  ce = []; 
  if ~isempty(baseservers)
    for i = 1:size(baseservers,1)
      if starttoend
        ce = strvcat(ce, '   ');
        servers = strvcat(servers, baseservers(i,:));
      else
        ce = strvcat(ce, ['&',otherTName,'>=',num2str(startTime,9),...
                          '&',otherTName,'<=',num2str(endTime,9)]);
        servers = strvcat(servers, baseservers(i,:));
      end
    end
  end
      
  timestr = ce;

  return

elseif strcmp(str, 'recal')

  % because varargin is packed in cell array, need to release here
  cell = varargin{1};
  fields = {'year','month','day','yrday','julian','dyear','hr',...
            'min','sec','comptime'};
  timestruct = cell2struct(cell, fields, 2);
  othertvalue = timestruct.comptime;
  
  if ~isempty(othertvalue)
    tmptimes = d2years(othertvalue,dref);
    urlinfolist(3).time_info = tmptimes';
  end
  
  return;
 
elseif strcmp(str, 'data')
  
  % it is redundant!  but let's wait for more datasets coming in 
  servers = urlinfolist(1).server_info;
  
end
