% This Matlab script extracts bathymetry data from ETPOP5
%
% Modifications by John Wilkin

region = 'cblast';
region = 'leeuwin';
region = 'useast';
region = 'natl';

switch region    
  
  case 'cblast'
    job = 'seagrid';
    database = 'full';
    Llon = -71.5               % Left   corner longitude
    Rlon = -69.0;              % Right  corner longitude  
    Blat = 40.5;               % Bottom corner latitude
    Tlat = 42.0;               % Top    corner latitude

  case 'natl'
    job = 'seagrid';
    database = 'int';
    Llon = -100.0;             % Left   corner longitude
    Rlon = -45.0;              % Right  corner longitude  
    Blat = 16.0;               % Bottom corner latitude
    Tlat = 55.0;               % Top    corner latitude

  case 'useast'
    job = 'seagrid';
    database = 'high';
    Llon = -105.0              % Left   corner longitude
    Rlon = -45.0;              % Right  corner longitude  
    Blat = 15.0;               % Bottom corner latitude
    Tlat = 55.0;               % Top    corner latitude

  case 'leeuwin'
    job = 'seagrid';
    database = 'int';
    Llon = 95.0                % Left   corner longitude
    Rlon = 130.0;              % Right  corner longitude  
    Blat = -45.0;              % Bottom corner latitude
    Tlat = -19.0;              % Top    corner latitude

end

Oname = [pwd '/' region '_etopo5.mat']; 
Bname = '/n0/arango/ocean/matlab/bath/etopo5.nc';
nc = netcdf(Bname);
x = nc{'topo_lon'}(:); 
y = nc{'topo_lat'}(:); 
xx = (find(x>=Llon&x<=Rlon));
yy = (find(y>=Blat&y<=Tlat));
h = nc{'topo'}(yy,xx);  
lon = x(xx);
lat = y(yy);
save(Oname,'lon','lat','h','Bname')
