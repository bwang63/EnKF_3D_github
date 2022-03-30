 function h=fill_cst(cstlon,cstlat,color);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright (c) 1996 Rutgers University.                                    %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                           %
% function h=fill_cst(cstlon,cstlat,color)                                  %
%                                                                           %
% This function fills the coastlines within the box defined by the          %
% plotting object.  It assumes that the "User" opened and read the          %
% appropriate  coastline file  and that lines outside the plotting          %
% box are clipped.                                                          %
%                                                                           %
% On Input:                                                                 %
%                                                                           %
%    cstlon       longitude of the points (real vector; degree_east).       %
%    cstlat       latitude of the points (real vector; degree_north).       %
%    color        coastline color (character; Matlab's color syntax).       %
%                                                                           %
% WARNING:  In general, this routine does NOT work unless you cook the      %
%           coastline file.                                                 %
%                                                                           %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Find the number and starting point for coastal segments.

spval=999.0;
[icst]=find(cstlon==spval);
npts=max(size(icst)-1);

% Plot coastal segments

for n=1:npts
  is=icst(n)+1;
  ie=icst(n+1)-1;
  if (is~=ie)
    fill(cstlon(is:ie),cstlat(is:ie),color);
  end
end

return
