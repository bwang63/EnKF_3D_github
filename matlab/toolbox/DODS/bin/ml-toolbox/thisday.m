function decdate = thisday()
% THISDAY   calculate the current day in decimal years.
%
% USAGE     DECDATE = THISDAY;

% D. Byrne 98/04/23
VERSION = version; VERSION = str2num(VERSION(1));
mos = str2mat('Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep', ...
    str2mat('Oct','Nov','Dec'));
d = date; 
if VERSION < 5
  i = findstr(d,'-'); i = i(1)-1;
  if i == 1
    % the date is < 10 and we need to add a leading zero
    d = ['0' d]; 
  end
  yr = str2num(d(8:9))+1900;
else
  yr = str2num(d(8:11));
end 
day = str2num(d(1:2));
mo = d(4:6);
for i = 1:12
  if strcmp(mos(i,:),mo)
    mo = i;
    break
  end
end
lmo = [31 28+isleap(yr) 31 30 31 30 31 31 30 31 30 31];
decdate = yr+(sum(lmo(1:(mo-1)))+day-1)./sum(lmo);
