function theResult = rnt_earthdist(alon, alat, blon, blat, radius)

% rnt_earthdist -- Distance in meters between two lon/lats.
%  earthdist(alon, aloat, blon, blat, radius) returns the
%   distance in maters between locations (alon, alat)
%   and loncations (blon, blat).  The default earth radius is
%   assumed to be 6371*1000 meters, the radius for
%   a sphere of equal-volume.
%
%  from Chuck..

if nargin < 4, help(mfilename), return, end
if nargin < 5, radius = 6371*1000; end   % meters.

RCF = 180 / pi;

alon = alon / RCF;
alat = alat / RCF;
blon = blon / RCF;
blat = blat / RCF;

c = cos(alat);
ax = c .* cos(alon);
ay = c .* sin(alon);
az = sin(alat);

c = cos(blat);
bx = c .* cos(blon);
by = c .* sin(blon);
bz = sin(blat);

result = acos(ax.*bx + ay.*by + az.*bz) .* radius;

if nargout > 0
        theResult = result;
else
        disp(result)
end
