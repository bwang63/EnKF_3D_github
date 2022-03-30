
function files = rnt_getfilenames(direc,prefix)
% function files = rnt_getfilenames(direc,prefix)
% prefix = 'his' or 'roms_his'
% direc = './'
% files = rnt_getfilenames( './','his');
eval (['cd ',direc]);

[s,s1]=unix(['ls -1rt *',prefix,'*']);


iend=findstr(s1,s1(end)) ;
istr=1:iend(1):iend(end);
istr=[1 ; iend(:)+1];

for i=1:length(iend)
   files{i} = [direc,'/',s1(istr(i):iend(i)-1)];
end

disp(['ctl=rnt_timectl(files,''ocean_time'');'])

