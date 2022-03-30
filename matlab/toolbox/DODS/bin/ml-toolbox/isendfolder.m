function out = isendfolder(inlist,pos)
global folder_end
ssize = size(folder_end,2);
out = 0;
if nargin == 2
  datastring = pad(deblank(inlist(pos).name),ssize);
  if strcmp(datastring(1:ssize),folder_end)
    out = 1;
  end
end
return
