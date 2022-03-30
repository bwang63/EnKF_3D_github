function val = instr(str1, str2)

% INSTR like findstr but stricter.  FIND IF STR1 is in STR2!

sz1 = size(str1,2);
sz2 = size(str2,2);

if sz2 < sz1
  % string 1 CANNOT be contained within string 2.
  val = [];
else
  val = findstr(str1, str2);
end
return
