function han=svectors(u,v,index,rlon,rlat,rangle,flag,iplt);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright (c) 1997 Rutgers University.                                    %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                           %
% function han=svectors(u,v,index,rlon,rlat,rangle,flag,iplt)               %
%                                                                           %
% This function plots a SCRUM vector field. It rotates the vectors          %
% according with the value of "flag".                                       %
%                                                                           %
% On Input:                                                                 %
%                                                                           %
%    u           vector component in the XI-direction (matrix or array).    %
%    v           vector component in the XI-direction (matrix or array).    %
%    index       Index of the third dimension.  Set to one if not a third   %
%                dimension is available (integer).                          %
%    rlon        Longitudes at RHO-points (degrees, matrix).                %
%    rlat        Latitudes at RHO-points (degrees, matrix).                 %
%    rangle      Rotation angle at RHO-points (radiand, matrix).            %
%    flag        Rotation equation flag (integer):                          %
%                 flag = 0, no rotation is perfomed.                        %
%                 flag = 1, rotate from (lon,lat) to (XI,ETA).              %
%                 flag = 2, rotate from (XI,ETA) to (lon,lat).              %
%    iplt        Plotting coordinate flag (integer):                        %
%                 iplt = 0, (XI,ETA) plot.                                  %
%                 iplt = 1, (lon,lat) plot.                                 %
%                                                                           %
% On Output:                                                                %
%                                                                           %
%    han         Figure handle.                                             %
%                                                                           %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%  Set dimension parameters.

[Lu,Mu,N]=size(u);
[Lv,Mv,N]=size(v);
[L,M]=size(rlon);
Lm=L-1;
Lm2=Lm-1;
Mm=M-1;
Mm2=M-2;

% If not provided, set plotting coordinate flag.

if (nargin < 8),
  iplt=0;
end,

% Extract (lon,lat) at interior RHO-points.

vlon=rlon(2:Lm,2:Mm);
vlat=rlat(2:Lm,2:Mm);

% Expand rotation angle to the third dimension; and extract interior
% points

wrk=rangle(:,:,ones([1 N]));
alpha=wrk(2:Lm,2:Mm,:);
clear work

%  Average vectors to RHO-points.

if (Lu < Lv ),
  U=0.5.*(u(1:Lm2,2:Mm ,:)+u(2:Lm,2:Mm,:));
  V=0.5.*(v(2:Lm ,1:Mm2,:)+v(2:Lm,2:Mm,:));
else
  U=0.5.*(v(2:Lm ,1:Mm2,:)+v(2:Lm,2:Mm,:));
  V=0.5.*(u(1:Lm2,2:Mm ,:)+u(2:Lm,2:Mm,:));
end

%  Rotate vectors.

if (flag == 0),
  ur = U;
  vr = V;
elseif (flag == 1),
  ur =   U .* cos(alpha) + V .* sin(alpha);
  vr = - U .* sin(alpha) + V .* cos(alpha);
elseif (flag == 2),
  ur =   U .* cos(alpha) - V .* sin(alpha);
  vr =   U .* sin(alpha) + V .* cos(alpha);
end

%  Plot vector field.

if (iplt),
  han=quiver(vlon,vlat,ur(:,:,index),vr(:,:,index));
else
  han=quiver(ur(:,:,index)',vr(:,:,index)');
  set(gca,'xlim',[1 L],'ylim',[1 M]);
end,
grid;

return
  