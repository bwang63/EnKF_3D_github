%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright (c) 1996 Rutgers University.                                    %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                           %
% set_mask                                                                  %
%                                                                           %
% This procedure creates/updates the  Land/Sea mask field on RHO-points.    %
% If applicable, the coastline data provided by the USER is overlayed to    %
% facilitate the masking.  It also computes the mask fields on U-, V-,      %
% PSI-points.                                                               %
%                                                                           %
% On Input:                                                                 %
%                                                                           %
%    mask       original Land/Sea mask on RHO-points (real matrix):         %
%                 mask=0, land.                                             %
%                 mask=1, Sea.                                              %
%    xrgrd      X-location of mask at RHO-points (real matrix).             %
%    yrgrd      Y-location of mask at RHO-points (real matrix).             %
%    spherical  grid type switch (character):                               %
%                 spherical=T, spherical grid set-up.                       %
%                 spherical=F, Cartesian grid set-up.                       %
%    xcst       X-location of Coastlines (real vector).                     %
%    ycst       Y-location of Coastlines (real vector).                     %
%                                                                           %
% Output:                                                                   %
%                                                                           %
%    rmask        modified Land/Sea mask on RHO-points (real matrix).       %
%    umask        Land/Sea mask on U-points (real matrix).                  %
%    vmask        Land/Sea mask on V-points (real matrix).                  %
%    pmask        Land/Sea mask on PSI-points (real matrix).                %
%                                                                           %
% Calls:                                                                    %
%                                                                           %
%    draw_cst, ijgrid, mask_uifn, put_states, uvp_masks                     %
%                                                                           %
% Adapted from a routine written by Pat J. Haley (Harvard University).      %
%                                                                           %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%----------------------------------------------------------------------------
%  Keep user waiting until ready.
%----------------------------------------------------------------------------

disp(' ');
disp('---------------------------------------------------------------------');
disp('------------------- Processing Land/Sea Mask Data -------------------');
disp('---------------------------------------------------------------------');
disp(' ');
disp('Please wait a moment...');

%----------------------------------------------------------------------------
%  Copy the data into the working array.  Find data limits.
%  Differentiate between land and sea points.  Create plot.
%----------------------------------------------------------------------------

% Find grid range values.
 
xgrdmin=min(min(xrgrd));
xgrdmax=max(max(xrgrd));
ygrdmin=min(min(yrgrd));
ygrdmax=max(max(yrgrd));

% Convert grid matrices to a single column vector.
 
x=reshape(xrgrd,prod(size(xrgrd)),1);
y=reshape(yrgrd,prod(size(yrgrd)),1);

% Load initial Land/Sea mask at RHO-points.

rmask=mask;
c0=0.0;
c1=1.0;

% Set indices for land and water points.

iland=find(rmask == c0);
isea=find(rmask == c1);

% Plot mask. If appropriate, draw coastline(s).

clf;
xmin=xgrdmin;
xmax=xgrdmax;
ymin=ygrdmin;
ymax=ygrdmax;
plot(x(iland),y(iland),'ro',x(isea),y(isea),'co'); ...
axis([xmin xmax ymin ymax]); ...
title('Mouse:  LEFT-select   MIDDLE-zoom in   RIGHT-zoom out'); ...
hold on; ...
if (~isempty(xcst) & (spherical == 'T' | spherical == 't')),
  draw_cst(xcst,ycst,'b');
end

%----------------------------------------------------------------------------
%  Set control buttons and initialize states.
%----------------------------------------------------------------------------

States=mask_uifn('initialize');
figure(gcf);

%----------------------------------------------------------------------------
%  Write instructions.
%----------------------------------------------------------------------------

disp(' ');
disp('---------------------------------------------------------------------');
disp(' ');
disp('The newly created figure displays the current land mask with the');
disp('following symbols:');
disp(' ');
disp('   red  circles =>  Land points');
disp('   blue circles =>  Open sea points');
disp(' ');
disp('Land and Open sea points may be modified using this tool. Boundary');
disp('sea points are derived from the Land points.  Use the following');
disp('guidelines in setting the mask:');
disp(' ');
disp(' -- Channels and bays should be at least 2 open sea points wide.');
disp(' ');
disp(' -- Boundary sea points must touch both land and open sea points.');
disp(' ');
disp(' -- Open sea points must touch only boundary sea and open sea points.');
disp(' ');
disp('---------------------------------------------------------------------');
disp(' ');
disp('Carefully select mask points to change:');
disp(' ');
disp('   Use the LEFT mouse button to select a single point or');
disp('      two opposing corners of a rectangle for an area to change.');
disp('   Use the MIDDLE mouse button to select two opposing');
disp('      corners of an area for zooming.');
disp('   Use the RIGHT mouse button to unzoom.');
disp(' ');
disp('Use the cyan graph buttons to change from flipping to');
disp('      filling with land or sea.');
disp(' ');
disp('Use the yellow graph buttons to select between changing');
disp('      a point or an entire area.');
disp(' ');
disp('Use the purple graph button to cancel an area');
disp('      manipulation or zoom-in operation.');
disp(' ');
disp('When done, use the green graph button to stop.');
disp(' ');
disp('To abort: use the red graph bottom.');
disp(' ');

%----------------------------------------------------------------------------
% Modify land mask according to user's instructions. Loop until the
% DONE button is pressed.
%----------------------------------------------------------------------------

[xpt,ypt,butt]=ginput(1);
figure(gcf);
while (((States(4) == 1) | (States(5)==1)) & (States(3) == 0)),
  States(4:5)=[0 0];
  put_states(States);
  [xpt,ypt,butt]=ginput(1);
  figure(gcf);
end,

while (States(3) == 0),

