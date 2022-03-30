% TMEXCDF Test of mexcdf Mex-file interface to NetCDF.

% Copyright (C) 1993 Dr. Charles R. Denham, ZYDECO.
% All Rights Reserved.

status = mexcdf('setopts', 0);

for i = 0:10
   status = mexcdf('close', i);
end

% Phase 1: Simple creation and fill.

cdf = mexcdf('create', 'mycdf.cdf', 'clobber');

xdim = mexcdf('dimdef', cdf, 'x', 10);
ydim = mexcdf('dimdef', cdf, 'y', 10);

avar = mexcdf('vardef', cdf, 'a', 'double', 1, [xdim]);
bvar = mexcdf('vardef', cdf, 'b', 'double', 1, [ydim]);

status = mexcdf('close', cdf);

cdf = mexcdf('open', 'mycdf.cdf', 'write');

status = mexcdf('redef', cdf);

cvar = mexcdf('vardef', cdf, 'c', 'double', 2, [xdim ydim]);

status = mexcdf('endef', cdf);

a = rand(10, 1);
b = ones(10, 1) * pi;

status = mexcdf('varput', cdf, 'a', [0], [10], a);
status = mexcdf('varput', cdf, 'b', [0], [10], b);

status = mexcdf('close', cdf);

disp('TMEXCDF: Phase 1 done.')

% Phase 2: foo.cdf example, NetCDF User's Guide, Chapter 10.

cdf = mexcdf('create', 'foo.cdf', 'clobber');

dlat = mexcdf('dimdef', cdf, 'lat', 10);
dlon = mexcdf('dimdef', cdf, 'lon', 5);
dtime = mexcdf('dimdef', cdf, 'time', 'unlimited');

vlat = mexcdf('vardef', cdf, 'lat', 'long', 1, dlat);
vlon = mexcdf('vardef', cdf, 'lon', 'long', 1, dlon);
vtime = mexcdf('vardef', cdf, 'time', 'long', 3, [dtime dlat dlon]);
vz = mexcdf('vardef', cdf, 'z', 'float', 3, [dtime dlat dlon]);
vt = mexcdf('vardef', cdf, 't', 'float', 3, [dtime dlat dlon]);
vp = mexcdf('vardef', cdf, 'p', 'double', 3, [dtime dlat dlon]);
vrh = mexcdf('vardef', cdf, 'rh', 'long', 3, [dtime dlat dlon]);

status = mexcdf('endef', cdf);

status = mexcdf('attput', cdf, vlat, 'units', 'char', -1, 'degrees_north');
status = mexcdf('attput', cdf, vlon, 'units', 'char', -1, 'degrees_east');
status = mexcdf('attput', cdf, vtime, 'units', 'char', -1, 'seconds');
status = mexcdf('attput', cdf, vz, 'units', 'char', -1, 'meters');
status = mexcdf('attput', cdf, vz, 'valid_range', 'float', -1, [0 5000]);
status = mexcdf('attput', cdf, vp, '_FillValue', 'double', -1, -9999);
status = mexcdf('attput', cdf, vrh, '_FillValue', 'long', -1, -1);

lat = [0 10 20 30 40 50 60 70 80 90];
lon = [-140 -118 -96 -84 -52];

status = mexcdf('varput', cdf, vlat, 0, 10, lat);
status = mexcdf('varput', cdf, vlon, 0, 5, lon);

status = mexcdf('close', cdf);

disp('TMEXCDF: Phase 2 done.')

% Phase 3: bar.cdf for NC_UNLIMITED data.

cdf = mexcdf('create', 'bar.cdf', 'clobber');

dimid = mexcdf('dimdef', cdf, 'i', 'unlimited');

varid = mexcdf('vardef', cdf, 'x', 'double', 1, dimid);

status = mexcdf('endef', cdf);

status = mexcdf('close', cdf);

[x, j] = sort(rand(11, 1));
j = j(:).' - 1;
disp(j)

for i = j
   cdf = mexcdf('open', 'bar.cdf', 'write');
   varid = mexcdf('varid', cdf, 'x');
   status = mexcdf('varput', cdf, varid, i, 1, i);
   x = mexcdf('varget', cdf, 'x', i, 1);
   if x ~= i
      disp(['Bad put/get: ', int2str(i), num2str(x)]);
   end
   status = mexcdf('close', cdf);
end

disp('TMEXCDF: Phase 3 done.')

