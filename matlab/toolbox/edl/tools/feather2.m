function [h,vmax]=feather2(x,u,v,ymax,vmax,scale,linespec);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright (c) 1998 Rutgers University.                                    %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                           %
% function [h,vmax]=feather2(x,u,v,ymax,vmax,scale,linespec)                %
%                                                                           %
% This function plots a feather vector diagram: vectors emanating from a    %
% straight line parallel to the x-axis.                                     %  
%                                                                           %
% On Input:                                                                 %
%                                                                           %
%    x         X-axis coordinate, usually time.                             %
%    u         U-vector component.                                          %
%    v         V-vector component.                                          %
%    ymax      Maximum y-axis range.                                        %
%    vmax      Maximum speed.  Set to the appropriate value for overlays,   %
%              otherwise set vmax=0 to found it value internally.           %
%    scale     vector scaling factor.                                       %
%    linespec  Line specifications: color, marker (see plot).               %
%                                                                           %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

alpha=0.33;    % Size of arrow head relative to the length of the vector
beta =0.33;    % Width of the base of the arrow head relative to the length

x0=0;
x1=10;
x2=20;
x3=30;

y=zeros(size(x));

%----------------------------------------------------------------------------
% Determine vector scale.
%----------------------------------------------------------------------------

if (scale),

 if min(size(x))==1,
   n=sqrt(prod(size(x)));
   m=n;
 else,
   [m,n]=size(x);
 end,
 
 if (~vmax),
   delx=diff([min(x(:)) max(x(:))])/n;
   dely=diff([min(y(:)) max(y(:))])/m;
   len=sqrt((u.^2 + v.^2)/(delx.^2 + dely.^2));
   vmax=max(len(:));
 end,

 scale=scale*0.9/vmax;
 u=u*scale;
 v=v*scale;

 yscale=ymax*scale;

else,

 yscale=ymax;

end,

%----------------------------------------------------------------------------
%  Make vector arrows.
%----------------------------------------------------------------------------

x=x(:).';
y=y(:).';
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

ax=newplot;
next=lower(get(ax,'NextPlot'));
hold_state=ishold;

Xsub1=find((x >= x0) & (x <= x1));
Xsub2=find((x >= x1) & (x <= x2));
Xsub3=find((x >= x2) & (x <= x3));

h.s1=subplot(3,1,1);
h.h1=plot(uu(:,Xsub1),vv(:,Xsub1),linespec,...
          hu(:,Xsub1),hv(:,Xsub1),linespec,...
          [x0 x1],[0 0],'k');
axis equal;
set(gca,'Xlim',[x0 x1],'Ylim',[-yscale yscale],...
    'Xtick',[1:1:x1],'Xticklabel',[1:1:x1],...
    'Ytick',[-yscale 0 yscale],'Yticklabel',[-ymax 0 ymax]);
set(h.h1,'Clipping','off');
ylabel('m/s');
grid on;

h.s2=subplot(3,1,2);
h.h2=plot(uu(:,Xsub2),vv(:,Xsub2),linespec,...
          hu(:,Xsub2),hv(:,Xsub2),linespec,...
          [x1 x2],[0 0],'k');
axis equal;
set(gca,'Xlim',[x1 x2],'Ylim',[-yscale yscale],...
    'Xtick',[x1:1:x2],'Xticklabel',[x1:1:x2],...
    'Ytick',[-yscale 0 yscale],'Yticklabel',[-ymax 0 ymax]);
set(h.h2,'Clipping','off');
ylabel('m/s');
grid on;

h.s2=subplot(3,1,3);
h.h3=plot(uu(:,Xsub3),vv(:,Xsub3),linespec,...
          hu(:,Xsub3),hv(:,Xsub3),linespec,...
          [x2 x3],[0 0],'k');
axis equal;
set(gca,'Xlim',[x2 x3],'Ylim',[-yscale yscale],...
    'Xtick',[x2:1:x3],'Xticklabel',[x2:1:x3],...
    'Ytick',[-yscale 0 yscale],'Yticklabel',[-ymax 0 ymax]);
set(h.h3,'Clipping','off');
ylabel('m/s');
grid on;

return