%----------------------------------------------------------------------------
%  Select action based on button value.
%----------------------------------------------------------------------------

  if (butt == 1),

%----------------------------------------------------------------------------
%  Change point(s) based on current button values.
%----------------------------------------------------------------------------

    [i1,j1]=ijgrid(xpt,ypt,xrgrd,yrgrd);

    if (States(1) == 0),

%  Change a single point.

      if ((States(2) == 1) & (j1 ~= 0)),
        rmask(j1,i1)=c0;
      elseif ((States(2) == 2) & (j1 ~= 0)),
        rmask(j1,i1)=c1;
      elseif ((States(2) == 0) & (j1 ~= 0)),
        rmask(j1,i1)=c1-rmask(j1,i1);
      else
        xlabel('Point outside of domain, try again.')
        set(get(gca,'XLabel'),'Color',[1.0 0.25 0.25]);
        pause(1);
      end,

    else

%  Change rectangular area.

      plot(xpt,ypt,'mx');
      xlabel('AREA Change:  Select second corner'); ...
      set(get(gca,'XLabel'),'Color','c');
      figure(gcf);
      [xpt,ypt,butt]=ginput(1);
      figure(gcf);
      while ((States(4) == 1) & (States(3) == 0)),
        States(4)=0;
        put_states(States);
        [xpt,ypt,butt]=ginput(1);
        figure(gcf);
      end,

      if ((States(1) == 1) & (States(3) == 0) &(States(5) == 0)),

        [i2,j2]=ijgrid(xpt,ypt,xrgrd,yrgrd);
        imin=min([i1 i2]);
        imax=max([i1 i2]);
        jmin=min([j1 j2]);
        jmax=max([j1 j2]);
        if ((States(2) == 1) & (j1 ~= 0) & (j2 ~= 0)),
          rmask(jmin:jmax,imin:imax)=c0.*rmask(jmin:jmax,imin:imax);
        elseif ((States(2) == 2) & (j1 ~= 0) & (j2 ~= 0)),
          rmask(jmin:jmax,imin:imax)=c0.*rmask(jmin:jmax,imin:imax)+1;
        elseif ((States(2) == 0) & (j1 ~= 0) & (j2 ~= 0)),
          rmask(jmin:jmax,imin:imax)=c1-rmask(jmin:jmax,imin:imax);
        else
          xlabel('Point outside of domain, try again.')
          set(get(gca,'XLabel'),'Color',[1.0 0.25 0.25]);
          pause(1);
        end,
      elseif (States(5) == 1),
        States(5)=0;
        put_states(States);
      end,
    end,

    iland=find(rmask == c0);
    isea=find(rmask == c1);

  elseif (butt == 2),

%----------------------------------------------------------------------------
%  Choose new zoom.
%----------------------------------------------------------------------------

    xpt1=xpt;
    ypt1=ypt;
    plot(xpt1,ypt1,'m+');
    xlabel('ZOOM In:  Select second corner');
    set(get(gca,'XLabel'),'Color','y');
    figure(gcf);
    [xpt,ypt,butt]=ginput(1);
    figure(gcf);
    while ((States(4) == 1) & (States(3) == 0)),
      States(4)=0;
      put_states(States);
      [xpt,ypt,butt]=ginput(1);
      figure(gcf);
    end,

    if ((States(3) == 0) & (States(5) == 0)),
      xpt2=xpt;
      ypt2=ypt;
      if ((xpt1 ~= xpt2) & (ypt1 ~= ypt2)),
        xmin=min([xpt1 xpt2]);
        xmax=max([xpt1 xpt2]);
        ymin=min([ypt1 ypt2]);
        ymax=max([ypt1 ypt2]);
      else,
        xlabel('Bad zoom window, try again.');
        set(get(gca,'XLabel'),'Color',[1.0 0.25 0.25]);
        pause(1);
      end;
    elseif (States(5) == 1),
      States(5)=0;
      put_states(States);
    end;

  elseif (butt == 3),

%----------------------------------------------------------------------------
%  Return to full plot.
%----------------------------------------------------------------------------

    xmin=xgrdmin;
    xmax=xgrdmax;
    ymin=ygrdmin;
    ymax=ygrdmax;

  end;

%----------------------------------------------------------------------------
%  Redraw and wait for next selection.
%----------------------------------------------------------------------------

  hold off; ...
  plot(x(iland),y(iland),'ro',x(isea),y(isea),'co'); ...
  set(gca,'xlim',[xmin xmax],'ylim',[ymin ymax],'FontName','Times'); ...
  title('Mouse:  LEFT-select   MIDDLE-zoom in   RIGHT-zoom out'); ...
  xlabel(''); ...
  hold on; ...
  if (~isempty(xcst) & (spherical == 'T' | spherical == 't')),
    draw_cst(xcst,ycst,'b');
  end
  [xpt,ypt,butt]=ginput(1);
  figure(gcf);
  while (((States(4) == 1) | (States(5) == 1)) & (States(3) == 0)),
    States(4:5)=[0 0];
    put_states (States);
    [xpt,ypt,butt]=ginput(1);
    figure(gcf);
  end,

end;

%----------------------------------------------------------------------------
%  Save abort flag, clear workspace.
%----------------------------------------------------------------------------

abort=States(6);

clear butt c0 c1 i iland imax imin isea i1 i2 j jland jmax jmin jsea j1 j2
clear States x xgrdmax xgrdmin xmax xmin xpt y ygrdmax ygrdmin ymax ymin ypt

%----------------------------------------------------------------------------
%  Set Land/Sea mask at the U-, V-, and PSI-points: UMASK, VMASK, PMASK.
%----------------------------------------------------------------------------

if (~abort),
  [umask,vmask,pmask]=uvp_masks(rmask);
end,
