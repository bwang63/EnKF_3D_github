
load rnt_hindices_TestData

mex rnt_hindices_mex.f
[Ipos,Jpos]=rnt_hindices_mex(Xpos,Ypos,lonr,latr,angler);


return

pcolor(lonr,latr,lonr*nan);
hold on
plot(Xpos,Ypos,'r*');

for k=1:length(Ipos)
  i=fix(Ipos(k));
  j=fix(Jpos(k));
  plot(lonr(i,j),latr(i,j),'*b');
end

Xpos=Xpos(1);
Ypos=Ypos(1);

% rnt_hindices_mex.f
