% This script computes the Land/Sea mask for an existing grid NetCDF
% file.


Gname='/n0/arango/ocean/matlab/coastlines/japan.nc';
Cname='/n0/arango/ocean/matlab/coastlines/japan_coast.mat';

%-----------------------------------------------------------------------
% Load coastline data (closed polygoms) extracted from GSHHS dataset.
%-----------------------------------------------------------------------

load(Cname);
cx=lon';
cy=lat';

%-----------------------------------------------------------------------
% Get grid coordinates.
%-----------------------------------------------------------------------

rlon=nc_read(Gname,'lon_rho');
rlat=nc_read(Gname,'lat_rho');

[Im,Jm]=size(rlon);

%-----------------------------------------------------------------------
% Compute Land/Sea mask.
%-----------------------------------------------------------------------

u=rlon';
v=rlat';

f=find(~isfinite(cx) | ~isfinite(cy));
f=f(:).';
if ~any(f),
  f=[0 length(cx)+1];
end,
if (f(1) ~= 1),
  f=[0 f];
end,
if (f(end) ~= length(cx)),
  f(end+1)=length(cx)+1;
end

h=warndlg('Please wait ...', 'Computing Mask');
drawnow

theMask=zeros(size(u));

for i=2:length(f),
  g=find(theMask == 0);
  if (~any(g)),
    break,
  end,
  j=f(i-1)+1:f(i)-1;
  if (length(j) > 2),
    theMask(g)=mexinside(u(g),v(g),cx(j),cy(j));
  end,
end,

if (ishandle(h)),
  delete(h),
end,

theLand = ~~theMask;
theWater = ~theLand;







