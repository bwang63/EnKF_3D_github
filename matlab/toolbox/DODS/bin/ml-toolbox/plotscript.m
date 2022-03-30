% PLOTSCRIPT   Part of the DODS data browser (browse.m).
%
% PLOTSCRIPT   generates the display string for plotting returned data.
%
%
%            Deirdre Byrne, University of Maine, 23 Feb 1998
%                 dbyrne@grayling.umeoce.maine.edu
%

% The preceding empty line is important.
%
% $Id: plotscript.m,v 1.1 2000/05/31 23:11:48 dbyrne Exp $

% $Log: plotscript.m,v $
% Revision 1.1  2000/05/31 23:11:48  dbyrne
% *** empty log message ***
%
% Revision 1.1  2000/05/31 22:57:20  root
% *** empty log message ***
%
% Revision 1.23  2000/03/23 02:53:17  dbyrne
%
%
% Rewrote unpack.m from scratch.  Much shorter, better commented,
% more robust now.  In particular, it now checks for blank names,
% zero-size arguments, removes these all handily, and distinguishes
% between the potential number of plots and the returned number
% of URLs.  Plotscript.m and dispmenu.m changed accordingly to
% use num_plots instead of num_urls.  -- dbyrne 00/03/22
%
% Revision 1.22  2000/03/17 08:41:33  dbyrne
%
%
% Fixed a bug which had plot loop aborting early for multiple plots
% outside of browse window.  Fixed another small bug that had a
% variable not being cleared from workspace.  -- dbyrne 00/03/16
%
% Revision 1.21  2000/03/15 00:13:00  dbyrne
% *** empty log message ***
%
% Revision 1.20  1999/10/27 21:23:10  dbyrne
%
% Changed minmax to mminmax to avoid conflict with a script in nnet toolbox.
%
% Revision 1.18  1999/10/27 21:14:09  root
% Changed minmax to mminmax to avoid conflict with a script in nnet toolbox.
%
% Revision 1.17  1999/09/02 18:12:22  root
% *** empty log message ***
%
% Revision 1.19  1999/07/21 18:20:10  dbyrne
%
%
% changed plotscript to skip over datasets with empty plot args, instead of
% quitting.  Seems to work well.  This allowed addition of NSCAT20l dataset
% (finally!).  -- dbyrne 99/07/21
%
% Revision 1.18  1999/07/19 22:38:22  dbyrne
%
%
% Fixed a bug that carried over datarange from previous datasets!  Nasty.
% dbyrne 99/07/19
%
% Revision 1.17  1999/07/19 19:02:52  dbyrne
%
%
% Dataset scroll window is now modal -- will not show other datasets once
% one is chosen.  Also, dataset name colors changed to black for unselected,
% and choice of black or light gray once selected (depending on dataset color).
%
% Fixed a bug in plotscript that was using an incorrect index into the
% data range (used in scaling images).
%
% dbyrne 99/07/19
%
% Revision 1.16  1999/05/31 22:12:56  dbyrne
%
%
% Finished changing error msgs -- dbyrne 99/05/31
%
% Revision 1.15  1999/05/31 21:52:39  dbyrne
%
%
% Made bailout for empty args slightly more intelligent -- dbyrne 99/05/31
%
% Revision 1.14  1999/05/31 21:45:35  dbyrne
%
%
% Finished conversion to dodsmsg -- dbyrne 99/05/31
%
% Revision 1.13  1999/05/31 21:42:21  dbyrne
%
%
% Started using dodsmsg.m --dbyrne 99/05/31
%
% Revision 1.16  1999/05/25 00:02:06  root
% Found a bug in user ranges display during plotting, and fixed plotscript
% to default to pcolor if image is to be split into 2 pieces. -- dbyrne 99/05/23
%
% Revision 1.15  1999/05/13 00:53:06  root
% Lots of changes for version 3.0.0 of browser.
%
% Revision 1.14  1999/03/04 13:05:47  root
% *** empty log message ***
%
% Revision 1.13  1998/10/22 14:49:59  root
% Made datarange consistently optional.
%
% Revision 1.12  1998/09/13 19:59:07  root
% Added an abort if any argument is empty!
%
% Revision 1.11  1998/09/13 14:51:24  root
% Encountered (as usual) some weird problems with longitude.
%
% Revision 1.10  1998/09/13 08:03:48  root
% Eliminated DataMinMax in favor of browse_minmax.
%
% Revision 1.9  1998/09/12 20:00:50  root
% Finished changes so that dispmenu can be used again & again.
% Added 'checkplot' to pop the image stack if only one image in it.
%
% Revision 1.8  1998/09/12 15:28:41  root
% Made modifications necessary to let display menu be called numerous times.
%
% Revision 1.7  1998/09/08 16:12:45  dbyrne
% more changes from browse_display_choices to browse_dispchoices
%
% Revision 1.6  1998/09/08 16:00:57  dbyrne
% changed AxVals to browse_axes_vals
%
% Revision 1.5  1998/09/03 20:32:41  dbyrne
% CLeaning up multivariable plot items.
%
% Revision 1.4  1998/09/03 19:59:00  dbyrne
% changed all local variables to begin with 'browse_'.
%
% Revision 1.3  1998/09/03 19:09:05  dbyrne
% Fixed scaling.
%
% Revision 1.2  1998/09/02 15:37:02  dbyrne
% *** empty log message ***
%
% Revision 1.1  1998/05/17 14:10:51  dbyrne
% *** empty log message ***
%
% Revision 1.1.1.1  1997/09/22 14:13:53  tom
% Imported Matlab GUI sources to CVS
%

