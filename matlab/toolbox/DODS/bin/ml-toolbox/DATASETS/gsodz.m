function [depthstr,servers,tmptimes,urlinfolist] = gsodz(str,getarchive,...
                  getranges,getmode,getvars,urlinfolist,varargin)

%
%
%

% The preceding empty line is important
% $Log: gsodz.m,v $
% Revision 1.1  2000/09/19 20:50:42  kwoklin
% First toolbox internal release.   klee
%

% $Id: gsodz.m,v 1.1 2000/09/19 20:50:42 kwoklin Exp $
% klee

% initialization
depthstr = [];  servers = []; tmptimes = [];  

if exist(getarchive) == 2   
  eval(getarchive)
else
  dodsmsg('Metadata not found!')
  return
end

% Names
varname = urlinfolist(1).var_name;
depthName = deblank(varname(3,:));
wdepthName = deblank(varname(4,:));
presName = deblank(varname(5,:));
instName = deblank(varname(6,:));
otherDName = deblank(varname(7,:));

% water_column or met?
%     clean up varbool and varname since both depth and height
%       appear in the same dataset
inwater = 0;  inair = 0;
varbool = urlinfolist(1).var_info;
if strcmp(getarchive, 'gsodockw')
  inwater = 1;  
  varbool(5) = nan;
  varname(5,:) = char(setstr(32)*ones(1,size(varname,2)));
elseif strcmp(getarchive, 'gsodockm')
  inair = 1;
  varbool(3) = nan;
  varname(3,:) = char(setstr(32)*ones(1,size(varname,2)));
end
urlinfolist(1).var_info = varbool;
urlinfolist(1).var_name = varname;

if strcmp(str, 'url')
  % starttoend
  starttoend = 0;
  if inwater
    if (getranges(3,1) <= DepthRange(1) & getranges(3,2) >= DepthRange(2))
      starttoend = 1;
    end
  elseif inair
    % getranges and DepthRange all are negative in air
    if (getranges(3,1) <= DepthRange(1) & getranges(3,2) >= DepthRange(2))
      starttoend = 1;
    end
  end

  % servers
  baseservers = [];
  baseservers = [urlinfolist.server_info];

  % construct depthstr and servers
  ce = []; 
  if ~isempty(baseservers)
    for i = 1:size(baseservers,1)
      if starttoend
        ce = strvcat(ce, '   ');
        servers = strvcat(servers, baseservers(i,:));
      else
        if inwater
          ce = strvcat(ce, ['&',depthName,'>=',num2str(getranges(3,1)),...
			    '&',depthName,'<=',num2str(getranges(3,2))]);
        elseif inair
          % actual data in air are positive numbers
          ce = strvcat(ce, ['&',presName,'<=',num2str(-getranges(3,1)),...
		            '&',presName,'>=',num2str(-getranges(3,2))]);
        end
        servers = strvcat(servers, baseservers(i,:));
      end
    end
  end
      
  depthstr = ce;  

elseif strcmp(str, 'data')

  servers = urlinfolist(1).server_info;

end

return
