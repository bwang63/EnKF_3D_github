function [h]=pltmask(mask,x,y,spherical,xcst,ycst,msktitle);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright (c) 2001 Rutgers University.                                    %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                           %
% function h=pltmask(mask,x,y,spherical,xcst,ycst,msktitle)                 %
%                                                                           %
% This function plots the land/sea mask. If appropriate, It also ovelays    %
% the given coastline data.                                                 %
%                                                                           %
% On Input:                                                                 %
%                                                                           %
%    mask       Land/Sea mask (real matrix):                                %
%                 mask=0, land.                                             %
%                 mask=1, Sea.                                              %
%    x          X-location of mask (real matrix).                           %
%    y          Y-location of mask (real matrix).                           %
%    spherical  grid type switch (logical):                                 %
%                 spherical=1, spherical grid set-up.                       %
%                 spherical=0, Cartesian grid set-up.                       %
%    xcst       X-location of Coastlines (real vector).                     %
%    ycst       Y-location of Coastlines (real vector).                     %
%    msktitle   title of figure (character string).                         %
%                                                                           %
% Calls:    draw_cst                                                        %
%                                                                           %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Find grid range values.

xmin=min(min(x));
xmax=max(max(x));
ymin=min(min(y));
ymax=max(max(y));

% Plot mask.

clf
colormap([1 0 0; 0 1 1]);
h=surface(x,y,mask,mask); shading flat;
axis([xmin xmax ymin ymax]);
hold on;
title(msktitle);

% If appropriate, draw coastline in blue color.

if (~isempty(xcst) & spherical),
  hcst=draw_cst(xcst,ycst,'b');
end

return

