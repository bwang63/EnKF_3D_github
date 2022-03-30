function out = newzoom(m)
%NEWZOOM	Newzoom in and out on a 2-D plot.
%	NEWZOOM ON turns newzoom on for the current figure.  Click 
%	the left mouse button to zoom in on the point under the 
%	mouse.  Click the right mouse button to zoom out 
%	(shift-click on the Macintosh).  Each time you click, 
%	the axes limits will be changed by a factor of 2 (in or out).
%	You can also click and drag to zoom into an area.
%	
%	NEWZOOM OFF turns newzoom off. NEWZOOM with no arguments 
%	toggles the newzoom status.  NEWZOOM OUT returns the plot
%	to its initial (full) newzoom.
%
%	NEWZOOM XON newzooms x-axis only
%	NEWZOOM YON newzooms y-axis only

%       Original 'zoom.m' written by:
%	Clay M. Thompson 1-25-93
%	Revised 11 Jan 94 by Steven L. Eddins
%	Copyright (c) 1984-94 by The MathWorks, Inc.
%	$Revision: 1.2 $  $Date: 2000/11/20 19:04:11 $
%
%       Modified for use with DODS data browser (browse.m)
%       by Deirdre Byrne, dbyrne@islandinstitute.org, 97/05/19

% The preceding empty line is important.
%
% $Id: newzoom.m,v 1.2 2000/11/20 19:04:11 dbyrne Exp $

% $Log: newzoom.m,v $
% Revision 1.2  2000/11/20 19:04:11  dbyrne
%
%
% Changes to remove support for Matlab v4 and add support for Folders.
% -- dbyrne 00/11/20
%
% Revision 1.2  2000/11/20 16:11:17  root
% Changes and addition for Folders Edition.  -- dbyrne 00/11/20
%
% Revision 1.1  2000/05/31 22:57:20  root
% *** empty log message ***
%
% Revision 1.7  2000/03/16 03:41:31  dbyrne
%
%
% Removed unused windowbuttonupfcn '1'. -- dbyrne 00/03/14
%
% Revision 1.6  1999/05/13 03:09:53  dbyrne
%
%
% Added Acknowledge and Data_Use_Policy to archive.m.  Fixed getxxx functions
% to use dodsmsg instead of stdout for errors/info.  Made ChangeLog so that it's
% in Emacs format.  All changes for release 3.0.0 -- dbyrne 99/05/12
%
% Revision 1.1  1998/05/17 14:10:51  dbyrne
% *** empty log message ***
%
% Revision 1.1.1.1  1997/09/22 14:13:53  tom
% Imported Matlab GUI sources to CVS
%

%	Note: newzoom uses the userdata of the zlabel of the axis
%
global AXES range_boxes ranges axes_vals thandle lhandle tstring
global dods_colors fontsize
if nargin==1, % Catch off first
  if isstr(m),
    if strcmp(m,'off'),
      set(gcf,'windowbuttondownfcn','','windowbuttonupfcn','',...
              'windowbuttonmotionfcn','','buttondownfcn','');
      return
    end
  end
end
       
if any(get(gca,'view')~=[0 90]), error('Only works for 2-D plots'); end

rbbox_mode = 0;
zoomx = 1; zoomy = 1; % Assume no constraints

if nargin==0, % Toggle buttondown function
   if strcmp(get(gcf,'windowbuttondownfcn'),'newzoom(''down'')'),
      set(gcf,'windowbuttondownfcn','','windowbuttonupfcn','', ...
              'windowbuttonmotionfcn','','buttondownfcn','');
   else
      set(gcf,'windowbuttondownfcn','newzoom(''down'')', ...
              'windowbuttonupfcn','', ...
              'windowbuttonmotionfcn','','buttondownfcn','', ...
              'interruptible','on');
      set(gca,'interruptible','on')
      figure(gcf)
   end
   return

