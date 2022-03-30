name1='/d15/kate/ncfiles/damee_diag_14a';
name2='/d15/kate/ncfiles/damee_diag_14b';
name3='/d15/kate/ncfiles/damee_diag_14c';

n=0;
for i=1:70,
  n=n+1;
  for k=1:20,
    Tsur=getcdf_batch(name1,'temp',[i k -1 -1],[i k -1 -1],[1 1 1 1],2,1,0);
    Tavg(n,k)=sum(sum(rmask.*Tsur./(pm.*pn)))/area;
  end,
end,

for i=1:25,
  n=n+1;
  for k=1:20,
    Tsur=getcdf_batch(name2,'temp',[i k -1 -1],[i k -1 -1],[1 1 1 1],2,1,0);
    Tavg(n,k)=sum(sum(rmask.*Tsur./(pm.*pn)))/area;
  end,
end,

for i=1:25,
  n=n+1;
  for k=1:20,
    Tsur=getcdf_batch(name3,'temp',[i k -1 -1],[i k -1 -1],[1 1 1 1],2,1,0);
    Tavg(n,k)=sum(sum(rmask.*Tsur./(pm.*pn)))/area;
  end,
end,

Tsave=Tavg;

Tavg(48,:)=0.5*Tavg(48,:);
Tavg(73,:)=0.5*Tavg(73,:);
Tavg(84,:)=0.5*Tavg(84,:);
Tavg(93,:)=Tavg(93,:)+Tavg(94,:);
Tavg(107,:)=0.5*Tavg(107,:);
Tavg(118,:)=0.5*Tavg(118,:);

%Tavg(94,:)=[];
%Tavg(71,:)=[];
%Tavg(71,:)=[];
