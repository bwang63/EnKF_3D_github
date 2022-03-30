function [hchild,alpha]=connect_topo(hchild,hparent,nband)
%
%  connect "smoothly" the child topography to the parent one
%  watch out the four_boundaries switch
%
[Mp,Lp]=size(hchild);
alpha=0*hchild+nband;
four_boundaries=1;
if (four_boundaries==1)
  disp(' ')
  disp('Connect the topography on the four boundaries')
  for i=1:nband+1
    alpha(i,i:Lp-i+1)=i-1;
    alpha(Mp-i+1,i:Lp-i+1)=i-1;
    alpha(i:Mp-i+1,i)=i-1;
    alpha(i:Mp-i+1,Lp-i+1)=i-1;
  end
elseif (four_boundaries==2)
  disp(' ')
  disp('  Connect the topography only to 3 boundaries')
  disp('         (not connected at the east)...')
  for i=1:nband+1
    alpha(i,i:Lp)=i-1;
    alpha(Mp-i+1,i:Lp)=i-1;
    alpha(i:Mp-i+1,i)=i-1;
  end
elseif (four_boundaries==3)
  disp(' ')
  disp('  Connect the topography only to 2 boundaries')
  disp('         (not connected at the east and at the north)...')
  for i=1:nband+1
    alpha(i,i:Lp)=i-1;
    alpha(i:Mp,i)=i-1;
  end
end
alpha=0.5*(cos(pi*alpha/nband)+1); 
hchild=alpha.*hparent+(1-alpha).*hchild;
return
