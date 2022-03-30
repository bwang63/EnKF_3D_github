function [urlinfolist,varargout] = getd8(str, getarchive, getranges, ...
          names, varbool, urlinfolist, varargin)

%
%  yrday only
% 

% $Log: getd8.m,v $
% Revision 1.1  2000/09/19 20:50:41  kwoklin
% First toolbox internal release.   klee
%

% $Id: getd8.m,v 1.1 2000/09/19 20:50:41 kwoklin Exp $
% klee 

% initialization
varargout{1} = [];
yrdayname = names(1,:);

if isstr(str)
  
  if strcmp(str, 'url')
  
    % ------------   IN URL CONSTRUCTION MODE  -------------------------------
    % build url for the final inventory search, for geolocation/depth/time

    if exist(getarchive) == 2   
      eval(getarchive)
    else
      dodsmsg('Metadata not found!')
      return
    end

    beginTime = max(TimeRange(1), getranges(4,1));
    lastTime = min(TimeRange(2), getranges(4,2));
    beginy = floor(beginTime);   lasty = floor(lastTime);
    years = [beginy:lasty];
    leaps = isleap(years);yeardays = 365 + leaps;
    begind = (beginTime - beginy) * yeardays(1);
    lastd = (lastTime - lasty) * yeardays(length(years));

    baseservers = [];
    if isfield(urlinfolist, 'server_info')
      baseservers = [urlinfolist(1).server_info];
    end


    %%%%%%%%%%%%%%%%%%%
    % For server optimization
    times1 = [];  times2 = [];  tmptimes1 = [];  tmptimes2 = [];
    if isfield(urlinfolist, 'time_info')
      times1 = [urlinfolist(1).time_info];    % presumably the starttimes
      times2 = [urlinfolist(2).time_info];    % presumably the endtimes
    end
    starttoend = 0;  fromthestart = 0;  totheend = 0;
    if ~isempty(times1) | ~isempty(times2)
      % after the first cat return
      if (getranges(4,1) <= TimeRange(1) & getranges(4,2) >= TimeRange(2))
        starttoend = ones(1,size(baseservers,1));  
        fromthestart = 1;  totheend = 1;
      else
        if (getranges(4,1) <= TimeRange(1)),  fromthestart = 1;  end
        if (getranges(4,2) >= TimeRange(2)),  totheend = 1;  end
        for i = 1:size(baseservers)
          if isempty(times2)
            starttoend(i) = (getranges(4,1) <= TimeRange(1) & ...
                             getranges(4,2) >= TimeRange(2));
          else
            starttoend(i) = (getranges(4,1) <= times1(i) & ...
                             getranges(4,2) >= times2(i));
          end
        end
      end
    else
      % if no Cat Server requested
      if (getranges(4,1) <= TimeRange(1) & getranges(4,2) >= TimeRange(2))
        starttoend = ones(1,length(years));  fromthestart = 1;  totheend = 1;
      else
        starttoend = zeros(1,length(years));
      end
    end
    %%%%%%%%%%%%%%%%%%%


    %%%%%%%%%%%%%%%%%%%
    % BUILD URL FOR INVENTORY SEARCH 
    %    (SECOND PASS, FOR INVENTORY OF EACH SELECTED OBJECT)
    % constraint expression here
    %       
    ce = [];  serverstr = []; 
    startd = begind;    endd = lastd;
    for i = 1:size(baseservers,1)
      if starttoend(i) 
        ce = strvcat(ce, '   ');  
        serverstr = strvcat(serverstr, baseservers(i,:));
        urlinfolist(4).time_info(i) = floor(max(beginy,times1(i)));
      else
        if ~isempty(times1) & ~isempty(times2)
          starty = floor(max(beginy,times1(i)));
          endy = floor(min(lasty,times2(i)));
          years = [starty:endy];
          leaps = isleap(beginy);
          yeardays = 365 + leaps;
          if beginy < starty,  startd = 0;  else,  startd = begind;  end
          if lasty > endy
            endd = yeardays(length(yeardays));
          else,  endd = lastd;  end
        else
          starty = beginy;  endy = lasty;
        end
        if endy > starty
          ce = strvcat(ce, ['&',yrdayname,'>=',num2str(startd),'&',...
                 yrdayname,'<=',num2str(yeardays(1))]);
          urlinfolist(4).time_info(i) = starty;
          serverstr = strvcat(serverstr, baseservers(i,:));
          j = 0;
          for j = 1:(endy - starty)-1
	    ce = strvcat(ce, ['&',yrdayname,'>=0','&',yrdayname,'<=',...
		   num2str(yeardays(j+1))]);
            urlinfolist(4).time_info(i+j) = starty + j;
            serverstr = strvcat(serverstr, baseservers(i,:));
          end
          if floor(endy) <= endy & floor(endy) ~= TimeRange(2)
            ce = strvcat(ce, ['&',yrdayname,'>=0','&',...
                   yrdayname,'<=',num2str(endd)]);
            urlinfolist(4).time_info(i+j+1) = endy;
            serverstr = strvcat(serverstr, baseservers(i,:));
          end
        else
          ce = strvcat(ce, ['&',yrdayname,'>=',num2str(startd),'&',...
                 yrdayname,'<=',num2str(endd)]);
          urlinfolist(4).time_info(i) = starty;
          serverstr = strvcat(serverstr, baseservers(i,:));
        end
      end
    end
    timestr = ce;
    %%%%%%%%%%%%%%%%%%%


    % first, update server_info
    urlinfolist(1).server_info = serverstr;
    varargout(1) = {timestr};
    varargout(2) = {serverstr};
    return

  end
end
