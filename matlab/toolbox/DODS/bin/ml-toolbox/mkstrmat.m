function strmat=mkstrmat(instr)

% strmat takes a simple input string which contains line feeds '\n',
%  and creates a string matrix of the individual lines.
%  Uneven lines are padded to make the string matrix.
%
% begun 4 April 1999 by paul hemenway
%

% The preceeding blank line is important for cvs.
% $Id: mkstrmat.m,v 1.2 2000/09/01 18:45:04 dbyrne Exp $
%

% $Log: mkstrmat.m,v $
% Revision 1.2  2000/09/01 18:45:04  dbyrne
% *** empty log message ***
%
% Revision 1.2  2000/09/01 18:30:10  root
% *** empty log message ***
%
% Revision 1.1  2000/05/31 22:57:20  root
% *** empty log message ***
%
% Revision 1.1  1999/09/02 18:33:45  root
% *** empty log message ***
%
% Revision 1.4  1999/05/26 20:59:23  paul
%
%
% Fixed 'em up.  -- dbyrne 99/05/26
%
% Revision 1.3  1999/05/25 15:33:43  paul
% add cvs logging and id lines ...   phemenway
%

%check for a simple string:
if ~isstr(instr)
  dodsmsg('Mkstrmat: you have not input a string. please try again.')
  return
elseif isstr(instr) & size(instr,1) > 1
  strmat = instr;
  return
end

newline = setstr(10);
i = findstr(instr,newline);
if ~isempty(i)
  i = [0 i];
  strmat='';
  ssn=[];
else
  % there are no newlines in the string
  strmat = instr;
  return
end

for j=1:length(i)-1
  istr = instr(i(j)+1:i(j+1)-1);
  strmat = str2mat(strmat,istr);
end
strmat = strmat(2:size(strmat,1),:);
return
