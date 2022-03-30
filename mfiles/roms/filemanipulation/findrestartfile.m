function [restartfile, fileentry, oceantime, timediff,oceantime_unit] = findrestartfile(filedir, fileregex, searchdate, fileentryzeroifsingleentry)
% [restartfile, fileentry, oceantime, timediff] = findrestartfile(filedir, fileregex, searchdate)
% searhes a number of ROMS restart files (or history or average files) for
% an entry that is closest to the specified date.
% 
% INPUT:
% filedir: the directory containing the restart files.
% fileregex: a regular expression matching the filenames in the directory
%     that are searched.
% searchdate: the date that is searched for.
% 
% OUTPUT:
% restartfile: the name of the restart file that has the entry that is
%     closest to searchdate.
% fileentry: The time index of the entry in restartfile.
% oceantime: the ocean_time of the entry that is closest to searchdate.
% timediff: time difference (in days, always positive) between searchdate
%     and the closest date that was found.
%

if nargin < 4
    fileentryzeroifsingleentry = false;
end

ctl = roms_timectl(filedir, fileregex);
[val, ind] = min(abs(ctl.dnum-searchdate));

if val > 10
    warning('findrestartfile:NoCloseDate', 'The closest entry is more than %d days away from %s.', floor(val), datestr(searchdate));
end

restartfile = ctl.files{ctl.file_index(ind)};
if fileentryzeroifsingleentry && numel(ctl.dnum) == 1
    fileentry = 0;
else
    fileentry = ctl.in_file_index(ind)+1;
end
oceantime = ctl.time(ind);
timediff = ctl.dnum(ind)-searchdate;

% LY: add the following line to record ocean_time unit
oceantime_unit = nc_attget(ctl.files{ctl.file_index(ind)},'ocean_time','units');



