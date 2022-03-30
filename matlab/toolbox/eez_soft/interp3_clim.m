% INTERP3_CLIM  Extract climatology variables and interpolate to a set of
%      locations (and optionally evaluate at day-of-year's)
%
% INPUTS
%   fpth,fnam  Source file path and name part, as for GETMAP
%   fll    fill option, as for GETMAP
%   prop   unambiguous mapped property name string, as for GETMAP
%   var    single variable number, as for GETMAP. If supplying doy, use var==1.
%   dps    Depths (in m)
%   xi,yi  Locations at which values required
% Optional:
%   doy    Day-of-year to evaluate each interpolated point
%   vin    input result matrix - nans indicate which values need to be filled
%
% OUTPUT
%   vout   Interpolated variable or evaluated fields
%
% Jeff Dunn  CSIRO Marine Research  Dec 2000
%     Called direct or by GET_CLIM
%
% USAGE: vout = interp3_clim(fpth,fnam,fll,prop,var,dps,xi,yi,doy,vin);

function vout = interp3_clim(fpth,fnam,fll,prop,var,dps,xi,yi,doy,vin)

% $Id: $
%
% Really just do 2D interps at each depth level.
   
if isempty(fpth)
   fpth = '/home/eez_data/atlas/';
end
if isempty(fnam)
   fnam = 'cars2000';
end
   
if isempty(dps)
   dps = csl_dep(1:56);
end
 
if nargin<9
   doy = [];
end


% Create output matrix of the right dimensions

[nyo nxo] = size(xi);
nzo = length(dps);
if nargin<10 | isempty(vin)
   vin = repmat(nan,[nyo nxo nzo]);
else   
   % An input matrix provided - check that it has dimenions corresponding to
   % or at least compatible with other inputs. We want vout to be 3D, even if
   % some dims degenerate, so that do not need to cope with different
   % dimension cases in later assignments.
   
   if dims(vin)<3
      if prod(size(vin)) ~= nyo*nxo*nzo
	 error('Size of xi & depths do not match dimensions of supplied vin');
      else
	 vin = reshape(vin,[nyo nxo nzo]);
      end      
   else
      [nyi nxi nzi] = size(vin);

      if nyi~=nyo | nxi~=nxo
	 if nyi==nxo & nxi==nyo
	    disp([7 'Rotating xi,yi to match vin dimensions']);
	    xi = xi';
	    yi = yi';
	    doy = doy';
	 else
	    error('Dimensions of xi & yi do not match supplied vin');
	 end
      end
      if nzi~=length(dps)
	 error('Number of depths does not match 3rd dimension of supplied vin');
      end
   end
end

vout = vin;

xi = xi(:)';
yi = yi(:)';
doy = doy(:)';

if var==1 & ~isempty(doy)
   temporal = 1;
else
   temporal = 0;
end

% x0 = west edge of grid, nx = number of x

[x,y] = getmap(prop,0,fpth,fnam,fll,[4 5]);
x0 = x(1); y0 = y(1);
[ny,nx] = size(x);
inc = abs(y(2)-y(1));

ix = 1+(xi-x0)/inc;
iy = 1+(yi-y0)/inc;

jin = find(ix>=1 & ix<=nx & iy>=1 & iy<=ny);
ix = ix(jin);
iy = iy(jin);
if ~isempty(doy)
   doy = doy(jin);
end

% Indices to grid points surrounding target point: i1=SW i2=NW i3=SE i4=NE

i1 = round((ny*floor(ix-1))+floor(iy));
i2 = i1+1;
i3 = round((ny*floor(ix))+floor(iy));
i4 = i3+1;

% For points on nx or ny boundaries, fold indices back to prevent accessing
% non-existant nx+1 or ny+1 elements

j2 = find(ix==nx);
i3(j2) = i1(j2);
i4(j2) = i2(j2);

j2 = find(iy==ny);
i2(j2) = i1(j2);
i4(j2) = i3(j2);

% Calc interpolation weights. xr, yr are fractional distances from West and
% South grid lines. Weigths are 1 minus those, so if target point very near
% east grid point, then xr~1 and w~0 for west grid points.

xr = ix-floor(ix);
yr = iy-floor(iy);

w = [(1-xr).*(1-yr); (1-xr).*yr; xr.*(1-yr); xr.*yr];

timc = -i*2*pi/366;

% Do 2D interp for each depth level

for idp = 1:length(dps)
   % We may be below temporal harmonics depth, in which case an & sa will
   % just be empty
   if temporal
      [dd,an,sa] = getmap(prop,dps(idp),fpth,fnam,fll,[1 2 3]);
   else
      dd = getmap(prop,dps(idp),fpth,fnam,fll,var);
   end
   
   dd = dd([i1; i2; i3; i4]);
   aa = ~isnan(dd);
   sumw = sum(aa.*w);

   % Require that data is not only at points almost the full grid interval
   % away (ie that the good data interpolation weight is non-trivial)
   
   if ~isempty(vin)
      % Only get values where we don't currently have them.
      tmp = squeeze(vin(:,:,idp));
      ic = find(isnan(tmp(jin)) & sumw>.05);
   else
      tmp = repmat(nan,[nyo nxo]);
      ic = find(sumw>.05);
   end

   dd = dd(:,ic);
   % Set nans to 0 as alternative to using nansum below
   bad = find(isnan(dd));
   dd(bad) = zeros(size(bad));

   tmp(jin(ic)) = sum(dd.*w(:,ic))./sumw(ic);

   if temporal & ~isempty(an)
      dd = an([i1(ic); i2(ic); i3(ic); i4(ic)]);
      % Could possibly be missing harmonics where do have a mean value 
      bad = find(isnan(dd));
      dd(bad) = zeros(size(bad));
      tmp2 = sum(dd.*w(:,ic))./sumw(ic);
      tmp(jin(ic)) = tmp(jin(ic)) + real(tmp2.*exp(timc*doy(ic)));
      if ~isempty(sa)
	 dd = sa([i1(ic); i2(ic); i3(ic); i4(ic)]);
	 dd(bad) = zeros(size(bad));
	 tmp2 = sum(dd.*w(:,ic))./sumw(ic);
	 tmp(jin(ic)) = tmp(jin(ic)) + real(tmp2.*exp(2*timc*doy(ic)));
      end
   end
   
   vout(:,:,idp) = tmp;
end

vout = squeeze(vout);

%---------------------------------------------------------------------------
