% GET_ALL_CSL  Get CSIRO-standard-level hydro & CTD data
%     
% INPUT:  
%  src    [w e s n] limits of region of required data
%      OR defining polygon [x1 y1; x2 y2; x3 y3; ... ] 
%  hvar   vector of one or more cast header info codes:
%         1)CPN   2)time   3)castflag  4)bot_depth   5)country   6)cruise
%         7)pos_stat   8)OCL
%  var    vector of property codes:  
%         ** WOD98 vars must all belong to the same file prefix, eg 
%            [1 2 3 9] is ok (all from 'ts_' files), but [2 10] is not **
%         1)t   2)s  3)02   4)Si  5)PO4   6)NO3   7)gamma  8)tflag
%         9)sflag   10)oflag   11)siflag   12)pflag   13)nflag  14)no4
%         15)nh3
%  suf    vector of suffix codes:
%         1)ctd  2)ctd2  3)bot  4)bot2  5)xbt  6)xbt  7)CSIRO(CTD&Hyd)
%         9)NIWA
%  deps    Vector of indices of CSL depth levels to extract (not nec contiguous)
%          [use round(dep_csl(depths)) to convert from +ve metres to indices]
%  scr     0 => disable pre-flagged bad-cast and bad-individual-data screening
%
% OUTPUT:
%  v1 etc  [ncast ndep] for property vars, [ncast] for header vars
%
% NOTE:  For each cast-row there will be at least some data in at least one
%   of the returned variables. Empty depth columns will only occur if there
%   is deeper good data.
%
% USAGE: [lat,lon,v1,v2,..] = get_all_csl(src,hvar,vars,suf,deps,scr)

% $Id: get_all_csl.m,v 1.2 2000/04/04 07:12:22 dunn Exp dunn $
% Author: Jeff Dunn  CSIRO Marine Research Dec 1999
% Devolved from get_all_obs.m

function [lat,lon,varargout] = get_all_csl(src,hvar,vars,suf,deps,scr)

if nargin<5
   disp('  GET_ALL_CSL  requires 5 or 6 input arguments')
   help get_all_csl
   disp('  NOTE: ');
   disp('Can only extract data from one prefix-type of WOD98 files at a time.');
   disp('PREFIX   SUFFIX      VARS');
   disp(' ts     bot  ctd     t   s  gamma  tflag  sflag');
   disp(' o2     bot  ctd     o2  gamma  o2_flag');
   disp(' no3    bot          no3 gamma  no3_flag');
   disp(' po4    bot          po4 gamma  po4_flag');
   disp(' si     bot          si  gamma  si_flag');
   disp(' t      xbt          t   t_flag');
   disp(' Note: suffix bot implies bot and bot2, likewise for ctd & xbt');
   return
end

if nargin<6 | isempty(scr)
   scr = 1;
end   

nhv = length(hvar);
nvar = length(vars);
iv = nhv+(1:nvar);

lat = []; lon = [];
varargout{nhv+nvar} = [];

ii = find(suf<=6);
wsuf = suf(ii);
suf(ii) = [];

if ~isempty(wsuf)
   [lat,lon,vout] = getwodcsl(src,hvar,vars,wsuf,deps,scr);
   if ~isempty(lat)
      varargout = vout;
   end
end



for isuf = suf
   if isuf==7
      [la,lo,vout] = getCSIROcsl(src,hvar,vars,deps,scr);
   elseif isuf==9
      [la,lo,vout] = get_niwa(src,hvar,vars,deps,scr);
   end

   if ~isempty(la) & nvar>0
      % Get rid of profiles with no data in any var in the required depth range

      [ncst,ndep] = size(vout{iv(1)});
      some = zeros(1,ncst);
      for ii = iv
	 if ndep==1
	    some = (some | ~isnan(vout{ii}'));
	 else
	    some = (some | any(~isnan(vout{ii}')));
	 end
      end
      rr = find(~some);
      if ~isempty(rr)
	 la(rr) = [];
	 lo(rr) = [];
	 for jj = 1:nhv
	    vout{jj}(rr) = [];
	 end
	 for jj = iv
	    vout{jj}(rr,:) = [];
	 end	    
      end

      % Get rid of depths below the last data in any cast in any var.

      some = zeros(nvar,ndep);
      for ii = iv
	 some(ii,:) = any(~isnan(vout{ii}));
      end
      ldp = max(find(any(some)));
      if ldp < ndep
	 for jj = iv
	    vout{jj}(:,(ldp+1):ndep) = [];
	 end	    
      end

      % Create padding so that can append new to existing data, even if have
      % different number of depths
      
      [ncst,ndep] = size(vout{iv(1)});
      [mcst,mdep] = size(varargout{iv(1)});
      
      if ndep>mdep
	 mpad = repmat(nan,mcst,ndep-mdep);
	 npad = [];
      elseif ndep<mdep
	 mpad = [];
	 npad = repmat(nan,ncst,mdep-ndep);
      else
	 mpad = [];
	 npad = [];
      end

      for ii = iv
	 varargout{ii} = [[varargout{ii} mpad]; [vout{ii} npad]];
      end
   end
      
   if ~isempty(la)
      lat = [lat; la];
      lon = [lon; lo];   
      for jj = 1:nhv
	 varargout{jj} = [varargout{jj}; vout{jj}];
      end
   end
end

return

%------------------------------------------------------------------------
% GET_NIWA  Get NIWA CSL CTD data from .mat file

function [la,lo,vaout] = get_niwa(src,hvar,vars,deps,scr)

la = [];
lo = [];
nhv = length(hvar);
nv = length(vars);
for ii = 1:(nhv+nv)
   vaout{ii} = [];
end

if ~any(vars<=4) & ~any(hvar<=4)
   return
end

% Calc and restrict stdep as only 57 levels in NIWA file.

deps = deps(find(deps<=57));

load /home/eez_data/hydro/niwa_csl

mm = 1:length(lon);

% If screening, remove indices to flagged casts
if scr
   rr = find(cflag~=0);
   if ~isempty(rr)
      mm(rr) = [];
   end
end
   
if min(size(src))==1
   ii = mm(find(lon(mm)>=src(1) & lon(mm)<=src(2) & lat(mm)>=src(3) & lat(mm)<=src(4)));
else
   ii = mm(find(isinpoly(lon(mm),lat(mm),src(:,1),src(:,2))));
end

if ~isempty(ii)
   la = lat(ii);
   lo = lon(ii);

   for jj = 1:nhv
      switch hvar(jj)
       case 1
	  vaout{jj} = prid(ii);
       case 2
	  vaout{jj} = time(ii);
       case 3
	  vaout{jj} = cflag(ii);
       case 4
	  vaout{jj} = botdepth(ii);
       otherwise
	  vaout{jj} = repmat(nan,size(prid(ii)));
      end
   end
	
   for jj = 1:nv
      switch vars(jj)
       case 1
	  vaout{nhv+jj} = t(ii,deps);
       case 2
	  vaout{nhv+jj} = s(ii,deps);
       case 3
	  vaout{nhv+jj} = o2(ii,deps);
       case 7
	  vaout{nhv+jj} = nutdens(ii,deps);
       otherwise
	  vaout{nhv+jj} = repmat(nan,[length(ii) length(deps)]);      
      end
   end
end

return


%---------------------------------------------------------------------------
