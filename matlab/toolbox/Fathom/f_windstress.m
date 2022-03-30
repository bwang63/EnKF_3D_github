function tau = f_windstress(mag,z);
% - calculates wind stress in dynes per cm^2
%
% Usage: tau = f_windstress(mag,z);
%
% mag = magnitude of wind velocity (m/s)
% z   = height above sea surface of wind sensor

% by Dave Jones<djones@rsmas.miami.edu>, Sep-2001
% http://www.rsmas.miami.edu/personal/djones/
% ----------------- DISCLAIMER: -------------------
% This code is provided as is, with no guarantees
% and is only intended for non-commercial use.
% --------------------------------------------------

% -----References:-----
% Kourafalou, V. H., T. N. Lee, and L.-Y. Oey. 1996. The fate of river discharge
% on the continental shelf 2. Transport of coastel low-salinity waters under
% realistic wind and tidal forcing. J. Geophys. Res. 101: 3435-3455.
%
% Lee, T. N. and E. Williams. 1999. Mean distribution and seasonal variability
% of coastal currents and temperature in the Florida Keys with implications
% for larval recruitment. Bulletin of Marine Science 64: 35-56.


Pa = 1.22;      % density of air in kg/m^2
Cd = 0.0015;    % drag coefficient

mag_10 = mag .* (10/z)^0.1;      % calculate wind speed at standard 10 m height
tau    = (Pa*Cd) .* (mag_10).^2; % tau in N/m^2
tau    = tau .* 10;              % convert to dynes/cm^2

% -----Conversion Notes:-----
% Newtons to dynes multiply by 1E+05
% m^2 to cm^2 multiply by 1E+04