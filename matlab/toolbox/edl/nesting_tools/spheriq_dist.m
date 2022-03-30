function dist=spheriq_dist(lon1,lat1,lon2,lat2)
%
% determine the distance on the earth between 2 point
%
earthradius=6356750.52;
deg2rad=pi/180; 
rad2deg=180/pi;
%
%  Determine proper longitudinal shift.
%
delta=lon2-lon1; 
l=abs(delta);
l(l>=180)=360-l(l>=180);
%
%  Convert Decimal degrees to radians.
%
beta1 = lat1*deg2rad;
beta2 = lat2*deg2rad;
l = l*deg2rad;
%
%  Calculate S/Bo subformulas.
%
st = sqrt(((sin(l).*cos(beta2)).^2)+(((sin(beta2).*cos(beta1))...
          -(sin(beta1).*cos(beta2).*cos(l))).^2));
%
%       Calculate distance from point 1 to point 2
%
dist = asin(st) * earthradius;








