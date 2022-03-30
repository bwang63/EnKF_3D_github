function days = dpyear(year)
%
% Returns the number of days in a given year. 
%
% $Id: dpyear.m,v 1.1 2000/05/31 23:11:47 dbyrne Exp $

% $Log: dpyear.m,v $
% Revision 1.1  2000/05/31 23:11:47  dbyrne
% *** empty log message ***
%
% Revision 1.1  2000/05/31 22:57:20  root
% *** empty log message ***
%
% Revision 1.2  1999/09/02 18:12:21  root
% *** empty log message ***
%
% Revision 1.6  1999/05/13 03:09:53  dbyrne
%
%
% Added Acknowledge and Data_Use_Policy to archive.m.  Fixed getxxx functions
% to use dodsmsg instead of stdout for errors/info.  Made ChangeLog so that it's
% in Emacs format.  All changes for release 3.0.0 -- dbyrne 99/05/12
%
% Revision 1.1  1998/05/17 14:10:45  dbyrne
% *** empty log message ***
%
% Revision 1.1  1997/12/03 21:06:29  jimg
% Added.
%

if (isleap(year))
    days = 366;
else
    days = 365;
end

return;