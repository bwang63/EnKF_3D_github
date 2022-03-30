%main program 

% John this is an example.
%==========================================================
%	Preparing the grid param
%==========================================================
 seagridCoastline='ga8_COAST.mat';
 ax = [-185 -124 45 62];   % set this to draw the grid
 CornerFile= 'BoundaryGOA.dat';  % file where you will save the corner points for seagrid
 % add new grid in the configuration of the rnt_toolbox
 %!vi ../matlib/rnt/rnt_gridinfo.m

 nameit='goa8'; % 8 km grid
 outdir='../data/';
 grdfile=[outdir,nameit,'-grid.nc'];  



 % use this routine to design grid if needed.
 FindGridCorners (ax,seagridCoastline,CornerFile);
 
 % Plot grid
 PlotGridCorners(ax,CornerFile,seagridCoastline);

 % Find the distance and needed reolution for the grid.
 TellMeCornerDist(CornerFile);


%==========================================================
%	Running Seagrid 
%==========================================================
 % execute seagrid and prepare grid using the corner file and adding the topo.
 seagrid
 % convert seagrid file to ROMS grid
 seagrid2roms('seagridGOA8.mat', grdfile);
 
 grd=rnt_gridload(nameit);
 
 % store hraw
  nc=netcdf(grdfile,'w');
  nc{'hraw'}(1,:,:)=nc{'h'}(:,:);
  close(nc);
 
%==========================================================
%	Masking
%==========================================================

  grid=LoadGrid(grdfile);
  mask=grid.maskr;
  mask(:)=1;
  % set minimum depth
  mask(grid.h < 7) =0;
  % plot the grid
  rnt_plcm(grid.h,grd);
  
  %save raw mask
  nc=netcdf(grdfile,'w');
  nc{'mask_rho'}(:)=mask';
  close(nc);
 
  % refine the mask 
  editmask(grdfile,seagridCoastline);
  
%==========================================================
%	topography
%==========================================================
  
  grid=LoadGrid(grdfile);

hmin = 7;
hraw = grid.hraw;
hraw(hraw< 7) = 7;
tmp = shapiro2(hraw,2,2);   % once filtered

for i=1:7
tmp = shapiro2(tmp,2,2);   % once filtered
end
steep = find(rvalue(tmp)>0.2);
h = tmp;
mask=grid.maskr;
mask(mask==0)=NaN;
mdepth= min(min(h.*mask));

  % store new h
  %for i=1:126
  %h(i,:)= [1:170]+20;
  %end
  %for i=1:170
  %h(:,i)=htrans;
  %end

  nc=netcdf(grdfile,'w');
  nc{'h'}(:,:)=h';
  nc{'hraw'}(2,:,:)=h';
  close(nc);

%  !cp   queen-grid.nc  queen-gridNOMask.nc
%  nc=netcdf('queen-gridNOMask.nc','w');
%  nc{'mask_rho'}(:)=1;
%  nc{'mask_v'}(:)=1;
%  nc{'mask_u'}(:)=1;
%  nc{'mask_psi'}(:)=1;
%  close(nc);
  


figure;
grd=rnt_gridload(nameit);
mdepth= min(min(grd.h.*grd.maskr));

subplot(2,2,1); rnt_plcm(grd.hraw(:,:,1),grd); title 'hraw'
subplot(2,2,2); rnt_plcm(grd.h,grd); title (['h  (min depth ',num2str(mdepth),' )'])
subplot(2,2,3); rnt_plcm(rvalue(grd.h),grd); title 'rvalue h'
subplot(2,2,4); rnt_plcm(grd.h-grd.hraw(:,:,1),grd); title 'h - hraw'
print -djpeg100 queen_topo.jpg


%Utility
  % TellMeGridPoint.m  point click on map and get coordinates.

