function [dyeararray] = derefdat(dyear)

%
%  This is for the new loaddods, which pad str with nulls (char(0))
%  instead of spaces
%

% $Id: derefdat.m,v 1.3 2000/12/20 21:04:59 dbyrne Exp $
% klee 08/2000

dyeararray = []; 
decyear = [];  time = [];  date = [];  datetime = [];
columns = [];  slashes = [];

hasslash = 0;  hascolumn = 0;
space = ' ';
column = ':';
slash = '/';
decyear = eval('dyear');
decyear(decyear == char(0)) = space;
hascolumn = ~isempty(find(decyear == column));
hasslash = ~isempty(find(decyear == slash));

if hascolumn
  % either date_time or time info is returned
  if hasslash  
    % date_time is returned
    for i = 1:size(decyear,1)
      datetime = decyear(i,:);
      slashes = find(datetime == slash);
      columns = find(datetime == column);
      dyeararray = [dyeararray; [...
                    str2num(datetime(1:4)), ...
                    str2num(datetime(slashes(1)+1:slashes(2)-1)), ...
                    str2num(datetime(slashes(2)+1:columns(1)-1)), ...
                    str2num(datetime(columns(1)+1:columns(2)-1)), ...
                    str2num(datetime(columns(2)+1:columns(3)-1)), ...
                    str2num(datetime(columns(3)+1:columns(3)+2))]];
    end
  else
    %time is returned   
    for i = 1:size(decyear,1)
      time = decyear(i,:);
      columns = find(time == column);
      dyeararray = [dyeararray; [...
                    str2num(time(1:columns(1)-1)), ...
                    str2num(time(columns(1)+1:columns(2)-1)), ...
                    str2num(time(columns(2)+1:columns(2)+2))]];
    end
  end
elseif hasslash
  % date only is returned  
  for i = 1:size(decyear,1)
    date = decyear(i,:);  
    slashes = find(date == slash);
    dyeararray = [dyeararray; [...
                  str2num(date(1:slashes(1)-1)), ...
                  str2num(date(slashes(1)+1:slashes(2)-1)), ...
                  str2num(date(slashes(2)+1:slashes(2)+2))]];
  end
else                 
  % decimal is returned
  if ~isempty(decyear)
    dyeararray = str2num(decyear);
  end
end
 

% $Log: derefdat.m,v $
% Revision 1.3  2000/12/20 21:04:59  dbyrne
% *** empty log message ***
%
% Revision 1.2  2000/11/14 19:22:00  kwoklin
% Safeguard for empty entry.   klee
%
% Revision 1.1  2000/09/19 20:51:59  kwoklin
% First toolbox internal release.   klee
%
