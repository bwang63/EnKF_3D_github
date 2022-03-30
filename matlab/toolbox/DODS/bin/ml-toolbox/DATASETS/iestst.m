function [timestr,servers,tmptimes,urlinfolist] = iestst(str,getarchive,...
                  getranges,getmode,getvars,urlinfolist,varargin)

%
%  TimeInfo_File for GEM-derived Asuka IES dataset
%

% The preceding empty line is important
% $Log: iestst.m,v $
% Revision 1.2  2000/10/19 16:33:16  kwoklin
% Fix on date calculation for getdetail.  klee
%

% $Id: iestst.m,v 1.2 2000/10/19 16:33:16 kwoklin Exp $
% klee

% initialization
timestr = [];  servers = []; tmptimes = [];

if exist(getarchive) == 2   
  eval(getarchive)
else
  dodsmsg('Metadata not found!')
  return
end

% start and end times 
beginTime = max(TimeRange(1), getranges(4,1));
lastTime = min(TimeRange(2), getranges(4,2));

% start and end yrdays
startYear = floor(beginTime);
startYrday = (beginTime - startYear) * 365;
endYear = floor(lastTime);
endYrday = (lastTime - endYear) * 365;

% servers
baseservers = [];
baseservers = [urlinfolist(1).server_info];

if strcmp(str, 'url')
  % for catalog display
  tmptimes = [startYear+...
              ceil(startYrday)/365:1/365:endYear+floor(endYrday)/365]';
 
  % construct servers and timestr
  if ~isempty(baseservers)
    for i = 1:size(baseservers,1)
      timestr = strvcat(timestr, '   ');
      servers = strvcat(servers, baseservers(i,:));
    end
  end
 
elseif strcmp(str, 'data')
  % initialization 
  startindex = 0;  endindex = 0;  startindex8 = 0;  endindex8 = 0;
  newStartTime = beginTime;  newStartTime8 = beginTime;
  newEndTime = lastTime;  newEndTime8 = lastTime;

  % convert to 1994 yrdays
  if startYear == 1993,  startYrday = startYrday - 365;
  elseif startYear == 1995,  startYrday = startYrday + 365;  end
  if endYear == 1993,  endYrday = endYrday - 365;
  elseif endYear == 1995,  endYrday = endYrday + 365;  end

  % start and end index
  if isfield(urlinfolist, 'server_info')
    if ~isempty(urlinfolist(2).server_info)
      if any(urlinfolist(2).server_info == 7)
        % if ies station 8 is requested
        if startYrday > -172
          startindex8 = ceil(startYrday) + 172;  % change floor to ceil 10/19
        else
          startindex8 = 0;  
        end
        if endYrday < 126
          endindex8 = floor(endYrday) + 172;
        else
          endindex8 = 298; 
        end
      end
      if any(urlinfolist(2).server_info ~= 7)
        % for all the other stations other than station 8
        if startYrday < -61
          startindex = 0;  
        else
          startindex = ceil(startYrday) + 61;  % change floor to ceil 10/19
        end
        if endYrday > 682
          endindex = 743;
        else
          endindex = floor(endYrday) + 61;  
        end
      end
    end
  end

  % construct timestr and servers
  ce = [];  urlsize = [];
  for i = 1:size(baseservers,1)
    if findstr(baseservers(i,:), 'station8')
      ce = strvcat(ce, ['[',num2str(startindex8),':',num2str(endindex8),']']);
      servers = strvcat(servers, baseservers(i,:));
      if isfield(urlinfolist, 'sizeindex_info')
        tmptimes = [tmptimes; [-172+startindex8:-172+endindex8]'];
        urlsize = [urlsize; endindex8-startindex8+1];
      end
    else
      ce = strvcat(ce, ['[',num2str(startindex),':',num2str(endindex),']']);
      servers = strvcat(servers, baseservers(i,:));
      if isfield(urlinfolist, 'sizeindex_info')
        tmptimes = [tmptimes; [-61+startindex:-61+endindex]'];
        urlsize = [urlsize; endindex-startindex+1];
      end
    end
  end
  urlinfolist(5).time_info = tmptimes;
  urlinfolist(1).sizeindex_info = urlsize;
  timestr = ce;

end

return
  
