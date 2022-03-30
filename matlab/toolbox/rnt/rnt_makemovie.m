
function rnt_makemovie(frameRange,FRAMESxSEC,moviename,varargin)
%function rnt_makemovie(frameRange,FRAMESxSEC,varargin)
%  frameRange=1:FrameNum   or frameRange=10:20
% FRAMESxSEC how many frames per sec


% make a file with all the files
fid=fopen('file.list','w');
c=[];
for it=frameRange
c=[c,' .',num2str(it),'.ppm'];
fprintf(fid,'%10s \n',['.',num2str(it),'.ppm']);
end
fclose(fid);

p1=['ls -rta1 .*.ppm > file.list'];
unix(p1);

% frame x sec
%FRAMESxSEC=2;
optS=1000/FRAMESxSEC

% size of ppm for FLI
file = textread('file.list','%s','delimiter','\n','whitespace','');
unix(['head -2 ',file{1},' | tail -1 > file.list.tmp']);
tmp=load('file.list.tmp');
!rm file.list.tmp
optG=[num2str(tmp(1)),'x',num2str(tmp(2))]

%p1=['/usr/local/bin/ppm2fli -g ',optG,' -s ',num2str(optS),' -N file.list  ',moviename];
p1=['/sdb/local/bin/ppm2fli -g ',optG,' -s ',num2str(optS),' -N file.list  ',moviename];
unix(p1);
%p1=['/usr/local/bin/ppm2fli -N file.list  ',moviename];
%unix(p1);

dele=input('Delete Files ? (ctrl-C to STOP)')
p1=['rm   ', c];
unix(p1)
