%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  help tune the position of the nested grid in the parent grid
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all
close all
parent_grd='grid-sb.nc';
%
%
%
finish=0;
imin=1;
imax=2;
jmin=1;
jmax=2;
refinecoeff=3;
%
while finish==0
disp(' ')
value=input([' refinement coefficient ? ',...
'(default = ',num2str(refinecoeff),') ']);
if ~isempty(value)
  refinecoeff=value;
end
value=input([' imin ? ',...
'(default = ',num2str(imin),') ']);
if ~isempty(value)
  imin=value;
end
value=input([' imax ? ',...
'(default = ',num2str(imax),') ']);
if ~isempty(value)
  imax=value;
end
value=input([' jmin ? ',...
'(default = ',num2str(jmin),') ']);
if ~isempty(value)
  jmin=value;
end
value=input([' jmax ? ',...
'(default = ',num2str(jmax),') ']);
if ~isempty(value)
  jmax=value;
end
%
% Read in the parent grid
%
nc=netcdf(parent_grd);
latp_parent=nc{'lat_psi'}(:);
lonp_parent=nc{'lon_psi'}(:);
latr_parent=nc{'lat_rho'}(:);
lonr_parent=nc{'lon_rho'}(:);
maskr_parent=nc{'mask_rho'}(:);
h_parent=nc{'h'}(:);
result=close(nc);
%
% Parent indices
%
[Mp,Lp]=size(h_parent);
[igrd_r,jgrd_r]=meshgrid((1:1:Lp),(1:1:Mp));
[igrd_p,jgrd_p]=meshgrid((1:1:Lp-1),(1:1:Mp-1));
%
% Test if correct 
%
if imin>=imax
  error(['imin >= imax - imin = ',...
         num2str(imin),' - imax = ',num2str(imax)])
end
if jmin>=jmax
  error(['jmin >= jmax - jmin = ',...
         num2str(jmin),' - jmax = ',num2str(jmax)])
end
if jmax>(Mp-1)
  error(['jmax > M - M = ',...
         num2str(Mp-1),' - jmax = ',num2str(jmax)])
end
if imax>(Lp-1)
  error(['imax > L - L = ',...
         num2str(Lp-1),' - imax = ',num2str(imax)])
end
%
% the children indices
%
ipchild=(imin:1/refinecoeff:imax);
jpchild=(jmin:1/refinecoeff:jmax);
irchild=(imin+0.5-0.5/refinecoeff:1/refinecoeff:imax+0.5+0.5/refinecoeff);
jrchild=(jmin+0.5-0.5/refinecoeff:1/refinecoeff:jmax+0.5+0.5/refinecoeff);
[ichildgrd_p,jchildgrd_p]=meshgrid(ipchild,jpchild);
[ichildgrd_r,jchildgrd_r]=meshgrid(irchild,jrchild);
%
% interpolations
%
lonpchild=interp2(igrd_p,jgrd_p,lonp_parent,ichildgrd_p,jchildgrd_p,'cubic');
latpchild=interp2(igrd_p,jgrd_p,latp_parent,ichildgrd_p,jchildgrd_p,'cubic');
lonrchild=interp2(igrd_r,jgrd_r,lonr_parent,ichildgrd_r,jchildgrd_r,'cubic');
latrchild=interp2(igrd_r,jgrd_r,latr_parent,ichildgrd_r,jchildgrd_r,'cubic');
[Mchild,Lchild]=size(latpchild);
disp(' ')
disp(['  Size of the grid:  L = ',...
      num2str(Lchild),' - M = ',num2str(Mchild)])
%
% make a plot
%
disp([' imin = ',num2str(imin),' imax = ',...
num2str(imax),' jmin = ',...
num2str(jmin),' jmax = ',...
num2str(jmax),' ; refinement coefficient : ',num2str(refinecoeff)])

warning off
themask=maskr_parent./maskr_parent;
warning on
pcolor(lonr_parent,latr_parent,h_parent.*themask)
axis image 
colorbar
shading flat
hold on
lonbox=cat(1,lonp_parent(jmin:jmax,imin),  ...
                lonp_parent(jmax,imin:imax)' ,...
                lonp_parent(jmax:-1:jmin,imax),...
                lonp_parent(jmin,imax:-1:imin)' );
latbox=cat(1,latp_parent(jmin:jmax,imin),  ...
                latp_parent(jmax,imin:imax)' ,...
                latp_parent(jmax:-1:jmin,imax),...
                latp_parent(jmin,imax:-1:imin)' );
plot(lonbox,latbox,'k')
loncbox=cat(1,lonpchild(1:Mchild,1),  ...
                lonpchild(Mchild,1:Lchild)' ,...
                lonpchild(Mchild:-1:1,Lchild),...
                lonpchild(1,Lchild:-1:1)' );
latcbox=cat(1,latpchild(1:Mchild,1),  ...
               latpchild(Mchild,1:Lchild)' ,...
                latpchild(Mchild:-1:1,Lchild),...
                latpchild(1,Lchild:-1:1)' );
plot(loncbox,latcbox,'w--')
hold off
response=input('zoom (y/n)? ','s');
if response == 'y'
  axis([min(min(lonrchild)) max(max(lonrchild))...
        min(min(latrchild)) max(max(latrchild))])
end
response=input('stop (y/n)? ','s');
if response == 'y'
  finish=1;
end
end
disp([' imin = ',num2str(imin),' imax = ',...
num2str(imax),' jmin = ',...
num2str(jmin),' jmax = ',...
num2str(jmax),' ; refinement coefficient : ',num2str(refinecoeff)])
