function [URL] = fsupsurl(archive, pass_times, columns, rows, dset_stride, ...
    ranges, variablelist, server)
%
% This function will build the FSU Pacific Monthly Pseudostress Averages file name.
%

% The preceding empty line is important.
%
if exist(archive) == 2
  eval(archive)
else
  dodsmsg([ 'Archive file ' archive ' not found!'])
  return
end

% Need to get the month first.
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

StartYear = floor(ranges(4,1));
jMonth = (StartYear - TimeRange(1)) * 12 + iMonth;

Constraint = '';
for i = 1:size(variablelist,1)
  TempName = deblank(variablelist(i,:));
  if i > 1
    Constraint = [Constraint ','];
  end
  Constraint = [Constraint sprintf('%s',TempName,'[', num2str(jMonth), ':', ...
	num2str(jMonth), '][', num2str(rows(1)),':', ...
	num2str(dset_stride),':',num2str(rows(2)),'][', ...
	num2str(columns(1)), ':', num2str(dset_stride), ':',...
	num2str(columns(2)), ']')];
end
URL = sprintf('%s', deblank(server), '?', Constraint);
return
