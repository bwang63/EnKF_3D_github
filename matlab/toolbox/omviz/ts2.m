function [w,jd,z]=ts2(cdf,var,ista,zuser);
% TS Reads a scalar variable at a particular station from TSEPIC.CDF files.
% Returns data from all sigma layers, or intepolates to specified depths.
%
% USAGE:
%   1.  [u,jd,z]=ts(cdf,var,sta);  to return a matrix containing time,depth
%                                 information for variable "var" at station
%                                 sta for all sigma levels.
%
%   2.  [u,jd]=ts(cdf,var,sta,depths);
%                                 to return a matrix containing time,depth
%                                 information for variable "var" at station
%                                 sta for depths specified in vector "depths".
%
%       Example: [t,jd]=ts('tsepic.cdf','temp',2,[-2 -10 -24]);
%              Returns a matrix containing temperature at Station 2 at
%              2, 10 and 24 m below surface.  jd is the julian day vector.
%   if depths are positive, assume that they are heights above bottom
%
%   z are the *water depths*, elevation not included

% use Chuck's tookit
nc=netcdf(cdf);

% valid station?
nsta=length(nc{'stations'}(:));
if(ista>nsta),
  disp('invalid station');
  return
end

% determine if the variable is in the center of the sigma layer or
% at the top

switch var
 case {'u','v','salt','temp','conc','am'}
   vloc='center';
 case {'w','kh','km'}
   vloc='top';
 otherwise
   disp(['Error: Unknown variable ' var ': please modify TS.M!']);
   return
end

% get all the data at station ista
uz=nc{var}(:,:,:,ista);
[m,n]=size(uz);
% find out the vertical coordinate (depth + elevation)

sigma=nc{'sigma'}(:);

sigma2=sigma(1:n-1)+0.5*diff(sigma);

% add on the bottom, so that interpolations between the bottom grid
% cell center and the bottom can be made
sigma2(n)=-1;

base_date=zeros(1,6);
t=nc{'time'}(:);
base_date(1:3)=nc.base_date(:);
jd0=julian(base_date);
jd=jd0+t/(3600*24);

depth=nc{'depth'}(ista);
elev=nc{'elev'}(:,:,:,ista);
close(nc)
tdepth=depth+elev;
switch vloc
 case 'top'
   zlevt=tdepth*sigma';    % total depth including surface 
 case 'center'
   zlevt=tdepth*sigma2';    % total depth including surface 
end
%   want length(sigma) rows 

uz=uz.';
zlevt=zlevt.';
  
% Assign bottom half of bottom grid cell the same
% value as at the grid cell center.
uz(n,:)=uz(n-1,:);

for k=1:length(zuser);
   % zlev(k) negative denotes distance below surface
   % zlev(k) positive denotes distance above bottom
     if(zuser(k)<0),
       zlev=zlevt;
     else
       zlev=zlevt-ones(n,1)*zlevt(n,:);
     end
     zind=zlev < zuser(k);
    % find the indices IK of the cells that are just above the required level
    dz=diff(zind);
    dz(n,:)=zeros(size(dz(n-1,:)));
    ik=find(dz==1);

% find the indices ISUM where the requested depth is between two data values
    isum=find(sum(dz));
    u=zeros(m,1);
% do linear interpolation
   u(isum)=uz(ik)+(uz(ik+1)-uz(ik)).*(zuser(k)-zlev(ik))./(zlev(ik+1)-zlev(ik));

% find requested values that are above top data value but below surface
   if(zuser(k)<0),
    iabove=find(zlev(1,:) < zuser(k) & zuser(k) < elev(:)');
    itoohigh=find(zuser(k) > elev(:)');
   else
    iabove=find(zlev(1,:) < zuser(k) & zuser(k) < tdepth(:)');
    itoohigh=find(zuser(k) > tdepth(:)');
   end
% assign top data value to requested values above it
   u(iabove)=uz(1,iabove);

% find requested values that are above the free surface & mask 'em
   u(itoohigh)=uz(1,itoohigh)*nan;

   w(:,k)=u(:);

end
