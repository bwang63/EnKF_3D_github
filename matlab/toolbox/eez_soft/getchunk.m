% GETCHUNK: Extract a 3D chunk of a netCDF file map
% INPUT:
%    property - property name (eg 'salinity' or just 's')
%  Optional....
%    deps    - scalar or vector of std depth levels to extract 
%    region  - [w e s n] boundaries included in data extracted
%    path    - path to netCDF map file
%    fname   - input file name component, if non-CARS. Full name is built as
%              follows:    filename = [fullproperty '_' fname '.nc']
%            eg: property='s', fname='maps'  then filename='salinity_maps.nc'
%    opt     - 1: [default] return lat/lon for x,y
%              2: return grid indices (ix,iy) for x,y
%              -1 or -2: as above, but return empty args for all except mn,x,y
%
% OUTPUT:   Matlab 5   (Note: depth is the right-hand index)
%    mn     - [nlat,nlon,ndep] mean field (1/2 degree grid in [100 180 -50 0])
% Optional....
%    an     - [nlat,nlon,ndep] complex annual harmonics, [] if none available
%    sa     - [nlat,nlon,ndep] complex semiannual harmonics, "  "  "   " 
%    rq     - [nlat,nlon,ndep] data source radius (km)
%    dets   - [ndep,det_len] mapping details text strings
%                opt = 1                         opt = 2    [see 'opt' above])
%    x      - [nlat,nlon] longitudes         [nlon] map grid coords
%    y      - [nlat,nlon] latitudes          [nlat] map grid coords
%
% * If ONLY ONE DEPTH specified, 3D outputs collapse to 2D.
% * Matlab Version 4:  Output dimensions are [ndep,ngrid]
%
% Copyright (C) J R Dunn, CSIRO Division of Marine Research
% $Id: getchunk.m,v 1.9 1999/02/10 22:56:29 dunn Exp dunn $
%
% USAGE: [mn,an,sa,rq,dets,x,y] = getchunk(property,deps,region,path,fname,opt)

function [mn,an,sa,rq,dets,x,y] = getchunk(property,deps,region,path,fname,opt)

%global BLANKBELOWBOT

if length(property)==1
  property = [property ' '];
end

if strcmp(property(1),'t')
  property = 'temperature';
elseif strcmp(property(1),'o')
  property = 'oxygen';
elseif strcmp(property(1),'n')
  property = 'nitrate';
elseif strcmp(property(1),'p')
  property = 'phosphate';
elseif strcmp(property(1:2),'si')
  property = 'silicate';
elseif strcmp(property(1),'s')
  property = 'salinity';
end
  
% Must allow for non-contiguous vector of depths
if nargin<2; deps=[]; end
if isempty(deps)
  deps = 1:33;
end
ndep = length(deps);
dep1 = deps(1);
depn = deps(ndep);


if nargin<3; region=[]; end

if nargin<4 | isempty(path)
  path = '/home/eez_data/atlas/';
end

if nargin<5 | isempty(fname)
  fname='maps';
end

cdfile = [path property '_' fname];

if nargin<6 | isempty(opt)
  opt = 1;
end
  
getan = 0; an = [];
getsa = 0; sa = [];

% --- Get grid and check existence of any requested data

[fid,rcode] = ncmex('ncopen',[cdfile '.nc'],'nowrite');
if rcode==-1 | fid==-1
  error(['Cant open file ' cdfile]);
end

if nargout > 1 & opt>=0
  % Find out at what depths these variables exist  
  varid = ncmex('ncvarid',fid,'an_cos');
  if varid == -1
    disp('No temporal info.');
  else
    dtid = ncmex('ncdimid',fid,'depth_timefit');
    [name,dtmax] = ncmex('ncdiminq',fid,dtid);
    if dtmax>=dep1
      getan = 1;
      varid = ncmex('ncvarid',fid,'sa_cos');
      if nargout > 2 & varid ~= -1
	getsa = 1;
      end
    end
  end
else
  rq = [];
  dets = [];
end

ncmex('ncclose',fid);

Xg = getnc(cdfile,'lon');
Yg = getnc(cdfile,'lat');
if min(size(Xg))==1
  [Xg,Yg] = meshgrid(Xg,Yg);
end


% ----------------------------------------------------------------------
% Make use of higher dimensional output with version 5
% Note that we permute order of outputs for compatibility with earlier version
% of this script (which is a pain in the bum).

vers=version;

if strcmp(vers(1),'5')

  didx = deps+1-dep1;

  if isempty(region)
    x1 = 1; y1 = 1;
    x2 = length(Xg(1,:));
    y2 = length(Yg(:,1));
  else
    % Note that even for rotated grids this will find the minimum 
    % grid-rectangular area enclosing all of 'region'
    [iy,ix] = find(Yg>=region(3)& Yg<=region(4)& Xg>=region(1)& Xg<=region(2));
    y1 = min(iy); y2 = max(iy);
    x1 = min(ix); x2 = max(ix);
  end
  ny = 1+y2-y1;
  nx = 1+x2-x1;
  
  % Get mean and shape it. DIMS is a function at the end of this file
  mn = getnc(cdfile,'mean',[dep1 y1 x1],[depn y2 x2],-1,-2,2,0,0);
  if dims(mn)==1
     mn = reshape(mn,[ny nx]);
  elseif dims(mn)==1
     mn = mn';
  else
     mn = permute(mn(:,:,didx),[2 1 3]);
  end

