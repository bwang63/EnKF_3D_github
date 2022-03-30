% getCSIRO:  Extract CSIRO standard level CTD data (from csiro_ctd.nc) 
%
% ***   WARNING  -  Some of this data is subject to embargo  ***
%
% INPUTS
%  lim     [w e s n] define geographic extent (eg: [100 130 -40 -10])
%         OR  [x1 y1;x2 y2;x3 y3; ... ] vertices of polygon of required data
%  v1      Variable name string: 't' 's' 'neut_density' etc..
%  deps    [upper lower] limits of standard levels to extract (eg [1 33])
%  v2      [optional] name of second variable to extract at the same depths
%  v3      [optional] name of third variable to extract at the same depths
%  v4      [optional] name of 4th variable to extract at the same depths
%  v5      [optional] name of 5th variable to extract at the same depths
% OUTPUTS
%  la      Latitude of extracted casts
%  lo      Longitude "    "       "
%  tim     Time, days since 1900, "
%  d1      [ncast X ndeps] First variable
%  prid    Profile ID comprised of: vCCCCsss v=vessel CCCC=cruise sss=station
%  d2      [ncast X ndeps] Second variable, if requested
%  d3      [ncast X ndeps] Third variable, if requested
%  d4      [ncast X ndeps] 4th variable, if requested
%  d5      [ncast X ndeps] 5th variable, if requested
%
% USAGE
%  [la,lo,tim,d1,prid,{d2,d3,d4,d5}]=getCSIRO(lim,v1,deps{,v2,v3,v4,v5});

%  Jeff Dunn  Feb 1998

function [la,lo,tim,d1,prid,d2,d3,d4,d5]=getCSIRO(lim,v1,deps,v2,v3,v4,v5)

fname = '/home/eez_data/hydro/csiro_ctd';

if max(size(deps))==1
  deps = [deps deps];
end

la = getnc(fname,'lat');
lo = getnc(fname,'lon');
tim = getnc(fname,'time');
csflg = getnc(fname,'csiro_flag');

d1 = getnc(fname,v1,[-1 deps(1)],[1 deps(2)]);
if nargin > 3
 d2 = getnc(fname,v2,[-1 deps(1)],[1 deps(2)]);
 if nargin > 4
   d3 = getnc(fname,v3,[-1 deps(1)],[1 deps(2)]);
   if nargin > 5
     d4 = getnc(fname,v4,[-1 deps(1)],[1 deps(2)]);
     if nargin > 6
       d5 = getnc(fname,v5,[-1 deps(1)],[1 deps(2)]);
     end
   end
 end
end

prid = getnc(fname,'profilid');

% If ncast=1 getnc will transpose the output. This is of course not a problem
% if ndep=1, but should be corrected in other cases, which are detected by
% a difference between dim(2) and ndep.

ndep = 1+deps(2)-deps(1);
if size(d1,2) ~= ndep
  d1 = d1';
  if nargin > 3
    d2 = d2';
    if nargin > 4
      d3 = d3';
      if nargin > 5
	d4 = d4';
	if nargin > 6
	  d5 = d5';
	end
      end
    end
  end
end


% If required and can be easily added in (ie no other data requested) then
% get supplementary nitrate data.

if nargin==3 & strcmp(v1,'no3')
  tmp = getnc('/home/eez_data/hydro/csiro_no3','lat'); 
  la = [la(:); tmp(:)];
  tmp = getnc('/home/eez_data/hydro/csiro_no3','lon');
  lo = [lo(:); tmp(:)];
  tmp = getnc('/home/eez_data/hydro/csiro_no3','time');
  tim = [tim(:); tmp(:)];
  tmp = getnc('/home/eez_data/hydro/csiro_no3','profilid');
  prid = [prid(:); tmp(:)];
  tmp = getnc('/home/eez_data/hydro/csiro_no3','csiro_flag');
  csflg = [csflg(:); tmp(:)];
  tmp = getnc('/home/eez_data/hydro/csiro_no3','no3',[-1 deps(1)],[1 deps(2)]);
  if size(tmp,2) ~= ndep
    d1 = [d1; tmp'];
  else
    d1 = [d1; tmp];
  end
end


if min(size(lim))==1
   rej = find(lo<lim(1) | lo>lim(2) | la<lim(3) | la>lim(4) | isnan(lo) ...
	      | isnan(la) | csflg>0);
else
   rej = find(~isinpoly(lo,la,lim(:,1),lim(:,2)) | isnan(lo) ...
	      | isnan(la) | csflg>0);
end
if ~isempty(rej)
  la(rej) = [];
  lo(rej) = [];
  tim(rej) = [];
  d1(rej,:) = [];
  prid(rej) = [];
  if nargin > 3
    d2(rej,:) = [];
    if nargin > 4
      d3(rej,:) = [];
      if nargin > 5
	d4(rej,:) = [];
	if nargin > 6
	  d5(rej,:) = [];
	end
      end
    end
  end
end


%----------------- End of getCSIRO.m -------------------------------
