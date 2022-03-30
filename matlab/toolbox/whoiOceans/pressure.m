function P80=pressure(DPTH,XLAT);
% PRESSURE Computes pressure given the depth at some latitude
%          P=PRESSURE(D,LAT) gives the pressure P (dbars) at a depth D (m)
%          at some latitude LAT (degrees).
%
%          This probably works best in mid-latitude oceans, if anywhere!
%
%          Ref: Saunders, "Practical Conversion of Pressure to Depth",
%              J. Phys. Oceanog., April 1981.
% 

%         I copied this directly from the UNESCO algorithms.


% CHECK VALUE: P80=7500.004 DBARS;FOR LAT=30 DEG., DEPTH=7321.45 METERS

      PLAT=abs(XLAT*pi/180.);
      D=sin(PLAT);
      C1=5.92E-3+(D.*D)*5.25E-3;
      P80=((1-C1)-sqrt(((1-C1).^2)-(8.84E-6*DPTH)))/4.42E-6;
