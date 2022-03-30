function list = parselist(listin)
%Parse comma seperated list into a cell array

i=0;
while ~isempty(listin)
  i=i+1;
  [list{i}, listin] = strtok(listin,',');
end
return;
