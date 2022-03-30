function h = smoothgrid(h,hmin,rmax)
%
%  Smooth the topography to get a maximum r factor = rmax
%
disp(' ')
disp(' Smooth the topography...')
disp(' ')
h(h<hmin)=hmin;
h=rotfilter(h,rmax);
%disp(['hmin = ',num2str(min(min(h)))])
%
%  Smooth the topography again
%
disp(' ')
disp(' Smooth the topography a bit more...')
n=4;
for i=1:n
  h=hanning(h);
end
disp(' ')
disp(['  hmin = ',num2str(min(min(h)))])
return
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function h=rotfilter(h,rmax)
[M,L]=size(h);
Mm=M-1;
Mmm=M-2;
Lm=L-1;
Lmm=L-2;
cff=0.8;
nu=3/16;
[rx,ry]=rfact(h);
r=max(max(max(rx)),max(max(ry)));
h=log(h);
i=0;
while r>rmax
  i=i+1;
  cx = (rx>cff*rmax);
  cx=hanning(cx);
  cy=(ry>cff*rmax);
  cy=hanning(cy);
  fx=cx.*FX(h);
  fy=cy.*FY(h);
  h(2:Mm,2:Lm)=h(2:Mm,2:Lm)+nu*...
             ((fx(2:Mm,2:Lm)-fx(2:Mm,1:Lmm))+...
              (fy(2:Mm,2:Lm)-fy(1:Mmm,2:Lm)));
  h(1,:)=h(2,:);
  h(M,:)=h(Mm,:);
  h(:,1)=h(:,2);
  h(:,L)=h(:,Lm);
  [rx,ry]=rfact(exp(h));
  r=max(max(max(rx)),max(max(ry)));
end
disp(['  ',num2str(i),' iterations - rmax = ',num2str(r)]) 
h=exp(h);
return
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [rx,ry]=rfact(h);
[M,L]=size(h);
Mm=M-1;
Mmm=M-2;
Lm=L-1;
Lmm=L-2;
rx=abs(h(1:M,2:L)-h(1:M,1:Lm))./(h(1:M,2:L)+h(1:M,1:Lm));
ry=abs(h(2:M,1:L)-h(1:Mm,1:L))./(h(2:M,1:L)+h(1:Mm,1:L));
return
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function h=hanning(h);
[M,L]=size(h);
Mm=M-1;
Mmm=M-2;
Lm=L-1;
Lmm=L-2;

h(2:Mm,2:Lm)=0.125*(h(1:Mmm,2:Lm)+h(3:M,2:Lm)+...
                       h(2:Mm,1:Lmm)+h(2:Mm,3:L)+...
                       4*h(2:Mm,2:Lm));
h(1,:)=h(2,:);
h(M,:)=h(Mm,:);
h(:,1)=h(:,2);
h(:,L)=h(:,Lm);
return
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function fx=FX(h);
[M,L]=size(h);
Mm=M-1;
Mmm=M-2;
Lm=L-1;
Lmm=L-2;

fx(2:Mm,:)=(h(2:Mm,2:L)-h(2:Mm,1:Lm))*5/12 +...
   (h(1:Mmm,2:L)-h(1:Mmm,1:Lm)+h(3:M,2:L)-h(3:M,1:Lm))/12;
fx(1,:)=fx(2,:);
fx(M,:)=fx(Mm,:);
return
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function fy=FY(h);
[M,L]=size(h);
Mm=M-1;
Mmm=M-2;
Lm=L-1;
Lmm=L-2;

fy(:,2:Lm)=(h(2:M,2:Lm)-h(1:Mm,2:Lm))*5/12 +...
           (h(2:M,1:Lmm)-h(1:Mm,1:Lmm)+h(2:M,3:L)-h(1:Mm,3:L))/12;
fy(:,1)=fy(:,2);
fy(:,L)=fy(:,Lm);
return

