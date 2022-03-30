function [eofs,eofs_coeff,varexp]=doEof(X,Y,maskX,maskY)

x=ConvertXYT_into_ZT(X,maskX);
y=ConvertXYT_into_ZT(Y,maskY);

Ctt=x'*x;
[PCx,S]=eig(Ctt);
VEXP=diag(S)/sum(diag(S))*100;
EOFx=ConvertZT_into_XYT(x*PCx,maskX);
EOFy=ConvertZT_into_XYT(y*PCx,maskY);

Ctt=y'*y;
[PCy,S]=eig(Ctt);
VEXP=diag(S)/sum(diag(S))*100;
EOFx=ConvertZT_into_XYT(x*PCy,maskX);
EOFy=ConvertZT_into_XYT(y*PCy,maskY);

subplot(2,2,1)
pcolor(-EOFy(:,:,end)'); shading flat; colorbar
subplot(2,2,2)
pcolor(-EOFy(:,:,end-1)'); shading flat; colorbar
subplot(2,2,3)
pcolor(-EOFx(:,:,end)'); shading flat; colorbar
subplot(2,2,4)
pcolor(-EOFx(:,:,end-1)'); shading flat; colorbar

% U(location, kmode)
% V(location, kmode)

Cxy=y*x';
[U,S,V]=svd(Cxy,0);
% U(location, kmode)
% V(location, kmode)
PCx=U'*x;
PCy=V'*x;
VEXP=diag(S)/sum(diag(S))*100;

EOFx=ConvertZT_into_XYT(U,maskX);
EOFy=ConvertZT_into_XYT(V,maskY);


% /drive/edl/matlib-master/misc/ConvertXYT_into_ZT.m
% /drive/edl/matlib-master/misc/ConvertZT_into_XYT.m
