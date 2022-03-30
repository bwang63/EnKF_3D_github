 function [h]=draw_cst(xcst,ycst,color);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright (c) 1996 Rutgers University.                                    %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                           %
% function [h]=draw_cst(xcst,ycst,color)                                    %
%                                                                           %
% This function  draws the coastlines within the box defined by             %
% the plotting object. It assumes that the User opened and read             %
% the  appropriate  coastline file  and  that lines outside the             %
% plotting box are clipped.                                                 %
%                                                                           %
% On Input:                                                                 %
%                                                                           %
%    xcst         Coastline X-positions (real vector).                      %
%    ycst         Coastline Y-positions (real vector).                      %
%    color        line color (character; Matlab's color syntax).            %
%                                                                           %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%  Find the number and starting point for coastal segments.

[icst]=find(isnan(ycst));
npts=max(size(icst)-1);

%  Plot coastal segments.

for n=1:npts,
  is=icst(n)+1;
  ie=icst(n+1)-1;
  if (ie > is+2)
    h=plot(xcst(is:ie),ycst(is:ie),color);
  end,
end,

return
