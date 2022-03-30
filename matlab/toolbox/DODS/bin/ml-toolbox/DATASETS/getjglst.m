function [strarray, numarray] = getjglst(filename)

%
%
%

strarray = [];  numarray = [];
tmp = [];
fid = fopen(filename, 'r');
if fid <= -1
  return
end

tmp = fscanf(fid, '%c');
comma = find(tmp == ',');
space = find(isspace(tmp));
k = 1;
if ~isempty(comma)
  for i = 1:length(comma)
    strarray = strvcat(strarray, tmp(k:comma(i)-1));
    numarray = [numarray; str2num(tmp(comma(i)+1:space(i)-1))];
    k = space(i) + 1;
  end
else
  for i = 1:length(space)
     strarray = strvcat(strarray, tmp(k:space(i)-1));
     k = space(i) + 1;
  end
end

return
