function [argout] = dods_combine(argin1, argin2, argin3)
%
%  Function to combine two vectors/arrays
%  Third argument may be 'lr', to combine them
%  side-by-side ([a b]), or 'ud', to combine them 
%  one on top of the other [a; b];
%

% The preceding empty line is important.
%
% $Id: dods_combine.m,v 1.1 2000/05/31 23:11:47 dbyrne Exp $

% $Log: dods_combine.m,v $
% Revision 1.1  2000/05/31 23:11:47  dbyrne
% *** empty log message ***
%
% Revision 1.1  2000/05/31 22:57:19  root
% *** empty log message ***
%
% Revision 1.1  2000/05/25 14:58:53  root
% *** empty log message ***
%
% Revision 1.2  1999/09/02 18:05:28  root
% *** empty log message ***
%
% Revision 1.4  1999/05/13 03:09:53  dbyrne
%
%
% Added Acknowledge and Data_Use_Policy to archive.m.  Fixed getxxx functions
% to use dodsmsg instead of stdout for errors/info.  Made ChangeLog so that it's
% in Emacs format.  All changes for release 3.0.0 -- dbyrne 99/05/12
%
% Revision 1.1  1998/11/05 15:53:51  root
% Moved up from datasets directory.
%
% Revision 1.4  1998/09/13 21:31:08  dbyrne
% Updated to elminate global variables and add multivariables.
%
% Revision 1.2  1998/09/09 07:34:20  dbyrne
% Eliminating ReturnedVariables
%
% Revision 1.1  1998/05/17 14:18:03  dbyrne
% *** empty log message ***
%
% Revision 1.1.1.1  1997/09/22 14:13:54  tom
% Imported Matlab GUI sources to CVS
%
% Found an error in logic for identifying 
% rectangular matrices 98/04/20 -- dab.
%

[n1 m1] = size(argin1);
[n2 m2] = size(argin2);
argout = [];
% added check for null matrices -- dab, 98/04/14
if any([n1 m1 n2 m2] == 0)
  if any([n1 m1] == 0) & ~any([n2 m2] == 0)
    argout = argin2;
  elseif ~any([n1 m1] == 0) & any([n2 m2] == 0)
    argout = argin1;
  end
  return
end

%if (n1 == 1) & (m1 == 1) & (n2 == 1) & (m2 == 1)
%  disp('Problem in dods_combine; both arrays passed in are 1x1')
%  argout = [argin1 argin2];
%  return
%end

if nargin == 3
  if strcmp(argin3,'lr')
    argout = [argin1 argin2];
  elseif strcmp(argin3,'ud')
    argout = [argin1; argin2];
  end
else
  if (n1 == 1) & (n2 == 1) & ((m1 > 1) | (m2 > 1)) % Two row vectors.
    argout = [argin1 argin2];
  elseif (m1 == 1) & (m2 == 1) & ((n1 > 1) | (n2 > 1)) % Two column vectors.
    argout = [argin1; argin2];
  elseif (n1 == n2) & (m1 ~= m2) % Two rect matrices with equal rows, diff columns.
    argout = [argin1 argin2];
  elseif (n1 ~= n2) & (m1 == m2) % Two rect matrices with diff rows, equal columns.
    argout = [argin1; argin2];
  elseif (n1 == n2) & (m1 == m2) % Two square matrices. Print warning.
    %disp('The input matices to dods_combine.m are square. Will comine as [a b]')
    argout = [argin1 argin2];
  else % Two matrices, diff rows and columns
    disp('Problem in dods_combine; matrices differ in both rows and columns.')
  end
end

return

   