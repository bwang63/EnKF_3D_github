
function [sb,eb,nb,wb]=gridbox(grd,varargin)

gridid=grd.id;
rnt_gridloadtmp
p1=[lonr(1,1) lonr(1,end) lonr(end,end) lonr(end,1) lonr(1,1)];
p2=[latr(1,1) latr(1,end) latr(end,end) latr(end,1) latr(1,1)];
plot(p1,p2,varargin{:})

i=1; j=2;
sb=earthdist(p1(i),p2(i),p1(j),p2(j))/1000;

i=3; j=2;
eb=earthdist(p1(i),p2(i),p1(j),p2(j))/1000;
i=3; j=4;
nb=earthdist(p1(i),p2(i),p1(j),p2(j))/1000;
i=4; j=1;
wb=earthdist(p1(i),p2(i),p1(j),p2(j))/1000;

