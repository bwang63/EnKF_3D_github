function status=allsta(psname,gname,sname,vname,nsta,month);

status=0;

%  Plot station map.

[x,y]=staloc(sname,gname);
grid;

print -dps psname

%  Plot all stations.

for i=1:nsta,
  [T,f]=station(sname,vname,i,month);
  print -dps -append psname;
end,

status=1;

