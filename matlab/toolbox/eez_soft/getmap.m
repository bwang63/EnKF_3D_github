% GETMAP: Load maps to Matlab from netCDF file
%
% INPUT: property - unambiguous name (eg 'si' for "silicate")
%        depth   - depth (in m) of map to extract
%  Optional....   (use [] if not required)
%        fpath   - fpath to netCDF map file
%        fname   - file name component, to build full name as follows:
%                  filename = [fullproperty '_' fname '.nc']
%                  {Only required if not accessing standard CARS}
%        fill    - 1=value everywhere, instead of just above the sea bottom
%        vars    - specify variables to return:
%                  1=mn  2=an  3=sa  4=Xg  5=Yg  6=rq  7=details  8=nq  9=SD 
%                  10=rmsmr  11=rmsr  12=bcnt  13=grid-index
%
% OUTPUT:  All optional....
%         mn      - mean field (1/2 degree grid in [100 180 -50 0])
%         an      - complex annual harmonics
%         sa      - complex semiannual harmonics
%         Xg,Yg   - lon and lat coords of grid
%         rq      - data source radius (km) for mapping each grid point, OR
%                   where -ve, is number of data points used 
%         details - mapping details text string
%         nq      - number of data used in mapping each point
%         SD      - locally-weighted standard deviation of data
%         rmsmr   - locally-weighted RMS of residuals wrt mean field
%         rmsr    - locally-weighted RMS of residuals wrt mean and seasonal cyc
%         bcnt    - number of data in bin (cell) surrounding grid point 
% OR:
%         as above, but in order specified in input argument "vars"
%
% Copyright (C) J R Dunn, CSIRO Marine Research  1999-2000
%
% ### NEW - handles non-gridded (high-res) maps  (6/12/00)
%
% USAGE: getmap  OR  getmap('t')    {display concise index of available maps}
%
%    OR: [mn,an,sa,Xg,Yg,rq,details,nq,SD,rmsmr,rmsr,bcnt] = ...
%                                 getmap(property,depth,fpath,fname,fll,vars)

function varargout = getmap(property,depth,fpath,fname,fll,vars)

% MODS
%    - Added new output arguments Xg Yg    (4/6/98)
%    - Changed filename construction       (4/6/98)
%    - spec depth instead of depth index   (30/8/00)
%    - handles non-gridded (high-res) maps  (6/12/00)
%   
% $Id: getmap.m,v 1.9 2000/12/07 04:15:27 dunn Exp dunn $
   
ncquiet;
varnm = {'mean','annual','semi_an','Xg','Yg','radius_q','map_details','nq',...
	'std_dev','RMSspatialresid','RMSresid','bin_count'};
Xg = []; Yg = [];

if nargin<2
   disp('Less than 2 input arguments, so calling map_index for your info:');
   if nargin==1 & ~isempty(property)
      map_index(property);
   else
      map_index;
   end
   return
end

if nargin<3 | isempty(fpath)
  fpath = '/home/eez_data/atlas/';
end
  
if nargin<4 | isempty(fname)
  fname = 'cars2000';
end

if nargin<5 | isempty(fll)
  fll = 0;
end

if nargin<6 | isempty(vars)
   vars = 1:nargout;
end

nout = min([length(vars) nargout]);


if strncmp(property,'t',1)
  property = 'temperature';
elseif strncmp(property,'o',1)
  property = 'oxygen';
elseif strncmp(property,'n',1)
  property = 'nitrate';
elseif strncmp(property,'p',1)
  property = 'phosphate';
elseif strncmp(property,'si',2)
  property = 'silicate';
elseif strncmp(property,'s',1)
  property = 'salinity';
end

ncfile = [fpath property '_' fname '.nc'];

ncf =  netcdf(ncfile,'nowrite');
if isempty(ncf)
   error(['Cannot open file ' ncfile]);
end

grin = ncf{'grid_index'}(:);
gridded = isempty(grin);

[Xg,Yg] = getXgYg(ncf,Xg,Yg);

deps = ncf{'depth'}(:);
level = find(deps==round(depth));
if isempty(level)
   error(['There is no map for depth ' num2str(depth) ' in file ' ncfile]);
end

dtmax = length(ncf('depth_timefit'));


for kk = 1:nout
   iv = vars(kk);
   switch iv
    case {2,3,11}
       if level > dtmax
	  varargout{kk} = [];
	  tmp = [];
       elseif iv==2
	  rpart = scget(ncf,'an_cos',level);   
	  ipart = scget(ncf,'an_sin',level);   
	  tmp = rpart + i*ipart;
       elseif iv==3
	  rpart = scget(ncf,'sa_cos',level);
	  ipart = scget(ncf,'sa_sin',level);
	  tmp = rpart + i*ipart;
       else
	  tmp = scget(ncf,varnm{iv},level);
       end
       
    case {1,6,8,9,10,12} 
       tmp = scget(ncf,varnm{iv},level);
       
    case 7
       varargout{kk} = ncf{varnm{iv}}(:,level)';
       
    case 4
       varargout{kk} = Xg;
       
    case 5
       varargout{kk} = Yg;

    case 13
       varargout{kk} = grin;

   end
   if any([1:3 6 8:12]==iv)
      if ~gridded & ~isempty(tmp)
	 varargout{kk} = repmat(nan,size(Xg));
	 varargout{kk}(grin) = tmp;
      else
	 varargout{kk} = tmp;
      end
   end
end

if ~fll
   gdp = ncf{'grid_dep'}(:);
   % If grid_dep is not setup or initialised, gdp will be empty or fill-valued.
   if ~isempty(gdp) & any(any(gdp>-32766))
      rr = find(gdp<dep_csl(depth));
      ij = inboth(vars,[1 2 3]);
      for kk = ij(:)'
	 if vars(kk)==1 | level<=dtmax
	    varargout{kk}(rr) = repmat(NaN,size(rr));
	 end	    
      end
   end
end

close(ncf);

% --------------------------------------------------------------------
function [X,Y] = getXgYg(ncf,Xg,Yg)
   
   if isempty(Xg)	  
      X = ncf{'lon'}(:);
      Y = ncf{'lat'}(:);
      if min(size(X))==1
	 [X,Y] = meshgrid(X,Y);
      end
   else
      X = Xg;
      Y = Yg;
   end
   return
   
% --------------------------------------------------------------------
function vv = scget(ncf,varn,level)

fill = ncf{varn}.FillValue_(:);
miss = ncf{varn}.missing_value(:);

% Extract data WITHOUT scaling so that can detect flag values.
% We look only for exact equality to the flag values because assume are only
% checking integer data.

ii = [];
vv = ncf{varn}(level,:,:);

if isempty(vv)
   return
end

if ~isempty(fill)
  ii = find(vv==fill);
  % Avoid checking twice if missing and fill values are the same
  if ~isempty(miss)
    if miss==fill, miss = []; end
  end
end

if ~isempty(miss) 
  i2 = find(vv==miss);
  ii = [ii(:); i2(:)];
end

% Now scale data, and overwrite any locations which held flag values.

adof = ncf{varn}.add_offset(:);
if isempty(adof)
   adof = 0;
end
scf = ncf{varn}.scale_factor(:);
if isempty(scf)
   scf = 1;
end

vv = (vv*scf) + adof;

if ~isempty(ii)
  vv(ii) = repmat(NaN,size(ii));
end

% ------------ End of getmap -----------------------------------------
