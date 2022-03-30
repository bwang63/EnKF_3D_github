
function [files, fileshis] = rnt_getfilenames_c(direc,range)
% function files = rnt_getfilenames(direc,prefix)
% prefix = 'his' or 'roms_his'
% direc = './'
% files = rnt_getfilenames( './','his');



for i=1:length(range)
   files{i} = [direc,'/roms_avg_Y',num2str(range(i)),'.nc'];
   fileshis{i} = [direc,'/roms_his_Y',num2str(range(i)),'.nc'];

end

disp(['ctl=rnt_timectl(files,''ocean_time'');'])

