function [figno, dods_err, dods_err_msg] = browseplot1(mode, argin2, ...
    argin3, argin4, argin5)

% browseplot1 -- function to plot display requests from the DODS
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
    x_var = []; y_var = [];
    plot_data = [];
    
    if  display_choices.x == 1
      Argx = 'none';
    end
    if  display_choices.y == 1
      Argy = 'none';
    end

    if isempty(Argx)
      dods_err_msg = 'Error: x-variable is undefined.  Not able to plot.';
      dods_err = 1;
      return
    end

    if isempty(Argy)
      dods_err_msg = 'Error: y-variable is undefined.  Not able to plot.';
      dods_err = 1;
      return
    end
    
    if strcmp(Argx, 'none')
      x_var = [];
    else
      str = [ 'browseplot1(''sendvar'', ' Argx ');'];
      evalin('base', str);
      x_var = plot_data;
    end
    sx = size(x_var);
        
    acqno = display_choices.acqno;
    
    if strcmp(Argy, 'none')
      y_var = [];
    else
      str = [ 'browseplot1(''sendvar'', ' Argy ');'];
      evalin('base', str);
      y_var = plot_data;
      whichvar = display_choices.y;
      Argy = deblank(display_data(acqno).name(whichvar,:));
    end
    sy = size(y_var);
    
    if isempty(x_var) & isempty(y_var)
      dods_err = 1;
      dods_err_msg = 'All variables are empty';
      return
    end

    if length(sx) > 2 | length(sy) > 2
      dods_err = 1;
      dods_err_msg = ...
	  'X- and Y- variables can have no more than 2 dimensions';
      return
    end
      
    
    if isempty(x_var);
      % if only y-var defined, swap it to x-place
      x_var = y_var; y_var = [];
      Argx = ''; % this leaves Argy as the y-label.
    else
      whichvar = display_choices.x;
      Argx = deblank(display_data(acqno).name(whichvar,:));
      % use x-var name as y-label, since Matlab will plot
      % any single variable on the y-axis.
      if isempty(y_var)
	Argy = Argx;
	Argx = '';
      else
	% both x- and y- are full.  check that sizes match.
	if any(sx == 1) & any(sy == 1)
	  if max(sx) ~= max(sy)
	    dods_err_msg = 'x- and y- Variable sizes do not match.  Cannot plot.'; 
	    dods_err = 1;
	    return
	  end
	else % either x or y is a matrix
	  if all(sx > 1)
	    % x is a matrix
	    if ~any(max(sy) == sx)
	      dods_err_msg = 'x- and y- Variable sizes do not match.  Cannot plot.'; 
	      dods_err = 1;
	      return
	    end
	  else
	    % y is a matrix
	    if ~any(max(sx) == sy)
	      dods_err_msg = 'x- and y- Variable sizes do not match.  Cannot plot.'; 
	      dods_err = 1;
	      return
	    end
	  end
	end
      end
    end
    
    % set up axis labels
    Argx = strrep(Argx,'_',' ');
    Argy = strrep(Argy,'_',' ');
    
    % SET LONGITUDE VARIABLE CORRECTLY (FOR BROWSE WINDOW ONLY)
    if ~isempty(findstr(Argx,'Longitude')) & ...
	  strcmp(display_choices.figure, 'browse_fig')
      [x_var, xorder] = xrange('xarg', georange, x_var);
      if max(sy) < max(xorder)
	dods_err_msg = 'x- and y- Variable sizes do not match.  Cannot plot.'; 
	dods_err = 1;
	return
      end
      if ~isempty(xorder) % x has been rearranged
	if all(sy > 1)
	  k = find(~isnan(xorder));
	  y_var = y_var(:,xorder(k));
	  k = find(isnan(xorder));
	  for ii = 1:length(k),
	    sy = size(y_var);
	    y_var = [y_var(:,1:k(ii)-1) nan*ones(sy(1),1) ...
		  y_var(:,k(ii):sy(2))];
	  end
	else
	  k = find(~isnan(xorder));
	  y_var(k) = y_var(xorder(k));
	  k = find(isnan(xorder));
	  y_var(k) = nan;
	end
      end
    end % /* end of is x longitude */
    
    handle = [];
    if strcmp(display_choices.figure, 'browse_fig');
      figure(browse_fig); 
      subplot(findobj(gcf,'type','axes', 'userdata','GEOPLOT'))
    elseif strcmp(display_choices.figure, 'figure');
      figno = figure('userdata','DODS figure','Name', ...
	  'DODS Display','visible','off');
      box on
    else % figure is a number
      figno = display_choices.figure;
      if any(get(0,'children') == figno)
	set(0,'currentfigure', figno)
      else
	figure(figno); set(figno,'vis','off')
      end
      box on
    end
    hold on;

    color = display_choices.color;
    marker = display_choices.marker;
    if strcmp(marker,'none'), marker = ''; end
    linestyle = display_choices.linestyle;
    if strcmp(linestyle,'none'), linestyle = ''; end
    if isempty(y_var)
      handle = plot(x_var, [color marker linestyle]);
    else
      handle = plot(x_var, y_var, [color marker linestyle]);
    end

    if strcmp(display_choices.figure, 'browse_fig');
      if ~isempty(handle) 
	set(handle,'visible','off');
        browse('newplot', handle);
      end
    else
      xlabel(Argx); ylabel(Argy); box on
    end
  
  case 'sendvar'
    % get variables from user workspace
    plot_data = argin2;

end

return
