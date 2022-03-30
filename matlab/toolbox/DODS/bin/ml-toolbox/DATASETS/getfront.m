function [argout1, argout2, argout3, argout4, argout5, argout6] = getfront(...
          mode, get_ranges, get_dset, get_vars, get_dset_stride, get_num_urls, ...
          get_georange, get_variables, get_archive, whichurl)
%
% 
% GETfronts   Part of the DODS browse package.
%
% This function is used to load edges from the URI 1.2 km SST  
% DataBase.  Requests to the FRONTS require at least a Date and 
% Latitude/Longitude.  
%
%**************************************************************************
%
%

%
% $Log: getfront.m,v $
% Revision 1.2  2000/09/28 04:44:12  kwoklin
% *** empty log message ***
%
% Revision 1.11  2000/06/29 15:53:38  kwoklin
% Add condition checking for null frontal position. klee
%
% Revision 1.10  2000/06/28 15:10:09  kwoklin
% Fix datasize estimation bug.   klee
%
% Revision 1.9  2000/04/11 18:26:33  kwoklin
% Elimilate warning megs.  Make consistent in style.   klee
%
% Revision 1.8  2000/03/15 00:38:01  dbyrne
%
%
% Removed all loaddods('-T') calls, as this option is no longer implemented.
% -- dbyrne 00/03/14
%
% Revision 1.7  1999/07/21 18:59:14  kwoklin
% Update loaddods call.  klee
%
% Revision 1.6  1999/07/21 15:19:31  kwoklin
% Add lat/lon transform to getfront. Specify precision points in getfturl. klee
%
% Revision 1.5  1999/07/20 21:57:49  dbyrne
%
%
% commented out line 372.  -- dbyrne 99/07/20
%
% Revision 1.4  1999/07/06 19:47:17  kwoklin
% Add NaNs to all variables.    klee
%
% Revision 1.2  1999/06/01 00:53:51  dbyrne
%
%
% Many fixes in prep for AGU.  fth, htn, glk and prevu changed to use
% fileservers. -- dbyrne 99/05/31
%
% Revision 1.2  1999/05/28 17:32:51  kwoklin
% Add all globec datasets. Fix depth representation for all globec datasets
% and nbneer dataset. Fix frontal display for htn and glkfront. Make use of
% getjgsta for all jgofs datasets. Point usgsmbay to new server. Point htn,
% glk, fth and prevu to new FF server.                                 klee
%

% $Id: getfront.m,v 1.2 2000/09/28 04:44:12 kwoklin Exp $
%fix segment representation                                 04/28/99
%Adopting multiservers                                      10/09/98
%Set up using URL_m_File                                    10/08/98
%Update to adapt new archive.m and browse.m (v. 2.16)       10/07/98    

% used by DODS browser

%global range_day ranges lyr dset var dset_stride num_urls master_georange
%global archive gui_buttons num_vars num_sets

% used only locally
global old_var old_dset old_ranges times

% explanation:
%
% get_ranges = [WestLon EastLon   -- units: decimal degrees
%           SouthLat NorthLat -- units: decimal degrees
%           MinDepth MaxDepth -- units: meters
%           MinTime  MaxTime]  -- units: decimal years
%
% range_day  = the yearday of [MinTime MaxTime]
%
% lyr  = the length of year of [MinTime MaxTime]
%
% dset = the selected dataset
%
% var = the selected variable
%
% mode may be 'cat' (Catalogue data holdings) or 'get' (Get Data)
%
% if 'get', will have a second arguement, if 0, eval total size of request
% and return. If 1 or greater, get the data.
%

if exist(get_archive) == 2
  eval(get_archive)
else
  dodsmsg(['Problem reading dataset metadata ' get_archive '.m'])
  %disp(['Problem reading dataset metadata ' get_archive '.m'])
  return
end


