function xyz = f_exportDods(lon,lat,z);
% - export DODS bathymetry for import into Surfer
%
% USAGE: xyz = f_exportDods(lon,lat,z);
%
% lon = vector of longitudes
% lat = vector of latitudes
% z   = vector of depths
%
% use f_export('fname.dat',xyz,',') for ASCII export

% by Dave Jones,<djones@rsmas.miami.edu> Apr-2002
% http://www.rsmas.miami.edu/personal/djones/
% ----------------- DISCLAIMER: -------------------
% This code is provided as is, with no guarantees
% and is only intended for non-commercial use.
% --------------------------------------------------

% This function was written to format DODS data for export
% to Surfer for re-gridding and mapping. Note that in Surfer
% be sure to specify nr and nc for the x,y spacing when re-gridding.

% -----Links:-----
% DODS> http://www.unidata.ucar.edu/packages/dods/
%
% Surfer> http://www.golden.com

lon = lon(:); lat = lat(:); % make col vectors

[nr,nc] = size(z);

if (nr ~= length(lat)) | (nc ~= length(lon))
   error('Size of Z is incompatible with LON and LAT');
end;

noVar = length(z(:)); % # data points

xyz(noVar,3) = 0; % preallocate results array

k = 0; % initialize counter
for i = 1:nr
   for j = 1:nc
      k = k+1; % increment counter
      xyz(k,1:3) = [lon(j) lat(i) z(i,j)];
   end
end

