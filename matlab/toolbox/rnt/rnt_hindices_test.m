
load rnt_hindices_test

clf
subplot(1,2,1)
pcolor(grd.lonr,grd.latr,grd.h.*grd.maskr); shading faceted
hold on;

% now plot the lon, lat for which the I,J indexes need to be found
disp('Plotting lon,lat to be found'); 
plot(lon,lat,'*b');
input('(Return to conitnue)');



% now find indices
% help rnt_hindicesTRI  (for more info)
disp('Finding I,J of the grid associated with lon,lat'); 
[Ipos,Jpos]=rnt_hindicesTRI(lon(:),lat(:),grd.lonr,grd.latr);


disp('Plotting the left lower corner associated with each point'); 
for ind=1:length(Ipos)
	i=floor( Ipos(ind) );
	j=floor( Jpos(ind) );
	plot( grd.lonr(i,j) ,grd.latr(i,j) ,'.g');
end
input('(Return to conitnue)');


subplot(1,2,2)
disp('Now plot the location in I,J space');
pcolor((grd.h.*grd.maskr)'); shading faceted; hold on
plot(Ipos,Jpos,'*b')
plot( floor(Ipos) ,floor(Jpos),'.g')


grd.h(20:30,20:30)=nan;
pcolor((grd.h.*grd.maskr)'); shading faceted; hold on

h=rnt_fill(grd.lonr,grd.latr,grd.h,4,4);


