% test data
load rnt_griddata_TestData
%[lon,lat]=meshgrid(xlim(1):0.02:xlim(end), ylim(1):0.02:ylim(end) );
Xgrd=lonr;
Ygrd=latr;
Angler=angler;
Ypos=lat;
Xpos=lon;

[F,I,J]=rnt_griddata(lonr,latr,temp,lon,lat,'cubic');

[Ipos,Jpos]=rnt_hindicesTRI(Xpos,Ypos,Xgrd,Ygrd);

[X, Z, SECT, Ipos, Jpos] = rnt_section(lonr,latr,zr,field,x,y,OPT);

../rnt_section.m 

grd=rnt_gridload('sccoos');
grd2=rnt_gridload('sccoos2');
lon=grd2.lonr;
lat=grd2.latr;

tic; [F]=rnt_griddata(lonr,latr,angler,temp,lon,lat,'cubic'); toc
tic; [F2]=griddata(lonr,latr,temp,lon,lat,'cubic');toc


lonp=rnt_2grid(grd.lonr,'r','p');
latp=rnt_2grid(grd.latr,'r','p');


[Ipos,Jpos]=rnt_hindices(lonp(:),latp(:),lonr,latr,angler);

[Ipos,Jpos]=rnt_hindices2(lonp(:),latp(:),lonr,latr,angler);

tic; [F]=rnt_griddata(lonr,latr,angler,lonr,lonp,latp,'linear'); toc










