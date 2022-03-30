function out = findfig(instring)

k = get(0,'children');
j = [];
for i = 1:length(k);
  if strcmp(get(k(i),'userdata'), instring)
    j = [j k(i)];
  end
end

out = j;
return
