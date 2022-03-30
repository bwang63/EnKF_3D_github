function [srad1,srad2]=srflux(JulDay,lat,Tdew,RelHum);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright (c) 1998 Rutgers University.                                    %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                           %
% function [srad1,srad2]=srflux(JulDay,lat,Tdew,RelHum)                     %
%                                                                           %
% This function estimate incoming solar shortwave radiation (W/m2).         %
%                                                                           %
% On Input:                                                                 %
%                                                                           %
%    JulDay      Julian day.                                                %
%    lat         latitude (degrees).                                        %
%    Tdew        Dew-point temperatuere (Celsius).                          %
%    RelHum      Relative humidity (kg/kg).                                 %
%                                                                           %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

deg2rad=pi/180.0;
rad2deg=180.0/pi;

% Convert Julian day to Gregorian day and extract and year day and hours.

Date=caldate(JulDay);

hour=Date.hour;
yday=Date.yday;

LatRad=lat.*deg2rad;

%----------------------------------------------------------------------------
%  Scott's formulation
%----------------------------------------------------------------------------

% Estimate solar declination angle (radians).

Dangle=23.44*cos((172.0-yday).*pi./180.0);
Dangle=Dangle.*deg2rad;

% Compute hour angle (radians).

Hangle=(12.0-hour+4).*pi./12.0;

% Estimate variation in optical thickness of the atmosphere over
% the course of a day.

surfSR=max(0.0,1000.0.*cos(Hangle));

% Compute shortwave radiation flux.  Notice that flux is scaled
% from W/m2 to degC m/s by dividing by (rho0*Cp).

zenith=acos(sin(LatRad).*sin(Dangle)+ ...
            sin(LatRad).*sin(Dangle).*cos(Hangle)).*rad2deg;
zenith=min(90.0,zenith);

albedo=0.03+0.97.*exp(-0.12.*(90.0-zenith));

srad1=(1.0-albedo).*surfSR;

%----------------------------------------------------------------------------
%  Zillman (1972) formulation.
%----------------------------------------------------------------------------

% Determine solar constant (W/m2).

Csolar=1353.0;
Csolar=800;
 
solar=Csolar.*(1.0+0.03*cos(2.0.*pi.*yday./365.25));

% Estimate vapor pressure.

%power=9.5.*Tdew/(Tdew+273.16+7.66);
%VapPre=RelHum.*(611.0.*10.^power).*1.0e-5;

power=(0.7859+0.03477.*Tdew)./(1.0+0.00412.*Tdew);
VapPre=RelHum.*(10.^power).*1.0e-5;

% Estimate solar zenith angle (degrees).

CosZth=sin(LatRad).*sin(Dangle)+ ...
       sin(LatRad).*sin(Dangle).*cos(Hangle);
zenith=acos(CosZth).*rad2deg;

% Compute shortwave radiation flux (W/m2).

srad2=(solar.*CosZth.*CosZth)./ ...
      ((CosZth+2.7).*VapPre + 1.085.*CosZth + 0.10);

return


 
 
