function [URL] = reywkurl(archive, pass_times, columns, rows, ...
    dset_stride, ranges, variable, server)
%
%   This function will build a URL suitable for querying the 
%   Reynolds SST weekly dataset.
%

% The preceding empty line is important.
%
% $Id: reywkurl.m,v 1.1 2000/05/31 23:12:56 dbyrne Exp $

% $Log: reywkurl.m,v $
% Revision 1.1  2000/05/31 23:12:56  dbyrne
% *** empty log message ***
%
% Revision 1.1  2000/05/31 22:59:20  root
% *** empty log message ***
%
% Revision 1.9  1999/09/02 18:27:31  root
% *** empty log message ***
%
% Revision 1.7  1999/05/13 03:09:56  dbyrne
%
%
% Added Acknowledge and Data_Use_Policy to archive.m.  Fixed getxxx functions
% to use dodsmsg instead of stdout for errors/info.  Made ChangeLog so that it's
% in Emacs format.  All changes for release 3.0.0 -- dbyrne 99/05/12
%
% Revision 1.8  1999/05/13 01:24:19  root
% Added Acknowledge and Data_Use Policy.  Fixed some bugs.  Changed any
% messages to use to use 'dodsmsg' script instead of just displaying to stdout.
%
% Revision 1.7  1999/03/04 13:13:35  root
% All changes since AGU week.
%
% Revision 1.5  1998/11/18 19:57:02  dbyrne
%
%
% Second try.  Bug fixes to jpl pathfinder data, changed names of
% Reynolds datasets to clarify that one is a climatology and one is not.
%
% Revision 1.6  1998/11/09 14:53:20  root
% Fixed constraint on URL to reflect that this is a grid!
%
% Revision 1.5  1998/11/09 14:29:28  root
% Fixed stride for lon and lat fields.
%
% Revision 1.4  1998/11/05 16:01:56  root
% Changed LonVector and LatVector to be used if no Lon returned and tried the update function.
% DataScale and DataNull should now be optional!
%
% Revision 1.2  1998/09/13 21:31:19  dbyrne
% Updated to elminate global variables and add multivariables.
%
% Revision 1.3  1998/09/12 15:27:48  root
% Fixed some small bugs.
%
% Revision 1.2  1998/09/09 16:10:29  dbyrne
% Fixed numerous small bugs.
%
% Revision 1.1  1998/05/17 14:18:12  dbyrne
% *** empty log message ***
%
% Revision 1.1.1.1  1997/09/22 14:13:55  tom
% Imported Matlab GUI sources to CVS
%

%global TemporaryTime

if exist(archive) == 2
  eval(archive)
  StartTime = TimeRange(1);
else
  dodsmsg([ 'reywkurl: Unable to evaluate ' archive '.m'])
  return
end

variable = deblank(variable);
server = deblank(server);

% Find the number of days after the dataset StartTime until the
% requested time.

ReqTime = year2day(pass_times(1), StartTime) + pass_times(2);

% Convert it to the week number. (The number of weeks 
% since StartTime, plus one).
ITime = floor(ReqTime / 7.0);

% THIS WILL ONLY WORK UNTIL THEY MAKE A NEW FILE!
if ITime >= 0 & ITime < 427
  ImgName = 'sst.wkmean.1981-1989.nc';
elseif ITime >= 427 & ITime < 860
  ImgName = 'sst.wkmean.1990-present.nc';
  ITime = ITime - 427;
else
  % try and estimate if any new datasets have been added;
  decdate = thisday; % get the date
  if pass_times(1)+pass_times(2)/(365+isleap(pass_times(1))) < ...
	decdate-7/365; % if request is more than a week ago, try it.
    ImgName = 'sst.wkmean.1990-1996.nc';
    ITime = ITime - 427;
  else
    dodsmsg('Requested time is out of range')
    URL = '';
    return
  end
end
  
Constraint = sprintf('%s', variable,'[', num2str(ITime), ':', num2str(ITime), '][', ...
  num2str(rows(1)), ':', num2str(dset_stride), ':', num2str(rows(2)),'][', ...
  num2str(columns(1)), ':', num2str(dset_stride), ':', num2str(columns(2)), ']');

URL = sprintf('%s', server, ImgName, '?', Constraint);

return