elseif nargin==1, % Process call backs
  if isstr(m),
    m = lower(m);

    % Catch constrained zoom
    if strcmp(m,'xdown'),
      zoomy = 0; m = 'down'; % Constrain y
    elseif strcmp(m,'ydown')
      zoomx = 0; m = 'down'; % Constrain x
    end

    if strcmp(m,'down'),
      % Activate axis that is clicked in
      ax = get(gcf,'Children');
      ZOOM_found = 0;
      for i=1:length(ax),
        if strcmp(get(ax(i),'Type'),'axes'),
          ZOOM_Pt1 = get(ax(i),'CurrentPoint');
          xlim = get(ax(i),'XLim');
          ylim = get(ax(i),'YLim');
          if (xlim(1) <= ZOOM_Pt1(1,1) & ZOOM_Pt1(1,1) <= xlim(2) & ...
              ylim(1) <= ZOOM_Pt1(1,2) & ZOOM_Pt1(1,2) <= ylim(2))
            ZOOM_found = 1;
            axes(ax(i))
            break
          end
        end
      end
      if ZOOM_found==0, return, end

      % Check for selection type
      selection_type = get(gcf,'SelectionType');
      if (strcmp(selection_type, 'normal'))
        % Zoom in
        m = 1;
      elseif (strcmp(selection_type, 'open'))
        % Zoom all the way out
        newzoom('out');
        return;
      else
        % Zoom partially out
        m = -1;
      end
      
      ZOOM_Pt1 = get(gca,'currentpoint');
      ZOOM_Pt2 = ZOOM_Pt1;
      center = ZOOM_Pt1(1,1:2);
      
      if (m == 1)
        % Zoom in
        rbbox([get(gcf,'currentpoint') 0 0],get(gcf,'currentpoint'))
        ZOOM_Pt2 = get(gca,'currentpoint');

        % Note the currentpoint is set by having a non-trivial up function.
        if min(abs(ZOOM_Pt1(1,1:2)-ZOOM_Pt2(1,1:2))) >= ...
	      min(.01*[diff(get(gca,'xlim')) diff(get(gca,'ylim'))]),
          % determine axis from rbbox 
          a = [ZOOM_Pt1(1,1:2);ZOOM_Pt2(1,1:2)]; a = [min(a);max(a)];
          rbbox_mode = 1;
        end
      end
      limits = newzoom('getlimits');

    elseif strcmp(m,'on'),
      set(gcf,'windowbuttondownfcn','newzoom(''down'')', ...
              'windowbuttonupfcn','', ...
              'windowbuttonmotionfcn','','buttondownfcn','', ...
              'interruptible','on');
      set(gca,'interruptible','on')
      figure(gcf)       
      return

    elseif strcmp(m,'xon'),
      set(gcf,'windowbuttondownfcn','newzoom(''xdown'')', ...
              'windowbuttonupfcn','', ...
              'windowbuttonmotionfcn','','buttondownfcn','',...
              'interruptible','on');
      set(gca,'interruptible','on')
      figure(gcf)       
      return

    elseif strcmp(m,'yon'),
      set(gcf,'windowbuttondownfcn','newzoom(''ydown'')', ...
              'windowbuttonupfcn','', ...
              'windowbuttonmotionfcn','','buttondownfcn','',...
              'interruptible','on');
      set(gca,'interruptible','on')
      figure(gcf)       
      return

    elseif strcmp(m,'out'),
      limits = newzoom('getlimits');
      center = [sum(get(gca,'Xlim'))/2 sum(get(gca,'Ylim'))/2];
      m = -inf; % Zoom totally out

    elseif strcmp(m,'getlimits'), % Get axis limits
      limits = get(get(gca,'ZLabel'),'UserData');
      if size(limits,2)==4 & size(limits,1)<=2, % Do simple checking of userdata
        if all(limits(1,[1 3])<limits(1,[2 4])), 
          getlimits = 0; out = limits(1,:); return   % Quick return
        else
          getlimits = -1; % Don't munge data
        end
      else
        if isempty(limits), getlimits = 1; else getlimits = -1; end
      end

      % If I've made it to here, we need to compute appropriate axis
	  % limits.

      if isempty(get(get(gca,'ZLabel'),'userdata')),
        % Use quick method if possible
        xlim = get(gca,'xlim'); xmin = xlim(1); xmax = xlim(2); 
        ylim = get(gca,'ylim'); ymin = ylim(1); ymax = ylim(2); 

      elseif strcmp(get(gca,'xLimMode'),'auto') & ...
             strcmp(get(gca,'yLimMode'),'auto'),
        % Use automatic limits if possible
        xlim = get(gca,'xlim'); xmin = xlim(1); xmax = xlim(2); 
        ylim = get(gca,'ylim'); ymin = ylim(1); ymax = ylim(2); 

      else
        % Determine which IMAGE coordinate system is being used.
        s = [version '    ']; k = find(s<46 & s>58);
        if ~isempty(k), s = s(1:min(k)); end
        [ver,count,msg,next] = sscanf(s,'%f',1);
        if ver > 4.1,
          useNew = 1;
        elseif ver < 4.1,
          useNew = 0;
        else
          if s(next)>='a', useNew = 1; else useNew = 0; end
        end
  
        % Use slow method only if someone else is using the userdata
        h = get(gca,'Children');
        xmin = inf; xmax = -inf; ymin = inf; ymax = -inf;
        for i=1:length(h),
          t = get(h(i),'Type');
          if ~strcmp(t,'text'),
            if strcmp(t,'image') & useNew, % Determine axis limits for image
              x = get(h(i),'Xdata'); y = get(h(i),'Ydata');
              x = [min(min(x)) max(max(x))];
              y = [min(min(y)) max(max(y))];
              [ma,na] = size(get(h(i),'Cdata'));
              if na>1, dx = diff(x)/(na-1); else dx = 1; end
              if ma>1, dy = diff(y)/(ma-1); else dy = 1; end
              x = x + [-dx dx]/2; y = y + [-dy dy]/2;
            else
              x = get(h(i),'Xdata'); y = get(h(i),'Ydata');
            end
            xmin = min(xmin,min(min(x)));
            xmax = max(xmax,max(max(x)));
            ymin = min(ymin,min(min(y)));
            ymax = max(ymax,max(max(y)));
          end
        end

        % Use automatic limits if in use (override previous calculation)
        if strcmp(get(gca,'xLimMode'),'auto'),
          xlim = get(gca,'xlim'); xmin = xlim(1); xmax = xlim(2); 
        end
        if strcmp(get(gca,'yLimMode'),'auto'),
          ylim = get(gca,'ylim'); ymin = ylim(1); ymax = ylim(2); 
        end
      end
      limits = [xmin xmax ymin ymax];
      if getlimits~=-1, % Don't munge existing userdata.
        % Store limits in ZLabel userdata
        set(get(gca,'ZLabel'),'UserData',limits);
      end

      out = limits;
      return
   
   elseif strcmp(m,'getconnect'), % Get connected axes
    limits = get(get(gca,'ZLabel'),'UserData');
    if all(size(limits)==[2 4]), % Do simple checking
      out = limits(2,[1 2]);
    else
      out = [gca gca];
    end
    return

   else
      error(['Unknown option: ',m,'.']);
    end

  else
    error('Only takes the strings ''on'',''off'', or ''out''.')
  end
