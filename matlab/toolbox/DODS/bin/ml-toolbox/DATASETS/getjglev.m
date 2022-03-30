function [strout] = getjglev(strin,varnames)

%
% Get level information from a jg string.
%
% Usage:  [strout] = getjglev(strin,varnames)
%          strout contains (1), total number of levels (n)
%                          (2) to (n+1), variables within each level
%                          (n+2),  level number for x/y/z/t
%

% klee 09/2000

strout = [];
for i = 1:size(strin,1)
  tmpstr = [];  levels = [];
  tmpstr = deblank(strin(i,:));
  levels = findstr(tmpstr, 'Level_');
  if ~isempty(levels)
    maxlevel = length(levels);
    if isfield(strout, 'level_info')
      strout(1).level_info = max(strout(1).level_info, maxlevel);
    else
      strout(1).level_info = maxlevel;
    end
    dots = findstr(tmpstr, '.');
    if ~isempty(dots)
      % first, find out variables under each level
      dotindex = min(find(dots > levels(maxlevel)));
      nextdot = dots(dotindex);
      if dotindex < length(dots)
        nextnextdot = dots(dotindex+1);
        tmpvar = tmpstr(nextdot+1:nextnextdot-1);
        if maxlevel+1 > size(strout,2)
          eval(['strout(',num2str(maxlevel+1),').level_info = tmpvar;'])
        else
          eval(['strout(',num2str(maxlevel+1),').level_info = str2mat(' ...
                'strout(',num2str(maxlevel+1),').level_info, tmpvar);']);
        end
      end
    end
  end
end      

% now, find out level number for the basic 4s
maxlevel = strout(1).level_info;
tvars = varnames(4:size(varnames,1),:);
for i = 1:maxlevel
  tmpvars = strout(i+1).level_info;
  for j = 1:size(tmpvars,1)
    if strcmp(deblank(tmpvars(j,:)), deblank(varnames(1,:)))   
      % xdim
      eval(['strout(',num2str(maxlevel+2),').level_info(1,1) = ', ...
             num2str(i-1), ';'])
    elseif strcmp(deblank(tmpvars(j,:)), deblank(varnames(2,:)))
      % ydim
      eval(['strout(',num2str(maxlevel+2),').level_info(2,1) = ', ...
             num2str(i-1), ';'])
    elseif strcmp(deblank(tmpvars(j,:)), deblank(varnames(3,:)))
      % zdim
      eval(['strout(',num2str(maxlevel+2),').level_info(3,1) = ', ...
             num2str(i-1), ';'])
    else
      % time
      for k = 1:size(tvars,1)
        if strcmp(deblank(tmpvars(j,:)), deblank(tvars(k,:)))
          eval(['strout(',num2str(maxlevel+2),').level_info(4,', ...
                num2str(k),') = ', num2str(i-1), ';'])
        end
      end
    end
  end
end
