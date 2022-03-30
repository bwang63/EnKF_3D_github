function [nameout, indexout] = sortjgt(namein, indexin)

%
%
%

% klee 09/2000

% a reminder of all time variables available and their numbers
% year,month,day,yrday,julianday,decimaldate,hr,min,sec,othert
% 1,   2,    4,  8,    16,       32,         64,128,256,512

nameout = namein;  indexout = indexin;
if any(find(indexin == 1))   % year 
  if ~any(find(indexin == 512))
    if any(find(indexin == 2)) & any(find(indexin == 4))  % month/day
      if any(find(indexin == 32))
        indexout = 32;
        nameout = namein(find(indexin == 32),:);
      elseif any(find(indexin == 8))
        % take the year/yrday combination
        indexout = [1 8];
        nameout = str2mat(namein(find(indexin == 1),:), ...
                          namein(find(indexin == 8),:));
      else
        % year/month/day
        indexout = [1 2 4];
        nameout = str2mat(namein(find(indexin == 1),:), ...
                          namein(find(indexin == 2),:), ...
                          namein(find(indexin == 4),:));
      end
    elseif any(find(indexin == 32))  %decimaldate
      indexout = 32;
      nameout = namein(find(indexin == 32),:);
    end
  end
elseif any(find(indexin == 32))
  indexout = 32;
  nameout = namein(find(indexin == 32),:);
end

return
