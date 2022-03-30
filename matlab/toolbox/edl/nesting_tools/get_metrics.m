function  [pm,pn,dndx,dmde]=get_metrics(grdname)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%	Compute the pm and pn factors of a grid netcdf file 
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Read in the grid
%
nc=netcdf(grdname);
latu=nc{'lat_u'}(:);
lonu=nc{'lon_u'}(:);
latv=nc{'lat_v'}(:);
lonv=nc{'lon_v'}(:);
result=close(nc);
[Mp,L]=size(latu);
[M,Lp]=size(latv);
Lm=L-1;
Mm=M-1;
%
% pm and pn
%
dx=zeros(Mp,Lp);
dy=zeros(Mp,Lp);
dx(:,2:L)=spheriq_dist(lonu(:,2:L),latu(:,2:L),...
                       lonu(:,1:Lm),latu(:,1:Lm));
dx(:,1)=dx(:,2);
dx(:,Lp)=dx(:,L);
dy(2:M,:)=spheriq_dist(lonv(2:M,:),latv(2:M,:),...
                       lonv(1:Mm,:),latv(1:Mm,:));
dy(1,:)=dy(2,:);
dy(Mp,:)=dy(M,:);
pm=1./dx;
pn=1./dy;    
%
%  dndx and dmde
%
dndx(2:M,2:L)=0.5*(1./pn(2:M,3:Lp) - 1./pn(2:M,1:Lm));
dmde(2:M,2:L)=0.5*(1./pm(3:Mp,2:L) - 1./pm(1:Mm,2:L));
dndx(1,:)=0;
dndx(Mp,:)=0;
dndx(:,1)=0;
dndx(:,Lp)=0;
dmde(1,:)=0;
dmde(Mp,:)=0;
dmde(:,1)=0;
dmde(:,Lp)=0;


