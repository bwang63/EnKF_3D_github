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
      dods_err_msg = [ 'Error: for polar plot, both x- and y- variables ', ...
	    '(theta, rho) must be defined'];
      dods_err = 1;
      return
    end
    
    if  display_choices.y == 1
      dods_err_msg = [ 'Error: for polar plot, both x- and y- variables ', ...
	    '(theta, rho) must be defined'];
      dods_err = 1;
      return
    end

    acqno = display_choices.acqno;
    
    str = [ 'browseplot1(''sendvar'', ' Argx ');'];
    evalin('base', str);
    x_var = plot_data;
    whichvar = display_choices.x;
    Argx = deblank(display_data(acqno).name(whichvar,:));
    sx = size(x_var);
    
    % convert from degrees to radians if necessary
    if any(x_var(:) < -2*pi) | any(x_var(:) > 2*pi)
      disp('Converting from degrees to radians')
      x_var = x_var*pi/180;
    end
        
    str = [ 'browseplot1(''sendvar'', ' Argy ');'];
    evalin('base', str);
    y_var = plot_data;
    whichvar = display_choices.y;
    Argy = deblank(display_data(acqno).name(whichvar,:));
    sy = size(y_var);
    
    if ~all(sx == sy)
      dods_err_msg = 'x- and y- Variable sizes do not match.  Cannot plot.'; 
      dods_err = 1;
      return
    end
    
    % set up axis labels
    Argx = strrep(Argx,'_',' ');
    Argy = strrep(Argy,'_',' ');
    
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
%    hold on;

    color = display_choices.color;
    marker = display_choices.marker;
    if strcmp(marker,'none'), marker = ''; end
    linestyle = display_choices.linestyle;
    if strcmp(linestyle,'none'), linestyle = ''; end
    if isempty(y_var)
      handle = polar(x_var, [color marker linestyle]);
    else
      handle = polar(x_var, y_var, [color marker linestyle]);
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