%  Give up on the "blanking" idea...
%  if ~isempty(BLANKBELOWBOT)
%    if ndims(mn)==2
%      mn = do_blanking(mn,dep1,Xg(y1:y2,x1:x2),Yg(y1:y2,x1:x2));
%    else
%      for ii=1:ndep
%	mn(:,:,ii) = do_blanking(mn(:,:,ii),deps(ii),Xg(y1:y2,x1:x2),Yg(y1:y2,x1:x2));
%      end
%    end
%  end

  if getan
    vcos = getnc(cdfile,'an_cos',[dep1 y1 x1],[dtmax y2 x2],-1,-2,2,0,0);
    vsin = getnc(cdfile,'an_sin',[dep1 y1 x1],[dtmax y2 x2],-1,-2,2,0,0);
    dtidx = deps(find(deps<=dtmax))+1-dep1;
    if dtmax<depn
      an = repmat(NaN+i*NaN,[ny nx ndep]);
    end
    if ndims(vcos)==2
      an(:,:,1) = vcos' + vsin'.*i;      % Works, even if an is 2D only.
    else
      an(:,:,1:length(dtidx)) = permute(...
	  vcos(:,:,dtidx) + vsin(:,:,dtidx).*i,[2 1 3]);
    end  
  end

  if getsa
    vcos = getnc(cdfile,'sa_cos',[dep1 y1 x1],[dtmax y2 x2],-1,-2,2,0,0);
    vsin = getnc(cdfile,'sa_sin',[dep1 y1 x1],[dtmax y2 x2],-1,-2,2,0,0);
    if dtmax<depn
      sa = repmat(NaN+i*NaN,[ny nx ndep]);
    end
    if ndims(vcos)==2
      sa(:,:,1) = vcos' + vsin'.*i;      % Works, even if sa is 2D only.
    else
      sa(:,:,1:length(dtidx)) = permute(...
	  vcos(:,:,dtidx) + vsin(:,:,dtidx).*i,[2 1 3]);
    end  
  end

  if nargout>3 & opt>=0
    rq = getnc(cdfile,'radius_q',[dep1 y1 x1],[depn y2 x2],-1,-2,2,0,0);
    if dims(rq)==1
       rq = reshape(rq,[ny nx]);
    elseif dims(rq)==2
       rq = rq';
    else
      rq = permute(rq(:,:,didx),[2 1 3]);
    end
  end
  
  if nargout>4 & opt>=0
    dets = getnc(cdfile,'map_details',[-1 dep1],[1 depn],-1,-2)';
    dets = dets(didx,:);
  end

  if nargout > 5
    if abs(opt)==2
      y = y1:y2;
      x = x1:x2;
    else
      x = Xg(y1:y2,x1:x2);
      y = Yg(y1:y2,x1:x2);
    end
  end

else     % ------------------------------------------------------------------
         % version 4 case

  dets = [];
  if nargout > 3
    getrq = 1;
  else
    getrq = 0;
  end

  [Xg Yg]=meshgrid(Xg,Yg);

  if isempty(region)
    ii = 1:prod(size(Xg));
  else
    ii = find(Xg>=region(1) & Xg<=region(2) & Yg>=region(3) & Yg<=region(4));
    ii = ii(:)';
  end
  ngrid = length(ii);
  
  mn = NaN*ones(ndep,ngrid);
  if getan
    an = mn + i*mn;
  end
  if getsa
    sa = mn + i*mn;
  end
  if getrq
    rq = mn;
  end

  if nargout > 5
    x = Xg(ii);
    y = Yg(ii);
  end


  for jj = 1:ndep
  
    dep = deps(jj);

    dtmp = getcdf(cdfile,'map_details',[dep -1],[dep 1]);
    dets = [dets; dtmp(:)']; 

    zi = getcdf(cdfile,'mean',[dep -1 -1],[dep 1 1])';
%    if ~isempty(BLANKBELOWBOT)
%      zi = do_blanking(zi,dep,Xg(y1:y2,x1:x2),Yg(y1:y2,x1:x2));
%    end
    mn(jj,:) = zi(ii);

    if getrq
      tmp = getcdf(cdfile,'radius_q',[dep -1 -1],[dep 1 1])';
      rq(jj,:) = tmp(ii);
    end
  
    if getan
      if dep <= dtmax
	tmp = getcdf(cdfile,'an_cos',[dep -1 -1],[dep 1 1])';
	tmp2 = getcdf(cdfile,'an_sin',[dep -1 -1],[dep 1 1])';
	an(jj,:) = tmp(ii) + tmp2(ii).*i;
      end
    end

    if getsa
      if dep <= dtmax
	tmp = getcdf(cdfile,'sa_cos',[dep -1 -1],[dep 1 1])';
	tmp2 = getcdf(cdfile,'sa_sin',[dep -1 -1],[dep 1 1])';
	sa(jj,:) = tmp(ii) + tmp2(ii).*i;
      end
    end  
  end  

end

% --------------------------------------------------------------
% DIMS  Improvement on ndim in that 1-D objects are identified 

function ndim = dims(A)

ndim = length(size(A));
if ndim==2 & min(size(A))<2
   ndim = 1;
end