if nargin >= 1

  % initialize return arguments
  argout1 = [];
  argout2 = [];
  argout3 = [];
  argout4 = [];
  argout5 = [];
  argout6 = [];

  % SET UP THE METADATA
  % ************************************************************************
  % Set-up for accessing the FRONTS DODS server:
  % Create  constraint expression form browser input values-
  % date, lat/lon, archive type and depth
  % ************************************************************************

  if strcmp(mode,'cat') 		% 'cat' return catalogue of time value
    
    %catch any unmatched data range
    if(get_ranges(4,1) > TimeRange(2) | get_ranges(4,2) < TimeRange(1))
      dodsmsg(' Requested time range does not overlap data. Please respecify')
      %disp(' Requested time range does not overlap data. Please respecify')
      return
    end
    
    %save these values
    old_ranges = get_ranges;
    old_dset = get_dset;
    old_var = get_vars;

    %fill up returned arguments with dummy values to prevent crashes
    time = []; inlon = []; ixlon = []; inlat = []; ixlat = [];
    snlon = []; sxlon = []; snlat = []; sxlat = []; dfile = [];
    lon = []; lat = []; segno1 = []; segno2 = [];

    %call the geturl function and return data points and URL
    eval(['[url]=',URL_m_File,'(get_archive, get_ranges, mode);']);
   
    % be sure to use '-F' tag cause jgofs returns string vector
    loaddods('-F',url);
   
    if length(time) > 0 
      argout4 = time;
      times = time;
    end

    % Check for Longitude convention used in the browser, need to convert lon < 0
    % to lon+360 when master_georange(1) == 0
    if argout4 > 1e-10
      TempLongitude = []; 
      if ~isempty(deblank(LongitudeName)) & exist(deblank(LongitudeName)) == 1
        TempLongitude = eval(LongitudeName);  
      end
      if ~isempty(TempLongitude)
        if abs(get_ranges(1,1) - get_ranges(1,2)) >= 360
          % the data were not split into 2 fetch args!
          % don't fiddle with them
        else
          if get_georange(1) == -180
            TempLongitude = (TempLongitude >=180).*(TempLongitude-360)+ ...
		            (TempLongitude < -180).*(TempLongitude+360)+ ...
		            (TempLongitude >= -180 & TempLongitude < 180).*TempLongitude;
          elseif get_georange(1) == 0
            TempLongitude = (TempLongitude >= 360).*(TempLongitude-360)+ ...
		            (TempLongitude < 0).*(TempLongitude+360)+ ...
		            (TempLongitude >= 0 & TempLongitude < 360).*TempLongitude;
          end
          eval([LongitudeName '= TempLongitude; clear TempLongitude'])
        end
      end % end of if ~isempty(TempLongitude)
    end % end of if argout4 > 1e-10

    % specific to fronts server 
    if (argout4 > 0) & (argout4 > 1e-10)
      argout5 = 1;
    else
      argout5 = 0;
    end

    return 				% catalog query ('cat') mode over
  else                                  % get data w/o catalog query
    %****************************************************************************
    %Get Data:  Requires multiaccess to server for multiple variables through loops
    % * FRONTS dataset has only one access to the server * 
    %****************************************************************************


    %Before going to get, check first if the data ranges has changed, second if the 
    %size of the data reqested is larger than the check_level in browse.m

    if isempty(old_var) | isempty(old_dset) | isempty(old_ranges)
      [x,y,z,t,n,URL] = getfront('cat',get_ranges, get_dset, get_vars, ...
          get_dset_stride, get_num_urls, get_georange, get_variables, get_archive); 
      get_num_urls = n;
    end
    if size(get_vars) ~= size(old_var) | (get_dset ~= old_dset) | ...
          any(any(get_ranges ~= old_ranges))
      [x,y,z,t,n,URL] = getfront('cat',get_ranges, get_dset, get_vars, ...
          get_dset_stride, get_num_urls, get_georange, get_variables, get_archive);
      get_num_urls = n;
    end
    
    if get_num_urls > 0
      if strcmp(mode, 'datasize')

        %Eval total size of data requested. If larger than check_level, warning is issued.
        %[datasize, nurls]=getxxx('datasize')
	argout2 = get_num_urls;

        % suppose there're avg of 50 pixels in each segment, 10 segments per image, 
        % each pixel has 7 parameters 
        argout1 = (max(length(times),1) * 500)*7*8/1e6;

        return
	
      else
 
        %The followings are added from getrectg.m.
        %get selected variables and match those to variablelist (DodsName) 
        %and serverlist (Server)
        whichvariables = [];
        for i = 1:size(get_variables,1)
	  for j = 1:size(SelectableVariables,1)
	    if strcmp(deblank(get_variables(i,:)), deblank(SelectableVariables(j,:)))
	      whichvariables = [whichvariables j];
	    end
	  end
        end
        if ~isempty(whichvariables)
	  variablelist = DodsName(whichvariables,:); 
	  serverlist = Server; 
        else
          dodsmsg('Getfront: No variables were selected!')
	  %disp('Getfronts: No variables were selected!')
        end


        % construct and evaluate URL(s)
        VERSION = version; VERSION = str2num(VERSION(1));
        tmpvariablelist = []; tmpserverlist = []; tmpvarlist = []; tmpserlist = [];
        if size(serverlist,1) == 1
          tmpvariablelist = str2mat(TimeName,LongitudeName,LatitudeName, ...
	    DepthName,variablelist);
          % replace the [ abs( ) ~= 32 ] code here      klee 03/17/00
          keep = zeros(size(tmpvariablelist,1),1);
	  for i = 1:size(tmpvariablelist,1)
	    if ~isempty(deblank(tmpvariablelist(i,:)))
	      keep(i) = 1;
	    end
	  end
	  tmpvariablelist = tmpvariablelist(find(keep),:);
	  tmpwhichvariables = [1 2 3 4 whichvariables+4];
          tmpserverlist = str2mat(TimeName,LongitudeName,LatitudeName, ...
	    DepthName, serverlist);
	  % there will be only one URL.  Initialize it.
	  iURL = '';
          % return the URL to be displayed by the browser. D.B. 98/4/5
	  eval([ '[iURL] =', URL_m_File, '(get_archive, get_ranges, mode,', ...
		 'tmpvariablelist, serverlist);'])
	  if ~isempty(iURL)
	    argout5 = iURL;
	    loaddods('-F',iURL);
	  end
        end

        % Check for Longitude convention used in browser, need to convert lon < 0
	% to lon+360 when get_georange(1) == 0

        if exist(dods_dbk(LongitudeName)) == 1
	  TempLongitude = eval(LongitudeName);
	  if abs(get_ranges(1,1) - get_ranges(1,2)) >= 360
	    % the data were not split into 2 fetch args!
	    % don't fiddle with them
	  else
	    if get_georange(1) == -180
	      TempLongitude = (TempLongitude >=180).*(TempLongitude-360)+ ...
		  (TempLongitude < -180).*(TempLongitude+360)+ ...
		  (TempLongitude >= -180 & TempLongitude < 180).*TempLongitude;
	    elseif get_georange(1) == 0
	      TempLongitude = (TempLongitude >= 360).*(TempLongitude-360)+ ...
		  (TempLongitude < 0).*(TempLongitude+360)+ ...
		  (TempLongitude >= 0 & TempLongitude < 360).*TempLongitude;
	    end
	  end
	  eval([LongitudeName '= TempLongitude; clear TempLongitude'])
	end

        % added for frontal position display      klee 12/98
        % fix replacing existing data points by nan values, by inserting ones in between.  klee 03/99, 06/06/99
        tmpvars1 = []; tmpvars2 = []; tmpvars3 = []; tmpvarname = []; tmplist = [];
        if exist(dods_dbk(LongitudeName)) == 1 & exist(dods_dbk(LatitudeName)) == 1
          tmp = eval(dods_dbk(LongitudeName));
          if ~isnan(tmp) | (-tmp) > 1e-10
            TempLon = eval(LongitudeName);
            TempLat = eval(LatitudeName);
            latnpts = length(TempLat);    
            latnpts2 = floor(latnpts/2);  
            coslat2 = cos(TempLat(latnpts2) * pi / 180.0) ^ 2;
            difflat = diff(TempLat);
            difflon = diff(TempLon);
            dist = 111 * sqrt(difflat .* difflat + difflon .* difflon * coslat2);
            diffdist = diff(dist);
