function []=gregaxh(jd,hourtic);
% GREGAXH Labels the current x-axis with Gregorian labels in units of hours,
%      GREGAXH(JD,HOURTIC) draws Gregorian time labels on the x-axis in
%      intervals of HOURTIC hours. 
monstr=['Jan';'Feb';'Mar';'Apr';'May';'Jun';'Jul';'Aug';'Sep';...
'Oct';'Nov';'Dec'];

n=length(jd);
[start]=gregorian(jd(1));
[stop]=gregorian(jd(n));
start=[start(1:4) 0 0];
stop=[stop(1:3) stop(4)+1 0 0];
jd0=julian(start);
jd1=julian(stop);
jdtic=[jd0:hourtic/24:jd1]';
greg=gregorian(jdtic);
%xlim=[jd0-1/48 jd1+1/48];
%set(gca,'xlim',xlim);
%
% find hour labels
%
hour=greg(:,4);
min=greg(:,5);
hourticlab=sprintf('%2.2d:%2.2d',[hour min]');
nhour=length(hour);
hourticlab=reshape(hourticlab,5,nhour)';
set(gca,'xtick',jdtic,'Xticklabels',hourticlab)
%
% find month and day labels
%
mon=greg(:,2);
day=greg(:,3);
daydiff=diff(day);
ind=[1 ; find(daydiff~=0)+1];
daytic=jdtic(ind)';
%
% find year labels
%
year=greg(:,1);
yeardiff=diff(year);
year_ind=[1 ; find(yeardiff~=0)+1];
yeartic=jdtic(year_ind)';

% determine y location of month and year labels by determining
% the font height for the day labels, separating the lines
% by linesep pixels 
%
linesep=8;
ylim=get(gca,'ylim');   %y position of x axis in user units
set(gca,'units','pixels'); 
pos=get(gca,'pos');
ymin=pos(2);            % y position of x axis in pixels
fontsize=get(gca,'fontsize');    %fontsize = height in pixels?
set(gca,'units','normalized');
ytop=ymin-(fontsize+linesep);    %y location of top of month labels in pixels
ytopm=ylim(1)-(ymin-ytop)*(ylim(2)-ylim(1))/pos(4); % " ", but in user units
ytopy=ytopm-(fontsize+linesep)*(ylim(2)-ylim(1))/pos(4);
%
% label day and month
%
for i=1:length(mon(ind));
  monticlab(i,:)=monstr(mon(ind(i)),:);
  text(daytic(i),ytopm,...
    [monticlab(i,:) ' ' int2str(day(ind(i)))],...
    'HorizontalAlignment','center',...
    'VerticalAlignment','top','fontsize',fontsize);
end
%
% label years
%
for i=1:length(year(year_ind));
  yearticlab(i,:)=int2str(year(year_ind(i)));
  text(yeartic(i),ytopy,yearticlab(i,:),...
     'HorizontalAlignment','center',...
     'VerticalAlignment','top','fontsize',fontsize);
end
