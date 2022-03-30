function rnt_movie2(field,grd,timec,ax,dir,moviename)
%function rnt_movie(field,grd,timec,ax,dir,moviename)
% dir='/d2/emanuele/web/FLI';
% moviename='queen8-JAN-zeta.fli'
% timec=ctl.datenum;
% ax=[]; % for no set ax.
papersize=[0.2492 7.9846 2.52 2.64];

%xlim=[-135.3917 -129.8154];
%ylim=[ 50.9016   53.6435];

%load xlim

if isempty(ax) 
ax(1)= min(field(:));
ax(2)= max(field(:));
end


%figure
%  colordef black;
%  set(gcf,'InvertHardCopy','off');
%close

figure
p=[1.1333      3.9444      6.2222      3.1111];
set(gcf, 'paperposition',p);

eval(['cd 'dir]);


%==========================================================
%	horizontal plot
%==========================================================
[I,J,T]=size(field);

%fid = fli_begin;
fr = 0;

for it=1:T
  fr = fr + 1;
  clf
  it
  rnt_plc2(field(:,:,it),grd,2,5,0,0); caxis(ax);
  colorbar
  set(gca,'xlim',xlim);
  set(gca,'ylim',ylim);
  %set(gca,'Ylim',ylim,'Xlim',xlim);
%  colordef black;
%  set(gcf,'InvertHardCopy','off');
  
  label_courier('Lon','Lat',datestr(timec(it)),8,'Helvetica',1);
  xlabel(['lon    FRAME N. ',num2str(it)]);
%  getframe_fli(fr,fid)
%  load(grd.cstfile);
%  plot(lon,lat,'k');
  rnt_font
  eval(['print -djpeg100 ',num2str(it),'.jpg']);
  p1=['convert ',num2str(it),'.jpg .',num2str(it),'.ppm'];
  unix(p1);
  p1=['rm ',num2str(it),'.jpg'];
  unix(p1);
  
end  
%fli_end(fid,moviename);

fid=fopen('file.list','w');
c=[];
for it=1:T
c=[c,' .',num2str(it),'.ppm'];
fprintf(fid,'%10s \n',['.',num2str(it),'.ppm']);
end
fclose(fid);

p1=['ls -rta1 .*.ppm > file.list'];
unix(p1);

% frame x sec
FRAMESxSEC=4;
optS=1000/FRAMESxSEC

% size of ppm for FLI
file = textread('file.list','%s','delimiter','\n','whitespace','');
unix(['head -2 ',file{1},' | tail -1 > file.list.tmp']);
tmp=load('file.list.tmp');
!rm file.list.tmp
optG=[num2str(tmp(1)),'x',num2str(tmp(2))]

p1=['/usr/local/bin/ppm2fli -g ',optG,' -s ',num2str(optS),' -N file.list  ',moviename];
unix(p1);
%p1=['/usr/local/bin/ppm2fli -N file.list  ',moviename];
%unix(p1);

dele=input('Delete Files ? (ctrl-C to STOP)')
p1=['rm   ', c];
unix(p1)


%==========================================================
% end of routine	
%==========================================================
return

% rnt_movielist.m


function rnt_movie3(field,ax,dir,papersize,timec,moviename)

papersize=[0.2492 7.9846 2.52 2.64];
ax=[ 0   22.7868];
ax=[ 10.3 18];
ax=[0 2];
field=permute(no3,[3 2 1]);
timec=ctl.datenum;
timec=1:140
dir='/d2/emanuele/web/movie'
moviename='NO3-obc-nudge.gif'

figure
set(gcf,'PaperPosition',papersize);
eval(['cd 'dir]);

if type ==1
[I,J,T]=size(field);

for it=1:T

  clf
  rnt_plcm(field(:,:,it),grd2); caxis(ax);
  label_courier('Lon','Lat',datestr(timec(it)),5,'Helvetica',1);
  eval(['print -djpeg100 ',num2str(it),'.jpg']);
  p1=['convert ',num2str(it),'.jpg ',num2str(it),'.gif'];
  unix(p1);
  p1=['rm ',num2str(it),'.jpg'];
  unix(p1);
end  
end


if type ==12
ax1=[0 10];
field1=permute(no3,[3 2 1]);
name1='NO3 ';
ax2=[0 2.5];
field2=permute(ph3,[3 2 1]);
name2='PYTHO ';
[I,J,T]=size(field1);

for it=1:T

  clf
  subplot(2,1,1)
  rnt_plc(field1(:,:,it),1); caxis(ax1);
  label_courier('Lon','Lat',[name1,' ',datestr(timec(it))],5,'Helvetica',1);
  subplot(2,1,2)
  rnt_plc(field2(:,:,it),1); caxis(ax2);
  label_courier('Lon','Lat',[name2,' ',datestr(timec(it))],5,'Helvetica',1);

  eval(['print -djpeg100 ',num2str(it),'.jpg']);
  p1=['convert ',num2str(it),'.jpg ',num2str(it),'.gif'];
  unix(p1);
  p1=['rm ',num2str(it),'.jpg'];
  unix(p1);
end  
end


if type ==2
rnt_chgrid('calc7')
field=permute(field,[3 2 1]);
[I,K,T]=size(field);
zr=rnt_setdepth(0);
rnt_gridload
JIND=40;
x=repmat(lonr,[1 1 20]);
x=squeeze(x(:,JIND,:));
maskc=repmat(maskr,[1 1 20]);
maskc=squeeze(maskc(:,JIND,:));
zr=squeeze(zr(:,JIND,:));


for it=1:T

  clf
  pcolor(x,zr,field(:,:,it).*maskc)
  caxis([0 30]);set(gca,'Ylim',[-450 0]);shading interp
  label_courier('Depth','Lat',datestr(timec(it)),5,'Helvetica',1);
  eval(['print -djpeg100 ',num2str(it),'.jpg']);
  p1=['convert ',num2str(it),'.jpg ',num2str(it),'.gif'];
  unix(p1);
  p1=['rm ',num2str(it),'.jpg'];
  unix(p1);
end  
end

c=[];
for it=1:T
c=[c,' ',num2str(it),'.gif'];
end

p1=['whirlgif -o ',moviename,'   ', c];
unix(p1);
%p1=['rm   ', c];
%unix(p1)
