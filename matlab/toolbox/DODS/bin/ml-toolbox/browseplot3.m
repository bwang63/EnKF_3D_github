function [figno, dods_err, dods_err_msg] =  browseplot3(mode, argin2, argin3, ...
    argin4, argin5)

% browseplot3 -- function to contour display requests from the DODS
% Matlab GUI.


global plot_data

switch mode
  case 'plot'
    dods_err = 0;
    dods_err_msg = '';
    figno = [];
    display_choices = argin2;
    display_data = argin3;
    georange = argin4;
    browse_fig = argin5;
    Argx = deblank(display_choices.x_slice);
    Argy = deblank(display_choices.y_slice);
    Argz = deblank(display_choices.z_slice);
    x_var = []; y_var = []; z_var = [];
    plot_data = [];
    
    if  display_choices.x == 1
      Argx = 'none';
    end
    if  display_choices.y == 1
      Argy = 'none';
    end
    if  display_choices.z == 1
      Argz = 'none';
    end

    if isempty(Argx)
      dods_errsmsg = 'X-variable is undefined.  Not able to plot.';
      dods_err = 1;
      return
    end
    
    if isempty(Argy)
      dods_errsmsg = 'Y-variable is undefined.  Not able to plot.';
      dods_err = 1;
      return
    end
    
    if isempty(Argz)
      dods_errsmsg = 'Z-variable is undefined.  Not able to plot.';
      dods_err = 1;
      return
    end
    
    if strcmp(Argx, 'none')
      x_var = [];
    else
      str = [ 'browseplot3(''sendvar'', ' Argx ');'];
      evalin('base', str);
      x_var = plot_data;
    end
    
    acqno = display_choices.acqno;
    
    if strcmp(Argy, 'none')
      y_var = [];
    else
      str = [ 'browseplot3(''sendvar'', ' Argy ');'];
      evalin('base', str);
      y_var = plot_data;
      whichvar = display_choices.y;
      Argy = deblank(display_data(acqno).name(whichvar,:));
    end
    
    if strcmp(Argz, 'none')
      z_var = [];
    else
      str = [ 'browseplot3(''sendvar'', ' Argz ');'];
      evalin('base', str);
      z_var = plot_data;
      whichvar = display_choices.z;
      Argz = deblank(display_data(acqno).name(whichvar,:));
    end
    
    if isempty(z_var)
      % nothing to contour
      return
    end
    
    if isempty(x_var) & ~isempty(y_var)
      dods_err_msg = [ 'x- and y-variables must be both present ', ...
	    '(and non-empty) or both absent.'];
      dods_err = 1;
      return
    end

    if ~isempty(x_var) & isempty(y_var)
      dods_err_msg = [ 'x- and y-variables must be both present ', ...
	    '(and non-empty) or both absent.'];
      dods_err = 1;
      return
    end

    if isempty(x_var) & isempty(y_var) & ...
	  strcmp(display_choices.figure,'browse_fig')
      dods_err_msg = [ 'Displaying on the browse window requires specifying', ...
	    ' the x- and y- plot variables.'];
      dods_err = 1;
      return
    end

    % set up axis labels and title
    Argx = strrep(Argx,'_',' ');
    Argy = strrep(Argy,'_',' ');
    Argz = strrep(Argz,'_',' ');
    
    sx = size(x_var);
    sy = size(y_var);
    sz = size(z_var);

    if any(sz == 1) | (length(sz) > 2)
      dods_err_msg = sprintf('%s\n', ...
	  'The contour and contourf commands require the z-variable to be a', ...
	  '2-D MATRIX.  Please check the size of your slice and try again.');
      dods_err = 1;
      return
    end
    
    if all(sx > 1)
      if ~all(sx == sz)
	dods_err_msg = 'Error: x-variable size must match z-variable size';
	dods_err = 1;
	return
      end
    else
      if all(sx) > 0 & max(sx) ~= sz(2)
	dods_err_msg = 'Length of x-variable must match COLUMN WIDTH of z-variable.';
	dods_err = 1;
	return
      end
    end
    
    if all(sy > 1)
      if ~all(sy == sz)
	dods_err_msg = 'Error: y-variable size must match z-variable size';
	dods_err = 1;
	return
      end
    else
      if all(sx) > 0 & max(sy) ~= sz(1)
	dods_err_msg = 'Length of y-variable must match ROW LENGTH of z-variable.';
	dods_err = 1;
	return
      end
    end
    
    % SET LONGITUDE VARIABLE CORRECTLY (FOR BROWSE WINDOW ONLY)
    if ~isempty(findstr(Argx,'Longitude')) & ...
	  strcmp(display_choices.figure, 'browse_fig')
      [x_var, xorder] = xrange('xarg', georange, x_var);
      if max(sz) < max(xorder)
	dods_err_msg = 'Variable sizes do not match.  Cannot plot.';
	dods_err = 1;
	return
      end
      if ~isempty(xorder) % x has been rearranged
	% must re-arrange COLUMNS of zvar
	k = find(~isnan(xorder));
	z_var = z_var(:,xorder(k));
	k = find(isnan(xorder));
	for ii = 1:length(k),
	  sz = size(z_var);
	  z_var = [z_var(:,1:k(ii)-1) nan*ones(sz(1),1) ...
		z_var(:,k(ii):sz(2))];
	end
      end
    end % /* end of is x longitude */

    handles = [];
    linestyle = [display_choices.linestyle];

    % empty linestyle is not valid for contour/contourf command.
    if isempty(linestyle),
      linestyle = '-';
    end
    linestyle = [display_choices.color linestyle];

    cval = display_choices.cval;
    if isempty(cval)
      cval = 10;
    end

    % select the correct figure and axis
    if strcmp(display_choices.figure, 'browse_fig');
      figure(browse_fig);
      subplot(findobj(gcf,'type','axes', 'userdata','GEOPLOT'));
    elseif strcmp(display_choices.figure, 'figure');
      figno = figure('userdata','DODS figure','Name', ...
	  'DODS Display','visible','off');
      box on
    else
      figno = display_choices.figure;
      if any(get(0,'children') == figno)
	set(0,'currentfigure', figno)
      else
	figure(figno); set(figno,'vis','off')
      end
      box on
    end
    hold on
    
    if isempty(x_var)
      if strcmp(display_choices.plot_type,'contour')
	[c, handles] = contour(z_var, cval, linestyle);
      else
	[c, handles] = contourf(z_var, cval, linestyle);
      end
    else
      if strcmp(display_choices.plot_type,'contour')
	[c, handles] = contour(x_var, y_var, z_var, cval, linestyle);
      else
	[c, handles] = contourf(x_var, y_var, z_var, cval, linestyle);
      end
    end

    lev = [];
    if strcmp(display_choices.plot_type,'contourf')
      % get the contour levels used
      lc = size(c,2);
      k = 1;
      lev = [];
      while (k < lc),
	lev = [lev c(1,k)];
	k = k + c(2,k) + 1;
      end
      lev = mminmax(lev);
    end
      
    if strcmp(display_choices.figure, 'browse_fig');
      if ~isempty(handles), 
	handles = handles(:);
	if strcmp(display_choices.plot_type,'contourf')
	  set(handles,'userdata', lev, 'tag', 'faceted');
	end
	set(handles,'visible','off');
	browse('newplot', handles);
      end
    else
      xlabel(Argx); ylabel(Argy); title(Argz);
      if isnumeric(display_choices.figure)
	if strcmp(display_choices.plot_type,'contourf')
	  if all(isnan(lev)), lev = [0 1]; end
	  set(gca,'clim', lev);
	end
      end
    end
    
  case 'sendvar'
    plot_data = argin2;

end

return
