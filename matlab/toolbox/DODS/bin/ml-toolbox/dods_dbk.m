function dstr = dods_dbk(str)
%
% DODS deblank. Like deblank, this removes trailing spaces. In addition it
% takes HTTP escape sequences and folds them to underscores. for example,
% `Sea%20Surface' becomes `Sea_Surface'. Note that this is a one way
% transformation since all escape sequences are rendered as undescores. 
%
% NB: the HTTP escape sequences replace certain characters with their ASCII
% codes in hexidecimal; 20 base 16 is a space.
%
% $Id: dods_dbk.m,v 1.1 2000/05/31 23:11:47 dbyrne Exp $

% $Log: dods_dbk.m,v $
% Revision 1.1  2000/05/31 23:11:47  dbyrne
% *** empty log message ***
%
% Revision 1.1  2000/05/31 22:57:19  root
% *** empty log message ***
%
% Revision 1.3  1999/09/02 18:12:21  root
% *** empty log message ***
%
% Revision 1.6  1999/05/13 03:09:53  dbyrne
%
%
% Added Acknowledge and Data_Use_Policy to archive.m.  Fixed getxxx functions
% to use dodsmsg instead of stdout for errors/info.  Made ChangeLog so that it's
% in Emacs format.  All changes for release 3.0.0 -- dbyrne 99/05/12
%
% Revision 1.2  1998/11/09 12:47:03  root
% Fixed small things in display.
%
% Revision 1.1  1998/05/17 14:10:45  dbyrne
% *** empty log message ***
%
% Revision 1.1  1997/12/04 18:57:12  jimg
% Added.
%

str = deblank(str);

percent_signs = findstr(str, '%');

% Assume that all escape sequences are three characters long (a percent sign
% followed by two hex digits)
dstr = [];
s = 1;
for e = percent_signs
    dstr = [dstr str(s : e-1) '_'];
    s = e + 3;
end

% Grab any trailing text.
e = size(str, 2);
if s <= e
    dstr = [dstr str(s : size(str, 2))];
else					% If no more text, remove trailing _
    dstr = dstr(1 : size(dstr, 2) - 1);
end
if isempty(dstr)
  dstr = '';
end
return;