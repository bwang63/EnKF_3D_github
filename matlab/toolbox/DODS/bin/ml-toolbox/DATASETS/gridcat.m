function [locate_x, locate_y, depths, tmp_times, URLinfo, urllist, ...
      url, dods_err, dods_err_msg] = gridcat(Server, ranges, ...
    georange, field1, URLinfo, archive, xystride)

% Note that this should have contingency for > 4 dims, with other dims
% being something we can't display in the browser: use a popup window
% showing dimension name and possible number of selections.
% this will mean that GEOPOS goes away (or becomes greater than 4);
% and axnames and ax must do the same.

% PCC added the following 2/2/02
% Source the .m file with suggested names to search for for map vectors
AxisNames; 

depths = [];
tmp_times  = [];
locate_x = [];
locate_y = [];
urllist = '';
url = '';
start_time = NaN;
timebase = '';
axnames = '';
axunits = [];
mapnames = '';
xmap = [];
ymap = [];
zmap = [];
tmap = [];
dods_err = 0;
dods_err_msg = '';
reversedepth = 0;
isgrid = 0;

% geopos: the positions of those axes displayed on the GUI,
% x-, y-, z-, t-axis.
geopos = zeros(1,4);

% replace %'s with _'s
newfield1 = strrep(field1,'%','_');

if exist(archive) ~= 2
  dodsmsg(['Problem reading dataset metadata ' get_archive '.m'])
  return
else
  eval(archive)
end

if isstruct(URLinfo)
  if ~isempty(strmatch('axnames',fieldnames(URLinfo),'exact'));
    % ok
  else
    URLinfo.axnames = [];
  end
else
  % if it's not a structure, must start from square one.
  % clear it and create a structure for the metadata:
  clear URLinfo
  URLinfo.axnames = [];
  URLinfo.axes = [];
end

% PCC added these comments on 2/4/02
%The following block of code is executed if the das information 
% has not been cached; i.e., if this is the first call to the data
% set made by the browser or if the archive.m has been reloaded in
% the bookmark edit properties.
if isempty(URLinfo.axnames) & isempty(URLinfo.axes)
  % get the DAS.  This needs to be done whether or not we are
  % using the archive file because even with the archive file
  % we don't know the ORDER in which the maps must be used.
  Server = deblank(Server(1,:));
  url = [Server '?' field1];
  [DAS] = loaddods('-A -e', url);
  if dods_err
    str = sprintf('%s%s', ...
	'Error accessing the dataset DAS. Unable to process request', ...
	dods_err_msg);
    dods_err_msg = str;
    return
  end

  % descend to data level

%  structname = ['DAS.' newfield1];  Replaced this line with the following group. 4/22/02 PCC
  struct_string = epstruct(DAS, 'DAS');
  num_elements = size(struct_string,1);
  for ipcc = 1:num_elements
    nn = findstr( struct_string(ipcc,:), newfield1);
    if ~isempty(nn)
      structname = [struct_string(ipcc,1:nn-1) newfield1];
    end
  end

  names = fieldnames(eval(structname));
  % Presence of DODS_ML_Size under a name in DAS means an array not a grid
  while isempty(strmatch('DODS_ML_Size', names,'exact'))  
    structname = [structname '.' newfield1];
    names = fieldnames(eval(structname));
    isgrid = 1;
  end

  if isgrid     % isgrid=1 means that this variable, newfield1, is a grid not an array 
    % one level up from data will have maps
    l = max(findstr(structname, '.'));
    structname = structname(1:l-1);
    names = fieldnames(eval(structname));

    % save only those names that are maps for field1
    start = strmatch(newfield1, names, 'exact')+1;
    sz = size(names,1);
    mapnames = names(start:sz,:);
    axnames = mapnames;
  end

  % manually set the axes order if axes_order exists for arrays (no maps!)
  if exist('axes_order') == 1
