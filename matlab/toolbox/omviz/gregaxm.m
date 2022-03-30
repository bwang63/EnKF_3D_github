function []=gregaxm(jd,montic);
% GREGAXM Labels the current x-axis with Gregorian labels in units of months,
%      GREGAXM(JD,MONTIC) draws Gregorian time labels on the x-axis in
%      intervals of MONTIC months. 

monstr1=['Jan';'Feb';'Mar';'Apr';'May';'Jun';'Jul';'Aug';'Sep';...
'Oct';'Nov';'Dec'];

monstr2=['J';'F';'M';'A';'M';'J';'J';'A';'S';'O';'N';'D'];
%
n=length(jd);
start=gregorian(jd(1));
stop=gregorian(jd(n));
start=[start(1:2) 0 0 0 0];
stop=[stop(1) stop(2)+1 0 0 0 0];
jd0=julian(start);
jd1=julian(stop);
ylim=get(gca,'ylim');  
%xlim=[jd0-15 jd1+15];
%set(gca,'xlim',xlim);  
set(gca,'units','pixels'); 
pos=get(gca,'pos');
ymin=pos(2);            % y position of x axis in pixels
fontsize=get(gca,'fontsize');    %fontsize = height in pixels?
set(gca,'units','normalized');
xlim=get(gca,'xlim');  
xfac=(xlim(2)-xlim(1))/pos(3);   %ratio of x user units to pixel units
yfac=(ylim(2)-ylim(1))/pos(4);   %ratio of y user units to pixel units
%
date_diff=stop-start;
nmon=date_diff(1)*12+date_diff(2);
start_mon=start(2);
start_year=start(1);
mon=start_mon+[0:montic:nmon];
year=start_year+floor((mon-0.5)/12);
mon=rem(mon,12);
mon=mon+(mon==0)*12;
n=length(mon);

greg=[year(:) mon(:) ones(n,1) zeros(n,3)];
jdtic=julian(greg);

%
% find month labels
%
gap_width_pixels=(jdtic(2)-jdtic(1))/xfac
if(gap_width_pixels > 3*fontsize),
   monstr=monstr1;
else
   monstr=monstr2;
end
monticlab=monstr(mon,:);
set(gca,'xtick',jdtic,'Xticklabels',monticlab)
%
% find year labels
%
yeardiff=diff(year)';
year_ind=[1 ; find(yeardiff~=0)+1];
yeartic=jdtic(year_ind)';

% determine y location of month and year labels by determining
% the font height for the day labels, separating the lines
% by linesep pixels 
%
linesep=8;
%
ytop=ymin-(fontsize+linesep);    %y location of top of year labels in pixels
ytopy=ylim(1)-(ymin-ytop)*yfac; % " ", but in user units
%
% label years
%
for i=1:length(year(year_ind));
  yearticlab(i,:)=int2str(year(year_ind(i)));
  text(yeartic(i),ytopy,yearticlab(i,:),...
     'HorizontalAlignment','center',...
     'VerticalAlignment','top','fontsize',fontsize);
end
