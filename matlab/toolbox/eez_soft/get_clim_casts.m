% GET_CLIM_CASTS: Return 3D extracts from CARS, at a set of locations and
%      depths, and optionally day-of-years, optionally limiting geographic
%      range to improve efficiency.     SUPERCEDES 'getsection'
% INPUT
%  prop    property ('t','s','o','si','n', OR 'p')
%  lon,lat   vectors of NN locations
%  deps    vector of DD depth level numbers. Need not be contiguous.
%  doy     OPTIONAL vector of NN day-of-year corresponding to locations
%  fname   OPTIONAL other maps to use instead of CARS: 'filled', 'sea10' 
%  woa     OPTIONAL 1=use WOA97 (Levitus) outside of CARS region
%
% OUTPUT
%  vv      psuedo-casts extracted from CARS, dimensioned [DD,NN]
%  out     index to casts outside region of specified maps
%
% AUTHOR: Jeff Dunn  CSIRO DMR  May 1998
% $Id: get_clim_casts.m,v 1.4 2000/03/14 23:03:52 dunn Exp dunn $
%
% CALLS:  clname  isinpoly  coord2grd  getchunk  get_woa_profiles
%
% USAGE: [vv,out] = get_clim_casts(prop,lon,lat,deps,doy,fname,woa);

function [vv,out] = get_clim_casts(prop,lon,lat,deps,doy,fname,woa);

vers = version;
if ~strcmp(vers(1),'5')
  error('Sorry - GET_CLIM_CASTS only works in Matlab v5')
end

ncquiet;

if nargin<5; doy = []; end
if nargin<6; fname = []; end
if nargin<7; woa = []; end

lon = lon(:)';
lat = lat(:)';
doy = doy(:)';

vv = repmat(nan,length(deps),length(lon));

tcor = -i*2*pi/366;
cpath = [];

[tmp,ncf] = clname(prop,cpath,fname);
gor = ncf{'gr_origin'}(:);
gsp = ncf{'grid_space'}(:);
rot = ncf{'rotation'}(:);
cnrs = ncf{'corners'}(:);
close(ncf);

if isempty(rot) | rot==0
  ic = find(lon>=min(cnrs(2,:)) & lon<=max(cnrs(2,:)) & ...
      lat>=min(cnrs(1,:)) & lat<=max(cnrs(1,:)));
else
  ic = isinpoly(lon,lat,cnrs(2,:),cnrs(1,:));
  ic = find(ic>0);
end
ic = ic(:)';  


if ~isempty(ic) 
  % Auto-set an efficient range, but guard against degenerate ones which 
  % would not provide enough grid points for interpolation.

  range = [floor((min(lon(ic))-.1)/gsp(2))*gsp(2) ...
	  ceil((max(lon(ic))+.1)/gsp(2))*gsp(2) ...
	 floor((min(lat(ic))-.1)/gsp(1))*gsp(1) ...
	  ceil((max(lat(ic))+.1)/gsp(1))*gsp(1)];
  ndep = length(deps);
  
  % Convert position to index-coords into the climatology chunk, so can
  % use abbreviated form for interp3 (ie not supply meshgrid). Because deeper
  % NaNs wipe out estimates up to and including at the layer above, we shift Z
  % to be just above the layer so they are uneffected by NaNs below. (However, 
  % this would then put layer 1 outside of the grid and hence lose it, so we
  % 2D-interpolate it separately!)

  [X,Y] = coord2grd(lon(ic),lat(ic),gor(2),gor(1),gsp(2),gsp(1),rot);

  if isempty(doy)

    [mn,t2,t3,t4,t5,ix,iy] = getchunk(prop,deps,range,cpath,fname,-2);
    X = X+1-min(ix);
    Y = Y+1-min(iy);
    if min(size(mn))<2
      error('GET_CLIM_CASTS - region lacks enough grid points to interpolate')
    end
    vv(1,ic) = interp2(mn(:,:,1),X,Y,'*linear');
    if ndep>1
      Y = repmat(Y,ndep-1,1);
      X = repmat(X,ndep-1,1);
      Z = repmat((2:ndep)'-.0001,1,length(ic));
      vv(2:ndep,ic) = interp3(mn,X,Y,Z,'*linear');
    end
    
  else
    
    [mn,an,sa,t4,t5,ix,iy] = getchunk(prop,deps,range,cpath,fname,2);

    if isempty(an)
       error('No temporal harmonics available - set "doy = []"')
    elseif isempty(sa)
       semian = 0;
    else
       semian = 1;
    end
    
    X = X+1-min(ix);
    Y = Y+1-min(iy);
    mt = interp2(mn(:,:,1),X,Y,'*linear');
    at = interp2(an(:,:,1),X,Y,'*linear');
    if semian; st = interp2(sa(:,:,1),X,Y,'*linear'); end
    
    if ndep>1
      Y = repmat(Y,ndep-1,1);
      X = repmat(X,ndep-1,1);
      Z = repmat((2:ndep)'-.0001,1,length(ic));
      mt = [mt; interp3(mn,X,Y,Z,'*linear')];
      at = [at; interp3(an,X,Y,Z,'*linear')];
      if semian; st = [st; interp3(sa,X,Y,Z,'*linear')]; end
    end

    % Replace temporal NaNs with 0 so that these have no effect in computation.
    kk = find(isnan(at));
    if ~isempty(kk), at(kk) = zeros(size(kk)); end
    if semian
       kk = find(isnan(st));
       if ~isempty(kk), st(kk) = zeros(size(kk)); end
    end
    
    doy = repmat(doy(ic),ndep,1);

    if semian
       vv(:,ic) = mt + real(at.*exp(tcor.*doy)) + real(st.*exp(2.*tcor.*doy));
    else
       vv(:,ic) = mt + real(at.*exp(tcor.*doy));
    end
  end
end


if length(ic)<length(lat(:))
  out = 1:length(lat(:));
  out(ic) = [];
else
  out = [];
end

if isempty(woa)
  if isempty(ic)
    warning('None of given locations are within this climatology`s region')
  end
else
  if ~isempty(out)
    disp([num2str(length(out)) ' profiles used WOA97']);
    if isempty(doy)
      vv(:,out) = get_woa_profiles(prop,lon(out),lat(out),deps);
    else
      vv(:,out) = get_woa_profiles(prop,lon(out),lat(out),deps,doy(out));
    end
    out = [];
  end
end

%------------- End of get_clim_casts -------------------------
