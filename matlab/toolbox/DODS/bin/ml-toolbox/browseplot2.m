function [figno, dods_err, dods_err_msg] = browseplot2(mode, argin2, ...
    argin3, argin4, argin5, argin6)

% browseplot2 -- function to image display requests from the DODS
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
    palette = argin6;
    Argx = deblank(display_choices.x_slice);
    Argy = deblank(display_choices.y_slice);
    Argz = deblank(display_choices.z_slice);
    x_var = []; y_var = []; z_var = [];

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
      dods_err_msg = 'X-variable is undefined.  Not able to plot.';
      dods_err = 1;
      return
    end
    
    if isempty(Argy)
      dods_err_msg = 'Y-variable is undefined.  Not able to plot.';
      dods_err = 1;
      return
    end
    
    if isempty(Argz)
      dods_err_msg = 'Z-variable is undefined.  Not able to plot.';
      dods_err = 1;
      return
    end
    
    if strcmp(Argx, 'none')
      x_var = [];
    else
      if all(display_choices.x_slicesize) > 0
	str = [ 'browseplot2(''sendvar'', ' Argx ');'];
	evalin('base', str);
	x_var = plot_data;
      else
	x_var = [];
      end
    end
    
    acqno = display_choices.acqno;
    
    if strcmp(Argy, 'none')
      y_var = [];
    else
      str = [ 'browseplot2(''sendvar'', ' Argy ');'];
      evalin('base', str);
      y_var = plot_data;
      whichvar = display_choices.y;
      Argy = deblank(display_data(acqno).name(whichvar,:));
    end
    
    if strcmp(Argz, 'none')
      z_var = [];
    else
      str = [ 'browseplot2(''sendvar'', ' Argz ');'];
      evalin('base', str);
      z_var = plot_data;
      whichvar = display_choices.z;
      Argz = deblank(display_data(acqno).name(whichvar,:));
    end
    
    if isempty(z_var)
      % nothing to image
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
	  'The imagesc command requires a 2-D MATRIX for imaging.', ...
	  'Please check the size of your slice and try again.');
      dods_err = 1;
      return
    end
    
    if all(sx > 1) | all(sy > 1)
      dods_err_msg = 'The imagesc command requires VECTOR axis variables.';
      dods_err = 1;
      return
    end
    
    % check sizes
    if all(sy) > 0 & max(sy) ~= sz(1)
      dods_err_msg = 'Length of y-variable must match ROW LENGTH of z-variable.';
      dods_err = 1;
      return
    end
    if all(sx) > 0 & max(sx) ~= sz(2)
      dods_err_msg = 'Length of x-variable must match COLUMN WIDTH of z-variable.';
      dods_err = 1;
      return
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

    % get the color limits
    clim = display_choices.clim;
    if isempty(clim), clim = mminmax(z_var); end
    if all(isnan(clim)), clim = [0 1]; end
    if clim(1) == clim(2), clim = [clim(1) clim(1)+1]; end

    % execute the plot commands
    handles = [];
    if strcmp(display_choices.figure, 'browse_fig');
      % use browse figure
      figure(browse_fig); 
      subplot(findobj(gcf,'type','axes','userdata','GEOPLOT'))
    elseif strcmp(display_choices.figure, 'figure');
      % open a new figure
      figno = figure('userdata','DODS figure','Name', ...
	  'DODS Display');
    else % use a figure specified by number
      figno = display_choices.figure;
      if any(get(0,'children') == figno)
	set(0,'currentfigure', figno)
      else
	figure(figno); set(figno,'vis','off')
      end
    end
    hold on
    colormap(palette)

    if isempty(x_var)
      handles = imagesc(z_var, clim);
    else
      handles = imagesc(x_var, y_var, z_var, clim);
    end
    if strcmp(display_choices.figure, 'browse_fig');
      if ~isempty(handles), 
	handles = handles(:);
	set(handles,'visible','off','userdata', clim)
	browse('newplot', handles);
      end
    else
      colorbar;
      set(gca,'ydir','normal')
      xlabel(Argx); ylabel(Argy); title(Argz)
    end

  case 'sendvar'
    plot_data = argin2;

end

return
