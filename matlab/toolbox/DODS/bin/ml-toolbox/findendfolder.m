function [endfolder] = findendfolder(inlist,pos)
if nargin < 2
  error('usage: FINDENDFOLDER(INLIST,POS)')
  return
end

listlength = size(inlist,1);
endfolder = 0;

if isfolder(inlist,pos)
  % find out nesting level of this folder
  thislevel = inlist(pos).nestinglevel;
  
  % get all levels
  level=cat(1,inlist(:).nestinglevel);

  % look in entries below
  endfolder = listlength;
  for i = pos+1:listlength
    if level(i) < (thislevel+1)
      endfolder = i-1;
      break
    end
  end

  % check that it's really an end folder
  % (should correct if it's not)
  if ~isendfolder(inlist,endfolder)
    error('Findendfolder: no end to this folder')
  end
else
  error('Findendfolder: Entry position is not a folder')
end
return
