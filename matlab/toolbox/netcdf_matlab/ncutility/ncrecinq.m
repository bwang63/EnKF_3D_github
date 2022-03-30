function [varids, varsizes, status] = ncrecinq(ncid, recdim)

% ncrecinq -- emulator for mexcdf4('ncrecinq', ...).
%  [narids, varsizes, status] = ncrecinq(ncid, recdim)
%   inquires about records stored in the NetCDF file whose
%   id is ncid.  If recdim is provided, it substitutes for
%   the actual recdim in the file, if any.
 
% Copyright (C) 1996 Dr. Charles R. Denham, ZYDECO.
% All Rights Reserved.

if nargin < 1, help ncrecinq, return, end
if nargin < 2, recdim = -1; end

if recdim == -1
   [ndims, nvars, ngatts, recdim] = mexcdf('inquire', ncid);
  else
   [ndims, nvars, ngatts] = mexcdf('inquire', ncid);
end

if recdim >= ndims, error(' ## Invalid recdim.'), end

status = 0;

varids = [];
varsizes = [];
for i = 1:nvars
   varid = i-1;
   [varname, datatype, ndims, dimids] = ...
         mexcdf('varinq', ncid, varid);
   if any(dimids == recdim)
      varids = [varids; varid];
      varsize = 1;
      for j = 1:length(dimids)
         dimid = dimids(j);
         if dimid ~= recdim
            [dimname, dimsize] = mexcdf('diminq', ncid, dimid);
            varsize = varsize .* dimsize;
         end
      end
      varsizes = [varsizes; varsize];
   end
end
