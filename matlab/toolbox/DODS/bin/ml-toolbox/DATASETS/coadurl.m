function [URL] = coadurl(archive, pass_times, columns, rows,  ...
    dset_stride, ranges, variablelist, serverlist)
%
%   This function will build the COADS and Esbensen-Kushnir file names.
%

% The preceding empty line is important.
%
% $Id: coadurl.m,v 1.1 2000/05/31 23:12:55 dbyrne Exp $

% $Log: coadurl.m,v $
% Revision 1.1  2000/05/31 23:12:55  dbyrne
% *** empty log message ***
%
% Revision 1.1  2000/05/31 22:59:19  root
% *** empty log message ***
%
% Revision 1.8  2000/04/12 01:16:50  root
% Changed to make complete URLs.
%
% Revision 1.7  1999/05/13 03:09:54  dbyrne
%
%
% Added Acknowledge and Data_Use_Policy to archive.m.  Fixed getxxx functions
% to use dodsmsg instead of stdout for errors/info.  Made ChangeLog so that it's
% in Emacs format.  All changes for release 3.0.0 -- dbyrne 99/05/12
%
% Revision 1.7  1999/05/13 01:24:14  root
% Added Acknowledge and Data_Use Policy.  Fixed some bugs.  Changed any
% messages to use to use 'dodsmsg' script instead of just displaying to stdout.
%
% Revision 1.6  1999/03/04 13:13:26  root
% All changes since AGU week.
%
% Revision 1.5  1998/11/18 19:57:01  dbyrne
%
%
% Second try.  Bug fixes to jpl pathfinder data, changed names of
% Reynolds datasets to clarify that one is a climatology and one is not.
%
% Revision 1.5  1998/11/05 16:01:51  root
% Changed LonVector and LatVector to be used if no Lon returned and tried the update function.
% DataScale and DataNull should now be optional!
%
% Revision 1.2  1998/09/13 21:31:07  dbyrne
% Updated to elminate global variables and add multivariables.
%
% Revision 1.4  1998/09/09 20:24:40  dbyrne
% Fixed syntax bug in Constraint expression.
%
% Revision 1.3  1998/09/08 21:18:08  dbyrne
% URL builder for the COADS monthly data, multivariable version.
%
% Revision 1.2  1998/09/08 14:59:07  dbyrne
% Modifications for multiple servers ....
%
% Revision 1.1  1998/05/17 14:18:01  dbyrne
% *** empty log message ***
%
% Revision 1.1.1.1  1997/09/22 14:13:54  tom
% Imported Matlab GUI sources to CVS
%

URL = '';
if exist(archive) == 2
  eval(archive)
else
  dodsmsg([archive ' does not exist!'])
  return
end
if strcmp(CatalogServer,'monthly')
  % Need to get the month first.
  year = pass_times(1);
  yearday = pass_times(2);
  
  if ~isleap(year)
    MonthLastDay = [31 59 90 120 151 181 212 243 273 304 334 400];
  else
    MonthLastDay = [31 60 91 121 152 182 213 244 274 305 335 400];
  end

  iMonth = 0;
  while yearday > MonthLastDay(iMonth+1)
    iMonth = iMonth + 1;
  end

  StartYear = floor(ranges(4,1));
  jMonth = (StartYear - TimeRange(1)) * 12 + iMonth;
  dataindex = jMonth;
elseif strcmp(CatalogServer,'seasonal')
elseif strcmp(CatalogServer,'annual')
  % Need to get the month first.
  year = pass_times(1);
  StartYear = floor(ranges(4,1));
  jYear = (StartYear - TimeRange(1));
  dataindex = jYear;
end
% Got the month now the constraint.
for i = 1:size(serverlist,1)
  Server = deblank(serverlist(i,:));
  variable = deblank(variablelist(i,:));
  Constraint = [sprintf('%s', variable, '[', num2str(dataindex), ':', ...
	num2str(dataindex), '][', num2str(rows(1)), ':', ...
	num2str(dset_stride), ':', num2str(rows(2)),'][', ...
	num2str(columns(1)), ':', num2str(dset_stride), ':',...
	num2str(columns(2)), ']')];
  iURL = sprintf('%s', Server, '?', Constraint);
  if i == 1
    URL = iURL;
  else
    URL = sprintf('%s\n%s', URL, iURL);
  end
end
URL = sprintf('%s\n',URL);
return