%    disp(' ')
%    disp('Array index order being forced by axes_order in archive.m')
%    disp(' ')
    % This is an array, with NO MAPS, or we are using our
    % OWN MAPS for some reason.
    % grid information will be added manually to the URL
    % constraint by addgrid in getrectg.m
    URLinfo.geopos = zeros(1,4);
    geopos = [axes_order zeros(1,4-length(axes_order))];
    URLinfo.geopos = geopos;
  end
    
  % PCC added 2/5/02 An array, but no axes_order, generate one.
  if exist('axes_order') ~= 1 & isgrid ~=1
    % This is an array, with NO MAPS
    % assume array indices are lat, lon
    axes_order = [2 1 0 0];
    URLinfo.geopos = zeros(1,4);
    geopos = [axes_order zeros(1,4-length(axes_order))];
    URLinfo.geopos = geopos;
  end
    
  % axindex will hold the indices for each axis, ax will
  % hold the value, and stride will hold the stride.
  % Next if appears to be the same as if isgrid.
  if ~isempty(axnames)     
    % there are maps in these metadata and we must determine. 
    % their meaning
    ND = size(axnames,1);
  else 
    % no maps were found and the axes order is prescribed
    ND = sum(geopos > 0);
  end
  axunits = cell(ND,1);
  axindex = cell(ND,1);
  ax = cell(ND, 1);
  stride = ones(ND, 1);

  keep = ones(size(mapnames));
  %  Next if appears to be the same as if isgrid.
  if ~isempty(mapnames)
    % find the longitude map
    for i = 1:size(mapnames,1)
      str = lower(mapnames{i});
      % added loop and reversed order of search so that search will
      % find any das name that starts with any of the strings in X_Names
      for ipcc = 1:length(X_Names)
        if any(strmatch(X_Names(ipcc), str)) & isempty(xmap)   % PCC 2/6/02 removed exact
	  xmap = mapnames{i};
	  keep(i) = 0;
        end
      end
    end
    
    mapnames = mapnames(find(keep));
    keep = ones(size(mapnames));
    % find the latitude map
    if ~isempty(mapnames)
      for i = 1:size(mapnames,1)
	str = lower(mapnames{i});
        % added loop and reversed order of search so that search will
        % find any das name that starts with any of the strings in X_Names
        for ipcc = 1:length(Y_Names)
          if any(strmatch(Y_Names(ipcc), str)) & isempty(ymap)   % PCC 2/6/02 removed exact
	    ymap = mapnames{i};
	    keep(i) = 0;
          end
        end
      end
    end
    
    mapnames = mapnames(find(keep));
    keep = ones(size(mapnames));
    % find the depth/elevation map
    if ~isempty(mapnames)
    % First look for special names that suggest atmosphere positive up.
      if (any(findstr(str, 'height')) | ...
	  any(findstr(str, 'vertical')) | ...
	  any(findstr(str, 'altitude')) | ...
	  any(findstr(str, 'elevation'))) & isempty(zmap)
	zmap = mapnames{i};
        keep(i) = 0;
	reversedepth = 1;
      end
      % Now search for depth names
      for i = 1:size(mapnames,1)
	str = lower(mapnames{i});
        % added loop and reversed order of search so that search will
        % find any das name that starts with any of the strings in X_Names
        for ipcc = 1:length(Z_Names)
          if any(strmatch(Z_Names(ipcc), str)) & isempty(zmap)   % PCC 2/6/02 removed exact
	    zmap = mapnames{i};
	    keep(i) = 0;
          end
        end
      end
    end
    
    mapnames = mapnames(find(keep));
    keep = ones(size(mapnames));
    % find the time map
    if ~isempty(mapnames)
      for i = 1:size(mapnames,1)
	str = lower(mapnames{i});
        % added loop and reversed order of search so that search will
        % find any das name that starts with any of the strings in X_Names
        for ipcc = 1:length(T_Names)
          if any(strmatch(T_Names(ipcc), str)) & isempty(tmap)   % PCC 2/6/02 removed exact
	    tmap = mapnames{i};
	    keep(i) = 0;
          end
        end
      end
    end
  end % end of check for non-empty mapnames

  if isgrid  % -----------------------------------------------------
    % now get the axes values themselves from the dataset
    Constraint = '';
    for i = 1:ND
      if ~isempty(Constraint), Constraint = [Constraint, ',']; end
      Constraint = [Constraint field1 '.' axnames{i}];
      eval([axnames{i} ' = [];'])
    end
    if ~isempty(Constraint)
      url = [Server '?' Constraint];
      loaddods('-e', url);
      if ~dods_err
	for i = 1:ND
	  if ~isempty(axnames{i})
	    ax{i} = eval(axnames{i});
	  end
	end
      else
	str = sprintf('%s\n%s', ...
	    'Error acquiring data maps from server:', ...
	    dods_err_msg);
	dods_err_msg = str;
	return
      end
    end

    % Check to see if there is information in the DAS re the direction of
    % the depth axis. Depth needs to be positive going DOWN.
    if exist('struct_string') & (length(geopos) > 2) 
      if ~isempty(geopos(3))
        if geopos(3) > 0
          for i=1:size(struct_string,1)
            if findstr(struct_string(i,:),axnames{geopos(3)})
              if findstr(struct_string(i,:),'positive')
                zdir = eval(struct_string(i,:));
                if findstr(zdir,'up')
                  ax{geopos(3)} = -ax{geopos(3)};
                end
              end
            end
          end
        end
      end
    end

    % PCC added the following section on 2/2/02 for possible later use.
    % Get offset, scale factor and missing value for dependent variable (Assume COARDS).
    field_offset = [];
    field_scale = [];
    field_missing = [];
    eval([ 'f = fieldnames(DAS.' newfield1 ');']);
    k = strmatch('add_offset', lower(f));
    if ~isempty(k)
      eval([ 'field_offset = DAS.' newfield1 '.' char(f(k)) ';']);
    end
    k = strmatch('scale_factor', lower(f));
    if ~isempty(k)
      eval([ 'field_scale = DAS.' newfield1 '.' char(f(k)) ';']);
    end
    k = strmatch('missing_value', lower(f));
    if ~isempty(k)
      eval([ 'field_missing = DAS.' newfield1 '.' char(f(k)) ';']);
    end
    % End block added by PCC 2/2/02
    
    % Get units for the map vectors
    for i = 1:length(axnames)
      eval([ 'f = fieldnames(DAS.' newfield1 '.' axnames{i} ');']);
      k = strmatch('units', lower(f));
      if ~isempty(k)
	eval([ 'axunits{i} = DAS.' newfield1 '.' axnames{i} '.' char(f(k)) ';']);
      end
    end

    % PCC added the following section on 2/2/02 do deal with sign problem in soda
    % Depth is a bit special in that sometimes it is positive down and
    % sometimes positive up. COARDS compliant data sets often specify
    % the direction. Assume that it positive down UNLESS (1) the das
    % has information that says otherwise. I would like to be able to
    % use the order of the two values in the DepthRanges, but they are
    % not available here. I put the code in here in case...
    if exist('DepthRange') == 1
       if DepthRange(1) > DepthRange(2)
          reversedepth = 1;
       end
    end
    % Existence of good info in DAS overrides whats in DepthRange
    if ~isempty(zmap)
      eval([ 'f = fieldnames(DAS.' newfield1 '.' zmap ');']);
      k = strmatch('positive', lower(f));
      if ~isempty(k)
        eval([ 'pos_up_down = DAS.' newfield1 '.' zmap '.' char(f(k)) ';']);
        str_up{1} = 'up';
        str_down{1} = 'down';
        if strmatch(lower(pos_up_down), str_up)
           reversedepth = 1;
        elseif strmatch(lower(pos_up_down), str_down)
           reversedepth = 0;
        end
      end
    end

    % Force gridcat to ignore the axes popup window if axes_order is present. 
    % Otherwise query the user.

    if exist('axes_order')
      geopos = [axes_order zeros(1,4-length(axes_order))];
    else
      output = dodsaxisdlg('start', axnames, axunits, ax, ...
	'Check Axis Mappings', [{xmap}; {ymap}; {zmap}; {tmap}], ...
	zeros(3,3), 0);

      if iscell(output)
        for i = 1:4
	  if i == 1, xmap = output{1};
 	  elseif i == 2, ymap = output{2};
	  elseif i == 3, zmap = output{3};
	  elseif i == 4, tmap = output{4};
	  end
	  if ~isempty(output{i})
	    j = strmatch(output{i}, axnames,'exact');
	    geopos(i) = j;
	  else
	    geopos(i) = 0;
	  end
        end
      else
        % user has cancelled this request
        dods_err = 1;
        dods_err_msg = 'Request cancelled';
        return
      end
    
      % find positions of the axes displayed on the GUI so they
      % can get special treatment.
      if ~isempty(xmap)
        geopos(1) = strmatch(xmap,axnames,'exact');
      end
      if ~isempty(ymap)
        geopos(2) = strmatch(ymap,axnames,'exact');
      end
      if ~isempty(zmap)
        geopos(3) = strmatch(zmap,axnames,'exact');
      end
      if ~isempty(tmap)
        geopos(4) = strmatch(tmap,axnames,'exact');
      end
      geopos   % Output geopos so know how to force axes_order
               % in the archive.m file.
    end
  end  % -----------------------------------------------------

