function [argout1, argout2, argout3, argout4, argout5, argout6, ...
      argout7] = getjgsta(mode, get_ranges, get_dset, get_vars, ...
    get_dset_stride, get_num_urls, get_georange, get_variables, ...
    get_archive, whichurl)

%
% 
% GETstation_f   Part of the DODS browse package.
%
% This function is used to get hydrography type of data with depth, 
% time and location information displayed. 

global urlinfolist times xdims ydims zdims urllist old_vars old_dset ...
       old_ranges old_stride whichvariables totalsizes

if exist(get_archive) == 2
  eval(get_archive)
else
  dodsmsg(['Problem reading dataset metadata ' get_archive '.m'])
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
  argout7 = [];

  if strcmp(mode,'cat') 		

    % --------------------  IN CAT MODE -----------------------------

    % SET UP THE METADATA
    % ***************************************************************
    % Create  constraint expression form browser input values-
    % date, lat/lon, archive type and depth
    % ***************************************************************
  
    %catch any unmatched data range
    if(get_ranges(4,1) > TimeRange(2) | get_ranges(4,2) < TimeRange(1))
      dodsmsg(' Requested time range does not overlap data. Please respecify')
      return
    end
    
    %save these values
    old_ranges = get_ranges;
    old_dset = get_dset;
    old_vars = get_vars;
    old_stride = get_dset_stride;
    totalsizes = [];
  
    %fill up returned arguments with dummy values to prevent crashes
    num_url = 1;  %set default
    loaddodsbool = 1; %set default 
    times = []; depths = []; lats = []; lons = []; 
    url = [];  urlinfolist = [];
    
    if exist('Cat_m_File') == 1 % check if 'Cat_m_File' is a local variable
      if exist(Cat_m_File) == 2 % check if Cat_m_File is a script
        eval(['[url,loaddodsbool,urlinfolist,times,',...
	      'zdims,ydims,xdims,num_url] = ', ...
	      Cat_m_File, ...
	      '(get_archive, get_ranges, mode, get_vars);'])
        argout6 = url;
      else
        dodsmsg(['Unable to find script ' Cat_m_File])
        return
      end
    end
  
    % get the inventory explicitly (loaddodsbool == 1)
    % note that normally there's only one loaddods call for jgofs/ff
    %     servers; if more than one call is necessary, let 'getcat'
    %     function or 'geturl' function to handle it.
    dods_err = 0;
    if loaddodsbool == 1
      if ~isempty(findstr(url, 'nph-jg'))
        % be sure to use '-F' tag cause jgofs returns string vector
        loaddods('-e -F',url);
      else
        % added condition here -- dbyrne 99/10/28
        if ~isempty(url)
	  loaddods('-e', url);
        end
      end
      if dods_err == 1
        dods_err_msg = sprintf('%s\n%s', ...
            '        >>>>>>>> ERROR IN DODS CATALOG ACQUISITION <<<<<<<<', ...
            dods_err_msg);
        dodsmsg(dods_err_msg)
        return
      end
    end

    %%%%%%%%%%%%%%%%%%%%%%%%
    % WHICH VARIABLES ARE SELECTED?
    % NOTE: get_variables is the selectablevariables
    whichvariables = [];
    for i = 1:size(get_variables,1)
      for j = 1:size(SelectableVariables,1)
	if strcmp(deblank(get_variables(i,:)), ...
	      deblank(SelectableVariables(j,:)))
	  whichvariables = [whichvariables j];
	end
      end
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%
    
    if num_url > 0
      eval(['[urllist,urlinfolist]=', URL_m_File, '(get_archive,' ...
            'get_ranges,''get'',whichvariables,urlinfolist);'])
    else
      return
    end
 
    % return x/y/z/time name here
    varnames = urlinfolist(1).var_name;
    LatitudeName = deblank(varnames(1,:));
    LongitudeName = deblank(varnames(2,:));
    DepthName = deblank(varnames(3:7,:));
    TimeName = deblank(varnames(8:17,:));

    % Check for Longitude convention used in the browser, need to
    % convert lon < 0 to lon+360 when master_georange(1) == 0
    if num_url > 0
      TempLongitude = [];   namebool = 0;
      if ~isempty(deblank(LongitudeName)) & exist(deblank(LongitudeName)) == 1
        TempLongitude = eval(LongitudeName);  namebool = 1;
      elseif ~isempty(xdims)
        TempLongitude = xdims;
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
	  if namebool == 1
	    eval([LongitudeName '= TempLongitude; clear TempLongitude'])
	  else
	    xdims = TempLongitude; clear TempLongitude;
	  end
        end
      end % end of if ~isempty(TempLongitude)
    end % end of if num_url > 0

    % FIXED so that if there are routines with names in TimeName, they
    % are not accidentally evaluated -- dbyrne 99/06/01
    %argout1, 2, 3, 4, 5, 6 are x, y, z, t, n, URL, respectively
    if loaddodsbool
      if isempty(times)
        if ~isempty(TimeName)
          if exist(TimeName)==1 
            argout4 = eval(deblank(TimeName));  
          end
        end
      elseif ~isempty(times), 
        argout4 = times; 
      end
      if isempty(zdims)
        if ~isempty(DepthName)
          if exist(DepthName)==1
            argout3 = eval(deblank(DepthName)); 
          end
        end
      elseif ~isempty(zdims), 
        argout3 = zdims; 
      end
      if isempty(ydims)
        if ~isempty(LatitudeName)
          if exist(LatitudeName)==1 
            argout2 = eval(deblank(LatitudeName)); 
          end
        end
      elseif ~isempty(ydims), 
        argout2 = ydims; 
      end
      if isempty(xdims)
        if ~isempty(LongitudeName)
          if exist(LongitudeName)==1
            argout2 = eval(deblank(LongitudeName));  
          end
        end
      elseif ~isempty(xdims), 
        argout1 = xdims; 
      end
    else
      if ~isempty(xdims), argout1 = xdims;  end
      if ~isempty(ydims), argout2 = ydims;  end
      if ~isempty(zdims), argout3 = zdims;  end
      if ~isempty(times),  argout4 = times;  end
    end

    % indicate if there really is any data 
    if any(length(argout1) > 0 | length(argout2) > 0 | ...
	  length(argout3) > 0 | length(argout4) > 0)
      if any(all(~isnan(argout1)) | all(~isnan(argout2)) | all(~isnan(argout3)) | all(~isnan(argout4)))
        % jg server returns a big negative number if any data is null
        argout5 = num_url;
      else
        argout5 = 0;
      end
    else
      argout5 = 0;
    end
    argout7 = urllist;

    return

  elseif strcmp(mode,'datasize')         

    %   -------------------  IN DATASIZE MODE -------------------                   
    % test conditions to see if user request has changed
    % since last catalog request
    getcat = 0;
    if isempty(old_vars) | isempty(old_dset) | isempty(old_ranges)
      getcat = 1;
    else
      if ~all(size(get_vars) == size(old_vars))
        getcat = 1;
      elseif (get_dset ~= old_dset)
        getcat = 1;
      elseif any(any(get_ranges ~= old_ranges))
        getcat = 1;
      elseif any(~isnan([old_stride get_dset_stride])) & ...
	    (old_stride ~= get_dset_stride)
        getcat = 1;
      elseif all(size(get_vars) == size(old_vars))
        if ~all(get_vars == old_vars)
	  getcat = 1;
        end
      end
    end

    % new catalog if needed
    if getcat
      [x,y,z,t,n,URL] = getjgsta_f2('cat', get_ranges, get_dset, get_vars, ...
	  get_dset_stride, get_num_urls, get_georange, get_variables, ...
	  get_archive);
      get_num_urls = n;
    end
    argout2 = get_num_urls;
    % it is only a very rough appoximation
    maxarg = max([length(times),length(xdims),length(ydims),length(zdims)]);
    argout1 = maxarg * (4 + size(get_vars,1)) * 8 / 1e6;
  
    return
	
  elseif strcmp(mode,'get')    
 
    % -------------------- IN GET_DATA MODE ---------------------------
    
    if get_num_urls > 0
        
    % get x/y/z/time name here
    varnames = urlinfolist(1).var_name;
    LatitudeName = deblank(varnames(1,:));
    LongitudeName = deblank(varnames(2,:));
    DepthName = deblank(varnames(3:7,:));
    TimeName = deblank(varnames(8:17,:));


    %%%%%%%%%%%%%%%%%%%%%%%%
    % EVALUATE urllist
    tmpurl = [];   dods_err = 0;
    sizeofurl = 1;  indexofurl = [];
    if isfield(urlinfolist, 'sizeindex_info')
      sizeofurl = urlinfolist(1).sizeindex_info(whichurl);
      indexofurl = [urlinfolist(2).sizeindex_info(whichurl,1), ...
		    urlinfolist(2).sizeindex_info(whichurl,2)];
    end    
    if ~isempty(urllist)
      %%for i = 1:size(urllist,1)
        tmpurl = deblank(urllist(whichurl,:));
        if findstr(tmpurl, 'nph-jg')
          loadstr = ['loaddods(''-F -e'',''',tmpurl,''')'];
        else
          loadstr = ['loaddods(''-e'',''',tmpurl,''')'];
        end
        eval(loadstr);
        if dods_err
          dods_err_msg = sprintf('%s\n%s', ...
	      '           >>>>>>>> ERROR IN DODS DATA ACQUISITION <<<<<<<<', ...
	      dods_err_msg);
          break;
        else
          if whichurl == 1 & isfield(urlinfolist,'infotext')
            % display only during first request
	    if ~isempty(urlinfolist(1).infotext)
	      dodsmsg([urlinfolist(1).infotext]);
            end
          end
        end     
      %%end   
    end
    %%%%%%%%%%%%%%%%%%%%%%%%


    %%%%%%%%%%%%%%%%%%%%%%%%
    % NOW, make up the final variablelist and whichvarlist
    tmpvarlist = [];  tmptmpvarlist = [];  tmpbasic = [];  variablelist = [];
    keep = [];
    tmpbasic = strvcat(TimeName, 'DODS_Decimal_Date', LongitudeName, ...
                       LatitudeName, DepthName);
    for i = 1:size(tmpbasic,1)
      if ~all(isspace(tmpbasic(i,:)))
        keep(i) = 1;
      end
    end
    tmpbasic = tmpbasic(find(keep),:);
    % for all the others .... includeing optional variables
    tmpvarlist = [urlinfolist(2).returned_var];
    keep = findstr(tmpvarlist, ',');  j = 1;
    for i = 1:length(keep)
      tmptmpvarlist = strvcat(tmptmpvarlist, tmpvarlist(j:keep(i)-1));
      j = keep(i) + 1;
    end
    tmpvarlist = strvcat(tmptmpvarlist, tmpvarlist(j:length(tmpvarlist)));
    % combine both tmpbasic and tmpvarlist into variablelist
    variablelist = strvcat(tmpbasic, tmpvarlist);   

    % for whichvariablelist
    %     first, the basic 4s
    tmpwhichbasicvar = [];  tmpwhichvar = [];  tmpwhichopvar = [];  
    whichvarlist = [];
    defaultholder = strvcat('TimeName','LongitudeName','LatitudeName',...
                            'DepthName');
    for i = 1:4
      tmpvnames = eval(deblank(defaultholder(i,:)));
      for j = 1:size(tmpvnames,1)
        if ~isempty(deblank(tmpvnames(j,:)))
          tmpwhichbasicvar = [tmpwhichbasicvar, i];
        end
      end
      % add the Dods_Decimal_Date
      if i == 1,  tmpwhichbasicvar = [tmpwhichbasicvar, i];  end
    end
    %     second, the selected vars
    %         before anything else, treat umbrella variable a special case
    if strcmp(deblank(DodsName),'Umbrella') == 1
      DodsName = UmbrellaDods;
      SelectableVariables = UmbrellaVariables;
    end
    for i = 1:size(tmpvarlist,1)
      for j = 1:size(DodsName,1)
        if strcmp(deblank(tmpvarlist(i,:)), deblank(DodsName(j,:)))
          tmpwhichvar = [tmpwhichvar, j];
        end
      end
    end
    %     third, the optionals
    tag = whichvariables(length(whichvariables));
    tagatsize = length(whichvariables);
    if exist('OptionalVariables') == 1 & ~isnan(OptionalVariables)          
      for i = 1:size(OptionalVariables,1)
	if exist(deblank(OptionalVariables(i,:))) == 1
	  % indicate it has been returned to this workspace in loaddods call
	  tmpwhichopvar = [tmpwhichopvar i];
	end
      end
    end     
    %     final, combine tmpwhichbasicvar and tmpwhichvar into whichvarlist
    whichvarlist = [tmpwhichbasicvar, tmpwhichvar+4, tmpwhichopvar+tagatsize+4];
    %%%%%%%%%%%%%%%%%%%%%%%%


    %%%%%%%%%%%%%%%%%%%%%%%%
    % GEO CONVERSION
    % Check for Longitude convention used in browser, need to convert lon < 0
    % to lon+360 when get_georange(1) == 0
    % Adopted from old version of getrectg, here multiple lonname is allowed. 
    TempLongitude = [];
    if ~isempty(LongitudeName)
      if ~isempty(deblank(LongitudeName(1,:)))
	if exist(deblank(LongitudeName(1,:))) == 1
	  lonsize = 0;
	  lonsize = size(LongitudeName,1);
	  str1 = sprintf('%s%s%s','(TempLongitude >=180).*(TempLongitude-360)+',...
	      '(TempLongitude < -180).*(TempLongitude+360)+', ...
	      '(TempLongitude >= -180 & TempLongitude < 180).*TempLongitude');
	  str2 = sprintf('%s%s%s','(TempLongitude >= 360).*(TempLongitude-360)+', ...
	      '(TempLongitude < 0).*(TempLongitude+360)+', ...
	      '(TempLongitude >= 0 & TempLongitude < 360).*TempLongitude');
	  if lonsize == 1
	    TempLongitude = eval(deblank(LongitudeName));
	    if abs(get_ranges(1,1) - get_ranges(1,2)) < 360
	      if get_georange(1) == 0
		eval(['TempLongitude =', str1, ';'])
	      elseif get_georange(1) == 0
		eval(['TempLongitude =', str2, ';'])
	      end
	    end  
	    eval([LongitudeName '= TempLongitude; clear TempLongitude'])
	  elseif lonsize > 1
	    for i = 1:lonsize
	      TempLongitude = eval(deblank(LongitudeName(i,:)));
	      if abs(get_ranges(1,1) - get_ranges(1,2)) < 360
		if get_georange(1) == -180
		  eval(['TempLongitude =', str1, ';'])
		elseif get_georange(1) == 0
		  eval(['TempLongitude =', str2, ';'])
		end
	      end
	      eval([LongitudeName(i,:) '= TempLongitude; clear TempLongitude;'])
	    end  % end of for loop
	end  % end of if lonsize == 1, elseif lonsize > 1
	end  % end of exist
      end  % end of ~isempty
    end % end of ~isempty(LongitudeName)
    %%%%%%%%%%%%%%%%%%%%%%%%


    %%%%%%%%%%%%%%%%%%%%%%%%
    % Check if the basic 4s are in the return.
    %     If time is not in the workspace, leave as it is since Dods_Decimal_Date
    %          is assigned as default.   If for xdim/ydim/zdim, eval them to 
    %          default values.
    for i = 1:size(defaultholder,1)
      tmpvars = eval(deblank(defaultholder(i,:)));
      if ~isempty(tmpvars)
        % if x/y/z is in the DodsName but somehow is not returned, use the 
        %      name in DodsName
        for j = 1:size(tmpvars,1)
          tmpvar = deblank(tmpvars(j,:));
          if ~isempty(tmpvar)
            if ~isempty(eval(tmpvar)) & ~exist(tmpvar) == 1
              switch i
                case 3
                  eval([tmpvar, '= ' ...
                    'xdims*ones(sizeofurl,1);']);
                case 2
                  eval([tmpvar, '= ' ...
                    'ydims*ones(sizeofurl,1);']);
                case 4
                  eval([tmpvar, '= ' ...
                    'zdims*ones(sizeofurl,1);']);
                case 1
                  eval([tmpvar, '= [];']);
              end
            end
          end
        end
      else
	% if x/y/z is an empty holder, return something in Dods default names
        switch i
          case 3
	    if ~isempty(xdims)
	      DODS_Latitude = xdims(whichurl)*ones(sizeofurl,1);
              % don't forget to add it to the variablelist and whichvarlist
              variablelist = str2mat(variablelist, 'DODS_Latitude');
              whichvarlist = [whichvarlist, 3];
            end
          case 2
	    if ~isempty(ydims)
	      DODS_Longitude = ydims(whichurl)*ones(sizeofurl,1);
              variablelist = str2mat(variablelist, 'DODS_Longitude');
              whichvarlist = [whichvarlist, 2];
            end
          case 4
            % it's a lazy way to incorporate varieties of z variables
            if ~isempty(zdims)
	      DODS_Zdim = zdims(whichurl)*ones(sizeofurl,1);
              variablelist = str2mat(variablelist, 'DODS_Zdim');
              whichvarlist = [whichvarlist, 4];
            end
        end
      end
    end
    %%%%%%%%%%%%%%%%%%%%%%%%
  

    %%%%%%%%%%%%%%%%%%%%%%%%
    % SET UP LIST FOR ALL RETURNED_VARS
    %     now the variablelist is for all returned variables and whichvarlist
    %         is index into variablelist
    % first, for the DODS_Decimal_Date
    %     record sizes of each individual url to split 'times' off 
    %         (could use structure on times in the future)
    totalsizes(whichurl) = sizeofurl;
    DODS_Decimal_Date = [];
    datesize = sum(totalsizes(1:whichurl));
    if whichurl == 1
      DODS_Decimal_Date = times(1:datesize);
    else
      DODS_Decimal_Date = times(sum(totalsizes(1:whichurl-1))+1:datesize);
    end
    for i = 1:size(variablelist,1)
      tmpname = deblank(variablelist(i,:));
      if ~isempty(tmpname)
	if exist(tmpname) == 1
          tmpout = eval(tmpname);
          sizes(i,:) = size(tmpout);
          if ~strcmp(tmpname, 'DODS_Decimal_Date')
            % here, reeval returned vars according to indexofurl  
            %     some precautions have to be done if something 
	    %     wrong with the networks, so that the expected returned
	    %     size is not equal to the real returned size (in other 
	    %     words, size from cat ~= size from get because timeout, etc
	    if size(tmpout,1) == indexofurl(2)         
              tmpout = tmpout(indexofurl(1):indexofurl(2));  
	      sizes(i,:) = size(tmpout);
            else
              % leave tmpout as it is
              % DODS_Decimal_Date has to be re-evaled
              %     assume only the first few data are returned
	      DODS_Decimal_Date = DODS_Decimal_Date(1:sizes(i,1));
            end
	    if exist('DataNull') == 1
	      if ~isnan(DataNull(whichvarlist(i)))
	        j = find(tmpout == DataNull(whichvarlist(i)));
	        tmpout(j) = NaN*j;
	      end
	    end
	    % stack data in a column and scale it if possible
	    if exist('DataScale') == 1
	      % DataScale now contains all the variables that
	      % need to be returned   klee 04/01/99
	      if ~isnan(OptionalVariables) & size(DataScale,1) ~= ...
		    size(DodsName,1)+size(OptionalVariables,1)+4
	        dodsmsg(['Error is in ' get_archive '.m'])
	        argout1 = [argout1; tmpout(:)];
	      elseif isnan(OptionalVariables) & size(DataScale,1) ~= ...
		    size(DodsName,1)+4
	        dodsmsg(['Error is in ' get_archive '.m'])
	        argout1 = [argout1; tmpout(:)];
	      else
	        if ~isnan(DataScale(whichvarlist(i),1))
		  argout1 = [argout1; DataScale(whichvarlist(i),1) + ...
		        tmpout(:)*DataScale(whichvarlist(i),2)];
	        else % scale exists but is a nan -- don't scale
		  argout1 = [argout1; tmpout(:)];
	        end
	      end
	    else % there is no DataScale
	      argout1 = [argout1; tmpout(:)];
	    end
          else  % for DODS_Decimal_Date only
            argout1 = [argout1; tmpout(:)];
          end
	else % the supposedly returned variable DOES NOT EXIST 
	  % in this workspace.  Put in an empty placeholder.
	  if ~isempty(tmpname)
	    eval([tmpname '= [];'])
	  end
	  sizes(i,:) = [0 0];
	end 
      end % end of ~isempty(tmpname)
    end
    %%%%%%%%%%%%%%%%%%%%%%%%

    
    %%%%%%%%%%%%%%%%%%%%%%%%
    % now convert variablelist to user-friendly names
    % here's the joggling for multi time/lat/lon/depth parameters
    % and added DodsName and OptionalVariables
    %     first, for the basic 4s
    names = [];  keep = [];
    defaultnames = str2mat('Time','Longitude','Latitude','Depth');
    tmptimename = eval(defaultholder(1,:));
    for i = 1:size(tmptimename,1)
      if ~all(isspace(tmptimename(i,:)))
        keep(i) = 1;
      end
    end
    tmptimename = tmptimename(find(keep),:);
    if ~isempty(tmptimename)
      if size(tmptimename,1) == 1, names = [defaultnames(1,:)];
      else, names = [upper(tmptimename(1,1)), ...
	      tmptimename(1,2:length(deblank(tmptimename(1,:))))]; 
	for i = 2:size(tmptimename)
	  names = strvcat(names, [upper(tmptimename(i,1)), ...
		tmptimename(i,2:length(deblank(tmptimename(i,:))))]);
	end
      end
    end 
    %     add DODS_Decimal_Date as default
    names = strvcat(names, 'DODS_Decimal_Date');
    %     for x, y and z
    for i = 2:4
      tmph = eval(defaultholder(i,:));
      if ~isempty(tmph)
	if size(tmph,1) == 1, 
	  names = strvcat(names, deblank(defaultnames(i,:)));
        else, for j = 1:size(tmph,1)
                if ~all(isspace(tmph(j,:)))
                  names = str2mat(names, [upper(tmph(j,1)), ...
                      tmph(j,2:length(deblank(tmph(j,:))))]);
                end
              end
	end
      end
    end
    %    second, for the others
    %       remember there're tmpwhichbasicvar, tmpwhichvar, tmpwhichopvar
    %       and all together there's the whichvarlist, and whichvariables
    %       is the selected var from the pull down list only
    if length(tmpwhichvar) > length(whichvariables)
      names = str2mat(names, DodsName(tmpwhichvar,:));
    elseif length(tmpwhichvar) == length(whichvariables)
      names = strvcat(names, SelectableVariables(whichvariables,:));
    end
    if ~isempty(tmpwhichopvar)
      names = strvcat(names, SelectableOptional(tmpwhichopvar,:));
    end
    %    third, for the extra x, y and z
    tmpholder = str2mat('DODS_Longitude','DODS_Latitude','DODS_Zdim');
    for i = 1:3
      if exist(deblank(tmpholder(i,:))) == 1
        names = strvcat(names, deblank(tmpholder(i,:)));
      end
    end
    %%%%%%%%%%%%%%%%%%%%%%%%

    argout2 = sizes;
    argout3 = names;
    argout4 = whichvarlist;
    argout5 = urllist(whichurl,:);
    if dods_err
      argout6 = dods_err;
      argout7 = dods_err_msg;
    else
      argout6 = 0;
    end

    return

    end % /* end of if num_urls > 0 */
  end % /* end of mode check */
end % end of nargin > 1
