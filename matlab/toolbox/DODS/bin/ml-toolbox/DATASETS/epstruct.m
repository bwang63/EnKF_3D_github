function [list] = epstruct(tmpname, name)

%
% expand struct hierarchy into a flat list
%
% Usage:  [list] = epstruct(struct, 'structname')
%
% ex, for a struct a
%      a == Level_0: [1x1 struct];
%      a.Level_0 == Level_1: [1x1 struct];
%                   x1: some_value;
%                   x2: some_value;
%      a.Level_0.Level_1 == Level_2: [1x1 struct];
%                           x1: some_value;
%      a.Level_0.Level_1.Level_2 == x1: some_value;
%      
%    list = epstruct(a, 'a');
%    returns list = a.Level_0.x1
%                   a.Level_0.x2
%                   a.Level_0.Level_1.x1
%                   a.Level_0.Level_1.Level_2.x1
%

% $Id: epstruct.m,v 1.7 2002/04/24 01:48:13 dan Exp $
% klee 07/2000

list = [];    
sizes = size(tmpname,2);
illstr = str2mat('(');
clean = 0;
if isstruct(tmpname)
%  tmp = getfield(tmpname);
%  tmpnames = str2mat(fieldnames(tmp));
  tmpnames = str2mat(fieldnames(tmpname));
  for i = 1:size(tmpnames,1)
    %realname = [name, '.', deblank(tmpnames(i,:))];
    tmptmpname = ['tmpname.',deblank(tmpnames(i,:))];
    if sizes == 1
      realname = [name, '.', deblank(tmpnames(i,:))];
      clean = 0;
      for k = 1:size(illstr,2)
        if isempty(findstr(realname, deblank(illstr(k,:))))
          clean = 1;
        end
      end
      if ~evalstr(realname),  clean = 1;  end
      if clean
        list = strvcat(list, epstruct(eval(tmptmpname), realname));
      end
    else
      for j = 1:sizes
        realname = [name,'(',num2str(j),').', deblank(tmpnames(i,:))];
        tmpstr = ['tmpname(',num2str(j),').',deblank(tmpnames(i,:))];
        if isstruct(tmpstr)
          list = strvcat(list, epstruct(eval(tmpstr), realname));
        else
          list = strvcat(list, realname);
        end
      end
    end
  end
else
  list = strvcat(list, name);
end

return


function [boolean] = evalstr(str)

boolean = 0;
dots = []; underline = [];
dot = '.';
underline = '_';
dots = findstr(str, dot);
underlines = findstr(str, underline);
if ~isempty(dots) & ~isempty(underlines)
  for i = 1:length(dots)
    if any(underlines == dots(i) + 1)
      boolean = 1;
      break;
    end
  end
end

return

% $Log: epstruct.m,v $
% Revision 1.7  2002/04/24 01:48:13  dan
% Moved from BROKEN_DATASETS. Used this program in gridcat.
%
% Revision 1.1  2002/04/15 20:03:32  dan
% Does not work in browser, so I moved to BROKEN_DATASETS directory.
%
% Revision 1.5  2002/04/15 14:53:55  dan
% Removed some bogus lines and fixed one line dealing with the fieldnames of a structure.
%
% Revision 1.4  2000/12/05 20:12:06  kwoklin
% Fix a typo.  klee
%
% Revision 1.3  2000/12/05 18:01:47  kwoklin
% Fix typos in epstruct, derefdat, gettstr and getjgsta.
% Fix returned argout6 to catserver in gbcat.
% Differentiate depth and heigth in getcat and getinfo.
% Add string building functionality in gburl for focus data set.  klee
%
% Revision 1.2  2000/11/14 19:41:25  kwoklin
% Fix for the presence of illegal matlab string.  klee
%