else % we already have cached information about the DAS.  Use it.
  axnames = URLinfo.axnames;
  ax = URLinfo.axes;
  geopos = URLinfo.geopos;
  if ~isempty(URLinfo.axnames)
    % there are maps in these metadata and we must determine
    % their meaning
    ND = size(axnames,1);
    isgrid = 1;
  else 
    % no maps were found and the axes order is prescribed
    ND = sum(geopos > 0);
  end
  stride = ones(ND, 1);
  axindex = cell(ND,1);
  if isgrid
    axunits = URLinfo.axunits;
    timebase = URLinfo.timebase;
    start_time = URLinfo.start_time;
    if geopos(1) > 0, xmap = axnames{geopos(1)}; end
    if geopos(2) > 0, ymap = axnames{geopos(2)}; end
    if geopos(3) > 0, zmap = axnames{geopos(3)}; end
    if geopos(4) > 0, tmap = axnames{geopos(4)}; end
  
    % make up the url for the benefit of displaying to the user
    % it is not going to be dereferenced because we have cached
    % the DAS.
    Server = deblank(Server(1,:));
    Constraint = '';
    for i = 1:ND
      if ~isempty(Constraint), Constraint = [Constraint, ',']; end
      Constraint = [Constraint field1 '.' axnames{i}];
    end
    if ~isempty(Constraint)
      url = [Server '?' Constraint];
    end
  end
  
