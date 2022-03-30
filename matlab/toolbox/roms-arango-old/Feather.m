function [h,Smax]=Feather(X,U,V,Xstr,Xend,Ymax,Smax,scale,linespec);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright (c) 2000 Rutgers University.                                    %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                           %
% function [h,Smax]=Feather(X,U,V,Xstr,Xend,Ymax,Smax,scale,linespec)       %
%                                                                           %
% This function plots a feather vector diagram: vectors emanating from a    %
% straight line parallel to the x-axis.                                     %  
%                                                                           %
% On Input:                                                                 %
%                                                                           %
%    X         X-axis coordinate, usually time.                             %
%    U         U-vector component.                                          %
%    V         V-vector component.                                          %
%    Xstr      Starting X-axis value.                                       %
%    Xend      Ending X-axis value.                                         %
%    Ymax      Maximum Y-axis range.                                        %
%    Smax      Maximum speed.  Set to the appropriate value for overlays,   %
%              otherwise set Smax=0 to found it value internally.           %
%    scale     vector scaling factor.                                       %
%    linespec  Line specifications: color, marker (see plot).               %
%                                                                           %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

alpha=0.33;    % Size of arrow head relative to the length of the vector
beta =0.33;    % Width of the base of the arrow head relative to the length

Y=zeros(size(X));

%----------------------------------------------------------------------------
% Determine vector scale.
%----------------------------------------------------------------------------

if (scale),

 if min(size(X))==1,
   n=sqrt(prod(size(X)));
   m=n;
 else,
   [m,n]=size(X);
 end,
 
 if (~Smax),
   delx=diff([min(X(:)) max(X(:))])/n;
   dely=diff([min(Y(:)) max(Y(:))])/m;
   len=sqrt((U.^2 + V.^2)/(delx.^2 + dely.^2));
   Smax=max(len(:));
 end,

 scale=scale*0.9/Smax;
 u=U*scale;
 v=V*scale;

 Yscale=Ymax*scale;

else,

 Yscale=Ymax;

end,

%----------------------------------------------------------------------------
%  Make vector arrows.
%----------------------------------------------------------------------------

x=X(:).';
y=Y(:).';
u=u(:).';
v=v(:).';

uu=[x; x+u; repmat(NaN,size(u))];
vv=[y; y+v; repmat(NaN,size(u))];

hu=[x+u-alpha*(u+beta*(v+eps)); x+u; ...
    x+u-alpha*(u-beta*(v+eps)); repmat(NaN,size(u))];
hv=[y+v-alpha*(v-beta*(u+eps)); y+v; ...
    y+v-alpha*(v+beta*(u+eps)); repmat(NaN,size(u))];

%----------------------------------------------------------------------------
%  Plot vectors.
%----------------------------------------------------------------------------

h=plot(uu,vv,linespec,hu,hv,linespec,[Xstr Xend],[0 0],'k');
axis equal;
set(gca,'Xlim',[Xstr Xend],'Ylim',[-Yscale Yscale],...
    'Xtick',[Xstr:1:Xend],'Xticklabel',[Xstr:1:Xend],...
    'Ytick',[-Yscale 0 Yscale],'Yticklabel',[-Ymax 0 Ymax]);
set(h,'Clipping','off');

return


