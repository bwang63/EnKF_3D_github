function closefig(instring)
% find and close a figure based on its userdata
kids = get(0,'children');
j = [];
for i = 1:length(kids),
  if strcmp(get(kids(i),'userdata'), instring)
    j = [j kids(i)];
  end
end
if ~isempty(j)
  close(j)
end
return