end

% now we've collected and arranged all the info we need

% CREATE A TIME AXIS

if exist('Ntime') == 1
  % PCC added the following 2/4/02  BEGIN
  % We can tell the GUI that this data set is just one field that is good
  % for all time by specifying Ntime=1 and a TimeRange pair that is not
  % equal to one another, e.g., TimeRange = [1800 2002].

  if Ntime == 1 & diff(TimeRange) ~= 0
    tmp_times = [];
    if geopos(4) ~= 0   % There is a time map vector with the data set!
      if length(ax{geopos(4)}) == 1;  % If more than one element then problem otherwise OK
        axindex{geopos(4)} = [1 1];
      end
    else
      axindex{geopos(4)} = [];
    end
  else             % make time map vector.
    tmp_times = mapvector(TimeRange,1,TimeRange,Ntime);
    ax{geopos(4)} = tmp_times;
    i = find(tmp_times >= ranges(4,1) & tmp_times <= ranges(4,2));
    axindex{geopos(4)} = mminmax(i);
    tmp_times = tmp_times(i);
  end
  % End PCC additions changes here 2/4/02

else
  if isgrid
    tmp_times = [];
    if ~isempty(tmap)
      timestring = '';
      if isempty(URLinfo.axnames)
	timestring = axunits{geopos(4)};
	timestring = lower(timestring);
	if ~isempty(instr('second', timestring))
	  timebase = 'seconds';
	elseif ~isempty(instr('minute',timestring))
	  timebase = 'minutes';
	elseif ~isempty(instr('hour',timestring))
	  timebase = 'hours';
	elseif ~isempty(instr('day',timestring))
	  timebase = 'days';
	elseif ~isempty(instr('month',timestring))
	  timebase = 'months';
	elseif ~isempty(instr('year',timestring))
	  timebase = 'years';
	end
      end
      
       if isempty(timebase) & isempty(URLinfo.axnames) & ~exist('Ntime')  % PCC 2/8/02
	% determine the timebase manually if it is not saved
	% or automagically obvious.
	eval([ 'c = struct2cell(DAS.' newfield1 '.' tmap ');']);
	eval([ 'f = fieldnames(DAS.' newfield1 '.' tmap ');']);
	for i = 1:length(c)
	  if isnumeric(c{i})
	    c{i} = num2str(c{i}(:)');
	  end
	end
	
	m = cell(length(c),1);
	[m{:}] = deal(': ');
	cc = cellstr([strvcat(f{:}), strvcat(m{:}), strvcat(c{:})]);
	str2 = '';
	for j = 1:length(cc)
	  str = cc{j};
	  while ~isempty(findstr(str,'  '))
	    str = strrep(str,'  ',' ');
	  end
	  str2 = [str2, sprintf('%s\n', str)];
	end
	str = sprintf('%s\n', ...
	    'The GUI is not able to automatically determine', ...
	    'the timebase (units) for this dataset.  Please examine', ...
	    'the information below and specify the dataset', ...
	    'time units as one of:', ...
	    ' ', ...
	    '           years months hours days minutes seconds', ...
	    '');
	str = sprintf('%s', str, str2);
	prompt = '';
	tbase = dodsdlg(str, ...
	    'DODS Browse: Specify Timebase', 1, {prompt}, zeros(3,3));
	if ~isempty(tbase)
	  tbase = char(tbase);
	  if strcmp(tbase,'seconds')
	    timebase = 'seconds';
	  elseif strcmp(tbase,'minutes')
	    timebase = 'minutes';
	  elseif strcmp(tbase,'hours')
	    timebase = 'hours';
	  elseif strcmp(tbase,'days')
	    timebase = 'days';
	  elseif strcmp(tbase,'months')
	    timebase = 'months';
	  elseif strcmp(tbase,'years')
	    timebase = 'years';
	  end
	end
      end
      
      % if the timebase is STILL empty, we're f****.
      if isempty(timebase) & isempty(URLinfo.axnames)
	tmap = [];
	geopos(4) = 0;
	timestring = '';
      end
      
      if ~isempty(timestring)
	yr = 0; mon = 0; day = 0; hr = 0; mm = 0; sec = 0;
	inx = instr('since',timestring);
	if isempty(inx)
	  eval([ 'c = struct2cell(DAS.' newfield1 '.' tmap ');']);
	  eval([ 'f = fieldnames(DAS.' newfield1 '.' tmap ');']);
	  for j = 1:length(c)
	    if isnumeric(c{j})
	      c{j} = num2str(c{j}(:)');
	    end
	  end
	  
	  m = cell(length(c),1);
	  [m{:}] = deal(': ');
	  cc = cellstr([strvcat(f{:}), strvcat(m{:}), strvcat(c{:})]);
	  str2 = '';
	  
	  for j = 1:length(cc)
	    str = cc{j};
	    while ~isempty(findstr(str,'  '))
	      str = strrep(str,'  ',' ');
	    end
	    str2 = [str2, sprintf('%s\n', str)];
	  end
	  
	  strtemp = lower(str2);
          if isempty(findstr(strtemp,'climatolog'))  % Does climatolog appear anywhere in this part of the metadata.
            str = sprintf('%s\n', ...
	      'The GUI is not able to automatically determine', ...
	      'the start time for this dataset.  Please examine', ...
	      'the information below and specify the dataset', ...
	      'start time as: YYYY/MM/DD hh:mm:ss.  If the', ...
	      'dataset is a climatology, use 0000/00/00 00:00:00', ...
	      'to indicate this.', ...
	      '');
	    str = sprintf('%s', str, str2);
	    prompt = '0000/00/00 00:00:00';      
	    timestring = dodsdlg(str, ...
	      'DODS Browse: Specify Start Time', 1, {prompt}, zeros(3,3));
	  else  
            timestring =  '0000/00/00 00:00:00'
          end
          timestring = char(timestring);
	  inx = -5; 
	end
      
	if length(timestring) > (inx+6)
	  timestring = timestring(inx+6:length(timestring));
	  p = findstr(timestring,':');
	  if ~isempty(p)
	    p = p(length(p)-1)-2;
	    hr = sscanf(timestring(p:p+1),'%i');
	    mm = sscanf(timestring(p+3:p+4),'%i');
	    sec = sscanf(timestring(p+6:p+7),'%i');
	    timestring = timestring(1:p-2);
	  end
	  p = instr('-', timestring);
	  if isempty(p) | length(p) < 2
	    p = instr('/', timestring);
	  end
	  if ~isempty(p) & length(p) == 2
	    yr = sscanf(timestring(1:p(1)-1),'%i');
	    mon = sscanf(timestring(p(1)+1:p(2)-1), '%i');
	    day = sscanf(timestring(p(2)+1:length(timestring)),'%i');
	  end
	  
	  if day == 0 & yr ~= 0
	    day = 1;
	  end
	  if mon == 0 & yr ~= 0
	    day = 1;
	  end
	  % convert time axis times to decimal days
	  start_time = [yr mon day hr mm sec];
	  tmp_t = ax{geopos(4)};
	  tmp_t = tmp_t(:);
	  s = [ones(length(tmp_t),1)*start_time];
	  switch timebase
	    case 'seconds'
	      col = 6;
	    case 'minutes'
	      col = 5;
	    case 'hours'
	      col = 4;
	    case 'days'
	      col = 3;
	    case 'months'
	      col = 2;
	    case 'years'
	      col = 1;
	  end
	  z = zeros(1,6); z(col) = 1;
	  tmp_t = s + tmp_t*z;
	  if start_time(1) == 0         % Must be a climatology since it is year 0
            if tmp_t(:,3:size(tmp_t,2)) == 0
              tmp_t(:,3) = 1;
            end
	    baseday = datenum([1900 1 1 0 0 0]);
	    tmp_t = [tmp_t(:,1)+1900 tmp_t(:,2:6)];
	    tmp_t = datenum(tmp_t);
	    tmp_t = tmp_t-baseday+1;
	    tmp_t = day2year(tmp_t,1900);
	    tmp_t = tmp_t-1900;
	  else
            % PCC changed the following line 2/15/02  
%	    baseday = datenum(start_time);
	    baseday = datenum(start_time(1),1,1); 
	    tmp_t = datenum(tmp_t);
	    tmp_t = tmp_t-baseday+1;
	    tmp_t = day2year(tmp_t,start_time(1));
	  end
	  tmp_t = tmp_t(:);
	  ax{geopos(4)} = tmp_t;
	else
	  % the user didn't specify a timebase or hit cancel
	  dods_err = 1;
	  dods_err_msg = 'Request Cancelled';
	  return
	end
      end

      if ~isempty(ax{geopos(4)})
        if isnan(start_time) | isempty(timebase)
	  tmap = [];
          geopos(4) = 0;
          timestring = '';
        else
	  tmp_t = ax{geopos(4)};
%	  if start_time(1) == 0 & ~strcmp(timebase,'years')
          % This is a climatology if: year < 10AD, time axis less than a year long and timebase not a year
          minmax_time = mminmax(ax{geopos(4)});
          if (diff(minmax_time) <= 1.001) & (minmax_time(2) < 10) & ~strcmp(timebase,'years')
	    % do two things: simulate times on user's axis
	    YEAR = floor(ranges(4,1));
            % Some climatologies are for year 1AD rather than year 0 so remove base year PCC 2/9/02
            tbyr = floor(tmp_t(1));
            tmp_t = tmp_t - tbyr;
	    while YEAR < ranges(4,2)
	      tmp_times = [tmp_times(:); YEAR+tmp_t(:)];
	      YEAR = YEAR+1;
	    end
	    i = find(tmp_times >= ranges(4,1) & tmp_times <= ranges(4,2));
	    % and also reduce user's timerange to year 0 and 
	    % get valid indices
	    if ~isempty(i)     % skip if no times in the range selected. Added by PCC 2/8/02
              if diff(ranges(4,:)) > 1
	        %if user has selected more than 1 year, give them whole year
	        axindex{geopos(4)} = [1 length(tmp_t)];
	      else
	        j = rem(i,length(tmp_t));
                j(find(j==0)) = length(tmp_t);
	        if floor(ranges(4,1)) ~= floor(ranges(4,2))
	          k = find(abs(diff(j)) > 1);
	          if ~isempty(k)
		    i1 = [j(1) j(k)];
		    i2 = [j(k+1) j(length(j))];
  	          else
	  	    i1 = [j(1) j(length(j))]; i2 = [];
                  end
	          axindex{geopos(4)} = [i1; i2];
	        else
	          axindex{geopos(4)} = [mminmax(j)];
	        end
              end
            end
	  else
	    tmp_times = tmp_t;
	    i = find(tmp_times >= ranges(4,1) & tmp_times <= ranges(4,2));
	    axindex{geopos(4)} = mminmax(i);
	  end

          % If the time range is empty let the user know that one is needed. Added by PCC 2/8/02
          if isempty(axindex{geopos(4)})
            str = ['  Warning: No time value in the time range that' ...
	           ' you selected. Check that the range you selected' ...
                   ' on the time axis is long enough before you' ... 
                   ' actually make a data request.'];
	    dodsmsg(1,str)
          end
	  tmp_times = tmp_times(i);
        end
      end
    else % if we get here, the dataset is a grid but contains
      % no time axis index that we can determine.  Fake it.
      % Give the user 1 point per year.
      YEAR = floor(ranges(4,1));
      i = 1;
      tmp_times = YEAR+0.5;
      while YEAR < ranges(4,2)
	i = i+1;
	YEAR = YEAR+1;
	tmp_times(i) = YEAR+0.5;
      end
      i = find(tmp_times >= ranges(4,1) & tmp_times <= ranges(4,2));
      tmp_times = tmp_times(i);
    end
  end
end
tmp_times = tmp_times(:);

% CREATE A DEPTH AXIS

% PCC changed calculation of constraint for Ndepth case on 2/5/02.

if geopos(3) ~= 0

  if ~(isgrid & isempty(xmap))  % Skip if grid but cannot match map with know maps

    if exist('Ndepth') == 1
      disp('Using simulated axis values (depth) to constrain URL')
      depths = mapvector(sort(DepthRange), 1, DepthRange, Ndepth);
    else
      depths = ax{geopos(3)};
    end

    if reversedepth, depths = -depths; ax{geopos(3)} = depths; end
    i = find(depths >= ranges(3,1) & depths <= ranges(3,2));
    axindex{geopos(3)} = mminmax(i);
    depths = depths(i);

    % If the depth range is empty let the user know that one is needed. Added by PCC 2/8/02
    if isempty(axindex{geopos(3)})
      str = ['  Warning: No depth value in the depth range that' ...
	     ' you selected. Check that the range you selected' ...
             ' on the depth axis is long enough before you' ... 
             ' actually make a data request.'];
      dodsmsg(1,str)
    end
  end

end
% END CHANGES HERE
depths = depths(:);

% CREATE A LONGITUDE AXIS
% if we've got info from the archive.m file, use it!

% PCC changed calculation of constraint for Nlon case on 2/1/02.

if geopos(1) ~= 0

  if ~(isgrid & isempty(xmap))  % Skip if grid but cannot match map with know maps

    if exist('Nlon') == 1
      disp('Using simulated axis values (Lon) to constrain URL')
      locate_x = mapvector(sort(LonRange),1,LonRange,Nlon);
    else
      locate_x = ax{geopos(1)};
    end

    [start_lon, end_lon] = splitrequest(mminmax(locate_x), ...
       ranges(1,:));

    if length(start_lon) > 1
      i1 = mminmax(find(locate_x >= start_lon(1) & ...
          locate_x <= end_lon(1)));
      i2 = mminmax(find(locate_x >= start_lon(2) & locate_x <= ...
          end_lon(2)));
      axindex{geopos(1)} = [i1; i2];
    else
      axindex{geopos(1)} = mminmax(find(locate_x >= start_lon(1) & ...
          locate_x <= end_lon(1)));
    end

    % If the longitude range is empty let the user know that one is needed. Added by PCC 2/8/02
    if isempty(axindex{geopos(1)})
      str = ['  Warning: No longitude value in the longitude range' ...
	     ' that you selected. Check that the range you selected' ...
             ' on the longitude  axis is long enough before you' ...
             ' actually make a data request.'];
      dodsmsg(1,str)
    end

    [locate_x, xorder] = xrange('xarg', georange, locate_x);
    i = find(locate_x >= ranges(1,1) & locate_x <= ranges(1,2));
    locate_x = locate_x(i);

  end

end
% END CHANGES HERE
locate_x = locate_x(:);

% CREATE A LATITUDE AXIS

% PCC changed calculation of constraint for Nlat case on 2/1/02. 

if geopos(2) ~= 0

  if ~(isgrid & isempty(xmap))  % Skip if grid but cannot match map with know maps
    if exist('Nlat') == 1
      disp('Using simulated axis values (Lat) to constrain URL')
      locate_y = mapvector(sort(LatRange),1,LatRange,Nlat);
    else
      locate_y = ax{geopos(2)};
    end
    i = find(locate_y >= ranges(2,1) & locate_y <= ranges(2,2));
    locate_y = locate_y(i);
    axindex{geopos(2)} = mminmax(i);

    % If the latitude range is empty let the user know that one is needed. Added by PCC 2/8/02
    if isempty(axindex{geopos(2)})
      str = ['  Warning: No latitude value in the latitude range' ...
	     ' that you selected. Check that the range you selected' ...
             ' on the latitude axis is long enough before you' ...
             ' actually make a data request.'];
      dodsmsg(1,str)
    end
  end

end
% END CHANGES HERE
locate_y = locate_y(:)';

% grid up the locations at actual resolution.
% I think this is the more elegant of the two choices.
%if ~isempty(locate_x) & ~isempty(locate_y)
%  [locate_y, locate_x] = meshgrid(locate_y, locate_x);
%end

% or, make a square
y = locate_y;
x = locate_x;
locate_y = [min(y) mminmax(y) max(y) min(y)];
locate_x = [mminmax(x) max(x) min(x) min(x)];

% change from 1:N -type indices to 0:N-1.
for i = 1:ND
  if ~isempty(axindex{i})
    for j = 1:size(axindex{i},1);
      axindex{i}(j,:) = axindex{i}(j,:) - 1;
    end
  end
end
% save the positions of the x- and y- axes so that later on,
% the 'stride' can be applied to them and them alone.

if isempty(URLinfo.axnames)
  URLinfo.axnames = axnames;
  URLinfo.axes = ax;
  URLinfo.geopos = geopos;
  URLinfo.axunits = axunits;
  URLinfo.timebase = timebase;
  URLinfo.start_time = start_time;
  % if there is not catalog server to have provided info yet,
  % fill in a blank field as a placeholder
  if ~isfield(URLinfo,'info')
    URLinfo.info = [];
  end
end
URLinfo.axindex = axindex;
URLinfo.stride = stride;

warn = 0;
for i = 1:ND
  if isempty(axindex{i}) & ~any(geopos) == i
    warn = 1;
  end
end

if warn
  str = sprintf('%s\n', ...
      'Warning: some axes are not able to be automatically constrained', ...
      'by the GUI.  You will be prompted to constrain them if/when an', ...
      'actual data download is requested.'); 
  dodsmsg(str)
end
return
