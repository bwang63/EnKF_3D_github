
function [sb,eb,nb,wb]=gridbox(grd,varargin)

gridid=grd.id;
rnt_gridloadtmp
%p1=[lonr(1,1) lonr(1,end) lonr(end,end) lonr(end,1) lonr(1,1)];
%p2=[latr(1,1) latr(1,end) latr(end,end) latr(end,1) latr(1,1)];
%plot(p1,p2,varargin{:})

p1=[sq(lonr(1,:))'; sq(lonr(:,end)); sq(lonr(end,end:-1:1))' ;sq(lonr(end:-1:1,1));];
p2=[sq(latr(1,:))'; sq(latr(:,end)); sq(latr(end,end:-1:1))';sq(latr(end:-1:1,1));];
plot(p1,p2,varargin{:})

dd=0;
if dd==2
i=1; j=2;
sb=earthdist(p1(i),p2(i),p1(j),p2(j))/1000;

i=3; j=2;
eb=earthdist(p1(i),p2(i),p1(j),p2(j))/1000;
i=3; j=4;
nb=earthdist(p1(i),p2(i),p1(j),p2(j))/1000;
i=4; j=1;
wb=earthdist(p1(i),p2(i),p1(j),p2(j))/1000;
end
