[gdist,galpha]=geodesic_dist (lon1,lat1,lon2,lat2,flag);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright (c) 1998 Rutgers University.                                    %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                           %
% [gdist,galpha]=geodesic_dist (lon1,lat1,lon2,lat2,flag)                   %
%                                                                           %
% Inverse, non-iterative solutions for distance and geodesic azimuth        %
% between two points on the ellipsoid (The Earth) from the equations,       %
% second order in spheroidal flatttening, given by:                         %
%                                                                           %
% Sodano , E.M., and T. Robinson, 1963: Direct and inverse solutions        %
%   of geodesics, Army Map Service Technical Report No. 7, AD 657591.       %
%                                                                           %
% On Input:    Longitude is positive to the east and negative to the        %
%              west.  Latitude is positive to the north and negative        %
%              to the south.                                                %
%                                                                           %
%    lon1      Longitude point 1 (decimal degrees).                         %
%    lat1      Latitude  point 1 (decimal degrees).                         %
%    lon2      Longitude point 2 (decimal degrees).                         %
%    lat2      Latitude  point 2 (decimal degrees).                         %
%    flag      flag for distance units on output:                           %
%                flag=1  => meters                                          %
%                flag=2  => nautical miles                                  %
%                flag=3  => feet                                            %
%                flag=4  => kilometers                                      %
%                flag=5  => statute miles                                   %
%                                                                           %
% On Output:                                                                %
%                                                                           %
%    gdist     Geodesic distance between point 1 and point 2.               %
%    galpha    Geodesic azimuth from point 1 to point 2 clockwise from      %
%                North (decimal degrees).                                   %
%                                                                           %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%  Determine output distance units.

if (nargin < 5),
  flag=1;
end,

switch (flag),
  case 1
    dscale=1.0;                 % meters
  case 2  
    dscale=5.396d-4;            % nautical miles
  case 3
    dscale=3.281;               % feet
  case 4
    dscale=0.001;               % kilometers
  case 5
    dscale=6.214d-4;            % statute mile
end,

%  Define parameters on first pass (SMIN: Ellipsoid semi-minor axis in
%  meters; SMAJ: Ellipsoid semi-major axis in meters; F: spheroidal
%  flattening).

smin=6356750.52;
smaj=6378135.0;
f=1-(smin/smaj);

%  Return if zero distance.

if ((lon1 == lon2) & (lat1 == lat2)),
  gdist=0;
  galpha=0;
  return
end,

%  Determine proper longitudinal shift.

delta=lon2-lon1;
l=abs(delta);
ind=find(l <= 180);
if (~inempty(ind)),
  l(ind)=360-abs(lon1(ind)-lon2(ind));
end,

%  Convert Decimal degrees to radians.

r_lat1=lat1.*deg2rad;
r_lat2=lat2.*deg2rad;
l=l.*deg2rad;

%  Calculate S/Bo subformulas.

beta1=atan(tan(r_lat1).*(1-f));
beta2=atan(tan(r_lat2).*(1-f));
a=sin(beta1).*sin(beta2);
b=cos(beta1).*cos(beta2);
ct=a+b.*cos(l);
st=sqrt(((sin(l).*cos(beta2)).^2)+ ...
        (((sin(beta2).*cos(beta1))-(sin(beta1).*cos(beta2).*cos(l))).^2));
t=asin(st);
c=(b*sin(l))./st;
m=1-(c*c);

%  Calculate S/Bo term.

q=f+(f.*f);
z=0.5.*f.*f;
x=0.0625.*f.*f;
y=0.125.*f.*f;
w=0.25.*f.*f;

sob=((1+q).*t)+(a.*((q.*st)-(z.*(t.*t)*(1./sin(t)))))+ ...
    (m.*(((-0.5.*q).*t)-((0.5.*q).*st.*ct)+(z.*(t.*t)*(1./tan(t)))))+ ...
    ((a.*a)*(-z.*st.*ct))+ ...
    ((m.*m)*((x.*t)+(x.*st.*ct)-(z.*(t.*t)*(1./tan(t)))- ...
     (y.*st.*(ct.*ct.*ct))))+ ...
    ((a.*m).*((z.*(t.*t).*(1./sin(t)))+(z.*st.*(ct.*ct))));

gdist=dscale.*sob;

%  Compute geodesic azimuth from point 1 to point 2 clockwise from
%  North, alpha.

lambda=q.*t+a.*(-z.*st-f.*f.*t.*t./sin(t))+ ...
       m.*(-5.*w.*t + w.*st.*cos(t) + f.*f.*t.*t./tan(t));
lambda=c*lambda+l;

cott=(sin(beta2).*cos(beta1)-cos(lambda).*sin(beta1).*cos(beta2))./ ...
     (sin(lambda).*cos(beta2));

%  Initialize geodesic azimuth with NaNs.

alpha=90.0.*ones(size(lambda));
galpha=NaN.*ones(size(lambda));

ind=find((lambda) == 0 & (lat1 < lat2));
if (~isempty(ind)),
  alpha(ind)=0;
end,

ind=find((lambda) == 0 & (lat1 > lat2));
if (~isempty(ind)),
  alpha(ind)=180;
end,

ind=find(isnan(alpha));
if (~isempty(ind)),
  gdis  

      if (cott.eq.c0) then
        alpha=c90
      else
        alpha=atan(c1/cott)*rad2deg
      endif
c 
c  Compute heading from point 1 to point 2 clockwise from north.
c 
      if (delta.gt.c0) then
        if (cott.gt.c0) then
          alpha=alpha
        elseif (cott.lt.c0) then
          alpha=c180+alpha
        endif
      endif
      if (delta.lt.c0) then
        if (cott.lt.c0) then
          alpha=c180-alpha
        elseif (cott.gt.c0) then
          alpha=c360-alpha
        endif
      endif
c 
c  Calculate distance from point 1 to point 2.
c
  10  adist=sob*smin
c 
c  Check flag for proper output units.
c 
c
c  Load output variables.
c
      gdist=dist
      galpha=alpha
      return
      end
