function [orbtyp]=typeorb(ascendingnode,aW,aE,dW,dE)

% typeorb
% determines the type of orbit:
%   orbtyp = 0       orbit misses the area
%   orbtyp = 1       orbit passes over the area on ascent.
%   orbtyp = 2       orbit passes over the area on descent.
%   orbtyp = 3       orbit passes over the area on both ascent and descent.
%
% and returns the orbit type.

orbtyp=0;

if ascendingnode<aW
   while ascendingnode<aW
     ascendingnode=ascendingnode + 360;
   end
elseif ascendingnode>aE
   while ascendingnode>aE
      ascendingnode=ascendingnode - 360;
   end
end
   
if aW<=ascendingnode & ascendingnode<=aE
   orbtyp=orbtyp + 1;
end

if ascendingnode<dW
   while ascendingnode<dW
     ascendingnode=ascendingnode + 360;
   end
elseif ascendingnode>dE
   while ascendingnode>dE
      ascendingnode=ascendingnode - 360;
   end
end
   
if dW<=ascendingnode & ascendingnode<=dE
   orbtyp=orbtyp + 2;
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% check longitude of the ascending node against all ranges:
% and determine the orbit type.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  initial version written by Paul Hemenway
%  Copyright 2000 by the University of Rhode Island
%  see the acompanying detailed copyright notice
%  >>help dodsqscopyright
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

