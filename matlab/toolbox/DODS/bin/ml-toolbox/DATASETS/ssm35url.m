function [URL] = ssm35url(archive, pass_times, columns, rows, ...
    dset_stride, ranges, variable, server)
%----------------------------------------------------------------------------
%
% Formal parameters:
% archive: Name of .m file containing metadata about this dataset. 
% columns, rows: matrix constraints 
% dset_stride: The stride value to use when reading the data. 
% nvars: Not used.
%
% NB: pass_times: This is a matrix of time with the year, day and
% ascending/descending flag of each hit. Note that the day here is the
% calendar day and the flag uses 0 for ascending and 1 for descending.

% The return values are:
% URL: A vector of URLs, one for each element of pass_times.
%
%----------------------------------------------------------------------------

% Note:  Inflexibly coding the url like this isn't quite proper, but in
%        the absence of a "real" catalog server - we've going to put up
%        with it for now.  The url should come from the catalog server
%        and it is, in fact, stored there - but that string is ignored.

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
monthList = str2mat('jan', 'feb', 'mar', 'apr', 'may', 'jun', 'jul', ...
             'aug', str2mat('sep', 'oct', 'nov', 'dec'));
monstr = monthList(month,:);
y2kyear = year(3:4);

% Build the remaing part of the directory/filename and the constraint
directory = [ year '/' ];
img_name = [ 'atlas.ssmi.ver02.level3.5.' monstr y2kyear '.hdf' ];
constraint = '';
for i = 1:size(variable,1)
  if i > 1
    constraint = [constraint ','];
  end
  constraint = [constraint deblank(variable(i,:)) ...
	'[0:1:0]' ...
	'[' StartRow ':' dset_stride ':' EndRow ']' ...
	'[' StartColumn ':' dset_stride ':' EndColumn ']'];
end
URL = [server directory img_name '?' constraint];
return;


