function [F3,FAC,VOL]=MATLAB_ConvolveZ(field,type,L,V,grd,Z,HZ)

str=[grd.id,'_',num2str(L),'_',type];
L=L/2;
V=V/2;
fac=3.2;


[I,J,K,T]=size(field);
X=grd.lonr; Y=grd.latr; 
%[Z,Zw,HZ]=rnt_setdepth(0,grd);
AREA=1./grd.pm./grd.pn;
mask=grd.maskr;

if type == 'u'
X=grd.lonu; Y=grd.latu; 
Z=rnt_2grid(Z,'r','u');
HZ=rnt_2grid(HZ,'r','u');
AREA=rnt_2grid(AREA,'r','u');;
mask=grd.masku;
end

if type == 'v'
X=grd.lonv; Y=grd.latv; 
Z=rnt_2grid(Z,'r','v');
HZ=rnt_2grid(HZ,'r','v');
AREA=rnt_2grid(AREA,'r','v');;
mask=grd.maskv;
end


file=['COVARIANCE_',str,'.mat'];
COV=[]; FAC=[];
if exist(file) 
load(file,'COV','FAC'); 
end


if isempty(COV)==1
  k=1;
  f2=zeros(I,J);f1=f2;
  in=find(~isnan(mask));
  z=Z(:,:,k); z=z(in);
  f1=f1(in);x=X(in); y=Y(in); 
  COV=zeros(length(in), length(in));
  disp('Computing COVARIANCE');
  for ir=1:length(f1)
     dx=abs(x(ir)-x);
     dy=abs(y(ir)-y);
     dz=abs(z(ir)-z);   
     arg=-(dx.^2)/L^2 -(dy.^2)/L^2  ;
     C=exp(arg);
     COV(:,ir)=C(:);
 %    FAC(ir)=sum(C.*VOL2D);
  end
 % FAC=FAC';
  COV=COV;
  save(file,'COV');
end

VOL=repmat(AREA,[1 1 grd.N]).*HZ;
if K==1, VOL=VOL(:,:,end); Z=Z(:,:,end); end


%==========================================================
%	% horizontal
%==========================================================

for k=1:K
f1=field(:,:,k);
f2=f1*0;
in=find(~isnan(mask));
VOL2D=VOL(:,:,k); VOL2D=VOL2D(in);
z=Z(:,:,k); z=z(in);
f1=f1(in);x=X(in); y=Y(in); 
  tmp=COV*f1;
  f2(in)=tmp;
  F2(:,:,k)=f2;
end % end K loop
ff1=F2;

%==========================================================
%	% vertical
%==========================================================
if K > 1
for k=1:K
   dz=abs(repmat(Z(:,:,k),[1 1 K])-Z(:,:,:));
   arg=-(dz.^2)/V^2 ;
   C=exp(arg);
   F3(:,:,k)=sum(ff1.*C,3);  
end
 F_TL=F3;
else
 F_TL=F2;
end

if K > 1 
for k=1:K
   dz=abs(repmat(Z(:,:,k),[1 1 K])-Z(:,:,:));
   arg=-(dz.^2)/V^2 ;
   C=exp(arg);
   F3(:,:,k)=sum(field.*C,3);
end
   ff1=F3;
else
   ff1=field;
end

%==========================================================
%	% horizontal
%==========================================================

for k=1:K
f1=ff1(:,:,k);
f2=f1*0;
in=find(~isnan(mask));
VOL2D=VOL(:,:,k); VOL2D=VOL2D(in);
z=Z(:,:,k); z=z(in);
f1=f1(in);x=X(in); y=Y(in); 
  tmp=COV*f1;
  f2(in)=tmp;
  F2(:,:,k)=f2;
end % end K loop
F_AD=F2;

F3=(F_TL+F_AD)/2;



