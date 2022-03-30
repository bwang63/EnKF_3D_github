function [figno, dods_err, dods_err_msg] = browseplot6(mode, argin2, ...
    argin3, argin4, argin5)

% browseplot6 -- function to quiver display requests from the DODS
% Matlab GUI.

global plot_data
global scale

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
    Argzz = deblank(display_choices.zz_slice);
    x_var = []; y_var = []; z_var = []; zz_var = [];
    
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
    if isempty(Argz)
      dods_err_msg = 'Error: u-component is undefined.  Not able to plot.';
      dods_err = 1;
      return
    end
    if isempty(Argzz)
      dods_err_msg = 'Error: v-component is undefined.  Not able to plot.';
      dods_err = 1;
      return
    end
    
    if (display_choices.x == 1 & display_choices.y ~= 1) | ...
    (display_choices.x == 1 & display_choices.y ~= 1)
      dods_err_msg = 'x- and y-variables must both be defined for QUIVER.';
      dods_err = 1;
      return
    else
      if display_choices.x == 1
	Argx = 'none'; Argy = 'none';
      end
    end
    
    acqno = display_choices.acqno;
    if (display_choices.z == 1 | display_choices.zz == 1)
      dods_err_msg = 'u- and v-components must both be defined for QUIVER.';
      dods_err = 1;
      return
    else
      str = [ 'browseplot6(''sendvar'', ' Argz ');'];
      evalin('base', str);
      z_var = plot_data;
      whichvar = display_choices.z;
      Argz = deblank(display_data(acqno).name(whichvar,:));
      str = [ 'browseplot6(''sendvar'', ' Argzz ');'];
      evalin('base', str);
      zz_var = plot_data;
      whichvar = display_choices.zz;
      Argzz = deblank(display_data(acqno).name(whichvar,:));
    end
    sz = size(z_var);
    szz = size(zz_var);

    if strcmp(Argx, 'none')
      x_var = []; y_var = [];
    else
      str = [ 'browseplot6(''sendvar'', ' Argx ');'];
      evalin('base', str);
      x_var = plot_data;
      whichvar = display_choices.x;
      Argx = deblank(display_data(acqno).name(whichvar,:));
      str = [ 'browseplot6(''sendvar'', ' Argy ');'];
      evalin('base', str);
      y_var = plot_data;
      whichvar = display_choices.y;
      Argy = deblank(display_data(acqno).name(whichvar,:));
    end
    sx = size(x_var);
    sy = size(y_var);
    
    if isempty(z_var) | isempty(zz_var)
      % nothing to plot
      return
    end

    if length(sz) > 2
      dods_err_msg = sprintf('%s\n', ...
	  'The quiver command cannot handle matrices of more than 2', ...
	  'dimensions.  Please check the size of your slice and try again.');
      dods_err = 1;
      return
    end
    
    % check that all vector component sizes match
    if ~all(sz == szz)
      dods_err_msg = 'u- and v-component sizes must match.';
      dods_err = 1;
      return
    end

    % check that sizes match.
    if any(sx == 1)
      if max(sx) ~= sz(2)
	dods_err_msg = [ 'Length of x-vector must match COLUMN WIDTH of', ...
	    ' u- and v-components.'];
	dods_err = 1;
	return
      end
    else % x is a matrix
      if ~all(sx == sz)
	% x is a matrix
	dods_err_msg = 'x-matrix must be size of u- and v- components';
	dods_err = 1;
	return
      end
      if ~all(sx == sy)
	% x is a matrix
	dods_err_msg = 'x-matrix and y-matrix sizes must match.';
	dods_err = 1;
	return
      end
      
    end
    if any(sy == 1)
      if max(sy) ~= sz(1)
	dods_err_msg = [ 'Length of y-vector must match ROW LENGTH of', ...
	    ' u- and v-components.'];
	dods_err = 1;
	return
      end
    else % x is a matrix
      if ~all(sy == sz)
	% x is a matrix
	dods_err_msg = 'y-matrix must be size of u- and v- components';
	dods_err = 1;
	return
      end
    end
    
    % set up axis labels
    Argx = strrep(Argx,'_',' ');
    Argy = strrep(Argy,'_',' ');
    Argz = strrep(Argz,'_',' ');
    Argzz = strrep(Argzz,'_',' ');
    
    % SET LONGITUDE VARIABLE CORRECTLY (FOR BROWSE WINDOW ONLY)
    if ~isempty(findstr(Argx,'Longitude')) & ...
	  strcmp(display_choices.figure, 'browse_fig')
      [x_var, xorder] = xrange('xarg', georange, x_var);
      if ~isempty(xorder) % x has been rearranged
	k = find(~isnan(xorder));
	z_var = z_var(:,xorder(k));
	zz_var = zz_var(:,xorder(k));
	k = find(isnan(xorder));
	for ii = 1:length(k),
	  sz = size(z_var);
	  z_var = [z_var(:,1:k(ii)-1) nan*ones(sz(1),1) ...
		z_var(:,k(ii):sz(2))];
	  szz = size(zz_var);
	  zz_var = [zz_var(:,1:k(ii)-1) nan*ones(szz(1),1) ...
		zz_var(:,k(ii):szz(2))];
	end
	if all(sy > 1)
	  k = find(~isnan(xorder));
	  y_var = y_var(:,xorder(k));
	  k = find(isnan(xorder));
	  for ii = 1:length(k),
	    sy = size(y_var);
	    y_var = [y_var(:,1:k(ii)-1) nan*ones(sy(1),1) ...
		  y_var(:,k(ii):sy(2))];
	  end
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
    else % figure is a number
      figno = display_choices.figure;
      if any(get(0,'children') == figno)
	set(0,'currentfigure', figno)
      else
	figure(figno); set(figno,'vis','off')
      end
    end
    hold on;
    
    linestyle = [display_choices.color display_choices.linestyle];
    
   % PCC added some lines here on 3/1/02
    if isempty(x_var)
      if isempty(scale)
        handle = quiver(z_var, zz_var, linestyle);
      else
        handle = quiver(z_var, zz_var, scale, linestyle);
      end
    else
      if isempty(scale) 
        handle = quiver(x_var, y_var, z_var, zz_var, linestyle);
      else
        handle = quiver(x_var, y_var, z_var, zz_var, scale, linestyle);
      end
    end

    if strcmp(display_choices.figure, 'browse_fig');
      if ~isempty(handle) 
	set(handle,'visible','off');
        browse('newplot', handle);
      end
    else
      box on
      xlabel(Argx); ylabel(Argy);
    end
      
  case 'sendvar'
    % get variables from user workspace
    plot_data = argin2;

end

return
