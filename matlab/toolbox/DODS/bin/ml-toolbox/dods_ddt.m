function dstr = dods_ddt(str)
%
% DODS de-dot. This removes all of a string up to and including the 
% rightmost period '.'.  For example, 'NSCAT_Rev_30.Avg_Wind_Vel_U'
% becomes 'Avg_Wind_Vel_U'.

str = deblank(str);

dots = findstr(str, '.');
if ~isempty(dots)
  dots = max(dots)+1;
  dstr = str(dots:size(str,2));
else
  dstr = str;
end
return
