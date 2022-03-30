function [val] = allsizesok(inlist, variables)

% put any integrity checks wanted in here.

val = 0;

dataprops = cat(1,inlist(:).dataprops);
nsets = size(dataprops,1);
nvars = size(variables,1);

if all(size(dataprops) == [nsets nvars])
  val = 1;
end
