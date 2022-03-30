function y = mminmax(x)
%
% MMINMAX      find the minimum and maximum of a vector or a matrix
%             Robust with respect to NaN.
%
% USAGE       MMINMAX(x)
%
%  Deirdre Byrne: 18 Jan 1995

% The preceding empty line is important.
%
% $Id: mminmax.m,v 1.1 2000/05/31 23:11:48 dbyrne Exp $

% $Log: mminmax.m,v $
% Revision 1.1  2000/05/31 23:11:48  dbyrne
% *** empty log message ***
%
% Revision 1.1  2000/05/31 22:57:20  root
% *** empty log message ***
%
% Revision 1.2  1999/10/27 21:11:28  root
% *** empty log message ***
%
% Revision 1.1  1999/10/27 20:44:06  root
% *** empty log message ***
%
% Revision 1.2  1999/09/02 18:12:22  root
% *** empty log message ***
%
% Revision 1.9  1999/05/13 03:09:53  dbyrne
%
%
% Added Acknowledge and Data_Use_Policy to archive.m.  Fixed getxxx functions
% to use dodsmsg instead of stdout for errors/info.  Made ChangeLog so that it's
% in Emacs format.  All changes for release 3.0.0 -- dbyrne 99/05/12
%
% Revision 1.1  1998/05/17 14:10:51  dbyrne
% *** empty log message ***
%
% Revision 1.1.1.1  1997/09/22 14:13:53  tom
% Imported Matlab GUI sources to CVS
%

if nargin == 1
  if any(any(isnan(x)))
    i = find(~isnan(x));
    if ~isempty(i)
      y = [min(min(x(i))) max(max(x(i)))];
    else
      y = [nan nan];
    end
  else
    y = [min(min(x)) max(max(x))];
  end
end
clear x i
