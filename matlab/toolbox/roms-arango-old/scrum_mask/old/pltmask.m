function h=pltmask(mask,xgrd,ygrd,spherical,xcst,ycst,msktitle);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright (c) 1996 Rutgers University.                                    %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                           %
% function h=pltmask(mask,xgrd,ygrd,spherical,xcst,ycst,msktitle)           %
%                                                                           %
% This function plots the land/sea mask. If appropriate, It also ovelays    %
% the given coastline data.                                                 %
%                                                                           %
% On Input:                                                                 %
%                                                                           %
%    mask       Land/Sea mask (real matrix):                                %
%                 mask=0, land.                                             %
%                 mask=1, Sea.                                              %
%    xgrd       X-location of mask (real matrix).                           %
%    ygrd       Y-location of mask (real matrix).                           %
%    spherical  grid type switch (character):                               %
%                 spherical=T, spherical grid set-up.                       %
%                 spherical=F, Cartesian grid set-up.                       %
%    xcst       X-location of Coastlines (real vector).                     %
%    ycst       Y-location of Coastlines (real vector).                     %
%    msktitle   title of figure (character string).                         %
%                                                                           %
% Calls:    draw_cst                                                        %
%                                                                           %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Set indices for land and water points.

iland=find(mask==0);
isea=find(mask>0);

% Find grid range values.

xmin=min(min(xgrd));
xmax=max(max(xgrd));
ymin=min(min(ygrd));
ymax=max(max(ygrd));

% Convert grid matrices to a single column vector.

x=reshape(xgrd,prod(size(xgrd)),1);
y=reshape(ygrd,prod(size(ygrd)),1);

% Plot mask.

clf
plot(x(iland),y(iland),'ro',x(isea),y(isea),'co');
hold on;
axis([xmin xmax ymin ymax]);
grid;
title(msktitle);

% If appropriate, draw coastline in blue color.

if (~isempty(xcst) & (spherical == 'T' | spherical == 't')),
  draw_cst(xcst,ycst,'b');
end

return

