function [w,jd,depth]=ecomts(cdf,var,i,j,zi,iind)
% ecomts extracts a velocity time series from a 4D netCDF ECOM output file.
%
%   USAGE:  [u,jd,depth]=ecomts(cdf,var,i,j,[zi],[tind]);
%
% cdf = cdf file e.g. 'ecomsi.cdf'
% (i,j) = station location in grid coordinates
%  var = variable (e.g. 'salt')
%  zi = z levels from which to extract time series 
%    If zi=nan or missing, the default is to extract data at all sigma levels
% iind= time indices 
%
% w = vector time series of "var"
% jd = time vector  (digital Julian days)
% depth = depth(s) of velocity time series (meters)
%
% examples:  To extract salinity at all levels and all time steps
%            for cell(i=30,j=47) from the file 'ecomsi.cdf': 
%
%              [w,jd,depths]=ecomts('ecomsi.cdf','salt',30,47);
%
%            To extract temperature at 5 and 25 m for time steps 1:10,
%            for cell(i=30,j=47) from the file 'ecomsi.cdf': 
%
%              [w,jd,depths]=ecomts('ecomsi.cdf','temp',30,47,[-5 -25],1:10);
%
%            To extract temperature at 5 and 25 m for all time steps
%            for cell(i=30,j=47) from the file 'ecomsi.cdf': 
%
%              [w,jd,depths]=ecomts('ecomsi.cdf','temp',30,47,nan,1:10);

% Rich Signell (rsignell@usgs.gov)

% suppress netcdf warnings
mexcdf('setopts', 0);

ncid=mexcdf('open',cdf,'nowrite');
[nam,nz]=mexcdf('diminq',ncid,'zpos');
[nam,nt]=mexcdf('diminq',ncid,'time');
if(exist('iind')==1),
  istart=min(iind)-1;
  icount=min(max(iind),nt)-istart;
else
  istart=0;
  icount=nt;
end
sigma=mexcdf('varget',ncid,'sigma',0,nz);
sigma=.5*(sigma(1:(nz-1))+sigma(2:nz));
depth=mexcdf('varget',ncid,'depth',[j-1 i-1],[1 1]);

base_date=[0 0 0 0 0 0];
base_date(1:3)=mexcdf('attget',ncid,'global','base_date');
t=mexcdf('varget',ncid,'time',istart,icount);
jd0=julian(base_date);
jd=jd0+t;

w=mexcdf('varget',ncid,var,[istart 0 j-1 i-1],[icount -1 1 1],1);
w=w.';
mexcdf('close',ncid);

depth=sigma*depth;

if(exist('zi')==1),
  if(~isnan(zi(1))),
  m=length(zi);
  if(min(zi)<min(depth)), disp('requested level below data!'),return,end
  if(max(zi)>max(depth)), disp('requested level above data!'),return,end
  for k=1:m,
    lev2=max(find(depth>zi(k)));
    lev1=lev2+1;
    frac=(zi(k)-depth(lev1))/(depth(lev2)-depth(lev1));
    wmod(:,k)=w(:,lev1)+frac*(w(:,lev2)-w(:,lev1));
  end
  w=wmod;
  depth=zi;
  end
end
