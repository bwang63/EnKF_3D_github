function [URL] = jplczurl(archive, pass_times, columns, rows, ...
    dset_stride, ranges, variable, server)
%----------------------------------------------------------------------------
%
% Formal parameters:
% archive: Name of .m file containing metadata about this dataset. 
% pass_times: Matrix from jplczcscat.
% StartColumnumn, ...: Integers denoting the obvious stuff about the data's
% matrix. 
% dset_stride: The stride value to use when reading the data. 
% nvars: Not used.
%
% NB: pass_times: This is a matrix of time with the year, day and
% ascending/descending flag of each hit. Note that the day here is the
% calendar day and the flag uses 0 for ascending and 1 for descending.

% The return values are:
% URL: A vector of URLs, one for each element of pass_times.
%
% $Log: jplczurl.m,v $
% Revision 1.1  2000/05/31 23:12:55  dbyrne
% *** empty log message ***
%
% Revision 1.1  2000/05/31 22:59:20  root
% *** empty log message ***
%
% Revision 1.1  1999/05/13 02:55:20  dbyrne
%
%
% New palettes, dataset files with shortened names, and a few new scripts for
% release 3.0.0. -- dbyrne 99/05/12
%
% Revision 1.1  1999/05/13 01:22:24  root
% These are all files that had names shortened from something longer.
%
% Revision 1.2  1999/03/04 13:13:29  root
% All changes since AGU week.
%
% Revision 1.2  1998/12/04 23:08:23  jimg
% Fix for Matlab 4's version of str2mat which can only take 11 or fewer
% elements.
%
%----------------------------------------------------------------------------

% Note:  Inflexibly coding the url like this isn't quite proper, but in
%        the absence of a "real" catalog server - we're going to put up
%        with it for now.  The url should come from the catalog server
%        and it is, in fact, stored there - but that string is ignored.

variable = deblank(variable);
server = deblank(server);

% Change the row/col  constraint information to string.
StartRow = num2str(rows(1));
dset_stride = num2str(dset_stride);
EndRow = num2str(rows(2));
StartColumn = num2str(columns(1));
EndColumn = num2str(columns(2));

% we need year, last two digits of year and first three digits
% of the month to build the rest of the path to the data.
% What is the year ?
year = num2str(pass_times(1));
% what is the month ?
month = pass_times(2);
% Note the following sleazy hack for ML 4's str2mat limitation. Since
% str2mat() may only be called with 11 or fewer elements, I curry the call...
% 12/4/98 jhrg.
monthList = str2mat(str2mat('jan', 'feb', 'mar', 'apr', 'may', 'jun'), ...
      'jul', 'aug', 'sep', 'oct', 'nov', 'dec');
monstr = monthList(month,:);
y2kyear = year(3:4);

% Build the remaing part of the directory/filename and the constraint
directory = [ '/' ];
img_name = [ 'c' y2kyear monstr 'v.hdf' ];

constraint = [ '?' variable ...
	   '[' StartRow ':' dset_stride ':' EndRow ']' ...
	   '[' StartColumn ':' dset_stride ':' EndColumn ']'];

URL = [ server directory img_name constraint ];

return;


