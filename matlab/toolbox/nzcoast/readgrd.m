% readgrd.m

lon_grd = 146:.03125:195;
lat_grd = -(25:.03125:60);

fid = fopen('bathy_nz_v4.grd');


depth = nan*ones(1121,1569);

for m = 1:1121
   if rem(m,100)==0; m,end
   for n = 1:10:1569
      a = fgetl(fid);
      s = sscanf(a,'%f');
      nl = length(s);
      depth(m,n:n+nl-1)= s';
   end
end

fclose(fid)

