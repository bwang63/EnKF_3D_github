
function files = rnt_getfilenames(direc,prefix,varargin)
% function files = rnt_getfilenames(direc,prefix)
% prefix = 'his' or 'roms_his'
% direc = '.'
% files = rnt_getfilenames( '.','his');
cdir=pwd;

eval (['cd ',direc]);

[s,s1]=unix(['ls -1rt ',direc,'/*',prefix,'* > /tmp/.tmp-rnt_getfilenames']);

if nargin > 2  & nargin < 3
  cmd=varargin{1};
[s,s1]=unix([cmd,' ',direc,'/*',prefix,'* > /tmp/.tmp-rnt_getfilenames']);
end

if nargin >= 3
  cmd=varargin{1};
  [s,s1]=unix([cmd,'  > /tmp/.tmp-rnt_getfilenames']);
end


file = textread('/tmp/.tmp-rnt_getfilenames','%s','delimiter','\n','whitespace','');

for i=1:length(file)
   files{i} = [direc,'/',file{i}];
end

files=file;

unix('rm /tmp/.tmp-rnt_getfilenames');

%disp(['ctl=rnt_timectl(files,''ocean_time'');'])

eval (['cd ',cdir]);
