function [URL] = climurl(archive, pass_times, columns, rows, ...
    dset_stride, ranges, variablelist, server)

%
%   This function will build URLs for a number of monthly climatologies.
%

% The preceding empty line is important.
%
% $Id: climurl.m,v 1.1 2000/05/31 23:12:54 dbyrne Exp $

% $Log: climurl.m,v $
% Revision 1.1  2000/05/31 23:12:54  dbyrne
% *** empty log message ***
%
% Revision 1.1  2000/05/31 22:59:19  root
% *** empty log message ***
%
% Revision 1.1  2000/04/12 01:16:14  root
% Used to be pmelurl.m
%
% Revision 1.7  1999/05/13 03:09:55  dbyrne
%
%
% Added Acknowledge and Data_Use_Policy to archive.m.  Fixed getxxx functions
% to use dodsmsg instead of stdout for errors/info.  Made ChangeLog so that it's
% in Emacs format.  All changes for release 3.0.0 -- dbyrne 99/05/12
%
% Revision 1.7  1999/03/04 13:13:32  root
% All changes since AGU week.
%
% Revision 1.5  1998/11/18 19:57:02  dbyrne
%
%
% Second try.  Bug fixes to jpl pathfinder data, changed names of
% Reynolds datasets to clarify that one is a climatology and one is not.
%
% Revision 1.6  1998/11/05 16:01:55  root
% Changed LonVector and LatVector to be used if no Lon returned and tried the update function.
% DataScale and DataNull should now be optional!
%
% Revision 1.2  1998/09/13 21:31:17  dbyrne
% Updated to elminate global variables and add multivariables.
%
% Revision 1.5  1998/09/08 14:59:06  dbyrne
% Modifications for multiple servers ....
%
% Revision 1.4  1998/09/08 11:18:14  dbyrne
% Added input argument 'server' for compatibility with coadurl.m --
% this means (I think) that archive.m does not need to be sourced inside
% the URL_m_file script any more.
%
% Revision 1.3  1998/09/08 11:02:31  dbyrne
% Added input argument 'ranges' for consistency with coadurl.m
%
% Revision 1.2  1998/08/31 12:12:26  dbyrne
% beginning changes for multiple variables
%
% Revision 1.1  1998/05/17 14:18:11  dbyrne
% *** empty log message ***
%
% Revision 1.1.1.1  1997/09/22 14:13:55  tom
% Imported Matlab GUI sources to CVS
%

year = pass_times(1);
yearday = pass_times(2);

if rem(year,4) ~= 0 | year == 1900
   MonthLastDay = [31 59 90 120 151 181 212 243 273 304 334 400];
else
   MonthLastDay = [31 60 91 121 152 182 213 244 274 305 335 400];
end

iMonth = 0;
while yearday > MonthLastDay(iMonth+1)
   iMonth = iMonth + 1;
end

% Got the month now the constraint.
Constraint = '';
for i = 1:size(variablelist,1)
  TempName = deblank(variablelist(i,:));
  if i > 1
    Constraint = [Constraint ','];
  end
  Constraint = [Constraint sprintf('%s', TempName,'[', num2str(iMonth), ':', ...
      num2str(iMonth), '][', num2str(rows(1)), ':', ...
      num2str(dset_stride), ':', num2str(rows(2)),'][', ...
      num2str(columns(1)), ':', num2str(dset_stride), ':',...
      num2str(columns(2)), ']')];
end
URL = sprintf('%s', deblank(server), '?', Constraint);
return