%            brkpts = find(abs(diffdist) >= 3) + 1;
            brkpts = find(abs(diffdist) >= 3);
%            nanarray = ones(latnpts,1) * NaN;
%            TempLon(brkpts) = nanarray(brkpts);
%            TempLat(brkpts) = nanarray(brkpts);
            if ~isempty(brkpts)
              k = brkpts(1);   tmpbrkpts = brkpts;   %kvar = brkpts(1); vartmpbrkpts = brkpts;
              leg = length(TempLon);   %legvar = length(TempLon);
              len = length(brkpts);
              tmplist = str2mat(TimeName,variablelist);
              for m = 1:size(tmplist,1)
                tmpvarname = deblank(tmplist(m,:));
                if exist(tmpvarname) == 1
                  eval(['tmpvars', num2str(m), '= eval(tmpvarname);']);
                end
              end
              for i = 1:len
                TempLon = [TempLon(1:k);nan;TempLon(k+1:leg)];
                TempLat = [TempLat(1:k);nan;TempLat(k+1:leg)];
                for n = 1:size(tmplist,1)
                  t = num2str(n);
                  eval(['tmpvars', t, '=[tmpvars',t,'(1:k);nan;tmpvars',t,'(k+1:leg)];'])
                end
                tmpbrkpts = tmpbrkpts + 1;
                if i < len, k = tmpbrkpts(i+1); end
                leg = leg + 1;
              end
              for n = 1:size(tmplist,1)
                t = num2str(n);
                eval([deblank(tmplist(n,:)) '= tmpvars', t, '; clear tmpvars', t,';'])
              end
              eval([LongitudeName '= TempLon; clear TempLon'])
              eval([LatitudeName '= TempLat; clear TempLat'])
            else
              eval([LongitudeName '= TempLon; clear TempLon'])
              eval([LatitudeName '= TempLat; clear TempLat'])
            end
          else
            dodsmsg('No frontal position detected in selected image: returned data will be empty');
          end
        end
 
        % now make up a list of all returned variables
	% (above list plus time, longitude, latitude, depth),
	% evaluate their sizes, scale them and convert nulls to NaNs.
	% this has to be a temporary variable list -- 'variablelist'
	% is still in use
	tmpvariablelist = str2mat(TimeName,LongitudeName,LatitudeName, ...
	    DepthName, variablelist);
	tmpwhichvariables = [1 2 3 4 whichvariables+4];
	for i = 1:size(tmpvariablelist,1)
	  tmpname = dods_dbk(tmpvariablelist(i,:));
          if ~isempty(tmpname)
	  if exist(tmpname) == 1
	    % make a temporary variable to work with
	    tmpout = eval(tmpname);
	    sizes(i,:) = size(tmpout);
	    if exist('DataNull') == 1
	      if ~isnan(DataNull(tmpwhichvariables(i)))
		j = find(tmpout == DataNull(tmpwhichvariables(i)));
		tmpout(j) = NaN*j;
	      else
		% do nothing because null values are already NaNs
	      end
	    end
	    % stack data in a column and scale it if possible
	    if exist('DataScale') == 1
	      if size(DataScale,1) ~= size(SelectableVariables,1)+4
                dodsmsg(['Error is in ' get_archive '.m'])
		argout1 = [argout1; tmpout(:)];
	      else
		if ~isnan(DataScale(tmpwhichvariables(i),1))
		  argout1 = [argout1; DataScale(tmpwhichvariables(i),1) + ...
			tmpout(:)*DataScale(tmpwhichvariables(i),2)];
		else % scale exists but is a nan -- don't scale
		  argout1 = [argout1; tmpout(:)];
		end
	      end
	    else % there is no DataScale
	      argout1 = [argout1; tmpout(:)];
	    end
	  else % the supposedly returned variable DOES NOT EXIST 
	    % in this workspace.  Put in an empty placeholder.
	    if ~isempty(tmpname)
	      eval([tmpname '= [];'])
	    end
	    sizes(i,:) = [0 0];
	  end
          end % end of if ~isempty(tmpname)
	end

	% now convert variablelist to user-friendly names
	names = str2mat('Time','Longitude','Latitude', 'Depth', ...
	    SelectableVariables(whichvariables,:));


        URL = argout5;
        argout2 = sizes;
        argout3 = names;
        argout4 = tmpwhichvariables;
        argout5 = URL;
	
	return
      end % /* end of strcmp(mode, 'datasize') */
    end % /* end of if num_urls > 0 */
  end % /* end of strcmp(mode, 'cat') */
end % /* end of if nargin >= 1 */


