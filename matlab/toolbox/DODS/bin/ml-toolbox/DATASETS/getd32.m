function [urlinfolist,varargout] = getd32(str, getarchive, getranges, ...
          names, varbool, urlinfolist, varargin)

%
% decimal_year, decimal_date
%

% $Log: getd32.m,v $
% Revision 1.1  2000/09/19 20:50:41  kwoklin
% First toolbox internal release.   klee
%

% $Id: getd32.m,v 1.1 2000/09/19 20:50:41 kwoklin Exp $
% klee 

% initialization
varargout{1} = [];
timename = deblank(names(1,:));

if isstr(str)

  if strcmp(str, 'url')

    % ------------   IN URL CONSTRUCTION MODE  -------------------------------

    if exist(getarchive) == 2   
      eval(getarchive)
    else
      dodsmsg('Metadata not found!')
      return
    end

    %%%%%%%%%%%%%%%%%%
    beginTime = max(TimeRange(1), getranges(4,1));
    lastTime = min(TimeRange(2), getranges(4,2));
    %%%%%%%%%%%%%%%%%%

    baseservers = [];
    baseservers = [urlinfolist.server_info];

    %%%%%%%%%%%%%%%%%%
    % for server optimization
    starttoend = 0;
    if (getranges(4,1) <= TimeRange(1) & getranges(4,2) >= TimeRange(2))
      starttoend = ones(size(baseservers,1),1); 
    else
      starttoend = zeros(size(baseservers,1),1); 
    end
    %%%%%%%%%%%%%%%%%%

    %%%%%%%%%%%%%%%%%%
    % BUILD URL FOR INVENTORY SEARCH
    ce = [];  serverstr = [];  timestr = [];
    for i = 1:size(baseservers,1)
      if starttoend(i)
        ce = strvcat(ce, '   ');
        serverstr = strvcat(serverstr, baseservers(i,:));
      else
        ce = strvcat(ce, ['&',timename,'>=',num2str(beginTime),...
                          '&',timename,'<=',num2str(lastTime)]);
        serverstr = strvcat(serverstr, baseservers(i,:));
      end
    end
    timestr = ce;
    %%%%%%%%%%%%%%%%%%

    % first, update server_info
    urlinfolist(1).server_info = serverstr;
    varargout(1) = {timestr};
    varargout(2) = {serverstr};
  
  end
end

return
