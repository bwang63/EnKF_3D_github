% (R)oms (N)umerical (T)oolbox
%
% FUNCTION [dataout,error,pmap]=rnt_oa3d(lonin,latin,zrin,tracer, ... 
%                                 lonout,latout,zrout,a,b,pmap);
%
% Make Objective analysis for 3D field tracer(lonin,latin,zrin) at locations
% [lonout,latout,zrout] using a horizzontal Covariance with decorr lenght scales a,b.
% The units of the a,b are the same as lon,lat. If you want only 2D please use 
% rnt_oa2d
%
% INPUT
%    lonin(i,j), latin(i,j), zrin(i,j,k), tracer(i,j,k)
%    a, b 
%    pmap (optional)
%    lonout(ii,jj) , latout(ii,jj), zrout(ii,jj,kk)
%
% OUTPUT
%    dataout(ii,jj,kk), error(ii,jj) , pmap(ii*jj, nsel)
%
% What is pmap?
%
%PMAP is used to store the position of the NSEL neiboring points for
%each location in [lon,lat]. PMAP is optional, if it is not provided
%the routine will compute the PMAP and return it in the output. Running
%the OA with PMAP can speed up the routine up to 100 times or more. So
%once you have computed PMAP in the first time you call the OA you can use 
%it for future calls in which you are objectlvely mapping from [lonr,latr]
%to [lon, lat].
%
% nsel =10 is what I use and tested. If lon and lat are in degress and
% you want a smooth interpolation use a,b = 3 degree for example.
%
% RNT - E. Di Lorenzo (edl@ucsd.edu)

  function [dataout,error,pmap]=rnt_oa3d(lonin,latin,zrin,tracer,lonout,latout,zrout,a,b,pmap);

    
   [I,J,K]=size(tracer);
   lonr=reshape(lonin,   [I*J 1]);
   latr=reshape(latin,   [I*J 1]);
   t1  =reshape(tracer, [I*J K]);
   zr =reshape(zrin, [I*J K]);

   [I,J,K]=size(zrout);
   lon=reshape(lonout, [I*J 1]);
   lat=reshape(latout, [I*J 1]);
   z =reshape(zrout, [I*J K]);

  
  [t2,error]=rnt_oa3d_v2_mex_tmp(lonr,latr,zr,t1, lon,lat,z,pmap,a,b);
  dataout=reshape(t2,[I,J,K]);
  


return

[lonin,latin]=meshgrid(1:2,1:2);
lonout=1.5;
latout=1.5;
zr=1+ sin([1:10]*pi/10);
zr=perm(repmat(zr',[1 2 2 ]));



% testing
load goa    % some data    
load GOA_map2  % pmap
temp=14*exp(zrin/400) +  1.1;
a=3;b=3;   
[dataout,error,pmap]=rnt_oa3d(lonin,latin,zrin,temp,lonout,latout,zrout,a,b,pmap);

[dataout,error,pmap]=rnt_oa2d(lonin,latin,zrin(:,:,1),lonout,latout,a,b,pmap);

ind=30;
   figure
   plot(lon(ind),lat(ind),'*b'); hold on
   i=sort(pmap(ind,:));
   plot(lonr(i),latr(i),'*r')

  
% vertical check
  plot(t2(ind,:),z(ind,:),'r')  
  hold on
  for k=1:10
  plot(t1(i(k),:),zr(i(k),:))
  end  
  plot(t2(ind,:),z(ind,:),'r')
  
 t2 =reshape(vgeo, [I*(J-1) K]);
  j=1:480;
  pcolor(repmat(lon(j),[ 1 30]) ,z(j,:),t2(j,:))  
  pcolor(repmat(lon(j),[ 1 30]) ,z(j,:),temp2(j,:))
  set(gca,'ylim',[-250 0])
  pcolor(repmat(lon(j),[ 1 30]) ,z(j,:),temp2(j,:)-t2(j,:))
shading interp
colorbar
  pcolor(repmat(lonr(j),[ 1 30]) ,zr(j,:),t1(j,:))  
  
                
