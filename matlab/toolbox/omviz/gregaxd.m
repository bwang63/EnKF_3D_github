function []=gregaxd(jd,daytic);
% GREGAXD Labels the current x-axis with Gregorian labels in units of days,
%      GREGAXD(JD,DAYTIC) draws Gregorian time labels on the x-axis in
%      intervals of DAYTIC days.

% Rich Signell

monstr=['Jan';'Feb';'Mar';'Apr';'May';'Jun';'Jul';'Aug';'Sep';...
'Oct';'Nov';'Dec'];

n=length(jd);
jd0=floor(jd(1));
jd1=ceil(jd(n));
%xlim=[jd0-.5 jd1+.5];
%set(gca,'xlim',xlim);
jdtic=[jd0:daytic:jd1]';
greg=gregorian(jdtic);
%
% find day labels
%
day=greg(:,3);
dayticlab=sprintf('%2d',day);
nday=length(day);
dayticlab=reshape(dayticlab,2,nday)';
set(gca,'xtick',jdtic,'Xticklabels',dayticlab)
%
% find month labels
%
mon=greg(:,2);
mondiff=diff(mon);
ind=[1 ; find(mondiff~=0)+1];
montic=jdtic(ind)';
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
% label months
%
for i=1:length(mon(ind));
  monticlab(i,:)=monstr(mon(ind(i)),:);
  text(montic(i),ytopm,monticlab(i,:),...
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