end

%
% Actual zoom operation
%
if ~rbbox_mode,
  xmin = limits(1); xmax = limits(2); ymin = limits(3); ymax = limits(4);
  if m==(-inf),
    dx = xmax-xmin;
    dy = ymax-ymin;
  else
    dx = diff(get(gca,'Xlim'))*(2.^(-m-1)); dx = min(dx,xmax-xmin);
    dy = diff(get(gca,'Ylim'))*(2.^(-m-1)); dy = min(dy,ymax-ymin);
  end

  % Limit zoom.
  center = max(center,[xmin ymin] + [dx dy]);
  center = min(center,[xmax ymax] - [dx dy]);
  a = [max(xmin,center(1)-dx) min(xmax,center(1)+dx) ...
       max(ymin,center(2)-dy) min(ymax,center(2)+dy)];
end

% *** SEND AXIS LIMITS TO BROWSE -- D.B.
if (gca == AXES(3))
  if a(1) ~= a(2)
    timetoggle = str2num(get(AXES(3),'tag'));
    [thandle, lhandle] = timelbl(a(1:2), timetoggle, thandle, lhandle, ...
	tstring, AXES, dods_colors, fontsize);
  else
    return
  end
  axes_vals(7:8) = a(1:2);
elseif (gca == AXES(2))
  a = a(:)'; 
  axes_vals(5:6) = a(3:4);
elseif (gca == AXES(1))
  a = a(:)'; 
  axes_vals(1:4) = a;
end

% Update circular list of connected axes
list = newzoom('getconnect'); % Circular list of connected axes.
if zoomx,
  if (gca == AXES(1)) | (gca == AXES(3))
    set(gca,'xlim',a(1:2))
  elseif gca == AXES(2)
    set(gca,'xlim',[0 1])
  end
  h = list(1);
  while h ~= gca,
    if (gca == AXES(1)) | (gca == AXES(3))
      set(gca,'xlim',a(1:2))
    elseif gca == AXES(2)
      set(gca,'xlim',[0 1])
    end
    % Get next axes in the list
    next = get(get(h,'ZLabel'),'UserData');
    if all(size(next)==[2 4]), h = next(2,1); else h = gca; end
  end
end
if zoomy,
  if (gca == AXES(1)) | (gca == AXES(2))
    set(gca,'ylim',a(3:4))
  else
    set(gca,'ylim',[0 1])
  end
  h = list(2);
  while h ~= gca,
    if (gca == AXES(1)) | (gca == AXES(2))
      set(gca,'ylim',a(3:4))
    else
      set(gca,'ylim',[0 1])
    end
    % Get next axes in the list
    next = get(get(h,'ZLabel'),'UserData');
    if all(size(next)==[2 4]), h = next(2,2); else h = gca; end
  end
end
