
Hi Enrique, John and Hernan,

  here are some new RNT routines for matlab.

rnt_hindicesTRI.m              (help  rnt_hindicesTRI)   
	% it is the equivalent of hindices.f in roms, it retruns fraction
	% indices of a given array Xpos, Ypos relative to a grid.   
			   
rnt_griddata.m                 (help rnt_griddata)
	% it is like griddata.m but it can handle much larger problems and
	% and faster. It uses rnt_hindicesTRI.m to the triangulation.
	% with Hernan we interpolated
	% from a 386x226 grid to a 120x80   in   1.4   sec. 			   
	% from a 386x226 grid to a 1004x500 in 111.2   sec. 
	% it also returns the Ipos, Jpos indeces which can be passed as
	% inputs in the following call. At that point it is really quick.
	% it would be equivalent of saving the triangulation in matlab's griddata. 

rnt_section.m                 (help rnt_section)
	% extracts an arbitraty section along locations (X,Y). THe X,Y can be the points
	% indicating the vertices of an open  polygon. The routine will sample along
	% the polygon at the wanted resolution. Look at the examples.


EXAMPLES: 

% compile the mex file
	mex rnt_hindicesTRI_mex.f

% load example data	
	load rnt_TEST_data

%--------------------------------------------------------------------	
% TEST rnt_griddata.m
%--------------------------------------------------------------------	
% assign test data to variables
lonr = calc_grd.lonr; latr = calc_grd.latr;
% interpolate pacific grid topography to Southern California grid
tic
h = rnt_griddata( pac_grd.lonr, pac_grd.latr, pac_grd.h, lonr,latr,'cubic');
toc
figure
pcolor(lonr,latr,h); shading interp; colorbar; hold on
pcolor(pac_grd.lonr,pac_grd.latr,pac_grd.h); shading interp; colorbar; hold on
shading faceted
pcolor(lonr,latr,h);

% compare to regular griddata (just take a nap!)
tic
h = griddata( pac_grd.lonr, pac_grd.latr, pac_grd.h, lonr,latr,'cubic');
toc


%--------------------------------------------------------------------	
% TEST rnt_hindicesTRI.m
%--------------------------------------------------------------------
% assign test data to variables
lonr = calc_grd.lonr; latr = calc_grd.latr;
Xpos=calc_grd.Xpos; Ypos=calc_grd.Ypos;

figure;
pcolor(lonr,latr,lonr*nan);  hold on
% zoom on the grid
set(gca,'xlim', [-124.1178 -121.8620]);
set(gca,'ylim', [31.7844   33.6871]);
% plot the points for which you want to find the Ipos, Jpos 
plot(Xpos,Ypos,'*m');
% find the Ipos, Jpos fractional indeces
[Ipos,Jpos]=rnt_hindicesTRI(Xpos,Ypos,lonr,latr);

% use the indeces to plot the lonr, latr of the bottom left corner 
% of the grid cell were Xpos, Ypos are located
for k=1:length(Ipos)
   i=fix( Ipos(k) );
   j=fix( Jpos(k) );
   plot(lonr(i,j), latr(i,j), '*b');
end   
legend 'Xpos,Ypos' 'left-bottom corner point of grid'



%--------------------------------------------------------------------	
% TEST rnt_section.m
%--------------------------------------------------------------------

% assign test data to variables
lonr = calc_grd.lonr; latr = calc_grd.latr;
zr = calc_grd.zr; field=calc_grd.temp;
x=calc_grd.x; y=calc_grd.y;

OPT.interp = 'cubic';

[X, Z, SECT, Ipos, Jpos, xcoord, ycoord] = rnt_section(lonr,latr,zr,field,x,y,OPT);

% now plot section
figure
subplot(2,1,1)
X=X/1000; % convert in km
pcolor(X,Z,SECT); shading interp ; colorbar; hold on
xlabel('distance in km');

% fill in black the topography
x_coord=X(:,1)'; h_bottom=Z(:,1)';
x_coord = [x_coord , x_coord(end) , x_coord(1) ,               x_coord(1)];
h_bottom = [h_bottom , min(h_bottom(:))-10, min(h_bottom(:))-10, h_bottom(1) ];
fill(x_coord,h_bottom,'k')


% plot the vertices of the polygon and the actual x,y of the transect
subplot(2,1,2)
surface_field = field(:,:,end); surface_field(surface_field==0)=nan;
pcolor(lonr,latr,surface_field ); shading interp; colorbar; hold on
plot(xcoord, ycoord,'.k');
plot(x,y,'*m');





























