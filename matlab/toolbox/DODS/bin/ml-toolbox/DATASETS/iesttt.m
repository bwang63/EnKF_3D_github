function [timestr,servers,tmptimes,urlinfolist] = iesttt(str,getarchive,...
                  getranges,getmode,getvars,urlinfolist,varargin)

%
% TimeInfo_File for ASUKA IES traval time dataset
%

% The preceding empty line is important
% $Id: iesttt.m,v 1.2 2000/10/19 18:56:05 kwoklin Exp $
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
dyName = deblank(varname(13,:));

if strcmp(str, 'url')
  % start and end times 
  beginTime = max(TimeRange(1), getranges(4,1));
  lastTime = min(TimeRange(2), getranges(4,2));

  % starttoend
  starttoend = 0;
  if (getranges(4,1) <= TimeRange(1) & getranges(4,2) >= TimeRange(2))
    starttoend = 1;
  end

  % servers
  baseservers = [];
  baseservers = [urlinfolist(1).server_info];

  % for catalog display
  tmptimes = daily(TimeRange, [IntervalTime,nan,TimeRange(1)], getranges);

  % construct timestr and servers
  ce = []; 
  if ~isempty(baseservers)
    for i = 1:size(baseservers,1)
      if starttoend
        ce = strvcat(ce, '   ');
        servers = strvcat(servers, baseservers(i,:));
      else
        ce = strvcat(ce, ['&',dyName,'>=',num2str(beginTime,9),...
                          '&',dyName,'<=',num2str(lastTime,9)]);
        servers = strvcat(servers, baseservers(i,:));
      end
    end
  end
      
  timestr = ce;

  return

elseif strcmp(str, 'data')
  
  % it is redundant!  but let's wait for more datasets coming in 
  servers = urlinfolist(1).server_info;
  
end


% $Log: iesttt.m,v $
% Revision 1.2  2000/10/19 18:56:05  kwoklin
% Change TimeRange(1).  klee
%
% Revision 1.1  2000/09/28 04:30:01  kwoklin
% First toolbox internal release.   klee
%