% these are the display_choices, stored here in browse_dispchoices
% 1 Plot/not plot 
% 2 kind of plot
% 3 not browse window/browse window
% 4 use new windows/reuse old one(s)
% 5 Plot all URLS/Plot only first URL
% 6 open one window per URL/one window for all URLs
% 7 X-argument
% 8 Y-argument
% 9 Z-Argument
% 10 2nd Z-argument (zz), for quiver plots
% 11 color argument for line & symbol plots
% 12 linestyle argument for "" & ""    ""

% 
% get/set the matlab version number

browse_version = version; browse_version = str2num(browse_version(1));
browse_Argx = ''; browse_Argy = ''; browse_Argz = ''; browse_Argzz = '';
browse_xargx = ''; browse_xargy = ''; browse_xargz = ''; ...
browse_xargzz = '';
browse('checkplots')
% NO LONGER STOPPING AT ONE PLOT WHEN REQUESTED THRU DISPLAY MENU!
for browse_j = 1:browse_num_plots

  if ~isempty(browse_data_range)
    browse_range = ...
	browse_data_range(browse_datarangeindex,:);
  else
    browse_range = [];
  end
  browse_plotstring = '';
  % 1. FILL UP THE TEMPORARY X, Y AND Z PLOTTING ARGUMENTS
  % because we are now making temporary variables instead of
  % just temporary plot string arguments, the browse_plotstring must
  % be evaluated each time around
  if browse_dispchoices(7) > 0
    browse_Argx = deblank(browse_dispargs(browse_dispchoices(7),:));
    browse_xargx = sprintf('R%i_%s',browse_count,...
	deblank(browse_dispargs(browse_dispchoices(7),:)));
  end
  
  if browse_dispchoices(8) > 0
    % if y is depth, use -y to plot (convention is y positive downward)
    if strcmp(browse_Argy,deblank(browse_depth_name)) & ...
	  ~isempty(browse_depth_name)
      browse_Argy = ...
	  deblank(browse_dispargs(browse_dispchoices(8),:));
      
      browse_xargy = sprintf('-R%i_%s',browse_count,...
	  deblank(browse_dispargs(browse_dispchoices(8),:)));
    else
      browse_Argy = deblank(browse_dispargs(browse_dispchoices(8),:));
      browse_xargy = sprintf('R%i_%s',browse_count,...
	  deblank(browse_dispargs(browse_dispchoices(8),:)));
    end
  end
  
  if browse_dispchoices(2) > 2 % contour, image, pcolor or quiver
    if browse_dispchoices(9) > 0 % GET THE Z-VAR !!!
      browse_Argz = ...
	  deblank(browse_dispargs(browse_dispchoices(9),:));
      browse_xargz = sprintf('R%i_%s',browse_count, ...
	  deblank(browse_dispargs(browse_dispchoices(9),:)));
    end
  end
  
  if browse_dispchoices(2) == 6 % QUIVER
    if browse_dispchoices(10) > 0
      browse_Argzz = ...
	  deblank(browse_dispargs(browse_dispchoices(10),:));
      browse_xargzz = sprintf('R%i_%s',browse_count,...
	  deblank(browse_dispargs(browse_dispchoices(10),:)));
    end
  end
  
  % 2. CONSTRUCT TEMPORARY VARIABLES THAT CAN BE MANIPULATED FOR PLOTTING
  browse_size_x = [0 0]; browse_size_y = [0 0]; 
  browse_size_z = [0 0]; browse_size_zz = [0 0]; 
  browse_x_var = []; browse_y_var = []; 
  browse_z_var = []; browse_zz_var = [];
  if ~isempty(browse_xargx)
    eval(['browse_x_var = ' browse_xargx ';'])
    browse_size_x = size(browse_x_var);
  end
  if ~isempty(browse_xargy)
    eval(['browse_y_var = ' browse_xargy ';'])
    browse_size_y = size(browse_y_var);
  end
  if ~isempty(browse_xargz)
    eval(['browse_z_var = ' browse_xargz ';'])
    browse_size_z = size(browse_z_var);
  end
  if ~isempty(browse_xargzz)
    eval(['browse_zz_var = ' browse_xargzz ';'])
    browse_size_zz = size(browse_zz_var);
  end
  
  % CHECK FOR EMPTIES
  if ~isempty(browse_xargx) & any(browse_size_x == 0)
    dodsmsg(sprintf('The X argument of R%i_ is empty.  This plot will be skipped.', browse_count))
    %break
  elseif ~isempty(browse_xargy) & any(browse_size_y == 0)
    dodsmsg(sprintf('The Y argument of R%i_ is empty.  This plot will be skipped.', browse_count))
    %break
  elseif ~isempty(browse_xargz) & any(browse_size_z == 0)
    dodsmsg(sprintf('The Z (or U-vector) argument of R%i_ is empty.  This plot will be skipped.', browse_count))
    %break
  elseif ~isempty(browse_xargzz) & any(browse_size_zz == 0)
    dodsmsg(sprintf('The V-vector argument of R%i_ is empty.  This plot will be skipped.', browse_count))
    %break
  else % we can go ahead
    % *****************************************  
    if browse_dispchoices(2) > 2
      % contouring or imaging
      % Flip vector arguments to the correct orientation
      if any(browse_size_x == 1)
	browse_x_var = browse_x_var(:)';
	browse_size_x = size(browse_x_var);
      end
      if any(browse_size_y == 1)
	browse_y_var = browse_y_var(:);
	browse_size_y = size(browse_y_var);
      end
      % *****************************************  
      % if x is matrix and y vector or vice versa,
      % expand vector to matrix
      if all(browse_size_x > 1) & any(browse_size_y == 1) 
	browse_y_var = browse_y_var(:)*ones(1,browse_size_x(2));
	browse_size_y = size(browse_y_var);
      elseif any(browse_size_x == 1) & all(browse_size_y > 1)
	browse_x_var = ones(browse_size_y(1),1)*(browse_x_var(:)');
	browse_size_x = size(browse_x_var);
      end
    end
    
    % check for correct argument sizes based on plot type
    if (browse_dispchoices(2) == 1 | ...
	  browse_dispchoices(2) == 2) % symbol or line plot
      if all(browse_size_x == browse_size_y) | ...
	    (any(browse_size_x == 1) & any(browse_size_y == 1) & ...
	    max(browse_size_x) == max(browse_size_y))
	% ok
      else
	if any(browse_size_x == 1) & any(browse_size_y == 1) & ...
	      max(browse_size_x) ~= max(browse_size_y)
	  browse_x_var = browse_x_var(:)';
	  browse_size_x = size(browse_x_var);
	  browse_y_var = browse_y_var(:);
	  browse_size_y = size(browse_y_var);
	  browse_y_var = browse_y_var(:)*ones(1,browse_size_x(2));
	  browse_x_var = ones(browse_size_y(1),1)*(browse_x_var(:)');
	  browse_size_x = size(browse_x_var); browse_size_y = size(browse_y_var);
	else
	  dodsmsg('Not able to plot these data using the browser.')
	  browse_dispchoices(1) = 0;
	  clear browse_x_var browse_y_var browse_z_var browse_zz_var
	  return
	end
      end
    elseif browse_dispchoices(2) == 3 % contour
      if all(browse_size_z > 2)
	if (browse_size_x(1) == 1 & ...
	      all([browse_size_y(1) browse_size_x(2)] == browse_size_z)) | ...
	      (all(browse_size_x == browse_size_y) & ...
	      all(browse_size_x == browse_size_z))
	  % ok
	else % open new window; don't use x- and y-args
	  browse_dispchoices(3) = 1;
	  browse_size_x = [0 0]; browse_size_y = [0 0];
	  clear browse_x_var browse_y_var
	  browse_xargx = ''; browse_xargy  = ''; 
	  browse_Argx  = ''; browse_Argy = '';
	end
      else % use 'plot' in new window
	% MUST CHANGE VARIABLES SO THAT 'Y' IS PLOT VARIABLE!
	browse_dispchoices(2) = 1; 
	browse_dispchoices(3) = 1; 
	browse_dispchoices(4) = 1; 
	browse_dispchoices(6) = 1;
	browse_dispchoices(11) = 1; 
	browse_dispchoices(12) = 1;
	browse_size_x = [0 0]; clear browse_x_var
	browse_xargx = ''; browse_Argx  = ''; 
	browse_Argy = browse_Argz; browse_xargy  = browse_xargz; 
	browse_size_y = browse_size_z; browse_y_var = browse_z_var;
	browse_Argz = ''; browse_xargz = ''; browse_size_z = [0 0]; 
	clear browse_z_var
      end
    elseif browse_dispchoices(2) == 4 % image
      if all(browse_size_z > 1)
	if browse_size_x(1) == 1 & ...
	      all([browse_size_y(1) browse_size_x(2)] == browse_size_z)
	  % ok
	elseif all(browse_size_x == browse_size_y) & ...
	      all(browse_size_x == browse_size_z)
	  dodsmsg('Not able to use image command; using ''pcolor'' instead.')
	  browse_dispchoices(2) = 5;
	else % open new window; don't use x- and y-args
	  browse_dispchoices(3) = 1;
	  browse_size_x = [0 0]; browse_size_y = [0 0];
	  clear browse_x_var browse_y_var
	  browse_xargx = ''; browse_xargy  = ''; 
	  browse_Argx  = ''; browse_Argy = '';
	end
      else % use 'plot' in new window
	% MUST CHANGE VARIABLES SO THAT 'Y' IS PLOT VARIABLE!
	if browse_version < 5
	  browse_dispchoices(2) = 1; 
	  browse_dispchoices(3) = 1; 
	  browse_dispchoices(4) = 1; 
	  browse_dispchoices(6) = 1;
	  browse_dispchoices(11) = 1; 
	  browse_dispchoices(12) = 1;
	  browse_size_x = [0 0]; browse_size_y = [0 0];
	  clear browse_x_var browse_y_var
	  browse_xargx = ''; browse_Argx  = ''; 
	  browse_Argy = browse_Argz; browse_xargy  = browse_xargz; 
	  browse_size_y = browse_size_z; browse_y_var = browse_z_var;
	  browse_Argz = ''; browse_xargz = ''; browse_size_z = [0 0]; 
	  clear browse_z_var
	else
	  % should be ok
	end
      end
    elseif browse_dispchoices(2) == 5 % pcolor
      if all(browse_size_z > 1)
	if (browse_size_x(1) == 1 & ...
	      all([browse_size_y(1) browse_size_x(2)] == browse_size_z)) | ...
	      (all(browse_size_x == browse_size_y) & ...
	      all(browse_size_x == browse_size_z))
	  % ok
	else % open new window; don't use x- and y-args
	  browse_dispchoices(3) = 1;
	  browse_size_x = [0 0]; browse_size_y = [0 0];
	  clear browse_x_var browse_y_var
	  browse_xargx = ''; browse_xargy  = ''; 
	  browse_Argx  = ''; browse_Argy = '';
	end
      else % use 'plot' in new window
	% MUST CHANGE VARIABLES SO THAT 'Y' IS PLOT VARIABLE!
	browse_dispchoices(2) = 1; 
	browse_dispchoices(3) = 1; 
	browse_dispchoices(4) = 1; 
	browse_dispchoices(6) = 1;
	browse_dispchoices(11) = 1; 
	browse_dispchoices(12) = 1;
	browse_size_x = [0 0]; clear browse_x_var
	browse_xargx = ''; browse_Argx  = ''; 
	browse_Argy = browse_Argz; browse_xargy  = browse_xargz; 
	browse_size_y = browse_size_z; browse_y_var = browse_z_var;
	browse_Argz = ''; browse_xargz = ''; browse_size_z = [0 0]; 
	clear browse_z_var
      end
    elseif browse_dispchoices(2) == 6 % quiver
      if all(browse_size_z == browse_size_zz)
	if ((browse_size_x(1) == 1) & ...
	      all([browse_size_y(1) browse_size_x(2)] == browse_size_z)) | ...
	      (all(browse_size_x == browse_size_y) & ...
	      all(browse_size_x == browse_size_z)) | ...
	      (any(browse_size_z) == 1 & (browse_size_x(2) == ...
	      browse_size_y(1)) & browse_size_x(2) ...
	      == max(browse_size_z))
	  % ok
	else % open new window; don't use x- and y-args
	  browse_dispchoices(3) = 1;
	  browse_size_x = [0 0]; browse_size_y = [0 0];
	  clear browse_x_var browse_y_var
	  browse_xargx = ''; browse_xargy  = ''; 
	  browse_Argx  = ''; browse_Argy = '';
	end
      else % do not plot at all
	dodsmsg('Not able to plot these data using the browser.')
	browse_dispchoices(1) = 0;
	clear browse_x_var browse_y_var browse_z_var browse_zz_var
	return
      end
    end
    
    % 3. SET LONGITUDE VARIABLE CORRECTLY (FOR BROWSE WINDOW ONLY)
    % IF LONGITUDES REARRANGED AND LAT AND DATA ARE MATRICES, 
    % THEY MUST ALSO BE REARRANGED !!!!!
    if ~isempty(browse_Argx) 
      if strcmp(browse_Argx,'Longitude') & browse_dispchoices(3) == 0
	browse_old_size_x = browse_size_x;
	eval(['[browse_x_var, browse_xorder, browse_display_new] = xrange(''xarg'',' ...
	      'browse_georange,' browse_xargx ', browse_dispchoices);'])
	% if the image has to be split into two parts, there will be
	% a NaN in the x-argument.  If so, switch from Image to Pcolor ....
	if browse_dispchoices(2) == 4 & any(isnan(browse_x_var))
	  dodsmsg('Changing ''image'' command to pcolor')
	  browse_dispchoices(2) = 5;
        end
	% added next line 99/05/12 when fixing quiver bug. -- dbyrne
	browse_size_x = size(browse_x_var);
	if ~isempty(browse_display_new)
	  browse_dispchoices = browse_display_new; 
	end
	if all(browse_old_size_x > 1) & any(browse_size_x == 1);
	  % browse_x_var has changed size!
	  browse_x_var = ones(browse_old_size_x(1),1)*(browse_x_var(:)');
	  browse_size_x = size(browse_x_var);
	end
	clear browse_display_new
	% if y is a matrix, y must also be rearranged!
	if ~isempty(browse_xargy) & ~isempty(browse_xorder) & all(browse_size_y > 1)
	  browse_k = find(~isnan(browse_xorder));
	  browse_y_var = browse_y_var(:,browse_xorder(browse_k));
	  browse_k = find(isnan(browse_xorder));
	  for browse_ii = 1:length(browse_k),
	    browse_size_y = size(browse_y_var);
	    browse_y_var = [browse_y_var(:,1:browse_k(browse_ii)-1) ...
		  nan*ones(browse_size_y(1),1) ...
		  browse_y_var(:,browse_k(browse_ii):browse_size_y(2))];
	  end
	  browse_size_y = size(browse_y_var);
	elseif ~isempty(browse_xargy) & ~isempty(browse_xorder) & ...
	      browse_dispchoices(2) < 3
	  browse_k = find(~isnan(browse_xorder));
	  browse_y_var(browse_k) = browse_y_var(browse_xorder(browse_k));
	  browse_k = find(isnan(browse_xorder));
	  browse_y_var(browse_k) = nan;
	end
	% if z is present, we know it is a matrix
	if ~isempty(browse_xargz) & ~isempty(browse_xorder)
	  if max(mminmax(browse_xorder)) > browse_size_z(2)
	    dodsmsg('Size of x argument does not equal size of z!')
	    browse_size_x = [0 0]; browse_size_y = [0 0];
	    browse_dispchoices(3) = 1;
	    clear browse_x_var browse_y_var
	    browse_xargx = ''; browse_xargy  = ''; 
	    browse_Argx  = ''; browse_Argy = '';
	  else
	    browse_k = find(~isnan(browse_xorder));
	    browse_z_var = browse_z_var(:,browse_xorder(browse_k));
	    browse_k = find(isnan(browse_xorder));
	    for browse_ii = 1:length(browse_k),
	      browse_size_z = size(browse_z_var);
	      browse_z_var = [browse_z_var(:,1:browse_k(browse_ii)-1) ...
		    nan*ones(browse_size_z(1),1) ...
		    browse_z_var(:,browse_k(browse_ii):browse_size_z(2))];
	    end
	    browse_size_z = size(browse_z_var);
	  end
	end
	if ~isempty(browse_xargzz) & ~isempty(browse_xorder)
	  if max(mminmax(browse_xorder)) > browse_size_zz(2)
	    dodsmsg('Size of x argument does not equal size of zz!')
	    browse_size_x = [0 0]; browse_size_y = [0 0];
	    browse_dispchoices(3) = 1;
	    clear browse_x_var browse_y_var
	    browse_xargx = ''; browse_xargy  = ''; 
	    browse_Argx  = ''; browse_Argy = '';
	  else
	    browse_k = find(~isnan(browse_xorder));
	    browse_zz_var = browse_zz_var(:,browse_xorder(browse_k));
	    browse_k = find(isnan(browse_xorder));
	    for browse_ii = 1:length(browse_k),
	      browse_size_zz = size(browse_zz_var);
	      browse_zz_var = [browse_zz_var(:,1:browse_k(browse_ii)-1) ...
		    nan*ones(browse_size_zz(1),1) ...
		    browse_zz_var(:,browse_k(browse_ii):browse_size_zz(2))];
	    end
	    browse_size_zz = size(browse_zz_var);
	  end
	end
      end % /* end of is x longitude */
    end
  
    % MISSING -- SHOULD CHECK Y-VARIABLE FOR CONSISTENCY -- 1%  tolerance
    
    % 3.1 FLIP LATITUDE VARIABLE IF NECESSARY FOR 'IMAGE' COMMAND
    if strcmp(browse_Argy,'Latitude') & browse_dispchoices(2) == 4
      if browse_dispchoices(2) == 4
	if all(browse_size_y) > 0
	  if all(browse_size_y) > 1
	    if all(all(diff(browse_y_var) < 0))
	      browse_y_var = flipud(browse_y_var);
	      if all(browse_size_z) > 0
		browse_z_var = flipud(browse_z_var);
	      end
	      if all(browse_size_zz) > 0
		browse_zz_var = flipud(browse_zz_var);
	      end
	    end
	  else
	    if all(diff(browse_y_var) < 0)
	      browse_y_var = flipud(browse_y_var);
	      if all(browse_size_z) > 0
		browse_z_var = flipud(browse_z_var);
	      end
	      if all(browse_size_zz) > 0
		browse_zz_var = flipud(browse_zz_var);
	      end
	    end
	  end
	end
      end
    end
  
    % 4. LAST CHECK: PLOT VIABILITY
    % From here on we should be able to assume that if browse_size_x > 0
    % or browse_size_y > 0, the temporary plotting variable to which it
    % refers is not empty.
  
    % check for x and y arguments' existence
    if browse_dispchoices(3) == 0 & (any(browse_size_x == 0) | any(browse_size_y == 0))
      dodsmsg('Not able to plot on browse window.')
      browse_dispchoices(3) == 1;
    end
  
    %  % Flip vector arguments to the correct orientation
    %
    %  if any(browse_size_x == 1)
    %    browse_x_var = browse_x_var(:)';
    %    browse_size_x = size(browse_x_var);
    %  end
    %  if any(browse_size_y == 1)
    %    browse_y_var = browse_y_var(:);
    %    browse_size_y = size(browse_y_var);
    %  end
  
    % if x is matrix and y vector or vice versa, and we are using 
    % 'image', 'pcolor' or 'quiver', expand vector args to matrix.
    if browse_dispchoices(2) > 2
      if all(browse_size_x > 1) & any(browse_size_y == 1)
	browse_y_var = browse_y_var(:)*ones(1,browse_size_x(2));
      elseif any(browse_size_x == 1) & all(browse_size_y > 1)
	browse_x_var = ones(browse_size_y(1),1)*(browse_x_var(:)');
      end
    end
  
    if ~browse_dispchoices(1) % ABORT!
      return
    end
  
    % 5. CONSTRUCT PLOT STRINGS FOR X, Y, Z
    if ~isempty(browse_Argx)
      browse_xargx = 'browse_x_var';
    end
    if ~isempty(browse_Argy)
      browse_xargy = ', browse_y_var';
    end
    if ~isempty(browse_Argz)
      browse_xargz = 'browse_z_var';
    end
    if ~isempty(browse_Argzz)
      browse_xargzz = 'browse_zz_var';
    end
    
    if browse_dispchoices(2) == 3  % contour
      browse_xargz = [',' browse_xargz];
    elseif browse_dispchoices(2) > 3 & browse_dispchoices(2) < 6 % 
      % we're doing some kind of imaging
      if ~isempty(browse_xargz)
	% THIS IS PRELIMINARY.  WHERE ELSE IS IT NEEDED?
	if ~isempty(browse_range)
	  % The scaling is as follows: the data are linearly scaled
	  % with a scale factor and offset to be in units of color
	  % palette index.  This conversion is based on the data range
	  % given in the archive.m file, or if that is not available,
	  % on the range of the data array itself.
	  %
	  % (size(palette,1)-1)/diff(browse_range(browse_dispchoices(9),:)) 
	  %
	  % is the number of colors per data unit. The data are 
	  % multiplied by this factor, which converts data units to
	  % color palette units.  The offset is: 
	  %
	  % (1-(size(browse_palette,1)-1)* ...
	  % browse_range(browse_dispchoices(9),1)/ ..
	  % diff(browse_range(browse_dispchoices(9),:)))
	  %
	  % The effect of this transformation is to map the data to
	  % colors #2-N of the colormap (where N is the length), and
	  % the null value of the dataset to color #1, as long as that
	  % null value was properly declared in the archive.m file.
	  if all(~isnan(browse_range(browse_dispchoices(9),:)))
	    browse_z_var = (size(browse_palette,1)-1)/...
		diff(browse_range(browse_dispchoices(9),:))* ...
		browse_z_var+(1-(size(browse_palette,1)-1)* ...
		browse_range(browse_dispchoices(9),1)/ ...
		diff(browse_range(browse_dispchoices(9),:)));
	    % workaround for Matlab imaging NaN bug -- D.B. 98/05/09
	    browse_k = find(isnan(browse_z_var));
	    if all(mminmax(browse_z_var) > 0)
	      browse_z_var(browse_k) = zeros(length(browse_k),1);
	    else
	      browse_z_var(browse_k) = ...
		  [min(mminmax(browse_z_var))-1]*ones(length(browse_k),1);
	    end
	  else
	    browse_minmax = mminmax(browse_z_var);
	    browse_z_var = (size(browse_palette,1)-1)/ ...
		diff(browse_minmax)*browse_z_var + ...
		(1-(size(browse_palette,1)-1)* ...
		browse_minmax(1)/diff(browse_minmax));
	    browse_k = find(isnan(browse_z_var));
	    if all(mminmax(browse_z_var) > 0)
	      browse_z_var(browse_k) = zeros(length(browse_k),1);
	    else
	      browse_z_var(browse_k) = [min(mminmax(browse_z_var))-1]*...
		  ones(length(browse_k),1);
	    end
	  end
	else % browse_range is empty (DataRange not defined in archive.m)
	  browse_minmax = mminmax(browse_z_var);
	  browse_z_var = (size(browse_palette,1)-1)/ ...
	      diff(browse_minmax)*browse_z_var + ...
	      (1-(size(browse_palette,1)-1)* ...
	      browse_minmax(1)/diff(browse_minmax));
	  
	  browse_k = find(isnan(browse_z_var));
	  if all(mminmax(browse_z_var) > 0)
	    browse_z_var(browse_k) = zeros(length(browse_k),1);
	  else
	    browse_z_var(browse_k) = [min(mminmax(browse_z_var))-1]*...
		ones(length(browse_k),1);
	  end
	end
	browse_xargz = [',' browse_xargz];
      end
    elseif browse_dispchoices(2) == 6
      if ~isempty(browse_Argz);
	browse_xargz = [',' browse_xargz];
      end
      if ~isempty(browse_Argzz);
	browse_xargzz = [',' browse_xargzz];
      end
    end

    % 6. SET UP THE COMMAND PREFIX
    if browse_dispchoices(3) % True == do not display on browser
      if browse_dispchoices(4) % True == open new windows rather 
	% than using existing ones
	if browse_dispchoices(6) % True == open one window per URL
	  %wham bam! open lots of new windows and dump all URLS
	  browse_prefix = ['figure(''userdata'',''DODS figure'',''Name'',' ...
		'''DODS Display''); browse_h = []; '];
	else
	  % calmly open one new window and dump all URLS in it
	  if browse_j == 1;
	    browse_prefix = ['figure(''userdata'',''DODS figure'',''Name'',' ...
		  '''DODS Display''); browse_h = []; '];
	  else
	    browse_prefix = 'browse_h = []; ';
	  end
	end
      else
	browse_c = get(0,'children'); browse_figure = [];
	for browse_k = 1:length(browse_c)
	  if strcmp(get(browse_c(browse_k),'userdata'),'DODS figure')
	    browse_figure = browse_c(browse_k);
	    break;
	  end
	end
	if isempty(browse_figure);
	  browse_figure = figure('visible','off', ...
	      'userdata','DODS figure', ...
	      'Name','DODS Display');
	end
	% plot in existing non-browse window, if there is one
	browse_prefix = sprintf('figure(%i); browse_h = []; ',browse_figure);
      end
    else 					% we're using browse window
      browse_prefix = sprintf('figure(%i); subplot(%s); browse_h = []; ', ...
	  browse_figure, ...
	  'findobj(gcf,''type'',''axes'', ''userdata'',''GEOPLOT'')' );
    end
    
    % 7. SET UP THE COMMAND STRING 
    if browse_dispchoices(2) < 3 % line or symbol plot
      browse_plotstyle = str2mat('+','o','x','*','.','-');
      browse_colorstyle = str2mat('','y','c','m','r','g', ...
	  'b', 'k','w');
      browse_linetype = [',' '''' ...
	    deblank(browse_colorstyle(browse_dispchoices(11),:)) ...
	    deblank(browse_plotstyle(browse_dispchoices(12),:)) ''''];
      if browse_dispchoices(2) == 1;
	browse_cmd = 'browse_h = plot';
      elseif browse_dispchoices(2) == 2;
	browse_cmd = 'browse_h = plot';
      end
    else
      browse_linetype = '';
      if browse_dispchoices(2) == 3
	browse_cmd = '[browse_c_h, browse_h] = contour';
      elseif browse_dispchoices(2) == 4 % the image command
	if browse_version < 5;
	  browse_aspectstring = sprintf('%s,[%g 1]', ...
	      '''AspectRatio''', ...
	      diff(browse_axes_vals(1:2))/diff(browse_axes_vals(3:4)));
	  if browse_dispchoices(6) == 1
	    browse_cmd = sprintf('set(gca,%s); browse_h = image',  ...
		browse_aspectstring);
	  else
	    browse_cmd = sprintf('set(gca,%s,''nextplot'',''add''); browse_h = image',  ...
		browse_aspectstring);
	  end
	else
	  browse_cmd = 'browse_h = image';
	end
      elseif browse_dispchoices(2) == 5
	browse_cmd = 'browse_h = newpclr';
      elseif browse_dispchoices(2) == 6
	browse_cmd = 'browse_h = quiver';
	if browse_dispchoices(10) > 0
	  browse_colorstyle = str2mat('','y','c','m','r','g', ...
	      'b', 'k','w');
	  browse_linetype = [ ',', '''', ...
		deblank(browse_colorstyle(browse_dispchoices(11),:)), ...
		''''];
	end
      end
    end
    % 8. ATTEMPT TO PLOT 
    if all(browse_size_x > 0) & all(browse_size_y > 0)
      if browse_dispchoices(3) == 0; 	% aiming for browse window
	if browse_dispchoices(2) < 5
	  browse_plotstring = [browse_plotstring ...
		sprintf('%s %s %s(%s%s%s%s); %s', ...
		browse_prefix, 'hold on; colormap(browse_palette); ', ...
		browse_cmd, browse_xargx, browse_xargy, ...
		browse_xargz, browse_linetype, ...
		[ 'if ~isempty(browse_h), set(browse_h,''visible'',''off''); ', ...
		'browse(''newplot'', browse_h); end; '])];
        elseif browse_dispchoices(2) == 5
	  browse_plotstring = [browse_plotstring ...
		sprintf('%s %s %s(%s%s%s); %s', ...
		browse_prefix, 'hold on; colormap(browse_palette); ', ...
		browse_cmd, browse_xargx, browse_xargy, browse_xargz, ...
		[ 'shading flat; if ~isempty(browse_h), ', ...
		    'set(browse_h,''visible'',''off''); ', ...
		  'browse(''newplot'',browse_h); end; '])];
	elseif browse_dispchoices(2) == 6 % quiver plot
	  browse_plotstring = [browse_plotstring ...
		sprintf('%s %s %s(%s%s%s%s%s); %s', ...
		browse_prefix, 'hold on; ', browse_cmd, ...
		browse_xargx, browse_xargy, browse_xargz, ...
		browse_xargzz, browse_linetype, ...
		[ ' if ~isempty(browse_h), ', ...
		  'set(browse_h,''visible'',''off''); ', ...
		'browse(''newplot'',browse_h); end; '])];
        end
      else % not aiming for browse window
	if ~isempty(browse_Argx)
	  browse_Argx = strrep(browse_Argx,'_',' ');
	end
	if ~isempty(browse_Argy)
	  browse_Argy = strrep(browse_Argy,'_',' ');
	end
	if ~isempty(browse_Argz)
	  browse_Argz = strrep(browse_Argz,'_',' ');
	end
	if ~isempty(browse_Argzz)
	  browse_Argzz = strrep(browse_Argzz,'_',' ');
	end
	if browse_dispchoices(2) < 4
	  browse_plotstring = [browse_plotstring ...
		sprintf('%s %s %s(%s%s%s%s); %s', ...
		browse_prefix, 'hold on; colormap(browse_palette); ', ...
		browse_cmd, browse_xargx, browse_xargy, browse_xargz, ...
		browse_linetype, 'xlabel(browse_Argx); ', ...
		'ylabel(browse_Argy); title(browse_Argz); drawnow; ')];
	elseif browse_dispchoices(2) == 4 %image
	  if browse_dispchoices(6) == 1 
	    % we get one new window per dataset. Don't use hold
	    browse_plotstring = [browse_plotstring ...
		  sprintf('%s %s(%s%s%s%s); %s', ...
		  browse_prefix, browse_cmd, browse_xargx, ...
		  browse_xargy, browse_xargz, browse_linetype, ...
		  'colormap(browse_palette); axis(''xy''); xlabel(browse_Argx); ', ...
		  'ylabel(browse_Argy); title(browse_Argz); drawnow; ')];
	  else
	    browse_plotstring = [browse_plotstring ...
		  sprintf('%s %s %s(%s%s%s%s); %s', ...
		  browse_prefix, 'hold on; colormap(browse_palette); ', ...
		  browse_cmd, browse_xargx, browse_xargy, browse_xargz, ...
		  browse_linetype, 'xlabel(browse_Argx); ', ...
		  'ylabel(browse_Argy); title(browse_Argz); drawnow; ')];
	  end
	elseif browse_dispchoices(2) == 5
	  browse_plotstring = [browse_plotstring ...
		sprintf('%s %s %s(%s%s%s); %s', ...
		browse_prefix, 'hold on; colormap(browse_palette); ', ...
		browse_cmd, browse_xargx, browse_xargy, browse_xargz, ...
		'xlabel(browse_Argx); ylabel(browse_Argy); ', ...
		'title(browse_Argz); shading flat; drawnow; ')];
	elseif browse_dispchoices(2) == 6 
	  browse_plotstring = [browse_plotstring ...
		sprintf('%s %s %s(%s%s%s%s%s); %s', ...
		browse_prefix, 'hold on; ', browse_cmd, browse_xargx, ...
		browse_xargy, browse_xargz, ...
		browse_xargzz, browse_linetype, ' xlabel(browse_Argx); ', ...
		'ylabel(browse_Argy); title([browse_Argz '' and '' browse_Argzz]); ', ...
		'drawnow; ')];
	end
      end
    else
      if browse_dispchoices(3) == 0
	browse_string = sprintf('\n%s\n\n', ...
	    'Not able to display on browse window!');
	dodsmsg(browse_string)
      else
	browse_string = sprintf('%s\n%s\n%s\n', ...
	    'Warning!  Your x- and y- plot arguments do not match', ...
	    'the size of the returned array, or your returned data', ...
	    'is not an array.  Plotting point data without x-, y-.');
	dodsmsg(browse_string)
	if browse_dispchoices(2) >= 3  & browse_dispchoices(2) < 6 
	  % reset 'data' as first arg
	  browse_k = min(findstr(browse_xargz,','))+1;
	  if isempty(browse_k), browse_k = 1; end
	  browse_xargx = browse_xargz(browse_k:length(browse_xargz));
	else
	  browse_k = min(findstr(browse_xargy,','))+1;
	  if isempty(browse_k), browse_k = 1; end
	  browse_xargx = browse_xargy(browse_k:length(browse_xargy));
	end
	if browse_dispchoices(2) < 5
	  browse_plotstring = [browse_plotstring ...
		sprintf(' %s %s %s(%s%s); %s',  ...
		browse_prefix, 'hold on; colormap(browse_palette); ', ...
		browse_cmd, browse_xargx, browse_linetype)];
	elseif browse_dispchoices(2) == 5
	  browse_plotstring = [browse_plotstring ...
		sprintf(' %s %s %s(%s%s); %s',  ...
		browse_prefix, 'hold on; colormap(browse_palette); ', ...
		browse_cmd, browse_xargx, browse_linetype, ...
		'shading flat;')];
	elseif browse_dispchoices(2) == 6 
	  browse_k = min(findstr(browse_xargz,','))+1;
	  if isempty(browse_k), browse_k = 1; end
	  browse_xargz = browse_xargz(browse_k:length(browse_xargz));
	  browse_plotstring = [browse_plotstring ...
		sprintf(' %s %s %s(%s%s%s);',  ...
		browse_prefix, 'hold on; ', browse_cmd, ...
		browse_xargz, ...
		browse_xargzz, browse_linetype)];
	end
      end
    end
    if browse_dispchoices(5) == 0 % plot only first URL of many
      if browse_j == 1
	if browse_dispchoices(3) == 0;
	  browse_plotstring = [browse_plotstring ...
		sprintf('set(gca,''clim'', [%g %g]);', ...
		browse_color_limits)];
	end
      end
    else
      if browse_dispchoices(3) == 0
	browse_plotstring = [browse_plotstring ...
	      sprintf('set(gca,''clim'', [%g %g]);',...
	      browse_color_limits)];
      end
    end
  end
  % increment the count
  browse_count = browse_count+1;
  eval(browse_plotstring)
end % this is the end point of the loop through the URLs

if all(browse_dispchoices([1 3]) == [1 0]')
  browse('newboxes'); % this redraws world map and selection
  % ranges; it also makes the first plot in the list visible
end
if browse_dispchoices(3) == 0 % if it is plotted to browse window, 
  % it may need to be added to a stack
  browse('moreon', browse_num_plots)
end
