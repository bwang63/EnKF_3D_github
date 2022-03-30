function ncrectest(nrecords)

% ncrectest -- Test of ncrecput/ncrecget.
%  ncrectest(nrecords) exercises the tmexcdf4 netcdf
%   test-file 'foo.cdf' by writing/reading nrecords,
%   using ncrecput() and ncrecget().
 
% Copyright (C) 1996 Dr. Charles R. Denham, ZYDECO.
% All Rights Reserved.
 
% Version of 17-Apr-96 at 16:45:57.08.

if nargin < 1, nrecords = 1; end

x = 1:201;

ncid = mexcdf4('open', 'foo.cdf', 'write');

[varids, varsizes, status] = mexcdf4('recinq', ncid);

disp(' ## Variable ids and sizes:')
disp([varids; varsizes])

if (1)
varid = 2;
for recnum = 0:nrecords-1
   status = mexcdf4('varput', ncid, varid, recnum, 1, 9999);
   [d, status] = mexcdf4('varget', ncid, varid, recnum, 1);
end
end

okay = 1;

d = [];
for recnum = 0:nrecords-1
   status = ncrecput(ncid, recnum, x);
   [d, status] = ncrecget(ncid, recnum);
   if any(d(:) ~= x(:))
      disp([' ## Bad round trip: record ' int2str(recnum)])
      okay = 0;
   end
end

status = mexcdf4('close', ncid);

if okay, disp(' ## Successfull test.'), end
