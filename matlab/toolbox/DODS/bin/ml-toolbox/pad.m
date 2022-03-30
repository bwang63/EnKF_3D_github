function outstring = pad(instring, stringlen)
% pad short strings to desired length

if nargin < 2
  if nargout > 0
    outstring = instring;
  end
  return
end

if ~isstr(instring) | (fix(stringlen) ~= stringlen)
  error('usage: pad(string, length)')
  return
end

s = size(instring);

if s(2) < stringlen % string is not long enough
  if ~isempty(instring)
    tmp = instring(1,:);
  else
    tmp = '';
  end
  addlen = stringlen-s(2);
  tmp = [tmp blanks(addlen)];
  if s(1) > 1
    tmp = str2mat(tmp,instring(2:s(1),:));
  end
  instring = tmp;
end

%if nargout > 0
outstring = instring;
%end
return
