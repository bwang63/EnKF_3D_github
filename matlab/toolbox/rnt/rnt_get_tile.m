function [I,J]= rnt_get_tile(tile,Lm,Mm,NSUB_X,NSUB_E)

      dx=ceil(Lm/NSUB_X);
	dy=ceil(Mm/NSUB_E);
	
	itile=0;
	for i=1:NSUB_X
	for j=1:NSUB_E
	   itile=itile+1;
	   Istr=1 +dx*(i-1);
	   Iend=1 +dx*i-1;	   
         Jstr=1 +dy*(j-1);
	   Jend=1 +dy*j-1;
	   
	   if itile == tile
	if Iend > Lm
	    Iend=Lm;
	end
	if Jend > Mm
	    Jend=Mm;
	end
      	J=Jstr:Jend;
	      I=Istr:Iend;	
	   end	   
	end
	end
	


return

load matlab
tempgr(:,:,end+1)= tempgr(:,:,end);
z(end+1) = 7000;
maskr=grd.masku;
maskr(:)=0;
%rnt_plc(grd.h,grd,0,7,0,0);
 for tile=1:7*5
[I,J]= rnt_get_tile(tile,grd.Lp,grd.Mp,10,10);
tile
maskr(I,J)=maskr(I,J)+999;
%plot(grd.lonr(I,J), grd.latr(I,J),'.b');
%pause
tmp=rnt_2s(tempgr(I,J,:),z_r(I,J,:),z);
f(I,J,:)=tmp;
end

%/sdb/edl/ROMS-pak/matlib/rnt/rnt_2s.m

