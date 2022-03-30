
function [sb,eb,nb,wb]=gridbox(grd,varargin)

gridid=grd.id;
rnt_gridloadtmp
p1=[sq(lonr(1,:))'; sq(lonr(:,end)); sq(lonr(end,end:-1:1))' ;sq(lonr(end:-1:1,1));];
p2=[sq(latr(1,:))'; sq(latr(:,end)); sq(latr(end,end:-1:1))';sq(latr(end:-1:1,1));];

%p1=[lonr(1,1) lonr(1,end) lonr(end,end) lonr(end,1) lonr(1,1)];
%p2=[latr(1,1) latr(1,end) latr(end,end) latr(end,1) latr(1,1)];


[p1,p2] = m_ll2xy(p1,p2);
plot(p1,p2,'color','k','linewidth',1.2);




