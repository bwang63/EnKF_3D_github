function test_clim(climname,tracer,l)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Test the climatology and initial files.
% pierrick 1/2000
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global IPRINT;
IPRINT=0;

temp=nc_read(climname,tracer,l);
nc = netcdf(climname, 'nowrite');
grd_file = nc.grd_file(:);
result = close(nc);
lat=nc_read(grd_file,'lat_rho');
lon=nc_read(grd_file,'lon_rho');
pm=nc_read(grd_file,'pm');
h=nc_read(grd_file,'h');
mask=nc_read(grd_file,'mask_rho');
mask=mask./mask;
theta_s=nc_read(climname,'theta_s');
theta_b=nc_read(climname,'theta_b');
Tcline=nc_read(climname,'Tcline');
dim_temp=size(temp);
N=dim_temp(3);
kgrid=0;
column=0;
index=1;
plt=0; 
[imax jmax]=size(pm);
jstep=round((jmax/3)-1);
image=0;
for j=1:jstep:jmax
  index=j;
  [z,sc,Cs]=scoord2(grd_file,theta_s,theta_b,Tcline,N,kgrid,column, ...
                           index,plt);
  image=image+1;
  subplot(2,2,image)
  field=squeeze(temp(:,j,:));
  topo=squeeze(h(:,j));
  mask_vert=squeeze(mask(:,j));
  dx=1./squeeze(pm(:,j));
  xrad(1)=0;
  for i=2:dim_temp(1)
    xrad(i)=xrad(i-1)+0.5*(dx(i)+dx(i-1));
  end
  x=zeros(dim_temp(1),N);
  masksection=zeros(dim_temp(1),N);
  for i=1:dim_temp(1)
    for k=1:N
      x(i,k)=xrad(i);
      masksection(i,k)=mask_vert(i);
    end
  end
  xrad=xrad/1000;
  x=x/1000;
  field=masksection.*field;
  pcolor(x,z,field) 
  colorbar
  shading interp
  hold on
  plot(xrad,-topo,'k')
  hold off
  title(num2str(j))
end











