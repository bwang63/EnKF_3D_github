% GET_CLIM: Return 3D extracts from CARS, at a set of locations and
%      depths, and optionally day-of-years
%      SUPERCEDES 'getsection' and 'get_clim_casts' and can be used instead
%      of 'getchunk'
%
% INPUT
%  prop    property ('t','s','o','si','n', OR 'p')
%  lon,lat  vector or array of NN locations
%  deps    vector of DD depths (in m). Need not be contiguous.
%  OPTIONAL:
%  doy     matrix day-of-year corresponding to locations
%  var     1=mean or temporally evaluated; 2,3,6,8,9,10,11,12 - as for GETMAP
%  fnms    name or cell array of names of climatology files to
%          access (in the order specified). 
%      OR  'best' to get best possible resolution
%  woa     1=use WOA98 (Levitus) outside of CARS EEZ region
%  fll     1=values at all depths outside of land areas 
%  fpth    to get map files from a non-standard disc location
%
% OUTPUT
%  vv      psuedo-casts extracted from CARS, dimensioned [size(lon) DD]
%
% AUTHOR: Jeff Dunn  CSIRO DMR  May 1998
% $Id: $
%
% CALLS:  intp3jd (getmap (clname))  csl_dep std_dep
%
% USAGE: vv = get_clim(prop,lon,lat,deps,doy,var,fnms,woa,fll,fpth);

function vv = get_clim(prop,lon,lat,deps,doy,var,fnms,woa,fll,fpth);

ncquiet;

if nargin<4 | isempty(deps)
   deps = csl_dep(1:56);
end
if nargin<5; doy = []; end
if length(doy)==1 & prod(size(lon))>1
   doy = repmat(doy,size(lon));
end
if nargin<6 | isempty(var)
   var = 1;
end
if nargin<7 | isempty(fnms)
   fnms = {'cars2000'};
elseif strcmp(fnms,'best')
   fnms = {'coast8','cars2000'};
elseif ~iscell(fnms)
   fnms = {fnms};
end
if nargin<8 | isempty(woa); woa = 0; end
if nargin<9 | isempty(fll); fll = 0; end
if nargin<10; fpth = []; end


vv = interp3_clim(fpth,fnms{1},fll,prop,var,deps,lon,lat,doy);
for ii = 2:length(fnms)
   if ~any(isnan(vv(:)))
      need = 0;
%   elseif strcmp(fnms(ii),'cars2000') & max(lon)<100
%      % Use this if split Indian from EEZ CARS
%      need = 0;
   else
      vin = vv;
      vv = interp3_clim(fpth,fnms{ii},fll,prop,var,deps,lon,lat,doy,vin);
   end
end


if woa & any(isnan(vv))
   % Only look for WOA values outside the CARS EEZ region
   kk = find((lat>0 | lon>200 | lon<100) & any(isnan(vv),dims(vv)));
   if ~isempty(kk)
      wdep = dep_std(deps);
      iw = find(wdep==round(wdep));
      if length(iw)~=length(deps)
	 nwdep = deps;
	 nwdep(iw) = [];
	 disp('The following depths are not available in WOA98 (is it mapped on');
	 disp(['a smaller set on depth levels: ' num2str(nwdep)]);
      end
      if ~isempty(iw)
	 disp([num2str(length(kk)) ' profiles used WOA98']);
	 if isempty(doy)	    
	    tmp = get_woa_profiles(prop,lon(kk),lat(kk),wdep(iw));
	 else
	    tmp = get_woa_profiles(prop,lon(kk),lat(kk),wdep(iw),doy(kk));
	 end
	 if dims(vv)==2
	    vv(kk,iw) = tmp';
	 else
	    for jj = 1:length(iw)
	       tmp2 = vv(:,:,iw(jj));
	       tmp2(kk) = tmp(jj,:);
	       vv(:,:,iw(jj)) = tmp2;
	    end
	 end
      end
   end
end

%------------- End of get_clim -------------------------
