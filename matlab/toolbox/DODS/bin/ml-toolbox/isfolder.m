function out = isfolder(inlist,pos)
global folder_start
psize = size(folder_start,2);
out = zeros(size(pos));
if nargin == 2
  for i = 1:length(pos)
    datastring = pad(deblank(inlist(pos(i)).name),psize);
    if strcmp(datastring(1:psize),folder_start)
      out(i) = 1;
    end
  end
end
return
