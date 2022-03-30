function [depthstr,servers,tmpdepths,urlinfolist] = iestsd(str,getarchive,...
                  getranges,getmode,getvars,urlinfolist,varargin)

%
%
%

% The preceding empty line is important
% $Log: iestsd.m,v $
% Revision 1.1  2000/09/28 04:30:01  kwoklin
% First toolbox internal release.   klee
%

% $Id: iestsd.m,v 1.1 2000/09/28 04:30:01 kwoklin Exp $
% klee

% initialization
depthstr = [];  servers = [];  tmpdepths = [];
dindex = [];

if exist(getarchive) == 2   
  eval(getarchive)
else
  dodsmsg('Metadata not found!')
  return
end

% servers
baseservers = [];
baseservers = [urlinfolist(1).server_info];

% start and end depths
mind = max(DepthRange(1), getranges(3,1));
maxd = min(DepthRange(2), getranges(3,2));

alldepths = [200:25:5000];
seD = [mind, maxd];
dindex = find(alldepths >= seD(1) & alldepths <= seD(2));

if strcmp(str, 'url')
  % for catalog display
  tmpdepths = alldepths(dindex);

  % constrcut severs and depthstr
  if ~isempty(baseservers)
    for i = 1:size(baseservers,1)
      depthstr = strvcat(depthstr, '   ');
      servers = strvcat(servers, baseservers(i,:));
    end
  end

elseif strcmp(str, 'data')
  % initialization
  startindex = 0;  endindex = 0;

  % start and end index
  if ~isempty(dindex)
    startindex = dindex(1)-1;
    endindex = dindex(length(dindex))-1;
  end

  % construct depthstr and servers
  ce = []; 
  for i = 1:size(baseservers,1)
    ce = strvcat(ce, ['[',num2str(startindex),':',num2str(endindex),']']);
    servers = strvcat(servers, baseservers(i,:));
  end
  depthstr = ce;

end

return
