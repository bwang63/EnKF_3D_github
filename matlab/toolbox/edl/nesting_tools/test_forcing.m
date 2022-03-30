function test_forcing(child_frc,thefield,thetime,skip)

i=0;
for time=thetime
  i=i+1;
  
  subplot(2,length(thetime),i)


  nc=netcdf(child_frc);
  parent_frc=nc.parent_file(:);
  child_grd=nc.grd_file(:);
  u=nc{'sustr'}(time,:,:);
  v=nc{'svstr'}(time,:,:);
  fieldc=nc{thefield}(time,:,:);
  fieldname=nc{thefield}.long_name(:);
  result=close(nc);

  nc=netcdf(child_grd);
  parent_grd=nc.parent_grid(:);
  refinecoeff=nc{'refine_coef'}(:);
  lonc=nc{'lon_rho'}(:);
  latc=nc{'lat_rho'}(:);
  mask=nc{'mask_rho'}(:);
  angle=nc{'angle'}(:);
  result=close(nc);
  warning off
  mask=mask./mask;
  warning on
  [ured,vred,lonred,latred,speed]=uv_vec2rho(u,v,lonc,latc,angle,skip*refinecoeff);
  pcolor(lonc,latc,mask.*fieldc)
  shading interp
  axis image
  caxis([min(min(fieldc)) max(max(fieldc))])
  colorbar
  hold on
  quiver(lonred,latred,ured,vred,'k')
  hold off
  axis([min(min(lonc)) max(max(lonc)) min(min(latc)) max(max(latc))])

  subplot(2,length(thetime),i+length(thetime))

  nc=netcdf(parent_frc);
  u=nc{'sustr'}(time,:,:);
  v=nc{'svstr'}(time,:,:);
  field=nc{thefield}(time,:,:);
  fieldname=nc{thefield}.long_name(:);
  result=close(nc);
  nc=netcdf(parent_grd);disp(parent_grd)
  lon=nc{'lon_rho'}(:);
  lat=nc{'lat_rho'}(:);
  mask=nc{'mask_rho'}(:);
  angle=nc{'angle'}(:);
  result=close(nc);
  warning off
  mask=mask./mask;
  warning on
  [ured,vred,lonred,latred,speed]=uv_vec2rho(u,v,lon,lat,angle,skip);
  pcolor(lon,lat,mask.*field)
  shading interp
  axis image
  caxis([min(min(fieldc)) max(max(fieldc))])
  colorbar
  hold on
  quiver(lonred,latred,ured,vred,'k')
  hold off
  axis([min(min(lonc)) max(max(lonc)) min(min(latc)) max(max(latc))])
end


